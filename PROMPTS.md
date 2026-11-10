# Prompt Pack - Vonte PoS

Prompt siap tempel untuk Antigravity, urut sesuai alur pengerjaan. File ini untuk kamu, bukan untuk agent. Boleh disimpan di luar repo atau di `docs/`.

## Cara pakai

1. Satu prompt untuk satu sesi kerja. Jangan menempel beberapa prompt sekaligus.
2. Setiap prompt diawali kalimat yang menyuruh agent membaca `AGENTS.md` dan `DESIGN.md`. Jangan dihapus.
3. Setelah agent selesai: baca hasilnya, jalankan `flutter analyze` dan `flutter test` sendiri, jalankan aplikasinya, lalu commit dengan pesan yang jelas.
4. Jalankan **Prompt Pemahaman** (di bagian akhir) setelah tiap slice. Ini yang membuat kamu siap wawancara.
5. Kalau agent melenceng, tempel ulang: "Baca ulang AGENTS.md. Bagian proyek mengalahkan ponytail. Perbaiki sesuai itu."
6. Teks dalam `[kurung siku]` diisi sendiri.

---

## 0. Setup proyek

```
Baca AGENTS.md dan DESIGN.md sepenuhnya. Gunakan antislop mode during untuk sesi ini.

Tugas: setup fondasi proyek Vonte PoS. Jangan membuat fitur apa pun.

1. Jika belum ada proyek Flutter di root repo, buat dengan:
   flutter create --org id.vonte --project-name vonte_pos --platforms=android .
2. Tambahkan paket dengan `flutter pub add` (jangan menulis nomor versi manual):
   runtime: flutter_bloc, equatable, get_it, sqflite, path, path_provider, image_picker, crypto, intl
   dev: bloc_test, mocktail, flutter_lints
3. Buat kerangka folder sesuai bagian Architecture di AGENTS.md (folder kosong cukup diberi .gitkeep).
4. Siapkan font Manrope sebagai asset lokal di assets/fonts/ (bobot 500, 600, 700, 800) dan daftarkan di pubspec.yaml.
   Jika kamu tidak bisa mengunduh fontnya, tetap tulis konfigurasi pubspec dan beri tahu saya file mana yang harus saya taruh manual.
5. Buat core/utils/format_rupiah.dart dan unit test-nya. Format target persis `Rp15.000`
   (tanpa spasi). Kasus uji: 0 -> `Rp0`, 15000 -> `Rp15.000`, 1500000 -> `Rp1.500.000`, -15000 -> `-Rp15.000`.
   Jika NumberFormat bawaan intl tidak menghasilkan format itu persis, sesuaikan implementasinya sampai test lulus.
6. Pastikan analysis_options.yaml memakai flutter_lints dan .gitignore tidak memasukkan keystore atau file rahasia.

Selesai: jalankan `flutter analyze` dan `flutter test`. Beri ringkasan file yang dibuat, jelaskan cara kerja
format_rupiah dalam 5 baris, dan akhiri dengan catatan ponytail.
```

---

## 1. Dokumen pegangan

```
Baca AGENTS.md dan DESIGN.md. Gunakan antislop mode during.

Tugas: buat dua dokumen saja, tanpa menyentuh kode.

1. docs/requirements.md: checklist fitur dari soal take-home, dikelompokkan sesuai bagian A (fitur wajib),
   B (empat tantangan logika), C (teknis), D (bonus), F (pengiriman). Setiap item punya kriteria selesai
   yang bisa diuji dan kolom status [ ] belum / [x] selesai. Tandai bonus yang saya pilih sesuai daftar bonus di AGENTS.md.
2. docs/schema.md: skema database v1 dari AGENTS.md dalam bentuk tabel (kolom, tipe, constraint, FK, alasan desain),
   plus diagram relasi sederhana dengan Mermaid. Jelaskan secara singkat mengapa ada kolom snapshot dan soft delete.

Jangan menambah fitur atau tabel baru yang tidak ada di AGENTS.md. Jika menemukan celah di skema, tulis di bagian
"Pertanyaan terbuka" di akhir docs/schema.md, jangan memutuskan sendiri.
```

