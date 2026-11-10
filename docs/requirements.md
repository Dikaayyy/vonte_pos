# Checklist Persyaratan & Fitur - Vonte PoS

Dokumen ini adalah checklist kebutuhan fungsional dan teknis aplikasi **Vonte PoS** yang diturunkan dari spesifikasi take-home test serta diselaraskan dengan [AGENTS.md](../AGENTS.md) dan [DESIGN.md](../DESIGN.md).

Dokumen ini berfungsi sebagai acuan verifikasi kesiapan fitur (*Definition of Done*) sepanjang proses pengembangan.

---

## Status Progres Ringkas

| Bagian | Kategori | Total Item | Selesai | Status |
|---|---|:---:|:---:|:---:|
| **Bagian A** | Fitur Wajib (Core Features) | 18 | 0 | 0% |
| **Bagian B** | Empat Tantangan Logika Kritis | 4 | 0 | 0% |
| **Bagian C** | Standar Arsitektur & Teknis | 10 | 0 | 0% |
| **Bagian D** | Fitur Bonus Terencana | 7 | 0 | 0% |
| **Bagian F** | Kriteria Pengiriman (Delivery Gate) | 5 | 0 | 0% |

---

## Bagian A: Fitur Wajib (Mandatory Features)

Fitur inti yang wajib berfungsi 100% offline dengan keandalan tinggi dan alur kerja kasir yang ergonomis.

