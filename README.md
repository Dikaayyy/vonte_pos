# Vonte PoS

Aplikasi Point of Sale (PoS) 100% offline mandiri untuk bisnis F&B dan retail, dibangun menggunakan Flutter dengan arsitektur Clean Architecture, Cubit (`flutter_bloc`), dan SQLite (`sqflite`).

---

## 1. Arsitektur & Struktur Proyek

Mengikuti **Feature-first Clean Architecture** dengan pemisahan dependensi ke arah dalam (*presentation -> domain <- data*):

```
lib/
  main.dart
  app.dart
  core/
    constants/        # AppStrings (Bahasa Indonesia), AppConstants, AppRoutes
    database/         # AppDatabase (SQLite migrations, PRAGMA foreign_keys = ON), AppTables
    di/               # injection.dart (GetIt service locator)
    error/            # AppException, ValidationException, AppDatabaseException
    storage/          # AppDirectoryProvider (abstraksi dokumen untuk testability)
    theme/            # Vonte Soft Glass tokens, AppTheme, AppGlass, AppCard, AppButton
    utils/            # formatRupiah, passwordHasher
    widgets/          # AppTextField, EmptyState, InlineError, QtyStepper
  features/
    auth/             # Session & Login/Register offline kasir
    category/         # CRUD Kategori master dan filter produk
    addon/            # CRUD Add-on dengan stok dan harga tersendiri
    product/          # CRUD Produk lengkap, foto lokal offline, pivot product_addons
    store_profile/    # Profil Toko, data contoh kopi & roti, dan Pengaturan sesi
    cashier/          # Keranjang & checkout
    transaction/      # Riwayat transaksi & snapshot nota
```

---

## 2. State Management

Menggunakan **Cubit** (`flutter_bloc`) dengan `equatable`:
- Satu Cubit per kebutuhan domain (`AuthCubit`, `CategoryCubit`, `AddonCubit`, `ProductCubit`, `CartCubit`, `CheckoutCubit`, `ReportCubit`).
- State bersifat immutable, memiliki status eksplisit (`initial`, `loading`, `success`, `failure`), `copyWith`, dan `errorMessage` yang ramah pengguna.
- Cubit hanya memanggil Use Case di lapisan domain (tidak memanggil database atau repository langsung).

---

## 3. Struktur Tabel Database (SQLite v1)

Foreign keys diaktifkan pada koneksi (`PRAGMA foreign_keys = ON` di `onConfigure`).

- `users` (`id`, `name`, `username UNIQUE`, `password_hash`, `salt`, `created_at`)
- `sessions` (`id`, `user_id FK`, `logged_in_at`)
- `store_profile` (`id`, `name`, `address`, `phone`, `receipt_footer`)
- `categories` (`id`, `name UNIQUE`)
- `products` (`id`, `category_id FK NULL ON DELETE SET NULL`, `name`, `price`, `stock`, `photo_path`, `is_deleted`, `created_at`, `updated_at`)
- `addons` (`id`, `name`, `price`, `stock`, `is_deleted`)
- `product_addons` (`product_id FK`, `addon_id FK`, `PRIMARY KEY (product_id, addon_id)`)
- `transactions` (`id`, `invoice_no UNIQUE`, `cashier_id`, `cashier_name`, `store_name`, `store_address`, `store_phone`, `subtotal`, `discount_type`, `discount_value`, `discount_amount`, `total`, `cash_received`, `change_amount`, `created_at`)
- `transaction_items` (`id`, `transaction_id FK`, `product_id`, `product_name`, `unit_price`, `qty`, `line_total`)
- `transaction_item_addons` (`id`, `transaction_item_id FK`, `addon_id`, `addon_name`, `addon_price`, `qty`, `line_total`)

---

## 4. Fitur CRUD Produk & Manajemen Foto Offline

### A. Fitur Produk
- **Kolom**: Nama, Kategori (opsional, dropdown), Harga jual (validasi > 0), Stok (validasi >= 0), Foto produk, dan Add-on yang dapat dipasang (pilih banyak lewat tabel pivot `product_addons`).
- **Pencarian & Filter**: Pencarian real-time berdasarkan nama produk, filter kategori interaktif (horizontal scrollable chips).
- **Indikator Stok**: Badge semantik stok menipis (`Sisa X` jika stok <= 5) dan badge `Habis` jika stok = 0.
- **Soft Delete**: Penghapusan produk menggunakan `is_deleted = 1`. Produk disembunyikan dari katalog kasir aktif, namun baris data tetap ada di SQLite agar riwayat transaksi dan nota masa lalu tetap valid.