---

## 2a. Tema dan widget dasar

```
Baca AGENTS.md dan DESIGN.md. Gunakan antislop mode during.

Tugas: implementasi design system (hanya fondasi UI, belum ada fitur).

1. core/theme: token warna, radius, spacing, dan tipografi persis dari DESIGN.md, plus ThemeData light.
   Angka memakai tabular figures.
2. Widget bersama: AppGlass (ClipRRect + BackdropFilter + DecoratedBox, dengan satu saklar untuk fallback solid tanpa blur),
   AppCard (solid), AppButton dengan varian primary / secondary / destructive / text, QtyStepper, InlineError, EmptyState.
3. Halaman pratinjau sementara di route /design-preview yang menampilkan semua widget di atas pada latar dengan
   dua lingkaran blur lembut. Tandai dengan komentar `TEMP` agar mudah dihapus nanti.
4. Ikuti larangan di DESIGN.md: tanpa gradien di komponen, tanpa tema gelap, tanpa BackdropFilter di item list.
5. Semua teks tampilan masuk core/constants/app_strings.dart.

Selesai: jalankan analyze dan test, ringkas file yang dibuat, dan jelaskan cara kerja AppGlass beserta alasan
saklar fallback-nya.
```

---

## 2b. Database

```
Baca AGENTS.md. Gunakan antislop mode during.

Tugas: fondasi database. Belum ada fitur.

1. core/database/app_database.dart: buka database sqflite dengan `PRAGMA foreign_keys = ON` di onConfigure,
   versi 1, struktur migrasi berversi.
2. onCreate membuat semua tabel persis sesuai skema v1 di AGENTS.md (users, sessions, store_profile, categories,
   products, addons, product_addons, transactions, transaction_items, transaction_item_addons), termasuk constraint,
   FK, dan index yang masuk akal (misalnya products.category_id, products.name, transactions.created_at).
3. Seed satu baris store_profile dengan nilai default yang netral.
4. Registrasikan AppDatabase di core/di/injection.dart dengan get_it.
5. Untuk menguji database di mesin lokal, tambahkan `sqflite_common_ffi` sebagai dev dependency dengan
   `flutter pub add --dev sqflite_common_ffi`, lalu catat di daftar Packages di AGENTS.md.
6. Test: semua tabel terbentuk, foreign key benar-benar aktif (insert dengan FK tidak valid harus gagal),
   dan constraint UNIQUE bekerja.

Selesai: analyze dan test, ringkas hasilnya, dan jelaskan mengapa foreign_keys harus diaktifkan manual di sqflite.
```

---

## 3a. Auth

```
Baca AGENTS.md dan DESIGN.md. Gunakan antislop mode during.

Tugas: fitur auth sebagai satu slice vertikal (domain, data, Cubit, UI, test).

Domain: entity User dan Session, AuthRepository (interface), use case RegisterUser, LoginUser, Logout, GetCurrentSession.
Aturan validasi (pesan error dalam Bahasa Indonesia di app_strings.dart):
- Nama tidak boleh kosong.
- Username minimal 3 karakter, tanpa spasi, unik (tanpa membedakan huruf besar kecil).
- Password minimal 6 karakter.
Data: PasswordHasher di core/utils (salt acak dari Random.secure + SHA-256 lewat paket crypto), data source sqflite,
implementasi repository. Sesi disimpan di tabel sessions.
Presentation: AuthCubit dengan state berstatus eksplisit, SplashPage (cek sesi lalu arahkan ke login atau home),
LoginPage, RegisterPage, sesuai DESIGN.md. Setelah login masuk ke halaman home placeholder. Navigasi pakai
named routes Navigator bawaan.

Test: PasswordHasher, setiap aturan validasi, use case dengan mock repository (mocktail), AuthCubit (bloc_test),
repository dengan database sementara.

Selesai: analyze dan test, jalankan di emulator, ringkas hasilnya, dan jelaskan alur dari tombol Masuk sampai ke
database dalam 8 baris. Akhiri dengan catatan ponytail.
```