| ID | Fitur | Kriteria Selesai yang Dapat Diuji | Status |
|---|---|---|:---:|
| **REQ-A01** | Splash Screen & Sesi | 1. Aplikasi memeriksa tabel `sessions` saat dibuka.<br>2. Jika terdapat sesi aktif valid, pengguna langsung diarahkan ke halaman Kasir tanpa jeda login ulang.<br>3. Jika tidak ada sesi aktif, pengguna diarahkan ke layar Login. | [ ] Belum |
| **REQ-A02** | Registrasi Akun Kasir | 1. Form registrasi menerima `name`, `username`, dan `password`.<br>2. Validasi: nama tidak boleh kosong, username minimal 3 karakter tanpa spasi & unik (case-insensitive), password minimal 6 karakter.<br>3. Password disimpan dalam bentuk hash + salt acak aman (SHA-256 via `crypto`). | [ ] Belum |
| **REQ-A03** | Login Offline Kasir | 1. Kasir dapat login menggunakan username dan password yang telah didaftarkan secara offline.<br>2. Menampilkan pesan error spesifik jika username tidak ditemukan atau password salah.<br>3. Login sukses membuat entri baru pada tabel `sessions` dan mengarahkan kasir ke halaman utama. | [ ] Belum |
| **REQ-A04** | Logout Kasir | 1. Menu logout tersedia di tab Pengaturan dengan dialog konfirmasi pencegahan ketidaksengajaan.<br>2. Konfirmasi logout menghapus sesi aktif dari tabel `sessions` dan mengembalikan aplikasi ke layar Login. | [ ] Belum |
| **REQ-A05** | Profil Toko (Store Profile) | 1. Tabel `store_profile` di-seed otomatis dengan 1 baris nilai default saat inisialisasi basis data.<br>2. Kasir/pemilik dapat mengubah nama toko, alamat, nomor telepon, dan teks footer struk di tab Pengaturan.<br>3. Pembaruan data langsung tersimpan ke basis data dan dipakai pada cetak/pratinjau struk berikutnya. | [ ] Belum |
| **REQ-A06** | CRUD Kategori Produk | 1. Pengguna dapat menambah, melihat, mengedit, dan menghapus kategori produk.<br>2. Nama kategori wajib diisi, di-trim, dan unik (case-insensitive).<br>3. Menghapus kategori menampilkan dialog konfirmasi: produk di dalamnya tidak dihapus, melainkan diatur menjadi tanpa kategori (`category_id = NULL`).<br>4. Daftar kategori menampilkan jumlah produk aktif yang bernaung di bawahnya. | [ ] Belum |
| **REQ-A07** | Filter Kategori Kasir | 1. Chip horizontal kategori ditampilkan di bagian atas katalog kasir dengan chip pertama "Semua".<br>2. Mengetuk chip kategori menyaring grid produk secara instan.<br>3. Status chip aktif memakai aksen warna tema (`primary-soft` dengan teks & border `primary`). | [ ] Belum |
| **REQ-A08** | CRUD Produk | 1. Form produk mencakup nama, kategori (opsional), harga jual (> 0), stok (>= 0), foto, dan pilihan add-on.<br>2. Hapus produk menggunakan soft delete (`is_deleted = 1`).<br>3. Produk yang dihapus tidak muncul di katalog kasir maupun master, tetapi baris datanya tetap utuh di database. | [ ] Belum |
| **REQ-A09** | Foto Produk Offline | 1. Pengguna dapat memilih foto dari kamera atau galeri.<br>2. File foto disalin ke direktori internal `<documents_dir>/product_images/` dengan nama unik; path relatif disimpan di database.<br>3. Mengganti foto menghapus file fisik foto lama.<br>4. Jika file foto hilang, UI menampilkan placeholder inisial nama produk tanpa crash. | [ ] Belum |
| **REQ-A10** | Pencarian Produk | 1. Field pencarian menyaring produk secara real-time saat pengguna mengetik (debounce/live filter).<br>2. Pencarian bekerja bersamaan dengan filter kategori yang sedang aktif.<br>3. Terdapat tombol pembersih (clear icon) untuk mereset kata kunci pencarian seketika. | [ ] Belum |
| **REQ-A11** | CRUD Add-on / Topping | 1. Pengguna dapat menambah, mengedit, dan menghapus add-on dengan kolom: nama, harga tambahan (>= 0), dan stok mandiri (>= 0).<br>2. Hapus add-on menggunakan soft delete (`is_deleted = 1`).<br>3. Add-on yang dihapus tidak muncul pada pilihan produk baru maupun transaksi baru. | [ ] Belum |
| **REQ-A12** | Relasi Add-on ke Produk | 1. Pada form produk, pengguna dapat memilih add-on mana saja yang kompatibel dengan produk tersebut (many-to-many via `product_addons`).<br>2. Produk yang memiliki opsi add-on ditandai dengan indikator ikon khusus pada kartu produk kasir. | [ ] Belum |
| **REQ-A13** | Penambahan ke Keranjang | 1. Mengetuk produk tanpa add-on langsung menambah 1 unit ke keranjang belanja.<br>2. Mengetuk produk dengan add-on membuka bottom sheet pilihan add-on (dengan toggle/stepper, live subtotal, dan tombol konfirmasi).<br>3. Menambahkan kombinasi produk + add-on yang identik akan meningkatkan qty pada baris yang sama. | [ ] Belum |
| **REQ-A14** | Manajemen Kuantitas Keranjang | 1. Setiap baris keranjang memiliki `QtyStepper` untuk menambah atau mengurangi kuantitas.<br>2. Mengurangi kuantitas hingga 0 atau menekan kontrol hapus akan mengeluarkan baris dari keranjang.<br>3. Total baris diperbarui secara instan dengan format angka rata kanan. | [ ] Belum |
| **REQ-A15** | Diskon Transaksi | 1. Mendukung tipe diskon persen (0..100%) dan nominal/fixed (0..subtotal).<br>2. Nilai diskon divalidasi ketat: input negatif atau melebihi batas langsung menampilkan pesan error inline dan menonaktifkan tombol Bayar.<br>3. Potongan rupiah dihitung menggunakan integer arithmetic dengan pembulatan half-up. | [ ] Belum |
| **REQ-A16** | Pembayaran Tunai & Kembalian | 1. Kasir memasukkan nominal uang tunai yang diterima (`cash_received`).<br>2. Field uang diterima menggunakan format Rupiah otomatis.<br>3. Kembalian (`change_amount`) dihitung live (`cash_received - total`).<br>4. Jika uang kurang, muncul peringatan inline "Uang kurang" dan transaksi diblokir. | [ ] Belum |
| **REQ-A17** | Pratinjau Struk (Receipt) | 1. Tampilan struk bergaya kertas (solid white, tanpa efek glass, font tabular figures).<br>2. Memuat: header toko (nama, alamat, telp), nama kasir, waktu transaksi, nomor faktur, daftar item belanja (beserta rincian add-on yang menjorok), subtotal, diskon, total, nominal bayar, kembalian, dan footer toko.<br>3. Tombol aksi: "Selesai" untuk menutup transaksi dan kembali ke kasir bersih. | [ ] Belum |
| **REQ-A18** | Laporan Omzet & Riwayat | 1. Menampilkan ringkasan total pendapatan kotor/bersih dan jumlah transaksi sukses.<br>2. Menampilkan daftar riwayat transaksi terurut dari yang terbaru (nomor invoice, tanggal/waktu, total).<br>3. Mengetuk salah satu transaksi membuka kembali pratinjau struk identik berbasis data snapshot. | [ ] Belum |

