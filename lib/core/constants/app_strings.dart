/// Centralized UI strings in Bahasa Indonesia as required by DESIGN.md and AGENTS.md.
/// No emoji, no hype words, short and plain copy.
abstract final class AppStrings {
  // Common Actions (Verbs)
  static const String add = 'Tambah';
  static const String pay = 'Bayar';
  static const String save = 'Simpan';
  static const String delete = 'Hapus';
  static const String cancel = 'Batal';
  static const String finish = 'Selesai';
  static const String edit = 'Ubah';
  static const String close = 'Tutup';
  static const String retry = 'Coba Lagi';

  // Navigation
  static const String navCashier = 'Kasir';
  static const String navProduct = 'Produk';
  static const String navReport = 'Laporan';
  static const String navSettings = 'Pengaturan';
  static const String cashierPlaceholderSubtitle = 'Area transaksi kasir dan keranjang belanja.';
  static const String productPlaceholderSubtitle = 'Katalog produk, manajemen kategori, dan add-on.';
  static const String reportPlaceholderSubtitle = 'Ringkasan laporan penjualan dan riwayat transaksi.';
  static const String settingsPlaceholderSubtitle = 'Informasi sesi kasir dan pengaturan aplikasi.';

  // Quantity Stepper
  static const String decreaseQty = 'Kurang jumlah';
  static const String increaseQty = 'Tambah jumlah';
  static const String stockExhausted = 'Stok habis';
  static const String stockRemainingPrefix = 'Sisa';

  // Empty State Defaults
  static const String emptyDataTitle = 'Belum ada data';
  static const String emptyDataSubtitle = 'Data akan muncul di sini setelah ditambahkan.';
  static const String emptyCartTitle = 'Keranjang kosong';
  static const String emptyCartSubtitle = 'Pilih produk dari menu untuk memulai transaksi.';

  // Design Preview (TEMP)
  static const String designPreviewTitle = 'Pratinjau Sistem Desain';
  static const String designPreviewSubtitle = 'Uji visual token warna, tipografi, dan widget bersama.';
  static const String sectionTypography = 'Tipografi (Tabular Figures)';
  static const String sectionGlass = 'Permukaan Kaca (AppGlass)';
  static const String sectionCard = 'Kartu Solid (AppCard)';
  static const String sectionButtons = 'Tombol (AppButton)';
  static const String sectionStepper = 'Pengatur Jumlah (QtyStepper)';
  static const String sectionInlineError = 'Pesan Kesalahan (InlineError)';
  static const String sectionEmptyState = 'Status Kosong (EmptyState)';

  static const String sampleTotalDisplay = 'Rp125.000';
  static const String samplePrice = 'Rp25.000';
  static const String sampleHeadlineLg = 'Kategori Minuman Kopi';
  static const String sampleHeadlineMd = 'Ringkasan Pesanan';
  static const String sampleTitle = 'Kopi Susu Gula Aren';
  static const String sampleBodyMd = 'Perpaduan espresso mantap dengan susu segar dan aren alami.';
  static const String sampleBodySm = 'Catatan: Kurang manis, es batu sedikit.';
  static const String sampleLabel = 'Nama Pelanggan';
  static const String sampleCaption = 'Waktu transaksi: 10 Nov 2026, 09:30';

  static const String tabularTestLabel = 'Uji Perataan Tabular Figures:';
  static const String tabularSampleA = '111.111.111';
  static const String tabularSampleB = '888.888.888';

  static const String glassDefaultLabel = 'Kaca Standar (surface-glass)';
  static const String glassStrongLabel = 'Kaca Tebal (surface-glass-strong)';
  static const String glassAccentLabel = 'Kaca Aksen (primary-soft)';
  static const String glassToggleBlur = 'Nonaktifkan Blur Kaca (Fallback Solid)';
  static const String glassToggleBlurDesc = 'Uji saklar fallback tanpa efek blur BackdropFilter untuk efisiensi GPU.';

  static const String cardTitleSample = 'Kartu Solid Produk';
  static const String cardSubtitleSample = 'Kartu konten berulang menggunakan warna putih solid tanpa blur untuk menjaga performa.';

  static const String buttonPrimaryLabel = 'Bayar Transaksi';
  static const String buttonPrimaryLargeLabel = 'Bayar Transaksi (Utama 56dp)';
  static const String buttonSecondaryLabel = 'Batal Transaksi';
  static const String buttonDestructiveLabel = 'Hapus Item (Outline)';
  static const String buttonDestructiveSolidLabel = 'Konfirmasi Hapus (Solid)';
  static const String buttonTextLabel = 'Lihat Selengkapnya';
  static const String buttonDisabledLabel = 'Tombol Nonaktif';
  static const String buttonLoadingLabel = 'Menyimpan...';

  static const String sampleErrorMessage = 'Stok tidak cukup. Tersisa 2 unit.';
  static const String sampleStockExhausted = 'Stok habis. Produk tidak dapat ditambah ke keranjang.';