## 3b. Shell navigasi

```
Baca AGENTS.md dan DESIGN.md. Gunakan antislop mode during.

Tugas: AppShell setelah login, dengan 4 tujuan: Kasir, Produk, Laporan, Pengaturan. Isinya placeholder.

- Compact dan medium: bottom bar glass mengambang. Expanded (840dp ke atas): navigation rail di kiri.
- Gunakan LayoutBuilder dengan breakpoint dari DESIGN.md. Tanpa FAB tengah.
- Tab Kasir adalah tab pertama dan menjadi halaman utama.
- Navigasi antar tab tidak boleh membuat ulang state tab lain (pakai IndexedStack atau setara).
- Item aktif memakai ikon terisi dan warna primary, item tidak aktif memakai ikon outline.

Test widget sederhana: pada lebar 400dp muncul bottom bar, pada lebar 900dp muncul rail.
```

---

## 4a. Kategori

```
Baca AGENTS.md dan DESIGN.md. Gunakan antislop mode during.

Tugas: CRUD kategori sebagai slice vertikal (domain, data, CategoryCubit, UI, test). Letakkan layarnya di tab Produk
sebagai sub-bagian (misalnya tab atau segmented control "Produk | Kategori | Add-on").

Aturan:
- Nama wajib, di-trim, unik tanpa membedakan huruf besar kecil.
- Hapus kategori menampilkan dialog konfirmasi yang menjelaskan bahwa produk di dalamnya menjadi "Tanpa kategori"
  (category_id menjadi NULL lewat ON DELETE SET NULL). Jangan menghapus produknya.
- Daftar kategori menampilkan jumlah produk per kategori.

Test: validasi nama, duplikat, hapus kategori yang punya produk, Cubit.
Selesai: ringkasan, penjelasan alur tambah kategori dari UI sampai SQL, catatan ponytail.
```

## 4b. Add-on

```
Baca AGENTS.md dan DESIGN.md. Gunakan antislop mode during.

Tugas: CRUD add-on / topping sebagai slice vertikal. Kolom: nama, harga tambahan (0 atau lebih), stok sendiri (0 atau lebih).
Hapus memakai soft delete (is_deleted = 1). Add-on yang dihapus tidak muncul di daftar, tetapi barisnya tetap ada.
Validasi dengan pesan spesifik dalam Bahasa Indonesia. Tampilkan badge stok menipis memakai konstanta ambang
di core/constants/app_constants.dart.

Test: validasi, soft delete (barisnya masih ada tetapi tidak ikut daftar), Cubit.
Selesai: ringkasan dan catatan ponytail.
```

## 4c. Produk dan foto

```
Baca AGENTS.md dan DESIGN.md. Gunakan antislop mode during.

Tugas: CRUD produk lengkap dengan foto, sebagai slice vertikal.

Kolom: nama, kategori (opsional, dropdown), harga jual (lebih dari 0), stok (0 atau lebih), foto, add-on yang bisa
dipasang (pilih banyak lewat product_addons). Hapus memakai soft delete.

Foto (aturan 3 di AGENTS.md):
- Pilih dari kamera atau galeri lewat image_picker (batasi maxWidth dan imageQuality).
- PhotoStorage (core atau feature product): salin file ke <documents dir>/product_images/ dengan nama unik,
  simpan path RELATIF di photo_path, resolve ke path absolut saat ditampilkan.
- Saat foto diganti, hapus file lama. Jika file tidak ada, tampilkan placeholder (huruf pertama nama produk), bukan crash.
- Direktori dokumen diinjeksi lewat interface agar bisa diuji dengan direktori sementara.
- Periksa izin kamera di AndroidManifest.

UI: daftar produk dengan pencarian dan filter kategori, form tambah/ubah, badge stok menipis.

Test: validasi, PhotoStorage (salin, ganti, file hilang), soft delete, pemasangan add-on, Cubit.
Selesai: ringkasan dan jelaskan secara spesifik mengapa path relatif dan mengapa foto tetap ada setelah cache dibersihkan.
```