### B. Aturan Foto Offline (Aturan 3)
1. **Penyimpanan Dokumen**: File foto disalin ke `<documents dir>/product_images/` dengan nama unik (`prod_<timestamp>_<random>.<ext>`), dibatasi `maxWidth: 1024` dan `imageQuality: 85`.
2. **Penyimpanan Path Relatif**: Hanya string path relatif (contoh: `product_images/prod_17000000_12345.jpg`) yang disimpan di database `photo_path`.
3. **Resolusi Aman & Placeholder**: Saat ditampilkan, path relatif di-resolve ke path absolut direktori dokumen aplikasi saat ini. Jika file fisik hilang atau belum ada, UI otomatis menampilkan placeholder huruf pertama nama produk tanpa pernah crash.
4. **Pembersihan File Saat Diganti**: Ketika foto produk diganti saat ubah produk, file foto lama dihapus dari disk penyimpanan untuk mencegah penumpukan file yatim (*orphaned files*).
5. **Abstraksi Testable**: Direktori dokumen diinjeksi melalui antarmuka `AppDirectoryProvider` sehingga dapat diuji menggunakan direktori sementara sistem (`Directory.systemTemp`).

---

## 5. Tab Pengaturan & Data Contoh

1. **Edit Profil Toko**: Menyimpan data nama toko, alamat, nomor telepon, dan pesan footer struk ke tabel `store_profile`. Data ini menjadi snapshot header dan footer saat transaksi dan cetak struk.
2. **Sesi Kasir & Keluar**: Menampilkan informasi akun kasir aktif, waktu sesi dimulai, dan ID pengguna, disertai tombol keluar dengan dialog konfirmasi (`AppButtonVariant.destructive`).
3. **Muat Data Contoh**: Tombol dengan dialog konfirmasi untuk memuat menu awal kedai kopi dan roti (3 kategori, 4 add-on, 5 produk realistis beserta relasi pivot `product_addons`, tanpa foto). Fitur ini memiliki proteksi atomik: hanya dapat memuat data jika katalog masih kosong, dan secara otomatis menolak duplikasi data bila tabel sudah berisi.

---

## 6. Tab Laporan & Riwayat Transaksi (Aturan 2: Immutability)

### A. Fitur Tab Laporan
1. **Query Terisolasi**: Query laporan dan riwayat transaksi **hanya** mengakses tabel `transactions`, `transaction_items`, dan `transaction_item_addons`. Dilarang keras melakukan `JOIN` ke tabel master `products` maupun `addons`.
2. **Kartu Statistik**: Menampilkan metrik utama di bagian atas menggunakan kartu solid `AppCard` sesuai `DESIGN.md`:
   - **Total Pendapatan**: Akumulasi nilai `total` dari seluruh transaksi sukses dalam format rupiah (`formatRupiah`) dengan *tabular figures*.
   - **Transaksi Sukses**: Jumlah total transaksi tercatat.
3. **Daftar Riwayat Transaksi**:
   - Menampilkan daftar transaksi terurut dari yang paling baru (`created_at DESC`).
   - Setiap kartu transaksi menampilkan nomor invoice resmi, waktu transaksi, kasir, jumlah item, serta total nominal yang rata kanan.
   - Tanpa efek blur (*strictly no BackdropFilter*) di dalam list scrolling sesuai aturan performa `DESIGN.md`.
4. **Pratinjau Struk Snapshot**: Mengetuk (*tap*) salah satu baris riwayat akan membuka tampilan struk (`ReceiptPage` / `ReceiptView`) yang dibangun dari data snapshot murni, identik dengan struk sesaat setelah checkout.

### B. Jaminan Immutability Riwayat Transaksi (Aturan 2)
- **Snapshot Kolom**: Saat checkout berhasil, seluruh data penting (nama toko, alamat, telepon kasir, nama kasir, nama produk, harga satuan saat dibeli, add-on dan harganya, serta total baris) disalin sebagai snapshot ke dalam tabel transaksi.
- **Kebal terhadap Perubahan Master Data**:
  - Jika harga produk diubah di masa depan (misal: Rp18.000 naik menjadi Rp45.000), total pendapatan laporan dan harga pada nota riwayat lama **tetap sama persis** dengan saat transaksi dilakukan.
  - Jika produk atau add-on dihapus (*soft delete* `is_deleted = 1`), riwayat transaksi dan struk lama **tetap dapat dimuat tanpa error atau null**, karena query tidak bergantung pada tabel produk.
- Diuji secara menyeluruh melalui `transaction_immutability_integration_test.dart` (mencakup skenario saat belum ada transaksi dan skenario jual -> ubah harga -> soft delete -> muat ulang).

---

## 7. Pengujian & Verifikasi

Semua lapisan diuji dengan unit test, bloc test, widget test, dan integration test (361 test case passing):
- `GetReportUseCaseTest`: pengujian kalkulasi agregasi pendapatan dan total transaksi domain.
- `ReportCubitTest`: pengujian alur state cubit (`loading`, `success`, `failure`) menggunakan `bloc_test`.
- `ReportPageTest`: widget test layar laporan (state kosong, kartu statistik, daftar riwayat, ketuk transaksi buka struk, tombol muat ulang).
- `TransactionImmutabilityIntegrationTest`: integrasi SQLite in-memory untuk memverifikasi kebalnya laporan dan struk terhadap perubahan harga atau penghapusan produk di master data.
- Hard Rule 1 (Shared Stock Validation) & Hard Rule 4 (Discount & Cash Calculator).

Jalankan pengujian:
```bash
flutter analyze
flutter test
```
