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

  // Product Management
  static const String productListTitle = 'Daftar Produk';
  static const String productListSubtitle = 'Kelola katalog produk, harga, stok, dan add-on.';
  static const String addProduct = 'Tambah Produk';
  static const String editProduct = 'Ubah Produk';
  static const String deleteProduct = 'Hapus Produk';
  static const String productNameLabel = 'Nama Produk';
  static const String productNameHint = 'Contoh: Kopi Susu Aren';
  static const String productCategoryLabel = 'Kategori';
  static const String productCategoryHint = 'Pilih kategori (opsional)';
  static const String productPriceLabel = 'Harga Jual (Rp)';
  static const String productPriceHint = 'Contoh: 18000';
  static const String productStockLabel = 'Jumlah Stok';
  static const String productStockHint = 'Contoh: 25';
  static const String productAddonsLabel = 'Pilihan Add-on';
  static const String productPhotoLabel = 'Foto Produk';
  static const String pickFromCamera = 'Kamera';
  static const String pickFromGallery = 'Galeri';
  static const String changePhoto = 'Ganti Foto';
  static const String removePhoto = 'Hapus Foto';
  static const String searchProductHint = 'Cari produk...';
  static const String allCategories = 'Semua';
  static const String deleteProductConfirmTitle = 'Hapus Produk?';
  static const String deleteProductConfirmMessage =
      'Produk ini akan dihapus dari katalog dan kasir, tetapi riwayat transaksi sebelumnya tetap aman.';
  static const String emptyProductTitle = 'Belum ada produk';
  static const String emptyProductSubtitle =
      'Tambahkan produk untuk mulai menyusun menu penjualan toko.';
  static const String noProductFoundTitle = 'Produk tidak ditemukan';
  static const String noProductFoundSubtitle =
      'Coba kata kunci pencarian atau kategori filter lain.';
  static const String productNameRequired = 'Nama produk tidak boleh kosong.';
  static const String productPriceInvalid = 'Harga produk harus lebih dari 0.';
  static const String productPriceNan = 'Harga produk harus berupa angka valid.';
  static const String productStockInvalid = 'Stok produk minimal 0.';
  static const String productStockNan = 'Stok produk harus berupa angka valid.';
  static const String lowStockPrefix = 'Sisa';
  static const String selectPhotoPrompt = 'Pilih Foto Produk';
  static const String addonCountPrefix = 'Add-on:';
  static const String noAddonsAvailable = 'Belum ada add-on yang dibuat di sistem.';

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

  // Store Profile & Settings
  static const String storeProfileTitle = 'Profil Toko';
  static const String storeProfileSubtitle =
      'Informasi toko yang akan tercetak pada struk transaksi.';
  static const String storeNameLabel = 'Nama Toko';
  static const String storeNameHint = 'Contoh: Vonte Coffee & Bakery';
  static const String storeAddressLabel = 'Alamat Toko';
  static const String storeAddressHint = 'Contoh: Jl. Sudirman No. 10';
  static const String storePhoneLabel = 'Nomor Telepon';
  static const String storePhoneHint = 'Contoh: 081234567890';
  static const String storeReceiptFooterLabel = 'Pesan Footer Struk';
  static const String storeReceiptFooterHint =
      'Contoh: Terima kasih atas kunjungan Anda';
  static const String saveStoreProfile = 'Simpan Profil';
  static const String storeProfileSaved = 'Profil toko berhasil disimpan.';
  static const String storeNameRequired = 'Nama toko tidak boleh kosong.';
  static const String storeAddressRequired = 'Alamat toko tidak boleh kosong.';
  static const String storePhoneRequired = 'Nomor telepon tidak boleh kosong.';
  static const String storeReceiptFooterRequired =
      'Pesan footer struk tidak boleh kosong.';

  // Sample Data Seeding
  static const String sampleDataTitle = 'Data Contoh';
  static const String sampleDataSubtitle =
      'Muat menu contoh kopi dan roti jika katalog toko masih kosong.';
  static const String seedSampleData = 'Muat Data Contoh';
  static const String seedSampleDataConfirmTitle = 'Muat Data Contoh?';
  static const String seedSampleDataConfirmMessage =
      'Data contoh untuk kedai kopi dan roti akan ditambahkan ke katalog. Tindakan ini hanya dapat dilakukan saat katalog masih kosong. Lanjutkan?';
  static const String seedSampleDataSuccess = 'Data contoh berhasil dimuat.';
  static const String seedSampleDataAlreadyPopulated =
      'Data contoh hanya dapat dimuat saat katalog masih kosong.';
  static const String confirmSeed = 'Muat Data';

  // Cashier Domain Validation Strings
  static const String stockInsufficient = 'Stok tidak cukup.';
  static const String stockExhaustedGeneral = 'Stok habis.';
  static const String discountPercentOutOfRange =
      'Diskon persen harus antara 0% hingga 100%.';
  static const String discountFixedExceedsSubtotal =
      'Diskon nominal tidak boleh melebihi subtotal.';
  static const String discountFixedNegative =
      'Diskon nominal tidak boleh negatif.';
  static const String paymentInsufficient = 'Uang pembayaran kurang.';

  // Cashier UI Strings
  static const String stockAlreadyInCart = 'Stok sudah di keranjang';
  static const String addToCart = 'Tambah ke keranjang';
  static const String cartTitle = 'Keranjang';
  static const String viewCart = 'Lihat Keranjang';
  static const String subtotal = 'Subtotal';
  static const String discount = 'Diskon';
  static const String total = 'Total';
  static const String checkoutTitle = 'Pembayaran';
  static const String checkoutPlaceholderSubtitle =
      'Proses pembayaran tunai dan cetak struk (tersedia di slice 6).';
  static const String itemSuffix = 'item';
  static const String orderQuantityLabel = 'Jumlah Pesanan';
  static const String selectAddonPrompt = 'Pilih Add-on (Opsional)';
  static const String noAddonsSelected = 'Tanpa add-on';
  static const String maxStockReached = 'Mencapai batas stok';

  // Checkout & Receipt Strings
  static const String receiptTitle = 'Struk Pembayaran';
  static const String paymentSuccess = 'Pembayaran Berhasil';
  static const String cashReceivedLabel = 'Uang Diterima';
  static const String cashReceivedHint = 'Masukkan nominal uang';
  static const String changeLabel = 'Kembalian';
  static const String exactMoney = 'Uang pas';
  static const String paymentShortage = 'Uang kurang';
  static const String discountLabel = 'Diskon';
  static const String discountTypeRp = 'Rp';
  static const String discountTypePercent = '%';
  static const String discountHint = '0';
  static const String discountPercentHint = '0%';
  static const String payButton = 'Bayar';
  static const String finishButton = 'Selesai';
  static const String printButton = 'Cetak';
  static const String printerComingSoon = 'Fitur cetak printer akan hadir pada pembaruan berikutnya.';
  static const String invoiceNoLabel = 'No. Invoice';
  static const String cashierLabel = 'Kasir:';
  static const String dateLabel = 'Waktu:';
  static const String totalBill = 'Total Tagihan';
  static const String cashPayment = 'Tunai';
  static const String defaultStoreFooter = 'Terima kasih atas kunjungan Anda';

  // Logout & Session
  static const String logoutConfirmTitle = 'Konfirmasi Keluar';
  static const String logoutConfirmMessage =
      'Apakah Anda yakin ingin mengakhiri sesi kasir ini?';
  static const String userSessionTitle = 'Sesi Kasir Aktif';
  static const String userSessionStartTime = 'Waktu Sesi Dimulai';
  static const String userIdLabel = 'ID Pengguna';
}