## 4d. Pengaturan toko

```
Baca AGENTS.md dan DESIGN.md. Gunakan antislop mode during.

Tugas: tab Pengaturan.
1. Edit profil toko (nama, alamat, telepon, footer struk) yang tersimpan di tabel store_profile. Data ini dipakai struk.
2. Tombol Keluar (logout) dengan konfirmasi.
3. Tombol "Muat data contoh" yang mengisi beberapa kategori, produk, dan add-on yang realistis untuk kedai kopi
   dan roti (misalnya Kopi Susu, Roti Bakar, Extra Shot). Tanpa foto. Tombol ini hanya mengisi data jika tabel
   masih kosong, dan ada konfirmasi. Tanpa angka karangan di UI, hanya data contoh.

Test: simpan dan baca profil toko, seeding tidak menggandakan data.
Selesai: ringkasan dan catatan ponytail.
```

---

## 5a. Logika inti kasir (domain murni + test dulu)

```
Baca AGENTS.md. Gunakan antislop mode during.

Tugas: hanya lapisan domain murni (Dart tanpa Flutter dan tanpa sqflite) untuk inti kasir. Tulis test lebih dulu atau
bersamaan. Ini bagian penilaian terpenting.

Buat di features/cashier/domain:
- CartLine (productId, nama, harga satuan, qty, daftar add-on terpasang dengan nama dan harga) dengan identitas
  baris = produk + himpunan add-on (urutan tidak berpengaruh).
- StockValidator: hitung pemakaian stok PRODUK = jumlah qty semua baris dengan productId yang sama, dan pemakaian
  stok ADD-ON = jumlah (qty baris x jumlah add-on itu pada baris). Kembalikan hasil yang menjelaskan alasan gagal
  dan sisa stok.
- Discount (percent atau fixed) dan DiscountCalculator dengan aturan 4 di AGENTS.md: persen bilangan bulat 0..100,
  fixed 0..subtotal, pembulatan half-up dengan aritmetika integer ((subtotal * persen + 50) ~/ 100), total tidak
  pernah negatif.
- CartTotals (subtotal, diskon, total) dan CashCalculator (uang diterima harus >= total, kembalian = uang - total).

Kasus test wajib:
- Stok 2: 1x Kopi Susu polos + 1x Kopi Susu + Extra Shot memakai 2 unit; penambahan ketiga ditolak.
- Stok add-on terakumulasi (Extra Shot stok 2; satu baris qty 2 dengan Extra Shot memakai 2; satu lagi ditolak).
- Perubahan qty ke atas ditolak saat melebihi stok, ke bawah diizinkan.
- Produk stok 0 ditolak.
- Diskon: persen 0, 100, 101, -1; fixed sama dengan subtotal, lebih dari subtotal, negatif; subtotal 0;
  pembulatan (subtotal 10005 dengan 15% menghasilkan 1501).
- Uang kurang, uang pas, kembalian.

Jangan menyentuh UI atau database di slice ini. Selesai: analyze dan test, ringkasan, jelaskan tiap class dalam 2 baris.
```

## 5b. CartCubit

```
Baca AGENTS.md. Gunakan antislop mode during.

Tugas: CartCubit di features/cashier/presentation yang memakai StockValidator dan kalkulator dari slice 5a.

- State (Equatable, copyWith): daftar CartLine, diskon, totals, serta pesan error stok terbaru bila ada.
- Fungsi: tambah produk (dengan add-on), ubah qty, hapus baris, atur diskon, kosongkan keranjang.
- Setiap perubahan divalidasi lewat domain. Jika ditolak, state tidak berubah dan error berisi alasan, misalnya
  "Stok tidak cukup. Tersisa 2."
- Cubit hanya membaca stok terkini lewat use case, bukan langsung dari database.

Test dengan bloc_test, termasuk skenario Kopi Susu stok 2 lewat Cubit.
Selesai: ringkasan dan penjelasan alur "tap produk -> state baru" dalam 6 baris.
```

