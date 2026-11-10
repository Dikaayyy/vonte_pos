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
      domain/         # Product entity, repository interface, use cases, ProductValidator
      data/           # ProductModel, ProductLocalDataSource, ProductRepositoryImpl, PhotoStorage, ImagePickerService
      presentation/   # ProductCubit, ProductState, ProductListView, ProductCard, dialogs
    cashier/          # Keranjang & checkout
    transaction/      # Riwayat transaksi & snapshot nota
```

---

## 2. State Management

Menggunakan **Cubit** (`flutter_bloc`) dengan `equatable`:
- Satu Cubit per kebutuhan domain (`AuthCubit`, `CategoryCubit`, `AddonCubit`, `ProductCubit`).
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

## 5. Pengujian & Verifikasi

Semua lapisan diuji dengan unit test dan widget test (206 test case passing):
- Validasi domain (`ProductValidatorTest`): aturan nama, harga > 0, stok >= 0.
- `PhotoStorageTest`: uji salin foto, resolusi path, penggantian/penghapusan file, dan penanganan file hilang tanpa crash.
- `ProductRepositoryImplTest`: integrasi SQLite in-memory, verifikasi soft delete, pivot table add-on, filter kategori, pencarian, dan cascading `SET NULL` kategori.
- `ProductCubitTest`: verifikasi transisi state, pencarian, filter, dan error handling.
- `ProductPageTest`: pengujian widget tampilan grid, badge stok menipis, placeholder inisial foto, filter chip, dialog form, dan dialog konfirmasi soft delete.

Jalankan pengujian:
```bash
flutter analyze
flutter test
```