---

## Bagian B: Empat Tantangan Logika Kritis (The Four Hard Rules)

Empat aturan bisnis fundamental yang menjadi bobot penilaian utama dan wajib dilindungi oleh unit test di lapisan domain.

| ID | Aturan Logika | Kriteria Selesai yang Dapat Diuji | Status |
|---|---|---|:---:|
| **REQ-B01** | **Aturan 1: Shared Stock Validation** | 1. **Akumulasi Produk:** Pemakaian stok produk dihitung dari akumulasi `qty` seluruh baris keranjang yang memiliki `product_id` sama, terlepas dari perbedaan variasi add-on.<br>2. **Akumulasi Add-on:** Pemakaian stok add-on dihitung dari perkalian `qty baris` x `jumlah add-on terpasang pada baris` di seluruh keranjang.<br>3. **Identitas Baris Keranjang:** Identitas baris dibentuk oleh kombinasi `product_id` + himpunan `addon_id`. Kombinasi persis menambah `qty`; kombinasi beda membentuk baris baru.<br>4. **Validasi Real-time:** Percobaan menambah item atau menaikkan kuantitas melebihi stok yang tersisa langsung ditolak dengan pesan jelas: *"Stok tidak cukup. Tersisa X"*.<br>5. **Validasi Atomik DB:** Saat checkout, pengecekan diulang di dalam transaksi database dengan kueri bersyarat `UPDATE ... SET stock = stock - ? WHERE id = ? AND stock >= ?`. Jika terpengaruh 0 baris, seluruh transaksi di-rollback. | [ ] Belum |
| **REQ-B02** | **Aturan 2: History Immutability** | 1. **Snapshot Transaksi:** Tabel transaksi dan item menyimpan snapshot lengkap (nama produk, harga satuan saat transaksi, nama toko, alamat, nama kasir, rincian add-on).<br>2. **Isolasi Perubahan Master:** Mengubah harga jual produk/add-on atau memperbarui profil toko di masa depan sama sekali tidak mengubah data struk atau laporan transaksi lampau.<br>3. **Ketahanan Terhadap Hapus:** Menghapus produk/add-on secara soft delete tidak menyebabkan error, null pointer, atau nilai Rp0 pada transaksi historis.<br>4. **Kueri Terisolasi:** Kueri laporan dan detail struk hanya membaca tabel `transactions`, `transaction_items`, dan `transaction_item_addons` tanpa join ke tabel master aktif. | [ ] Belum |
| **REQ-B03** | **Aturan 3: Offline Photo Persistence** | 1. **Isolasi dari Cache:** File foto hasil tangkapan kamera atau galeri langsung disalin ke folder internal aplikasi `<app_documents>/product_images/` dengan nama berkas unik (UUID/timestamp).<br>2. **Penyimpanan Path Relatif:** Basis data hanya menyimpan relative path (misal: `product_images/prod_123.jpg`), bukan absolute path sistem operasi yang rentan berubah.<br>3. **Pembersihan Berkas:** Saat foto produk diperbarui atau diganti, file foto lama otomatis dihapus dari penyimpanan fisik perangkat.<br>4. **Graceful Fallback:** Jika file foto fisik hilang atau corrupt, antarmuka menampilkan placeholder inisial nama produk tanpa throwing exception atau merusak tata letak. | [ ] Belum |
| **REQ-B04** | **Aturan 4: Discount Protection** | 1. **Batas Persen:** Diskon persen dibatasi integer 0 hingga 100.<br>2. **Batas Nominal:** Diskon nominal dibatasi dari 0 hingga maksimal sebesar subtotal belanja.<br>3. **Aritmetika Integer Half-up:** Perhitungan nilai rupiah diskon menggunakan pembulatan integer standar: `((subtotal * percent + 50) ~/ 100)`.<br>4. **Proteksi Nilai Negatif:** Nilai akhir transaksi `total = subtotal - discount_amount` dijamin tidak pernah bernilai negatif (selalu >= 0).<br>5. **Proteksi Input Kasir:** Nilai diskon yang tidak valid menampilkan pesan error inline seketika dan menonaktifkan tombol submit checkout di level domain maupun UI. | [ ] Belum |

