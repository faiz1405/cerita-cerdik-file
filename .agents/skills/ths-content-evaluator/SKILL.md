---
name: ths-content-evaluator
description: Menggunakan THS Framework (Thumb-stop Rate, Hold Rate/Retention, Shareability & Social Value) untuk menganalisis, mengaudit, dan mengoptimalkan performa konten video pendek sebelum dan sesudah dipublikasikan.
---

# THS Content Evaluator Skill (Analytics & Audit Engine)

Skill ini dirancang untuk mengaudit, menganalisis, dan membedah kualitas video pendek (TikTok, Instagram Reels, YouTube Shorts, Facebook Reels) berbasis **THS Framework**, baik secara **Pre-Production Audit** (analisis naskah/brief) maupun **Post-Upload Analytics** (analisis data grafik studio).

---

## 1. THS Framework Core Metrics

```
[ T ] THUMB-STOP RATE   →  Goal: ≥ 70%   (Tayangan 3 detik ÷ Jangkauan). < 60% = zona merah
[ H ] HOLD RATE         →  Goal: Avg watch ≥ 45 dtk (untuk video ≥ ~120 dtk; video lebih pendek nilai pakai rasio avg watch ÷ durasi)
                            Hold 1 menit (Tayangan 1 mnt ÷ Tayangan 3 dtk) = indikator sekunder saja
[ S ] SHAREABILITY RATE →  Belum ada patokan yang terbukti (lihat catatan di bawah)
```

**Kalibrasi (data FB Cerita Cerdik 7 Agu – 1 Okt 2026):** video reach ≥ 40k rata-rata thumb-stop 74,4% (min 65,3%), hold 1 mnt 36,1%, avg watch 48,9 dtk; video reach < 8k rata-rata thumb-stop 60,0%, hold 30,2%, avg watch 30,3 dtk. Hold 1 menit lemah sebagai pembeda: 7 dari 14 video juara berada di bawah 35% (Eps 27: 24,8% tapi reach 45k), korelasinya ke reach hanya 0,41 vs thumb-stop 0,75. Target lama (thumb-stop > 35%, share > 2%) jauh di bawah/di atas realita channel ini: share/reach tertinggi yang pernah tercapai hanya 0,055%, dan komentar+share hampir nol di semua video (termasuk yang memakai Neuro-CTA polarisasi). Untuk Facebook, nilai Shareability secara kualitatif saja sampai ada data yang menunjukkan CTA tertentu benar-benar menaikkan share/komentar. Definisi metrik & pengisian tracker: skill `meta-analytics-ingest`. Hitung ulang patokan ini setiap Monthly Macro-Audit.

---

## 2. Metodologi Audit Pra-Produksi (Pre-Production Audit)

Jalankan evaluasi THS pada draft naskah/brief sebelum proses editing/rendering:

### A. Audit [ T ] — Thumb-stop Potential (Detik 0 - 3)
* **Visual Check:** Apakah adegan 3 detik pertama menampilkan *Visual Pattern Interrupt* (ekspresi wajah kontras, pergerakan instan, atau objek unik)?
* **Verbal & Text Check:** Apakah headline overlay maksimal 6 kata dan mengandung *Open Loop* (rasa penasaran membakar)?
* **Audio Check:** Apakah ada *Audio Anchor* (SFX kejutan seperti *Boom / Record Scratch*) di detik 0.5?
* *Skor Maksimal: 35 Poin*

### B. Audit [ H ] — Hold Rate Potential (Detik 3 - akhir)
* **Dead-Air Check:** Apakah ada jeda hening narasi VO > 0.5 detik? (Jika ada, WAJIB dipotong).
* **Visual Transition Rule:** Apakah adegan visual berganti atau mengalami *Zoom/Panning* setiap 3-5 detik?
* **Conflict Arc:** Apakah rasa penasaran (*Cortisol trigger*) terjaga konsisten di Shot 2-3 hingga resolusi di Shot 4-5?
* *Skor Maksimal: 35 Poin*