## 5c. Layar kasir

```
Baca AGENTS.md dan DESIGN.md. Gunakan antislop mode during. Prioritaskan kecepatan dan kenyamanan kasir.

Tugas: UI tab Kasir yang memakai CartCubit.

- Pencarian (filter saat mengetik) dan chip kategori ("Semua" pertama), memfilter produk yang tidak soft-deleted.
- Grid produk: 2 kolom (compact), 3 kolom (medium), 4 kolom (expanded). Kartu produk solid dengan semua state di DESIGN.md:
  normal, punya add-on, stok menipis, habis, stok sudah penuh di keranjang.
- Tap produk tanpa add-on langsung menambah 1 unit dengan haptic ringan. Produk dengan add-on membuka add-on sheet
  (baris add-on, stepper, subtotal langsung, tombol "Tambah ke keranjang").
- Compact dan medium: bar ringkasan sticky (jumlah item dan total) yang membuka keranjang sebagai bottom sheet.
  Expanded: panel keranjang tetap di kanan.
- Keranjang: baris dengan add-on sebagai caption, QtyStepper, total per baris rata kanan, hapus baris, footer
  subtotal / diskon / total dan tombol "Bayar" (belum perlu fungsi checkout, cukup navigasi ke halaman placeholder).
- Alasan penolakan stok tampil inline dan jelas, bukan hanya tombol yang mati.
- Tanpa BackdropFilter di dalam item grid atau list.

Test widget: kartu habis tidak bisa di-tap, pesan stok tampil, layout berganti pada 400dp dan 900dp.
Selesai: ringkasan, dan sebutkan hal yang belum diverifikasi (misalnya performa blur di perangkat nyata).
```

---

## 6a. Checkout transaksi atomik

```
Baca AGENTS.md. Gunakan antislop mode during.

Tugas: lapisan domain dan data untuk checkout. Tanpa UI.

- Entity Transaction, TransactionItem, TransactionItemAddon (semua berisi snapshot nama, harga, detail toko, nama kasir).
- InvoiceNumberGenerator dengan format VNT-YYYYMMDD-0001, nomor urut reset setiap hari, jam diinjeksi (Clock) agar bisa diuji.
- CheckoutUseCase dan repository yang menjalankan SEMUA langkah di dalam satu db.transaction:
  1) validasi ulang stok produk dan add-on dari baris database saat ini,
  2) buat invoice_no,
  3) insert transactions, transaction_items, transaction_item_addons dengan snapshot,
  4) kurangi stok dengan `UPDATE ... SET stock = stock - ? WHERE id = ? AND stock >= ?` dan anggap 0 baris terpengaruh sebagai
     kegagalan yang me-rollback semuanya.
- Hasil berupa Result sukses (berisi transaksi lengkap) atau kegagalan dengan alasan.

Test (database sementara): sukses menyimpan semua baris dan mengurangi stok; rollback total saat stok produk kurang;
rollback total saat stok add-on kurang di tengah transaksi (pastikan stok produk tidak berkurang); snapshot
tersimpan; urutan invoice naik dan reset di hari berikutnya; diskon dan kembalian tersimpan benar.
Selesai: ringkasan dan penjelasan mengapa validasi stok diulang di dalam transaksi.
```

## 6b. UI checkout dan struk

