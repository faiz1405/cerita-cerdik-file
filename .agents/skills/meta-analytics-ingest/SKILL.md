---
name: meta-analytics-ingest
description: Memasukkan ekspor CSV video Meta Business Suite (Facebook Page Cerita Cerdik) ke cerita-cerdik/episode_tracker.csv, memetakan tiap video ke nomor episode, lalu membuat audit performa berbasis data (thumb-stop, avg watch, hold 1 menit, rekomendasi, demografi) lengkap dengan perbandingan kohort dan desain eksperimen. Gunakan skill ini SETIAP KALI pengguna menempelkan/mengirim file CSV Meta (nama file seperti "Sep-05-2026_Oct-02-2026_....csv", kolom "Jangkauan", "Tayangan video 3 detik"), meminta weekly/monthly audit, bertanya "kenapa reach turun", "episode mana yang menang", "isi tracker", "evaluasi tes jam posting/durasi", atau ingin menilai hasil eksperimen konten - walaupun tidak menyebut kata "ingest".
---

# Meta Analytics Ingest (Data Loop Cerita Cerdik)

Tujuan skill ini: menutup data loop. Sebelum skill ini ada, kolom metrik tracker kosong semua dan angka performa hanya hidup di prosa dokumen, sehingga keputusan konten (durasi, tema, jam posting) dibuat tanpa bukti yang bisa dicek ulang. Setiap ekspor Meta harus berakhir sebagai angka di tracker + kesimpulan yang jujur soal batas datanya.

## 1. Alur Kerja

1. **Simpan ekspor** pengguna ke disk (jika ditempel sebagai teks, tulis ulang apa adanya ke file `.csv` di scratchpad - jangan diketik ulang manual per kolom, rawan salah).
2. **Dry-run pemetaan**:
   ```
   python .agents/skills/meta-analytics-ingest/scripts/ingest_meta.py <ekspor.csv>
   ```
   Skrip membaca kolom berdasarkan **nama** (urutan kolom ekspor Meta tidak stabil, mis. interval retensi 18/19 tertukar).
3. **Tinjau baris bermasalah bersama pengguna** sebelum menulis:
   - `DUD (reach < 50)`: upload gagal/duplikat - dilewati otomatis, sebutkan ke pengguna.
   - `AMBIGU ... cek manual`: dua episode berdekatan berdurasi sama (contoh nyata: Eps 48/49 = 91 dtk). Konfirmasi ke pengguna.
   - `TIDAK TERPETAKAN`: biasanya `durasi_asli_detik` tracker kosong. Tetapkan dengan `--map "MM/DD/YYYY HH:MM=EPS"`.
   - `KONFLIK`: dua video untuk satu episode (re-upload). Skrip memilih reach terbesar.
4. **Tulis**: tambahkan `--write`. Skrip hanya menulis kolom manual (`tanggal_posting`, `hari`, `fb_reach`, `fb_views`, `thumbstop_pct`, `avg_watch_detik`, `hold_1min_pct`, `rekomendasi_pct`, `female_25_34_pct`, `share`, `komen`) - kompatibel dengan `cerita-cerdik/tools/build_tracker.ps1` yang tidak pernah menimpa kolom itu. BOM & line ending file dipertahankan.
5. **Buat laporan audit** (format di §5).

### Cara pemetaan bekerja (agar bisa menjelaskan ke pengguna)
Urutan prioritas: `--map` → `tanggal_posting` yang sudah tercatat (rerun aman) → judul Meta cocok dengan `judul` tracker → durasi. Durasi di Meta konsisten **= durasi file + 1 detik** (terverifikasi di 51 episode, Agu–Okt 2026). Durasi kembar dipecahkan dengan memasangkan urut tanggal ↔ urut nomor episode.

## 2. Definisi Metrik (satu-satunya definisi yang dipakai di proyek ini)

| Metrik | Rumus dari kolom Meta | Catatan |
|---|---|---|
| Thumb-stop | Tayangan video 3 detik ÷ Jangkauan | Bukan ÷ impresi (Meta tidak mengekspor impresi di file ini) |
| Hold 1 menit | Tayangan video 1 menit ÷ Tayangan video 3 detik | |
| Rekomendasi % | Detik dilihat dari Rekomendasi ÷ Detik dilihat | **Hasil**, bukan tuas. Tinggi karena Meta mendorong video, bukan sebaliknya |
| F25-34 % | kolom demografi (F, 25-34) ÷ total kolom demografi | Total perempuan = jumlah semua kolom `F, …` |
| Rasio tonton | Detik dilihat rata-rata ÷ Durasi | Hitung di analisis, tidak disimpan di tracker |