### C. Audit [ S ] — Shareability & Social Value Potential
* **Emotional Reward:** Apakah ending video memberikan rasa puas/haru/tawa (*Oxytocin/Dopamine Payoff*) yang layak dibagikan ke teman/grup?
* **Neuro-CTA Check:** Apakah kalimat penutup menanyakan opini yang memicu perdebatan di kolom komentar?
* **Looping Bridge:** Apakah kalimat akhir menyambung mulus kembali ke kata pertama di awal video?
* *Skor Maksimal: 30 Poin*

---

## 3. Metodologi Diagnostik Pasca-Upload (Post-Upload Analytics)

Gunakan matriks ini saat membedah data analitis dari dasbor YouTube Studio, Meta Business Suite, atau TikTok Center:

### Matriks Masalah & Solusi Perbaikan:

| Gejala Data Analitis | Diagnostik Masalah THS | Solusi / Tindakan Perbaikan Naskah Selanjutnya |
| :--- | :--- | :--- |
| **Thumb-stop (Tayangan 3 dtk ÷ Jangkauan) < 60%** | **Thumb-stop Rate Rendah:** Hook visual membosankan atau teks judul terlalu biasa. | • Ganti kalimat pembuka dengan *Open Loop* provokatif.<br>• Gunakan ekspresi wajah AI yang lebih kontras.<br>• Tambahkan SFX *Record Scratch* di detik awal. |
| **Grafik Retensi Anjlok di Detik 3 - 15** | **Hold Rate Lemah:** Pembukaan bertele-tele atau penjelasan latar belakang terlalu panjang. | • Hilangkan perkenalan salam/basa-basi.<br>• Langsung masuk ke konflik/masalah di Shot 1.<br>• Padatkan kalimat VO di Shot 1-2 (speed TTS tetap ikut `.agents/AGENTS.md`, jangan diubah di sini). |
| **Grafik Retensi Anjlok di Tengah Video** | **Dead Air & Visual Stagnan:** Adegan terlalu lama tidak berganti (stagnan). | • Terapkan aturan ganti adegan/efek zoom tiap 3-5 detik.<br>• Sisipkan SFX *Heartbeat* / *Dramatic Boom* saat konflik. |
| **Completion Rate Rendah, tapi Views Tinggi** | **Ending Kurang Menarik:** Resolusi tidak memuaskan atau terlalu dipanjang-panjangkan. | • Percepat durasi Shot 5-6.<br>• Pastikan *punchline* Ki Udin disampaikan dengan *comedic timing* yang pas. |
| **Komentar & Share Sangat Sedikit** | **Shareability Rendah:** CTA garing (*"Jangan lupa follow"*) atau tidak ada rasa haru/tawa. | • Ganti CTA menjadi pertanyaan *Neuro-CTA* yang memicu perdebatan moral.<br>• Perkuat pesan moral/kehangatan emosi di ending. |

---

## 4. Format Laporan Evaluasi THS (Output Template)

Saat AI Agent diminta mengevaluasi sebuah naskah/video, luarkan laporan dengan format berikut:

```markdown
# HASIL EVALUASI THS FRAMEWORK

## 1. Skor Pra-Produksi
- [ T ] Thumb-stop Potential : [XX/35]
- [ H ] Hold Rate Potential   : [XX/35]
- [ S ] Shareability Potential: [XX/30]
- **TOTAL THS SCORE:** [XX/100]

## 2. Catatan Kritis & Diagnostik
- **Thumb-stop:** [Evaluasi detik 0-3]
- **Hold Rate:** [Evaluasi pacing & visual transition]
- **Shareability:** [Evaluasi ending & Neuro-CTA]

## 3. Rekomendasi Perbaikan Instan
1. [Rekomendasi 1]
2. [Rekomendasi 2]
3. [Rekomendasi 3]
```