```
Baca AGENTS.md dan DESIGN.md. Gunakan antislop mode during.

Tugas: CheckoutCubit, layar checkout, dan pratinjau struk.

Checkout (sesuai DESIGN.md): blok ringkasan (subtotal, diskon, total), diskon dengan segmented "Rp | %" dan
validasi inline (negatif, melebihi subtotal, persen di atas 100), uang diterima dengan format Rupiah, chip "Uang pas" dan
nominal cepat, kembalian live, "Uang kurang" bila kurang, tombol "Bayar" nonaktif sampai valid.
Setelah sukses: kosongkan keranjang dan tampilkan struk.

Struk: tampilan kertas (putih solid, tanpa glass) berisi nama toko dan alamat, nama kasir, waktu, nomor invoice,
daftar item dengan add-on menjorok, subtotal, diskon, total, bayar, kembalian, footer. Tombol "Selesai"
(dan "Cetak" sebagai placeholder nonaktif sampai fitur printer dibuat).

Test: CheckoutCubit (bloc_test) untuk setiap kasus validasi dan kegagalan stok di tengah proses, serta widget test struk.
Selesai: ringkasan dan jelaskan alur penuh dari tombol Bayar sampai commit database.
```

---

## 7. Laporan dan riwayat

```
Baca AGENTS.md dan DESIGN.md. Gunakan antislop mode during.

Tugas: tab Laporan sebagai slice vertikal.

- Query hanya ke tabel transactions, transaction_items, dan transaction_item_addons. Dilarang join ke products atau addons.
- Tampilkan total pendapatan, jumlah transaksi sukses, dan daftar riwayat (terbaru di atas, tampil invoice, waktu, total).
- Tap transaksi membuka struk yang sama dengan struk checkout, dibangun dari data snapshot.
- Kartu statistik dan layout sesuai DESIGN.md.

Test immutability (wajib): jual produk -> ubah harga produk -> soft-delete produk -> muat ulang struk dan laporan ->
pastikan nama, harga, dan total tidak berubah serta tidak ada null atau error. Tambahkan juga test untuk laporan
saat belum ada transaksi.
Selesai: ringkasan dan penjelasan mengapa riwayat tidak terpengaruh perubahan master data.
```

---

## 8. Bonus (kerjakan satu per satu, sesuai prioritas)

### 8a. Indikator stok menipis
```
Baca AGENTS.md dan DESIGN.md. Gunakan antislop mode during.
Tugas: pastikan indikator stok menipis konsisten di kartu produk kasir, daftar produk, dan daftar add-on,
memakai satu konstanta ambang di app_constants.dart dan satu widget badge bersama. Tambahkan test untuk batas ambang
(tepat di ambang, di atas, stok 0).
```

### 8b. Responsif tablet
```
Baca AGENTS.md dan DESIGN.md. Gunakan antislop mode during dan skill antislop-layoutmobile.
Tugas: audit dan perbaiki layout untuk tablet portrait dan landscape pada seluruh layar (kasir, produk, laporan,
checkout, struk). Tidak ada overflow, grid dan panel sesuai tabel breakpoint di DESIGN.md, form tidak melebar penuh
tanpa batas. Beri laporan temuan sebelum mengubah, lalu perbaiki yang disetujui. Tambahkan widget test pada tiga lebar layar.
```

### 8c. Hold / simpan bill
```
Baca AGENTS.md dan DESIGN.md. Gunakan antislop mode during.
Tugas: fitur tahan bill sebagai slice vertikal. Bill yang ditahan disimpan di database (tabel baru held_bills dan
held_bill_items, tambahkan lewat migrasi v2 dan perbarui docs/schema.md) agar tetap ada setelah aplikasi ditutup.
Menahan bill tidak mengurangi stok. Saat bill dilanjutkan, semua baris divalidasi ulang terhadap stok saat ini dan
baris yang tidak valid ditandai jelas. Keranjang aktif yang tidak kosong tidak boleh tertimpa tanpa konfirmasi.
Test: tahan, lanjutkan, stok berubah di antaranya, hapus bill ditahan, migrasi v1 ke v2 mempertahankan data lama.
```

