"""Masukkan ekspor CSV video Meta Business Suite (Facebook Page) ke episode_tracker.csv.

Usage:
    python ingest_meta.py <ekspor_meta.csv> [--tracker PATH] [--map "MM/DD/YYYY HH:MM=EPS" ...] [--write]

Tanpa --write skrip hanya menampilkan pemetaan + metrik (dry-run).
Hanya kolom manual tracker yang ditulis, jadi aman dipakai bersama build_tracker.ps1.
"""
import argparse
import csv
import re
import sys
from datetime import datetime
from pathlib import Path

DEFAULT_TRACKER = Path(__file__).resolve().parents[4] / 'cerita-cerdik' / 'episode_tracker.csv'
HARI = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu']
DUD_REACH = 50  # upload gagal / duplikat yang tidak didistribusikan
DEMO_PREFIX = 'Tayangan video 3 detik berdasarkan pemirsa teratas ('

COL = {
    'title': 'Judul',
    'dur': 'Durasi (detik)',
    'published': 'Waktu penerbitan',
    'reach': 'Jangkauan',
    'v3': 'Tayangan video 3 detik',
    'v1m': 'Tayangan video 1 menit',
    'sec': 'Detik dilihat',
    'avg': 'Detik dilihat rata-rata',
    'comments': 'Komentar',
    'shares': 'Frekuensi dibagikan',
    'sec_rec': 'Detik dilihat dari Rekomendasi',
    'page': 'Nama halaman',
}

# Nama Page Facebook yang sah per proyek (= nama folder tempat tracker berada), untuk mencegah
# ekspor satu Page tertulis ke tracker proyek lain. Isi nama Page Jangan Tonton Sendirian persis
# seperti kolom "Nama halaman" di ekspor Meta setelah dikonfirmasi pengguna.
PAGE_NAMES = {
    'cerita-cerdik': {'Cerita Cerdik'},
    'jangan-tonton-sendirian': set(),
}


def num(value):
    value = (value or '').strip()
    return float(value) if value else 0.0


def norm(text):
    return re.sub(r'[^a-z0-9 ]', '', re.sub(r'\(.*?\)', '', (text or '').lower())).strip()


def read_meta(path):
    with open(path, encoding='utf-8-sig', newline='') as f:
        reader = csv.DictReader(f)
        missing = [c for c in COL.values() if c not in reader.fieldnames]
        if missing:
            sys.exit(f'Kolom tidak ditemukan di ekspor Meta: {missing}')
        demo_cols = [c for c in reader.fieldnames if c.startswith(DEMO_PREFIX)]
        rows = []
        for raw in reader:
            r = {k: raw[v] for k, v in COL.items()}
            r['published'] = datetime.strptime(r['published'].strip(), '%m/%d/%Y %H:%M')
            for k in ('dur', 'reach', 'v3', 'v1m', 'sec', 'avg', 'comments', 'shares', 'sec_rec'):
                r[k] = num(r[k])
            demo = {c[len(DEMO_PREFIX):-1]: num(raw[c]) for c in demo_cols}  # 'F, 25-34' -> nilai
            total = sum(demo.values())
            r['f2534_pct'] = demo.get('F, 25-34', 0) / total * 100 if total else 0
            r['female_pct'] = sum(v for k, v in demo.items() if k.startswith('F')) / total * 100 if total else 0
            rows.append(r)
    return sorted(rows, key=lambda r: r['published'])


def check_page(meta, tracker_path):
    """Hentikan skrip bila Page di ekspor bukan milik proyek pemilik tracker."""
    project = Path(tracker_path).resolve().parent.name
    if project not in PAGE_NAMES:
        return  # tracker di luar folder proyek (mis. salinan untuk uji)
    pages = {r['page'].strip() for r in meta if r['page'].strip()}
    expected = PAGE_NAMES[project]
    if expected:
        wrong = pages - expected
    else:
        # Nama Page proyek ini belum dikonfirmasi: minimal tolak Page milik proyek lain.
        wrong = pages & {p for other, names in PAGE_NAMES.items() if other != project for p in names}
    if wrong:
        sys.exit(f'Ekspor berisi Page {sorted(wrong)}, padahal tracker ini milik proyek "{project}". '
                 f'Pastikan --tracker menunjuk ke tracker proyek yang benar.')


