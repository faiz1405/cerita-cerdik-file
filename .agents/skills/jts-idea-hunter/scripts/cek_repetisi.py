"""Cek apakah sebuah premis (atau mekanik/kejanggalannya) sudah pernah dipakai di Jangan Tonton Sendirian.

Usage:
    python cek_repetisi.py --list                       # daftar semua episode (eps, slug, judul)
    python cek_repetisi.py rice cooker debu             # cari kata kunci di brief, prompt, dan bank premis

Pencarian mencakup isi naskah, bukan hanya judul - karena kejanggalan bisa muncul sebagai petunjuk
di tengah episode lain, bukan hanya sebagai hook. bank-ide.md sengaja TIDAK dicari: isinya stok
kejanggalan yang belum dipakai, jadi kecocokan di sana bukan tanda repetisi.
"""
import csv
import re
import sys
from pathlib import Path

JTS = Path(__file__).resolve().parents[4] / 'jangan-tonton-sendirian'
SOURCES = ['briefs/**/*.txt', 'prompts_flow/**/*.txt', '.agents/reference/bank-premis.md']


def list_episodes():
    tracker = JTS / 'episode_tracker.csv'
    if not tracker.exists():
        print('Tracker belum ada. Jalankan jangan-tonton-sendirian/tools/build_tracker.ps1.')
        return
    with open(tracker, encoding='utf-8-sig', newline='') as f:
        rows = list(csv.DictReader(f))
    if not rows:
        print('Belum ada episode.')
    for row in rows:
        print(f'{row["eps"]:>3}  {row["slug"]:45}  {row["judul"]}')


def search(keywords):
    # Awal kata harus cocok ('abu' tidak cocok dengan 'kabut'), akhiran boleh ('rambutnya').
    pats = [re.compile(r'\b' + re.escape(k), re.I) for k in keywords]
    results = []
    for pattern in SOURCES:
        for path in JTS.glob(pattern):
            lines = path.read_text(encoding='utf-8', errors='ignore').splitlines()
            matched = {k for k, p in zip(keywords, pats) if any(p.search(l) for l in lines)}
            if not matched:
                continue
            # Baris dengan kata kunci terbanyak sebagai cuplikan konteks.
            best = max(lines, key=lambda l: sum(bool(p.search(l)) for p in pats))
            results.append((len(matched), path.relative_to(JTS), sorted(matched), best.strip()[:160]))
    results.sort(key=lambda r: (-r[0], str(r[1])))
    if not results:
        print('Tidak ada kecocokan. Tetap cek sinonim / benda pengganti (mis. "guling" vs "bantal panjang").')
        return
    full = [r for r in results if r[0] == len(keywords)]
    if full:
        shown = full
        print(f'{len(full)} file memuat SEMUA kata kunci ({len(results) - len(full)} file cocok sebagian, tidak ditampilkan):')
    else:
        shown = results[:10]
        print(f'Tidak ada file yang memuat semua kata kunci. {len(shown)} cocokan sebagian teratas:')
    for hits, path, matched, snippet in shown:
        print(f'[{hits}/{len(keywords)}] {path}  {matched}\n      > {snippet}')


if __name__ == '__main__':
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    args = sys.argv[1:]
    if not args:
        sys.exit(__doc__)
    if args == ['--list']:
        list_episodes()
    else:
        search(args)
