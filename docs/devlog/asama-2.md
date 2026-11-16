# Aşama 2 — Kalıcı kayıt (devlog)

### Adım 2.1 — Drift kurulumu ve save_slots tablosu (2026-11-16)
- **Ne yaptık:** Oyunun yerel veritabanını kurduk; oyun henüz onu kullanmıyor (geçiş 2.3'te). `AppDatabase` (Drift /
  SQLite) iki tablo taşıyor: `save_slots` (kayıt yuvası) ve `save_backups` (okunamayan kaydın yedeği). `save_slots`
  satırı üç gruptan oluşur: ilerlemenin tamamı JSON olarak (`payload`), onun özeti (`caseId`, `chapterId`, `sceneId`,
  `playTimeSeconds`) ve bulut eşitleme sütunları (`localRevision`, `cloudRevision`, `isDirty`, zamanlar). SQL'in tamamı
  `SaveSlotsDao`'da: yuvayı oku, ilerlemeyi yaz (her yazışta `localRevision` bir artar), okunamayan yuvayı yedeğe
  taşı. `GameProgress` ↔ JSON dönüşümünü `GameProgressDto` yapar; `GameProgressConverter` bunu Drift'e bağlar, böylece
  kodun geri kalanı metin değil `GameProgress` görür. Ayrıca `deviceId` (ilk açılışta üretilen rastgele UUID,
  `shared_preferences`'ta) ve şema dökümü + şema testi eklendi.
- **Neden:** Oyuncu oyunu kapatıp açınca kaldığı yerden devam etmeli. Kayıt şekli geliştirme boyunca çok değişecek;
  SQLite + Drift bize hem tip güvenli sorgular hem de **migration** (eski veritabanını yeni şemaya taşıma) düzeni
  veriyor. Tek tablo + JSON seçimi bilinçli: oyun ilerlemeyi hep bütün olarak okur, o yüzden eşyaları, bayrakları ayrı
  tablolara bölmenin faydası yok; ama özet ve eşitleme sütunları ayrı durur ki JSON açılmadan okunabilsin ve bulut
  tablosu (Aşama 3) aynı şekli alsın. `writeProgress` daha yeni bir oyun sürümünün yazdığı yuvanın **üzerine yazmaz**:
  eski bir derleme, anlamadığı bir kaydı yok edemez.
- **Önemli dosyalar:** `lib/features/progress/data/datasources/local/` (`app_database.dart`, `save_tables.dart`,
  `save_slots_dao.dart`, `game_progress_converter.dart`, `save_database_connection.dart`),
  `lib/features/progress/data/models/game_progress_dto.dart`, `lib/core/device/device_id_provider.dart`,
  `lib/core/storage/key_value_store.dart`, `drift_schemas/app_database/drift_schema_v1.json`,
  `test/drift/app_database/schema_test.dart`, `build.yaml`.
- **Veritabanı dosyası nerede:** `<uygulama destek klasörü>/<ad>.sqlite`; ad `prod`'da `detective_dark`, diğerlerinde
  `detective_dark_dev` / `detective_dark_staging`.
  - Android: `/data/data/io.github.asklife23.detectivedark[.dev|.stg]/files/`
  - iOS: `<uygulama kabı>/Library/Application Support/`
  - Windows: `%APPDATA%\asklife23\DetectiveDark\` (Steam Cloud Aşama 11'de bu dosyayı eşitleyecek)
- **Tabloyu değiştirirken:** `AppDatabase.schemaVersion`'ı artır → `dart run drift_dev make-migrations` →
  `MigrationStrategy.onUpgrade`'e adımı yaz. Unutursan `schema_test.dart` kırılır (denedim: tabloya bir sütun ekleyip
  sürümü artırmayınca "Schema does not match" ile düştü).
- **Telefonda nasıl test edilir:** Bu adım ekranı etkilemiyor; oyun hâlâ bellekteki kaydı kullanıyor. `flutter test`
  → 846 test geçmeli. Tabloları görmek için `test/features/progress/data/datasources/local/save_slots_dao_test.dart`
  dosyasını oku.
- **Öğrenme notu:** **DAO** (Data Access Object) bir tablonun bütün sorgularını tek sınıfta toplar; repository SQL
  bilmez, DAO da oyun kurallarını bilmez. **TypeConverter**, bir sütunun veritabanındaki hali (metin) ile koddaki hali
  (`GameProgress`) arasındaki çevirmendir; yazarken `toSql`, okurken `fromSql` çalışır. **Transaction** birkaç sorguyu
  "ya hepsi ya hiçbiri" yapar: `moveSlotToBackup` kaydı önce yedeğe kopyalar, sonra yuvadan siler; araya uygulama
  kapanması girse bile kayıt ya eski yerinde ya yedekte olur, asla kaybolmaz. **İki ayrı sürüm numarası** var ve
  karıştırmamak önemli: Drift'in `schemaVersion`'ı *tabloların* şeklini (sütun ekle/sil), `payload`'ın içindeki sürüm
  ise *JSON'un* şeklini anlatır. Oyun geliştikçe çoğunlukla ikincisi değişecek (2.2). Testlerde veritabanı bellekte
  açılır (`NativeDatabase.memory()`): her test boş bir veritabanıyla başlar, diske hiçbir şey yazılmaz.