def read_tracker(path):
    raw = Path(path).read_bytes()
    newline = '\r\n' if b'\r\n' in raw else '\n'
    with open(path, encoding='utf-8-sig', newline='') as f:
        reader = csv.DictReader(f)
        return reader.fieldnames, list(reader), newline


def map_rows(meta, tracker, overrides):
    """Kembalikan list (meta_row, eps|None, alasan)."""
    by_eps = {int(t['eps']): t for t in tracker}
    by_date = {t['tanggal_posting']: int(t['eps']) for t in tracker if t['tanggal_posting']}
    taken, result, ambiguous = set(), [], []

    for r in meta:
        key = r['published'].strftime('%Y-%m-%d %H:%M')
        if r['reach'] < DUD_REACH:
            result.append([r, None, f'DUD (reach {int(r["reach"])}) - upload gagal/duplikat, dilewati'])
            continue
        if key in overrides:
            result.append([r, overrides[key], 'override --map'])
            continue
        if key in by_date:
            result.append([r, by_date[key], 'tanggal_posting sudah tercatat'])
            continue
        if r['title']:
            hits = [e for e, t in by_eps.items() if t['judul'] and norm(r['title']) and
                    (norm(r['title']) in norm(t['judul']) or norm(t['judul']) in norm(r['title']))]
            if len(hits) == 1:
                result.append([r, hits[0], 'judul cocok'])
                continue
        # Durasi Meta biasanya = durasi file + 1 detik; coba +1 dulu, baru +0 / +2.
        cands = []
        for delta in (1, 0, 2):
            cands = [e for e, t in by_eps.items()
                     if t['durasi_asli_detik'] and int(float(t['durasi_asli_detik'])) + delta == int(r['dur'])
                     and not t['tanggal_posting']]
            if cands:
                break
        if len(cands) == 1:
            result.append([r, cands[0], 'durasi unik'])
        elif cands:
            entry = [r, tuple(sorted(cands)), 'AMBIGU durasi']
            result.append(entry)
            ambiguous.append(entry)
        else:
            result.append([r, None, 'TIDAK TERPETAKAN - pakai --map'])

    taken = {e for _, e, _ in result if isinstance(e, int)}
    # Kelompok ambigu dengan kandidat yang sama: pasangkan urut tanggal <-> urut nomor eps.
    groups = {}
    for entry in ambiguous:
        groups.setdefault(entry[1], []).append(entry)
    for cands, entries in groups.items():
        free = [e for e in cands if e not in taken]
        # Kandidat berjauhan (mis. eps 15 vs 36) hampir pasti benar bila dipasangkan urut tanggal;
        # kandidat berdekatan (mis. 48 vs 49) bisa tertukar, jadi tetap ditandai.
        close = max(cands) - min(cands) <= 5
        for entry, eps in zip(entries, free):
            entry[1] = eps
            entry[2] = (f'AMBIGU dari {list(cands)} - dipasangkan urut tanggal, cek manual' if close
                        else f'durasi kembar {list(cands)}, dipecahkan urut tanggal')
            taken.add(eps)
        for entry in entries[len(free):]:
            entry[1] = None
            entry[2] = f'AMBIGU dari {list(cands)} - kandidat habis, pakai --map'

    # Satu eps dipetakan ke >1 video (re-upload): ambil reach terbesar.
    seen = {}
    for entry in result:
        eps = entry[1]
        if not isinstance(eps, int):
            continue
        if eps in seen:
            other = seen[eps]
            loser = entry if entry[0]['reach'] < other[0]['reach'] else other
            loser[2] = f'KONFLIK dengan video lain untuk eps {eps} - reach lebih kecil, dilewati'
            loser[1] = None
            seen[eps] = other if loser is entry else entry
        else:
            seen[eps] = entry
    return result


