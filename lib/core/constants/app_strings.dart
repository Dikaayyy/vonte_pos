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
}
