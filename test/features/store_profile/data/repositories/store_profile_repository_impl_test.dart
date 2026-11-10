import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vonte_pos/core/database/app_database.dart';
import 'package:vonte_pos/core/database/tables.dart';
import 'package:vonte_pos/features/store_profile/data/datasources/store_profile_local_data_source.dart';
import 'package:vonte_pos/features/store_profile/data/repositories/store_profile_repository_impl.dart';
import 'package:vonte_pos/features/store_profile/domain/entities/store_profile.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('StoreProfileRepository & Data Source (In-Memory Database)', () {
    late AppDatabase appDb;
    late Database db;
    late StoreProfileLocalDataSource dataSource;
    late StoreProfileRepositoryImpl repository;

    setUp(() async {
      appDb = AppDatabase.inMemory();
      db = await appDb.database;
      dataSource = StoreProfileLocalDataSourceImpl(appDb);
      repository = StoreProfileRepositoryImpl(dataSource);
    });

    tearDown(() async {
      await appDb.close();
    });

    test('simpan dan baca profil toko: membaca nilai awal lalu memperbarui dan membaca ulang', () async {
      // 1. Baca profil toko default yang dibuat saat migrasi database
      final initialProfile = await repository.getStoreProfile();
      expect(initialProfile.id, equals(1));
      expect(initialProfile.name, equals('Vonte PoS'));
      expect(initialProfile.address, equals('Jl. Bisnis No. 1'));
      expect(initialProfile.phone, equals('081234567890'));
      expect(
        initialProfile.receiptFooter,
        equals('Terima kasih atas kunjungan Anda'),
      );

      // 2. Simpan profil toko baru
      final updatedTarget = const StoreProfile(
        id: 1,
        name: 'Kopi & Roti Vonte',
        address: 'Jl. Malioboro No. 45',
        phone: '081298765432',
        receiptFooter: 'Terima kasih telah berbelanja!',
      );

      final saveResult = await repository.updateStoreProfile(updatedTarget);
      expect(saveResult.name, equals('Kopi & Roti Vonte'));
      expect(saveResult.address, equals('Jl. Malioboro No. 45'));
      expect(saveResult.phone, equals('081298765432'));
      expect(saveResult.receiptFooter, equals('Terima kasih telah berbelanja!'));

      // 3. Baca ulang dari database secara langsung untuk membuktikan persistence
      final refreshedProfile = await repository.getStoreProfile();
      expect(refreshedProfile.name, equals('Kopi & Roti Vonte'));
      expect(refreshedProfile.address, equals('Jl. Malioboro No. 45'));
      expect(refreshedProfile.phone, equals('081298765432'));
      expect(
        refreshedProfile.receiptFooter,
        equals('Terima kasih telah berbelanja!'),
      );

      final dbRows = await db.query(AppTables.storeProfile, where: 'id = 1');
      expect(dbRows.length, equals(1));
      expect(dbRows.first['name'], equals('Kopi & Roti Vonte'));
      expect(dbRows.first['address'], equals('Jl. Malioboro No. 45'));
      expect(dbRows.first['phone'], equals('081298765432'));
      expect(
        dbRows.first['receipt_footer'],
        equals('Terima kasih telah berbelanja!'),
      );
    });

    test('seeding tidak menggandakan data: hanya mengisi saat kosong dan menolak isi ulang', () async {
      // Pastikan katalog awal kosong
      final initialCats = await db.query(AppTables.categories);
      final initialProds = await db.query(AppTables.products);
      final initialAddons = await db.query(AppTables.addons);
      expect(initialCats, isEmpty);
      expect(initialProds, isEmpty);
      expect(initialAddons, isEmpty);

      // 1. Eksekusi pertama saat tabel masih kosong -> Berhasil mengisi (true)
      final firstSeedResult = await repository.seedSampleData();
      expect(firstSeedResult, isTrue);

      final catsAfterFirst = await db.query(AppTables.categories);
      final prodsAfterFirst = await db.query(AppTables.products);
      final addonsAfterFirst = await db.query(AppTables.addons);
      final pivotAfterFirst = await db.query(AppTables.productAddons);

      expect(catsAfterFirst.length, equals(3));
      expect(prodsAfterFirst.length, equals(5));
      expect(addonsAfterFirst.length, equals(4));
      expect(pivotAfterFirst.length, greaterThan(0));

      // Verifikasi contoh realistis kedai kopi & roti tanpa foto
      final prodNames = prodsAfterFirst.map((p) => p['name']).toList();
      expect(prodNames, contains('Kopi Susu Aren'));
      expect(prodNames, contains('Roti Bakar Cokelat Keju'));
      expect(prodNames, contains('Americano'));

      for (final prod in prodsAfterFirst) {
        expect(prod['photo_path'], isNull, reason: 'Data contoh tanpa foto');
        expect(prod['is_deleted'], equals(0));
      }

      // 2. Eksekusi kedua saat tabel SUDAH BERISI -> Ditolak (false) & jumlah data tidak bertambah
      final secondSeedResult = await repository.seedSampleData();
      expect(secondSeedResult, isFalse);

      final catsAfterSecond = await db.query(AppTables.categories);
      final prodsAfterSecond = await db.query(AppTables.products);
      final addonsAfterSecond = await db.query(AppTables.addons);
      final pivotAfterSecond = await db.query(AppTables.productAddons);

      // Pastikan TIDAK ADA DUPLIKASI DATA
      expect(catsAfterSecond.length, equals(3));
      expect(prodsAfterSecond.length, equals(5));
      expect(addonsAfterSecond.length, equals(4));
      expect(pivotAfterSecond.length, equals(pivotAfterFirst.length));
    });

    test('seeding berhasil jika produk dan add-on sebelumnya sudah di-soft-delete (is_deleted = 1)', () async {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;

      // 1. Simulasikan kondisi riil: pengguna pernah menghapus produk dan add-on (is_deleted = 1)
      // Di UI, kasir melihat daftar produk kosong ("Belum ada produk")
      await db.insert(AppTables.products, {
        'name': 'Produk Bekas Uji Coba',
        'price': 10000,
        'stock': 0,
        'is_deleted': 1,
        'created_at': now,
        'updated_at': now,
      });

      await db.insert(AppTables.addons, {
        'name': 'Addon Bekas Uji Coba',
        'price': 1000,
        'stock': 0,
        'is_deleted': 1,
      });

      // 2. Karena katalog aktif kosong, seeding harus diizinkan dan berhasil (isTrue)
      final seedResult = await repository.seedSampleData();
      expect(seedResult, isTrue);

      // Verifikasi produk aktif (is_deleted = 0) sekarang ada 5
      final activeProds = await db.query(
        AppTables.products,
        where: 'is_deleted = 0',
      );
      expect(activeProds.length, equals(5));
    });

    test('seeding berhasil jika kategori sudah ada namun belum ada produk aktif', () async {
      // Misal pengguna sebelumnya sudah membuat kategori 'Kopi'
      await db.insert(AppTables.categories, {'name': 'Kopi'});

      final seedResult = await repository.seedSampleData();
      expect(seedResult, isTrue);

      final activeProds = await db.query(
        AppTables.products,
        where: 'is_deleted = 0',
      );
      expect(activeProds.length, equals(5));

      // Pastikan kategori tidak duplikat
      final cats = await db.query(AppTables.categories);
      expect(cats.length, equals(3));
    });

    test('seeding ditolak jika sudah ada produk aktif di katalog', () async {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await db.insert(AppTables.products, {
        'name': 'Kopi Hitam',
        'price': 10000,
        'stock': 10,
        'is_deleted': 0,
        'created_at': now,
        'updated_at': now,
      });

      final seedResult = await repository.seedSampleData();
      expect(seedResult, isFalse);

      final activeProds = await db.query(
        AppTables.products,
        where: 'is_deleted = 0',
      );
      expect(activeProds.length, equals(1));
      expect(activeProds.first['name'], equals('Kopi Hitam'));
    });
  });
}