def metrics(r):
    return {
        'tanggal_posting': r['published'].strftime('%Y-%m-%d %H:%M'),
        'hari': HARI[r['published'].weekday()],
        'fb_reach': str(int(r['reach'])),
        'fb_views': str(int(r['v3'])),
        'thumbstop_pct': f'{r["v3"] / r["reach"] * 100:.1f}' if r['reach'] else '',
        'avg_watch_detik': f'{r["avg"]:.1f}',
        'hold_1min_pct': f'{r["v1m"] / r["v3"] * 100:.1f}' if r['v3'] else '',
        'rekomendasi_pct': f'{r["sec_rec"] / r["sec"] * 100:.1f}' if r['sec'] else '',
        'female_25_34_pct': f'{r["f2534_pct"]:.1f}',
        # Hanya tertulis bila tracker punya kolomnya (Jangan Tonton Sendirian); tracker lain mengabaikannya.
        'female_total_pct': f'{r["female_pct"]:.1f}',
        'share': str(int(r['shares'])),
        'komen': str(int(r['comments'])),
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('meta_csv')
    ap.add_argument('--tracker', default=str(DEFAULT_TRACKER))
    ap.add_argument('--map', action='append', default=[], help='"MM/DD/YYYY HH:MM=EPS" (waktu penerbitan Meta)')
    ap.add_argument('--write', action='store_true')
    args = ap.parse_args()

    overrides = {}
    for item in args.map:
        when, eps = item.rsplit('=', 1)
        overrides[datetime.strptime(when.strip(), '%m/%d/%Y %H:%M').strftime('%Y-%m-%d %H:%M')] = int(eps)

    meta = read_meta(args.meta_csv)
    check_page(meta, args.tracker)
    fields, tracker, newline = read_tracker(args.tracker)
    mapped = map_rows(meta, tracker, overrides)
    newest = max(r['published'] for r in meta)

    print(f'{"terbit":16} {"dur":>4} {"eps":>4} {"reach":>7} {"thumb":>6} {"avg":>5} {"hold":>5} {"rec":>5} {"umur":>4}  alasan')
    for r, eps, why in mapped:
        m = metrics(r)
        age = (newest - r['published']).days
        print(f'{m["tanggal_posting"]:16} {int(r["dur"]):>4} {str(eps or "-"):>4} {m["fb_reach"]:>7} '
              f'{m["thumbstop_pct"]:>6} {m["avg_watch_detik"]:>5} {m["hold_1min_pct"]:>5} {m["rekomendasi_pct"]:>5} '
              f'{age:>4}  {why}{"  [UMUR<7 HARI]" if age < 7 else ""}')

    if not args.write:
        print('\nDry-run. Tambahkan --write untuk menyimpan ke tracker.')
        unmatched = [r for r, eps, _ in mapped if eps is None and r['reach'] >= DUD_REACH]
        if unmatched:
            print(f'{len(unmatched)} video belum terpetakan - tentukan dengan --map "MM/DD/YYYY HH:MM=EPS".')
        return

    by_eps = {int(t['eps']): t for t in tracker}
    written = 0
    for r, eps, why in mapped:
        if not isinstance(eps, int) or eps not in by_eps:
            continue
        by_eps[eps].update(metrics(r))
        if why.startswith('AMBIGU'):
            note = '[ingest] mapping ambigu, cek manual'
            if note not in by_eps[eps]['catatan']:
                by_eps[eps]['catatan'] = (by_eps[eps]['catatan'] + ' | ' if by_eps[eps]['catatan'] else '') + note
        written += 1
    with open(args.tracker, 'w', encoding='utf-8-sig', newline='') as f:
        w = csv.DictWriter(f, fieldnames=fields, quoting=csv.QUOTE_ALL, lineterminator=newline,
                           extrasaction='ignore')
        w.writeheader()
        w.writerows(tracker)
    print(f'\n{written} episode diperbarui di {args.tracker}')


if __name__ == '__main__':
    main()
