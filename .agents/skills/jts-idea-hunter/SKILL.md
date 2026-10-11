---
name: jts-idea-hunter
description: KHUSUS proyek horror Jangan Tonton Sendirian (folder jangan-tonton-sendirian/) - BUKAN untuk Cerita Cerdik/Ki Udin (pakai idea-hunter). Mencari, menyaring, dan mengecek premis creepypasta rumah tangga yang diceritakan narator tetap seorang ibu muda, memakai bank kejanggalan dan bank premis proyek, supaya tidak mengulang episode yang ada, aman diproduksi dengan AI bergaya semi-realistis, dan lolos batas etika. Gunakan SETIAP KALI pengguna minta ide/premis/episode horror Jangan Tonton Sendirian, minta "eps selanjutnya" saat bekerja di folder jangan-tonton-sendirian, menilai apakah premis horror bagus, merencanakan season horror, atau sebelum menulis brief horror baru.
---

# JTS Idea Hunter (Jangan Tonton Sendirian)

Masalah yang diselesaikan: halaman horror ini baru mulai, stok kejanggalan di bank terbatas (±9 motif unik berkeandalan tinggi), dan narator tetap membuat setiap premis harus masuk akal terjadi pada satu orang yang sama. Skill ini menjaga agar setiap premis (1) belum pernah dipakai, (2) dekat dengan keseharian ibu muda, (3) twist-nya terbaca tanpa penjelasan, dan (4) aman diproduksi serta etis.

## 1. Alur Kerja

1. **Lihat apa yang sudah ada**:
   - `python .agents/skills/jts-idea-hunter/scripts/cek_repetisi.py --list`
   - Baca `jangan-tonton-sendirian/episode_tracker.csv` (kolom `tipe`, `fb_reach`, `female_total_pct`) untuk melihat tipe mana yang sudah dicoba dan hasilnya.
2. **Ambil bahan** dari:
   - `jangan-tonton-sendirian/.agents/reference/bank-ide.md` (bank kejanggalan, untuk hook & petunjuk),
   - `jangan-tonton-sendirian/.agents/reference/bank-premis.md` (sumber trope, riwayat terpakai/ditolak),
   - `jangan-tonton-sendirian/CHARACTER_BIBLE.md` (narator, fase hidup, tokoh pendukung). Jika masih berstatus USULAN, beri tahu pengguna sebelum menulis brief.
3. **Rakit premis**: `[kejanggalan dari bank] + [fase hidup narator & alasan ia sendirian] + [trope] + [twist satu gambar]`.
4. **Saring** dengan 4 kriteria di §2.
5. **Cek repetisi** tiap kandidat: jalankan `cek_repetisi.py` dengan 2-3 kata kunci *mekanik* (bukan judul), termasuk sinonim. Skrip mencari di brief, prompt, dan `bank-premis.md`; selalu baca cuplikannya sebelum menyimpulkan "sudah dipakai".
6. **Cek kontinuitas narator tetap**: premis tidak boleh bertentangan dengan episode sebelumnya (mis. suami tidak tiba-tiba punya pekerjaan lain, bayi tidak muncul di fase sebelum lahir).
7. **Cek logika twist** (§3).
8. **Sajikan 5 alternatif** dengan format §4, lalu **berhenti dan tunggu pengguna memilih**.
9. Bila kandidat yang lolos < 5, katakan terus terang stok menipis.

## 2. Saringan (hipotesis - halaman ini belum punya data; tinjau ulang setelah ±10 episode)

| # | Kriteria | Lolos jika |
|---|---|---|
| H1 | **Keanehan terbayang dalam 1 kalimat dan terlihat dalam 1 gambar** | Penonton langsung bertanya "kok bisa?" di 3 detik pertama, dan keanehannya sudah diucapkan di narasi Shot 1 |
| H2 | **Dekat dengan rutinitas ibu muda** | Terjadi di dapur, jemuran, kamar mandi, kamar bayi, rumah mertua, kontrakan, belanja, atau urusan ART/tetangga |
| H3 | **Twist terbaca lewat satu gambar + satu kalimat** | Tidak butuh penjelasan ala detektif (pelajaran Cerita Cerdik: episode investigasi Eps 47-50 hanya 4-7 ribu reach, bukti lemah karena beda halaman) |
| H4 | **Aman diproduksi & etis** | AI bisa menggambarnya tanpa teks/hitungan/angka/jam dan tanpa bergantung pada detail wajah; entitas tanpa wajah jelas; lolos AGENTS proyek §5.4 (fiksi, kekerasan tersirat, bayi selamat, keluarga inti bukan pelaku, benda ibadah dihormati) |

Risiko tinggi (bukan larangan, beri label risiko): kasus nyata yang mirip berita kriminal, pamali yang belum pasti dikenal nasional, premis yang bergantung pada layar HP/teks, dan bayi sebagai pusat ancaman (maksimal 1 dari 4 episode).

## 3. Cek Logika Twist (wajib)

Jawab setiap pertanyaan berikut dalam satu kalimat narasi. Kalau ada yang tidak bisa dijawab, premis gagal H3.
1. Kenapa narator tidak langsung lari, menyalakan lampu, atau menelepon suami?
2. Kenapa orang lain di rumah (suami, mertua, tetangga) tidak menyadarinya?
3. Apakah twist bisa dipahami dari satu gambar tanpa penjelasan tambahan?
4. Apakah twist bertentangan dengan fakta narator di episode lain?
5. **Khusus Tipe B/Kriminal**: apakah setiap kejadian yang tampak "mustahil" di awal (pintu terkunci, benda muncul sendiri, orang lain tahu hal pribadi) punya penjelasan manusia yang bisa disimpulkan penonton: siapa, bagaimana masuk, dan kenapa meninggalkan jejak? Contoh Eps 01: sandal tertinggal di kasur karena pelakunya masih di dalam rumah saat narator pulang, lalu kabur tanpa sempat mengambilnya.

## 4. Format Output

```markdown
## Ide [n]: [Judul pendek, maks 7 kata]
- **Tipe**: A/Supranatural, B/Kriminal, atau C/Aturan | **Fase hidup narator**: [kos / rumah mertua / kontrakan / perumahan]
- **Kejanggalan hook (dari bank)**: [baris bank-ide.md atau kejanggalan baru]
- **Premis (1 kalimat)**: ...
- **Alasan narator sendirian**: ...
- **Eskalasi (3 langkah)**: 1) ... 2) ... 3) ...
- **Twist (1 kalimat + 1 gambar)**: ...
- **Hook 3 detik**: Visual: ... | Teks overlay (≤6 kata): ... | SFX: ...
- **Saringan**: H1 ✔/✘ · H2 ✔/✘ · H3 ✔/✘ · H4 ✔/✘ - [alasan singkat bila ✘]
- **Cek repetisi**: kata kunci `...` → [tidak ada / mirip Eps X karena ...]
- **Risiko**: [rendah/sedang/tinggi + alasan]
```

Tutup dengan rekomendasi 1 premis terkuat beserta alasannya, dan catatan rotasi tipe A/B/C (selama baseline ±10 episode pertama, ketiga tipe harus kebagian).
