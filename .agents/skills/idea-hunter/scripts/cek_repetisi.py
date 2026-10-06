"""Cek apakah sebuah ide (atau mekanik tantangannya) sudah pernah dipakai di Cerita Cerdik.

Usage:
    python cek_repetisi.py --list                       # daftar semua episode (eps, slug, judul)
    python cek_repetisi.py abu jerami tali              # cari kata kunci di semua brief, hasil, prompt, dan ide

Pencarian mencakup isi naskah, bukan hanya judul - karena mekanik bisa muncul sebagai
"balasan" Ki Udin di episode lain (contoh: tali abu jerami adalah balasan di Eps 18 sebelum jadi Eps 42).
"""
import csv
import re
import sys
from pathlib import Path

CC = Path(__file__).resolve().parents[4] / 'cerita-cerdik'
SOURCES = ['briefs/**/*.txt', 'prompts_flow/**/*.txt', 'ideas/*.txt']


def list_episodes():
    with open(CC / 'episode_tracker.csv', encoding='utf-8-sig', newline='') as f:
        for row in csv.DictReader(f):
            print(f'{row["eps"]:>3}  {row["slug"]:45}  {row["judul"]}')


def search(keywords):
    # Awal kata harus cocok ('abu' tidak cocok dengan 'kabut'), akhiran boleh ('jeraminya').
    pats = [re.compile(r'\b' + re.escape(k), re.I) for k in keywords]
    results = []
    for pattern in SOURCES:
        for path in CC.glob(pattern):
            lines = path.read_text(encoding='utf-8', errors='ignore').splitlines()
            matched = {k for k, p in zip(keywords, pats) if any(p.search(l) for l in lines)}
            if not matched:
                continue
            # Baris dengan kata kunci terbanyak sebagai cuplikan konteks.
            best = max(lines, key=lambda l: sum(bool(p.search(l)) for p in pats))
            results.append((len(matched), path.relative_to(CC), sorted(matched), best.strip()[:160]))
    results.sort(key=lambda r: (-r[0], str(r[1])))
    if not results:
        print('Tidak ada kecocokan. Tetap cek sinonim / benda pengganti (mis. "gunting" vs "potong").')
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