  // Authentication & Session
  static const String appName = 'Vonte PoS';
  static const String appTagline = 'Aplikasi Kasir Offline Cepat & Mandiri';
  static const String authLoginTitle = 'Masuk Kasir';
  static const String authLoginSubtitle = 'Masuk untuk memulai sesi transaksi kasir.';
  static const String authRegisterTitle = 'Daftar Kasir Baru';
  static const String authRegisterSubtitle = 'Buat akun kasir baru untuk mengelola penjualan.';
  static const String nameLabel = 'Nama Lengkap';
  static const String nameHint = 'Masukkan nama lengkap';
  static const String usernameLabel = 'Username';
  static const String usernameHint = 'Minimal 3 karakter tanpa spasi';
  static const String passwordLabel = 'Kata Sandi';
  static const String passwordHint = 'Minimal 6 karakter';
  static const String loginButton = 'Masuk';
  static const String registerButton = 'Daftar';
  static const String dontHaveAccount = 'Belum punya akun? ';
  static const String haveAccount = 'Sudah punya akun? ';
  static const String goToRegister = 'Daftar Akun';
  static const String goToLogin = 'Masuk ke Akun';
  static const String logout = 'Keluar';
  static const String homePlaceholderTitle = 'Beranda Kasir';
  static const String activeSessionTitle = 'Sesi Aktif';
  static const String loggedInAs = 'Kasir aktif:';
  static const String invalidCredentials = 'Username atau kata sandi salah.';
  static const String sessionExpired = 'Sesi telah berakhir.';

  // Validation Rules
  static const String nameRequired = 'Nama tidak boleh kosong.';
  static const String usernameMinLength = 'Username minimal 3 karakter.';
  static const String usernameNoSpaces = 'Username tidak boleh mengandung spasi.';
  static const String usernameAlreadyTaken = 'Username sudah digunakan.';
  static const String passwordMinLength = 'Password minimal 6 karakter.';

  // Product & Category Management
  static const String productTabLabel = 'Produk';
  static const String categoryTabLabel = 'Kategori';
  static const String addonTabLabel = 'Add-on';
  static const String categoryListTitle = 'Daftar Kategori';
  static const String categoryListSubtitle = 'Kelola pengelompokan menu dan produk toko.';
  static const String addCategory = 'Tambah Kategori';
  static const String editCategory = 'Ubah Kategori';
  static const String deleteCategory = 'Hapus Kategori';
  static const String categoryNameLabel = 'Nama Kategori';
  static const String categoryNameHint = 'Contoh: Minuman Kopi';
  static const String categoryNameRequired = 'Nama kategori tidak boleh kosong.';
  static const String categoryNameDuplicate = 'Nama kategori sudah digunakan.';
  static const String deleteCategoryConfirmTitle = 'Hapus Kategori?';
  static const String deleteCategoryConfirmMessage =
      'Produk di dalam kategori ini tidak akan dihapus, tetapi kategorinya akan diubah menjadi Tanpa Kategori.';
  static const String emptyCategoryTitle = 'Belum ada kategori';
  static const String emptyCategorySubtitle =
      'Tambahkan kategori untuk memudahkan pengelompokan produk.';
  static const String productCountSuffix = 'produk';
  static const String uncategorized = 'Tanpa Kategori';
  static const String productCatalogPlaceholder =
      'Katalog produk utama akan aktif pada slice produk.';
  static const String addonCatalogPlaceholder =
      'Daftar add-on akan aktif pada slice add-on.';

  // Add-on Management
  static const String addonListTitle = 'Daftar Add-on';
  static const String addonListSubtitle =
      'Kelola topping dan pilihan tambahan untuk produk toko.';
  static const String addAddon = 'Tambah Add-on';
  static const String editAddon = 'Ubah Add-on';
  static const String deleteAddon = 'Hapus Add-on';
  static const String addonNameLabel = 'Nama Add-on';
  static const String addonNameHint = 'Contoh: Extra Shot';
  static const String addonPriceLabel = 'Harga Tambahan (Rp)';
  static const String addonPriceHint = '0 untuk gratis';
  static const String addonStockLabel = 'Stok Sendiri';
  static const String addonStockHint = 'Contoh: 20';
  static const String addonNameRequired = 'Nama add-on tidak boleh kosong.';
  static const String addonPriceInvalid = 'Harga tambahan harus 0 atau lebih.';
  static const String addonPriceNan = 'Harga tambahan harus berupa angka valid.';
  static const String addonStockInvalid = 'Stok harus 0 atau lebih.';
  static const String addonStockNan = 'Stok harus berupa angka valid.';
  static const String deleteAddonConfirmTitle = 'Hapus Add-on?';
  static const String deleteAddonConfirmMessage =
      'Add-on ini akan dihapus dari daftar master dan kasir, tetapi tetap tersimpan untuk riwayat transaksi.';
  static const String emptyAddonTitle = 'Belum ada add-on';
  static const String emptyAddonSubtitle =
      'Tambahkan topping atau pilihan tambahan untuk produk toko.';
  static const String outOfStockBadge = 'Habis';
  static const String freePriceLabel = 'Gratis';
  static const String stockLabelPrefix = 'Stok:';
}
