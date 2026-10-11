---
name: idea-hunter
description: KHUSUS proyek Cerita Cerdik (folder cerita-cerdik/) - BUKAN untuk proyek horror Jangan Tonton Sendirian (pakai jts-idea-hunter). Mencari, menyaring, dan mengecek ide episode baru Cerita Cerdik (Ki Udin) supaya tidak mengulang 57+ episode yang ada dan sesuai pola tema yang terbukti menang di data performa. Mengambil mekanik dari cerita akal-akalan dunia & nusantara (Nasreddin, Birbal, Tenali Raman, Ikkyu-san, Abu Nawas, Kancil) lalu melokalkannya ke desa Jawa. Gunakan skill ini SETIAP KALI pengguna minta ide konten/episode Cerita Cerdik atau Ki Udin, roadmap season baru, "stok ide habis", "ide kurang relate", menilai apakah sebuah ide bagus, atau sebelum menulis brief episode baru - walaupun pengguna hanya bilang "kasih ide dong" atau "episode selanjutnya apa".
---

# Idea Hunter (Cerita Cerdik)

Masalah yang diselesaikan: stok ide habis (file ide terakhir hanya sampai S4), roadmap pernah mengusulkan ulang episode lama (bebek panggang, bayangan pohon), dan tema yang dipilih belakangan sering jatuh di reach < 8k. Skill ini menjaga agar setiap ide (1) belum pernah dipakai, (2) berbentuk seperti episode-episode yang menang, (3) logikanya utuh sebelum masuk produksi.

## 1. Alur Kerja

1. **Lihat apa yang sudah ada**: `python .agents/skills/idea-hunter/scripts/cek_repetisi.py --list` + baca kolom `fb_reach` di `cerita-cerdik/episode_tracker.csv` untuk mengingat mana yang menang/gagal.
2. **Ambil bahan** dari `references/sumber_cerita.md` (motif belum terpakai + cara lokalisasi). Boleh mencari motif lain, tapi ambil *mekaniknya*, bukan tokohnya.
3. **Lokalkan**: latar desa/keraton Jawa, benda sehari-hari Indonesia, Ki Udin sebagai pemecah masalah, antagonis dari roster karakter (`cerita-cerdik/CHARACTER_BIBLE.md` + folder `character/`).
4. **Saring** dengan 4 kriteria di §2.
5. **Cek repetisi** tiap kandidat: jalankan `cek_repetisi.py` dengan 2-3 kata kunci *mekanik* (bukan judul), termasuk sinonim (mis. `jahit batu`, lalu `benang batu`). Skrip mencari di isi brief, hasil, prompt, dan file ide - karena mekanik bisa muncul sebagai *balasan* Ki Udin di episode lain, bukan hanya sebagai judul. Kecocokan dihitung per file (semua kata ada di mana saja dalam file), jadi file hasil yang panjang bisa memberi positif palsu - selalu baca cuplikannya sebelum menyimpulkan "sudah dipakai".
6. **Cek kelengkapan logika** (§3) untuk ide berjenis teka-teki/hitungan.
7. **Sajikan 5 alternatif** dengan format §4 (aturan `.agents/AGENTS.md` bagian Aturan Wajib: 5 alternatif + hook 3 detik).
8. Bila kandidat yang lolos < 5, **katakan terus terang** stok ide menipis (juga aturan AGENTS.md) - lebih baik 3 ide kuat daripada 5 ide dipaksakan.

## 2. Saringan (hipotesis dari data, bukan hukum)

Dasar: data FB 7 Agu – 1 Okt 2026 (lihat skill `meta-analytics-ingest` untuk definisi metrik). Perbandingan paling bersih (format sama, jam 19:00, minggu sama): minyak oplosan 7k vs tali abu jerami 49k vs semangka 46k (15–17 Sep); timbangan beras curang 11k vs kelapa muda 45k (1–3 Sep); masker abu vulkanik 5k vs telur matang-mentah 47k (5–8 Sep).

| # | Kriteria | Lolos jika | Contoh menang | Contoh gagal |
|---|---|---|---|---|
| 1 | **Tantangan mustahil yang terbayang dalam 1 kalimat** | Orang langsung bereaksi "hah, mana bisa?" | jahit batu cadas (79k), beli bayangan pohon (47k) | tentukan pangkal batang kayu (2k) |
| 2 | **Benda konkret sehari-hari** | Bendanya bisa difoto & dikenal ibu-ibu desa | tutut, nangka, kelapa, bebek, semangka | asap, koin dalam air panas |
| 3 | **Antagonis kalah oleh syaratnya sendiri** (Uno reverse) | Kemenangan datang dari membalik permintaan, bukan dari kuliah | pendopo: "angkat dulu ke pundak saya" | penjelasan kerapatan serat kayu |
| 4 | **Solusi paham tanpa penjelasan** | Penonton mengerti dalam 1 adegan visual | kelapa tanpa sentuh tanah | tiga pintu (2k), 9 koin |

Risiko tinggi menurut data (bukan larangan - jadwal rotasi di AGENTS.md masih meminta sebagian tema ini; beri label risiko dan bentuk ulang agar lolos kriteria 1-4):
- Isu sosial/kecurangan terkini (oplosan, koruptor, penimbun) - di Indonesia ini berita harian, tidak mengejutkan.
- Misteri/mitos (Eps 47–50: reach 4–7k) - bisa diselamatkan bila misterinya dipecahkan dengan tantangan fisik yang absurd, bukan investigasi.
- Penjelasan sains & teka-teki matematika.

Saringan ini dihitung ulang setiap Monthly Macro-Audit. Jika data baru membantahnya, perbarui tabel ini dan sebut tanggal datanya.

## 3. Cek Kelengkapan Logika (wajib untuk teka-teki)

Tulis semua cabang kemungkinan dan pastikan naskah menjawab setiap cabang. Contoh kegagalan nyata: naskah Eps 57 (9 koin, 2 kali timbang) hanya membahas kasus kelompok A = B; kasus A ≠ B (koin palsu ada di kelompok yang lebih ringan) tidak ada, padahal episode ini dirancang untuk memancing debat - penonton pasti menemukan celahnya. Jika satu cabang tidak bisa dijelaskan dalam 1 kalimat narasi, ide gagal kriteria 4.

## 4. Format Output

```markdown
## Ide [n]: [Judul pendek, maks 7 kata]
- **Sumber mekanik**: [tradisi + motif] → **lokalisasi**: [benda & latar Indonesia]
- **Antagonis**: [nama dari roster]  | **Taruhan**: [apa yang dipertaruhkan]
- **Tantangan (1 kalimat)**: ...
- **Balasan Ki Udin (Uno reverse)**: ...
- **Punchline slapstick**: [penghinaan visual antagonis]
- **Hook 3 detik**: Visual: ... | Teks overlay (≤6 kata): ... | SFX: ...
- **Saringan**: K1 ✔/✘ · K2 ✔/✘ · K3 ✔/✘ · K4 ✔/✘ — [alasan singkat bila ✘]
- **Cek repetisi**: kata kunci `...` → [tidak ada / mirip Eps X karena ...]
- **Risiko**: [rendah/sedang/tinggi + alasan]
```

Tutup dengan rekomendasi 1 ide terkuat dan alasannya, plus catatan bila ada ide yang sengaja dibuat untuk jadwal rotasi tema berisiko tinggi.
