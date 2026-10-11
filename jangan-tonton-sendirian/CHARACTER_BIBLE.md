# CHARACTER BIBLE - JANGAN TONTON SENDIRIAN

> **STATUS: DISETUJUI SEMENTARA (11 Okt 2026).** Pengguna melanjutkan ke Eps 01 dengan usulan ini tanpa perubahan, tapi belum menjawab secara eksplisit soal jilbab, nama, dan suara TTS narator. Jika pengguna mengubah salah satunya, perbarui file ini dan brief yang sudah memakainya, lalu ganti status menjadi DISETUJUI.

Panduan konsistensi tokoh untuk prompt AI (Google Flow / Imagen / CapCut) dan naskah VO.

---

## 1. Aturan Visual Global
- **Frasa pembuka**: `Cinematic semi-realistic horror style, near-photorealistic, realistic human proportions and natural skin texture, soft film grain, low-key moody lighting, modern Indonesian domestic setting`
- **Negative**: `[no cartoon, no anime, no claymation, no plastic toy look, no video game render, no gore, no blood, no corpse, no distorted face, no extra fingers, no deformed hands, no celebrity likeness, no readable text, no numbers, no clock hands, no watermark, no white studio background, no blank void]`
- **Register cahaya default**: malam dengan lampu kuning redup dan bayangan panjang; siang hari hanya untuk adegan "normal" (Shot 2) agar kontrasnya terasa.

---

## 2. Narator Tetap (USULAN)

### Laras - narator "aku"
- **Peran**: ibu muda yang menceritakan kejadian-kejadian janggal dalam hidupnya. Tenang, penyayang, sedikit penakut tapi selalu berusaha melindungi keluarganya.
- **Usia**: 28 tahun.
- **Penampilan (usulan)**: wajah bulat lembut, mata besar, kantong mata tipis (lelah khas ibu muda), jilbab instan (bergo) cokelat susu, daster batik biru tua saat di rumah. *Pilihan berjilbab atau rambut dicepol tanpa jilbab adalah keputusan pengguna.*
- **Prompt base (AI)**: `a 28-year-old Indonesian young mother, round gentle face, big expressive eyes, slightly tired under-eyes, plain light-brown instant hijab, dark blue batik house dress (daster), barefoot at home, clean face.`
- **Suara VO**: tenang dan pelan, seperti bercerita ke teman di malam hari; makin cepat dan tertahan saat eskalasi.

### Fase hidup (alasan cerita berpindah rumah)
Karena naratornya tetap, cerita bisa berlatar di rumah yang berbeda-beda dengan cara Laras menceritakan kejadian dari fase hidup yang berbeda. Sebut fasenya di narasi Shot 2 dan di header hasil brief.
1. **Masa kos putri** sebelum menikah (kamar & lorong kos, kamar mandi bersama).
2. **Awal menikah, menumpang di rumah mertua** di desa (rumah joglo tua, aturan-aturan mertua).
3. **Kontrakan pertama** di gang sempit kota (bayi baru lahir, tetangga dempet).
4. **Rumah cicilan di perumahan** sekarang (kompleks baru yang masih sepi).

Bayi baru ada sejak fase 3, sehingga tidak semua episode melibatkan bayi.

---

## 3. Tokoh Pendukung (USULAN)
- **Mas Bayu** (31): suami Laras, satpam pabrik yang sering **shift malam**, alasan utama Laras sendirian di malam hari. Prompt base: `a 31-year-old Indonesian man, short black hair, kind tired face, navy security guard uniform, clean face.`
- **Kinan** (10 bulan, fase 3-4): bayi perempuan Laras. Tampil tidur, digendong, atau di ayunan kain. Wajah bayi tidak pernah menjadi fokus close-up horor.
- **Bu Sumi** (60, fase 2): ibu mertua di desa, pendiam, penuh aturan rumah yang tidak pernah dijelaskan alasannya. Sumber utama cerita Tipe C. Prompt base: `a 60-year-old Javanese village woman, grey hair in a small bun, faded brown kebaya and batik jarik, stern quiet expression, clean face.`
- **Bu Wati** (45, fase 4): tetangga perumahan yang ramah berlebihan. Cocok untuk Tipe B (orang yang terlalu baik).

---

## 4. Entitas Gaib
- **Tidak pernah tampil dengan wajah jelas.** Cukup siluet, rambut panjang, tangan pucat, kaki, bayangan, kain putih, atau sosok di kejauhan yang tidak fokus.
- Bentuknya mengikuti folklor yang dikenal nasional (lihat `bank-premis.md`), tanpa darah dan tanpa luka.

---

## 5. Aturan Penerapan
- **Referensi wajah**: gaya visual hampir nyata (sejak 11 Okt 2026), jadi wajah mudah berubah antar-generate. Simpan aset tokoh pertama yang disetujui di `character/season1/` dan pakai sebagai referensi di setiap generate berikutnya.
- **DO**: aset tokoh selalu `empty hands` dan berlatar transparan (`isolated on clean transparent background, clean alpha cutout`) agar mudah dianimasikan dengan properti CapCut.
- **DON'T**: wajah tidak boleh berdarah, kotor, atau terluka di base render; noda, bayangan, dan efek lewat overlay CapCut.
- **Keluarga inti** (Laras, Mas Bayu, Kinan) tidak pernah menjadi pelaku kejahatan atau KDRT dan tidak pernah ditampilkan celaka (AGENTS §5.4).