---

## Bagian C: Standar Arsitektur & Teknis (Technical Requirements)

Standar teknis, arsitektur perangkat lunak, dan batasan kualitas repositori yang harus dipenuhi.

| ID | Kategori Teknis | Kriteria Selesai yang Dapat Diuji | Status |
|---|---|---|:---:|
| **REQ-C01** | 100% Offline Standalone | Aplikasi berjalan sepenuhnya tanpa koneksi internet. Tidak menggunakan paket HTTP, Firebase, analytics online, font runtime web, atau aset gambar daring. | [ ] Belum |
| **REQ-C02** | Clean Architecture (Feature-First) | 1. Kode diorganisasi per fitur: `auth`, `store_profile`, `category`, `product`, `addon`, `cashier`, `transaction`, `dashboard`.<br>2. Arah dependensi ke dalam: Presentation -> Domain <- Data.<br>3. Lapisan `domain` murni Dart (tanpa Flutter, tanpa sqflite, tanpa dependensi UI). | [ ] Belum |
| **REQ-C03** | State Management (Cubit) | 1. Menggunakan `flutter_bloc` (Cubit) dan `equatable`.<br>2. Satu Cubit untuk satu fokus fitur (tanpa giant god-cubit).<br>3. State bersifat *immutable*, memiliki `copyWith`, dan membawa status eksplisit (initial, loading, success, failure) serta pesan error user-facing. | [ ] Belum |
| **REQ-C04** | Basis Data Relasional SQLite | 1. Menggunakan `sqflite` dengan skema relasional v1 terstruktur.<br>2. Mengaktifkan foreign key via `PRAGMA foreign_keys = ON` pada callback `onConfigure`.<br>3. Memiliki skema migrasi versi sejak hari pertama. | [ ] Belum |
| **REQ-C05** | Standar Tipe Data Finansial | 1. Seluruh representasi uang menggunakan tipe data `int` Rupiah (dilarang menggunakan `double`).<br>2. Waktu disimpan dalam format epoch milliseconds UTC (`INTEGER`) dan hanya diformat ke string tanggal lokal pada presentation layer. | [ ] Belum |
| **REQ-C06** | Formatter Rupiah Standar | 1. Helper tunggal `formatRupiah` menghasilkan format persis `Rp15.000` (tanpa spasi antara simbol dan angka, titik pemisah ribuan).<br>2. Kasus khusus: `0 -> Rp0`, `1500000 -> Rp1.500.000`, `-15000 -> -Rp15.000`. Teruji unit test. | [ ] Belum |
| **REQ-C07** | Design System (Vonte Soft Glass) | 1. Light theme only (tidak menyediakan dark mode).<br>2. Menggunakan komponen bersama: `AppGlass`, `AppCard`, `AppButton` sesuai spesifikasi `DESIGN.md`.<br>3. Angka numerik menggunakan tabular figures (`fontFeatures: [FontFeature.tabularFigures()]`) dan uang rata kanan.<br>4. Target sentuh minimal 48dp; tidak ada gradien pada komponen tombol/kartu. | [ ] Belum |
| **REQ-C08** | Optimasi Performa Glassmorphism | 1. `AppGlass` tidak digunakan di dalam baris list/grid yang dapat di-scroll.<br>2. Maksimal 3 layer blur simultan yang aktif di layar.<br>3. Terdapat saklar fallback pada `AppGlass` untuk render solid tanpa `BackdropFilter` pada perangkat low-end. | [ ] Belum |
| **REQ-C09** | Manajemen Dependensi Terkendali | Hanya menggunakan paket yang diizinkan di `AGENTS.md`. Penambahan paket baru wajib meminta izin sebelum instalasi. | [ ] Belum |
| **REQ-C10** | Cakupan Pengujian Otomatis | 1. Unit test untuk validasi stok bersama (termasuk kasus Kopi Susu + Extra Shot).<br>2. Unit test untuk proteksi dan kalkulasi diskon.<br>3. Unit test untuk kalkulasi total, uang tunai, dan kembalian.<br>4. Test repository untuk skenario imutabilitas transaksi pasca perubahan master.<br>5. Test rollback transaksi atomik saat stok habis di tengah proses. | [ ] Belum |

