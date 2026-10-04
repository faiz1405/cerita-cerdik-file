---
name: ths-content-evaluator
description: Menggunakan THS Framework (Thumb-stop Rate, Hold Rate/Retention, Shareability & Social Value) untuk menganalisis, mengaudit, dan mengoptimalkan performa konten video pendek sebelum dan sesudah dipublikasikan.
---

# THS Content Evaluator Skill (Analytics & Audit Engine)

Skill ini dirancang untuk mengaudit, menganalisis, dan membedah kualitas video pendek (TikTok, Instagram Reels, YouTube Shorts, Facebook Reels) berbasis **THS Framework**, baik secara **Pre-Production Audit** (analisis naskah/brief) maupun **Post-Upload Analytics** (analisis data grafik studio).

---

## 1. THS Framework Core Metrics

```
[ T ] THUMB-STOP RATE   →  Goal: > 35% (Rasio Penonton 3 Detik Pertama)
[ H ] HOLD RATE         →  Goal: Completion > 30% & Retention 30s > 50%
[ S ] SHAREABILITY RATE →  Goal: Share Ratio > 2% & High Comment Density
```

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
| **3-Sec Views / Impression < 20%** | **Thumb-stop Rate Rendah:** Hook visual membosankan atau teks judul terlalu biasa. | • Ganti kalimat pembuka dengan *Open Loop* provokatif.<br>• Gunakan ekspresi wajah AI yang lebih kontras.<br>• Tambahkan SFX *Record Scratch* di detik awal. |
| **Grafik Retensi Anjlok di Detik 3 - 15** | **Hold Rate Lemah:** Pembukaan bertele-tele atau penjelasan latar belakang terlalu panjang. | • Hilangkan perkenalan salam/basa-basi.<br>• Langsung masuk ke konflik/masalah di Shot 1.<br>• Percepat tempo narasi VO (speed 0.88 - 0.95). |
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