## 3. Patokan Kalibrasi (data FB 7 Agu – 1 Okt 2026, n = 47 video Eps ≥ 4)

| Kelompok | Thumb-stop | Avg watch | Hold 1 mnt |
|---|---|---|---|
| Juara (reach ≥ 40k, n=14) | rata 74,4% (min 65,3%) | 48,9 dtk | 36,1% |
| Flop (reach < 8k, n=20) | rata 60,0% | 30,3 dtk | 30,2% |

- Korelasi Spearman ke reach: thumb-stop **0,75**, avg watch 0,64, hold 0,41, durasi 0,28, porsi perempuan **−0,18**.
- Komentar & share hampir nol di semua video (total 148 komentar + 122 share dari 1,05 jt reach; share/reach maksimum 0,055%). Jangan pakai komentar/share sebagai ukuran sukses di Facebook sampai polanya berubah.
- Patokan ini **wajib dihitung ulang** tiap Monthly Macro-Audit; tulis tanggal datanya saat mengutip.

## 4. Kejujuran Analisis (alasan di balik tiap aturan)

- **Bias umur video**: ekspor "Sepanjang Masa" = angka kumulatif. Video < 7 hari (skrip menandai `[UMUR<7 HARI]`, dihitung dari video terbaru di ekspor - bukan tanggal ekspor) belum selesai didistribusikan; jangan dibandingkan langsung dengan video lama. Untuk perbandingan adil, minta pengguna mengekspor ulang di umur yang sama (mis. hari ke-3 setiap video).
- **Konfounding**: jika beberapa variabel berubah bersamaan (contoh nyata sejak Eps 44: jam posting + durasi < 110 dtk + TTS 1.1 + jumlah shot + tema misteri), katakan terus terang bahwa penyebab tidak bisa dipisahkan. Jangan memilih satu penyebab favorit.
- **Sampel kecil**: dengan n < 5 per kelompok, sebut sebagai "pola", bukan "bukti".
- **Perbandingan terbaik = pasangan bersih**: video berformat sama, jam sama, minggu yang sama, beda satu hal (contoh: Eps 41 minyak oplosan 7k vs Eps 42 tali abu 49k vs Eps 43 semangka 46k, 15–17 Sep, semua 19:00).
- Pengguna sedang menjalankan **tes jam posting** secara sengaja (sejak Eps 44). Perlakukan sebagai eksperimen, bukan kesalahan.

### Aturan eksperimen (sarankan setiap kali pengguna "sedang test")
1. Ubah **satu variabel** per putaran; kunci variabel lain.
2. Tulis hipotesis di kolom `catatan` **sebelum** posting (mis. `[TES] slot 05:00, format terkunci 130 dtk`).
3. Minimal **3 video per kelompok**, tema setara.
4. Bandingkan di **umur video yang sama**.

## 5. Format Laporan Audit

```markdown
# AUDIT PERFORMA FB — [rentang tanggal data] (diekspor [tanggal])

## Ringkasan (3 kalimat maksimal)
## Pemetaan
- Terpetakan: X | Dud: Y | Ambigu/dikonfirmasi: Z | Tidak terpetakan: W
## Tabel Episode Baru (eps, tanggal, durasi, reach, thumb-stop, avg watch, hold, umur hari)
## Perbandingan Kohort / Eksperimen
- Variabel yang diuji, kelompok, n, median reach, thumb-stop rata-rata
- Konfounder yang tidak terkontrol
## Kesimpulan & Tingkat Keyakinan (tinggi / sedang / rendah + alasannya)
## Aksi Minggu Depan (maks 3, masing-masing bisa diuji)
```

## 6. Di luar cakupan skrip
- Ekspor Instagram/TikTok punya kolom berbeda; isi `ig_views` / `tiktok_views` manual dan sebutkan ke pengguna bahwa skrip baru mendukung Facebook.
- Jangan ubah aturan di `.agents/AGENTS.md` atau `EVALUASI_DAN_FORMULA_WINNING_CONTENT.md` berdasarkan hasil audit tanpa persetujuan pengguna - laporkan temuan + usulan, biar pengguna yang memutuskan.