---

## Bagian D: Fitur Bonus Terencana (Planned Bonus Features)

Fitur bonus yang dipilih dan diurutkan berdasarkan skala prioritas implementasi di [AGENTS.md](../AGENTS.md).

| Prioritas | ID | Fitur Bonus | Kriteria Selesai yang Dapat Diuji | Status |
|:---:|---|---|---|:---:|
| **1** | **BONUS-01** | Indikator Stok Menipis *(Dipilih)* | 1. Menampilkan badge peringatan visual ("Sisa 3") jika stok produk atau add-on berada di bawah atau sama dengan batas ambang tertentu (`app_constants.dart`).<br>2. Tampil seragam pada kartu produk kasir, daftar master produk, dan daftar add-on.<br>3. Produk dengan stok 0 menampilkan label visual "Habis" dan dinonaktifkan dari penambahan keranjang. | [ ] Belum |
| **2** | **BONUS-02** | Tombol Nominal Tunai Cepat *(Dipilih)* | 1. Layar checkout menyediakan chip shortcut pembayaran tunai: "Uang Pas" dan pecahan uang kertas bulat berikutnya yang >= total tagihan (misal: Rp20.000, Rp50.000, Rp100.000).<br>2. Mengetuk chip langsung mengisi kolom uang diterima dan memperbarui nominal kembalian seketika. | [ ] Belum |
| **3** | **BONUS-03** | Tata Letak Responsif Tablet *(Dipilih)* | 1. Layout beradaptasi menggunakan `LayoutBuilder` berdasarkan breakpoint di `DESIGN.md` (Compact < 600dp, Medium 600-839dp, Expanded >= 840dp).<br>2. Pada mode Expanded (tablet landscape), navigasi berubah menjadi Navigation Rail di sisi kiri, grid produk menjadi 4 kolom, dan panel keranjang tampil permanen di sisi kanan.<br>3. Tidak ada masalah layout overflow pada orientasi portrait maupun landscape. | [ ] Belum |
| **4** | **BONUS-04** | Tahan / Simpan Pesanan (Hold Bill) *(Dipilih)* | 1. Kasir dapat menahan transaksi aktif keranjang belanja saat antrean tertahan.<br>2. Data transaksi tertahan disimpan persisten di SQLite (melalui migrasi skema v2: `held_bills` & `held_bill_items`) sehingga tidak hilang jika aplikasi tertutup.<br>3. Menahan bill tidak mengurangi stok master.<br>4. Saat transaksi dilanjutkan, sistem memvalidasi ulang ketersediaan stok terhadap kondisi terkini dan menandai baris yang stoknya sudah tidak mencukupi. | [ ] Belum |
| **5** | **BONUS-05** | Filter Tanggal & Grafik Dasbor *(Dipilih)* | 1. Tab Laporan menyediakan filter rentang tanggal: Hari Ini, 7 Hari Terakhir, 30 Hari Terakhir, dan Rentang Kustom.<br>2. Menampilkan grafik visual omzet per hari menggunakan paket `fl_chart`.<br>3. Grafik mematuhi aturan warna `DESIGN.md` (warna aksen tunggal `primary` dan nuansa slate netral, tanpa warna-warni pelangi).<br>4. Menampilkan metrik sederhana: produk terlaris dan rata-rata nilai transaksi. | [ ] Belum |
| **6** | **BONUS-06** | Cetak Struk Printer Bluetooth *(Dipilih)* | 1. Tombol "Cetak" di struk terhubung dengan modul printer thermal Bluetooth ESC/POS 58mm/80mm.<br>2. Generator byte ESC/POS dibangun secara murni dan terpisah dari lapisan I/O Bluetooth agar dapat diuji secara unit test.<br>3. Menangani kondisi koneksi Bluetooth mati atau printer tidak terjangkau dengan pesan kegagalan yang ramah pengguna. | [ ] Belum |
| **-** | **BONUS-07** | Aksi "Muat Data Contoh" *(Nice to have)* | 1. Tersedia tombol "Muat Data Contoh" di tab Pengaturan.<br>2. Menampilkan dialog konfirmasi sebelum melakukan seeding.<br>3. Hanya melakukan seeding jika basis data masih kosong untuk mencegah duplikasi.<br>4. Mengisi data contoh menu kedai kopi dan roti yang realistis (tanpa foto) untuk mempermudah penguji/reviewer mengevaluasi APK secara instan. | [ ] Belum |