### 8d. Dashboard: filter tanggal dan grafik
```
Baca AGENTS.md dan DESIGN.md. Gunakan antislop mode during.
Tugas: tambahkan filter tanggal (hari ini, 7 hari, 30 hari, rentang kustom) dan grafik pendapatan per hari memakai fl_chart
(tambahkan lewat `flutter pub add fl_chart`), plus analitik sederhana: produk terlaris dan rata-rata nilai transaksi.
Hanya baca dari tabel transaksi. Grafik memakai warna primary untuk seri utama dan nuansa slate untuk lainnya,
tanpa pelangi. Test untuk query rentang tanggal, termasuk batas tengah malam.
```

### 8e. Printer thermal Bluetooth
```
Baca AGENTS.md dan DESIGN.md. Gunakan antislop mode during.
Tugas: cetak struk lewat printer thermal Bluetooth (ESC/POS). Sebelum memilih paket, periksa mana yang masih aktif dirawat
dan jelaskan pilihan serta alasannya, lalu tunggu persetujuan saya. Setelah disetujui: pisahkan pembuat byte struk
(murni, bisa diuji) dari pengirim Bluetooth, tangani izin dan kondisi printer tidak terhubung dengan pesan jelas, dan
aktifkan tombol "Cetak" di struk. Test hanya untuk pembuat byte struk; jelaskan apa yang belum bisa saya verifikasi
tanpa perangkat fisik.
```

---

## 9. Penutup

```
Baca AGENTS.md. Gunakan antislop mode after untuk audit akhir.

Tugas penutup, kerjakan berurutan dan laporkan hasil tiap langkah:
1. Audit antislop mode after pada UI, teks, dan komentar kode. Tampilkan daftar temuan bernomor dulu, jangan perbaiki sebelum saya setuju.
2. Hapus halaman /design-preview dan semua kode bertanda TEMP.
3. Telusuri docs/requirements.md dan centang hanya item yang benar-benar terpenuhi dan teruji. Laporkan item yang belum.
4. Tulis README.md: ringkasan proyek, arsitektur dan alur data, state management (Cubit) dan alasannya, struktur tabel
   database, empat aturan sulit dan cara pengamanannya, daftar bonus yang diimplementasikan, cara menjalankan, dan cara build APK.
5. Jalankan `flutter analyze`, `flutter test`, lalu `flutter build apk --release`. Laporkan lokasi APK dan hasil tiap perintah.
```

---

## Prompt pendukung

### Pemahaman (jalankan setelah tiap slice)
```
Saya harus bisa menjelaskan kode ini di wawancara teknis. Untuk slice yang baru selesai:
1. Gambarkan alur data dari UI sampai database dan kembali, dalam urutan nama file dan fungsi.
2. Sebutkan tiga keputusan desain terpenting beserta alternatif yang tidak dipilih.
3. Tunjukkan bagian paling rawan bug.
4. Ajukan 5 pertanyaan seperti penguji (satu di antaranya meminta perubahan kode secara langsung), tanpa jawaban. Saya akan menjawab dulu, lalu kamu menilai.
```

### Latihan live coding
```
Berperan sebagai penguji. Berikan satu permintaan perubahan fitur yang realistis untuk Vonte PoS (misalnya diskon per
item, batas maksimal qty per baris, atau metode pembayaran non-tunai) tanpa memberi solusi. Saya akan mengerjakannya
sendiri. Setelah saya bilang selesai, tinjau kode saya: ketepatan, cakupan test, dan apakah arsitektur tetap terjaga.
```

### Perbaikan bug
```
Bug: [jelaskan perilaku yang terjadi dan yang diharapkan, langkah mengulang, dan pesan error bila ada].
Cari akar masalahnya dulu dan jelaskan sebelum mengubah apa pun. Tulis test yang gagal karena bug ini, baru perbaiki di
tempat yang paling tepat (bukan tambalan di UI). Pastikan semua test lain tetap lulus.
```