---

## Bagian F: Kriteria Pengiriman (Delivery & Definition of Done)

Syarat mutlak sebelum proyek dinyatakan selesai dan diserahkan kepada tim penilai.

| ID | Item Pengiriman | Kriteria Selesai yang Dapat Diuji | Status |
|---|---|---|:---:|
| **REQ-F01** | Operasional 100% Offline | APK rilis berhasil diuji coba pada perangkat fisik/emulator tanpa akses jaringan; seluruh alur dari pendaftaran akun, kelola katalog, transaksi, hingga laporan berjalan mulus. | [ ] Belum |
| **REQ-F02** | Verifikasi Uji Otomatis | Rangkaian pengujian `flutter test` berjalan 100% lulus (green), mencakup seluruh unit test 4 aturan logika kritis, Cubit state management, dan skenario imutabilitas. | [ ] Belum |
| **REQ-F03** | Analisis Kode Bersih | Perintah `flutter analyze` menghasilkan output bersih tanpa warning atau error (`No issues found!`). | [ ] Belum |
| **REQ-F04** | Build APK Release | Perintah `flutter build apk --release` berhasil menghasilkan berkas APK yang siap diinstal dan telah melalui smoke test manual. | [ ] Belum |
| **REQ-F05** | Dokumentasi & Repositori | 1. Berkas `README.md` terisi lengkap menjelaskan arsitektur Clean Architecture, struktur tabel database, solusi 4 aturan logika, daftar bonus, serta panduan kompilasi.<br>2. Repositori diunggah ke GitHub/GitLab dengan hak akses penguji dan riwayat commit teratur per slice vertikal. | [ ] Belum |

