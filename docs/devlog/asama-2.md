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

### Adım 2.2 — Sürümlü payload ve migration zinciri (2026-11-16)
- **Ne yaptık:** Kaydın JSON'una sürüm numarası koyduk ve eski sürümleri yenisine taşıyan zinciri kurduk; oyun hâlâ
  bellekteki kaydı kullanıyor (geçiş 2.3'te). Kaydın ilk anahtarı artık `schemaVersion` (şimdi 1). `SaveMigrator`
  bir fonksiyon listesidir: 0. eleman v1'i v2'ye, 1. eleman v2'yi v3'e çevirir; "güncel sürüm" = 1 + liste uzunluğu.
  Liste şimdilik boş, çünkü henüz tek sürüm var. `JsonSaveCodec` okurken üç adım atar: metni JSON'a çevir → migrator
  ile güncel sürüme taşı → `GameProgressDto` ile her alanı denetle. Ters giden her şey iki sonuçtan birine iner:
  `SaveTooNewFailure` (kayıt daha yeni bir oyun sürümünden) veya `SaveCorruptFailure` (okunamıyor). Oyun açılamadığında
  çıkan ekran bu ikisine göre farklı konuşur: "oyunu güncelle" ya da "kaydın kenara alındı, yeni oyun başlat".
  Geliştirici menüsüne iki simge düğmesi geldi: kaydı JSON olarak panoya kopyala, panodaki kaydı yükle.
- **Neden:** Oyun yayınlandıktan sonra kayıt şekli değişecek (yeni alan, yeniden adlandırma). Sürüm numarası olmazsa
  eski telefondaki kayıt yeni sürümde ya çöker ya sessizce yanlış okunur. Sürümle birlikte her eski kayıt adım adım
  güncele taşınır. Daha yeni sürümün kaydını okumayı reddetmek de aynı derecede önemli: eski derleme anlamadığı alanları
  atıp üzerine yazarsa oyuncunun ilerlemesi geri dönüşsüz bozulur. Panoya verme/alma ise hata bildirimleri için:
  test eden kişi "şurada takıldım" derken durumunu yapıştırır, biz aynı durumu bir dokunuşla yeniden kurarız.
- **Önemli dosyalar:** `lib/features/progress/data/migrations/` (`save_migrator.dart`, `json_save_codec.dart`,
  `save_exception.dart`), `lib/features/progress/domain/services/save_codec.dart`,
  `lib/features/progress/data/models/game_progress_dto.dart`, `lib/core/error/failure.dart`,
  `lib/app/game/game_status_views.dart`, `lib/app/dev/` (`dev_actions.dart`, `dev_menu_cubit.dart`, `dev_menu.dart`),
  `test/fixtures/saves/save_v1.json`.
- **Kayıt şeklini değiştirirken:** `migrations/` klasörüne `v1ToV2` fonksiyonunu yaz → `saveMigrations` listesinin
  **sonuna** ekle → `GameProgressDto`'yu yeni şekle getir → gerçek bir v1 kaydıyla test ekle. Listedeki bir elemanı
  asla düzenleme veya silme. `save_v1.json` dondurulmuş gerçek bir sürüm 1 kaydıdır: şekli yanlışlıkla değiştirirsen
  `json_save_codec_test.dart` "migration ekle" diyerek kırılır.
- **Telefonda nasıl test edilir:**
  `flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json` → geliştirici menüsünü aç →
  kopyala simgesine bas ("Save copied to the clipboard." görünür) → bir not uygulamasına yapıştır: `{"schemaVersion":1,`
  ile başlayan JSON'u gör → menüden bir eşya ekle → yapıştır simgesine bas: menü kapanır, eşya gitmiştir (kopyaladığın
  duruma döndün). Panoda rastgele bir metin varken yapıştır: "That did not work. See the log." çıkar, oyun değişmez.
  İki hata ekranı (güncelle / yeni oyun) 2.3'te kayıt diske yazılınca görülebilir; şimdilik `flutter test` → 900 test.
- **Öğrenme notu:** **Migration zinciri**, her biri yalnızca bir sürüm atlatan küçük fonksiyonlardan oluşur; v1 kaydı
  v3'e taşımak için v1→v2 ve v2→v3 sırayla çalışır, böylece her yeni sürümde yalnızca *bir* fonksiyon yazılır. Bu
  fonksiyonlar bilerek entity ile değil düz `Map` ile çalışır: bugünkü `GameProgress` sınıfında eski kaydın alanları
  artık yoktur, o yüzden eski şekli yalnızca ham JSON olarak tutabiliriz. **Saf fonksiyon** (aynı girdi → aynı çıktı,
  disk/saat yok) olmaları test etmeyi kolaylaştırır. Hata yolunda iki katman var: `data` içinde **exception**
  (`SaveException`; Drift dönüştürücüsü `Result` döndüremez, fırlatmak zorunda), `domain`'e çıkarken **`Failure`**.
  `sealed class` sayesinde `switch` bütün türleri saymak zorundadır: yeni bir hata türü eklersek derleyici ele almayı
  unuttuğumuz yeri gösterir. DTO'da `checked: true` ve bilinmeyen anahtarı reddetme de bilinçli: kayıt yarım okunmaz,
  ya tamamı geçerlidir ya da bozuk sayılır.

### Adım 2.3 — DriftProgressRepository ve otomatik kayıt (2026-11-16)
- **Ne yaptık:** Oyun artık ilerlemeyi diske yazıyor ve açılışta oradan devam ediyor. `DriftProgressRepository`,
  `InMemoryProgressRepository` ile **aynı arayüzü** (`ProgressRepository`) uygular; oyunun geri kalanı (use case'ler,
  bloc'lar, widget'lar) hiç değişmedi, yalnızca DI'daki kayıt değişti. `save` çağrılınca bellek hemen güncellenir ve
  cevap hemen döner; diske yazım 500 ms sonra yapılır ve o arada gelen değişiklikler tek satır olarak yazılır. Uygulama
  arka plana geçince (`SaveLifecycle` → `ProgressAutosave.onBackground`) bekleyen ne varsa anında yazılır; Windows'ta
  pencere kapanırken uygulama yazımı bekler. Oyun süresini `PlayTimeCounter` sayar: yalnızca uygulama ön plandayken.
  Açılışta bozuk kayıt `save_backups`'a taşınır ("yeni oyun" ekranı), daha yeni sürümün kaydına dokunulmaz ("oyunu
  güncelle" ekranı).
- **Neden:** Oyuncu uygulamayı kapatıp açınca kaldığı yerden devam etmeli. Her değişiklikte hemen yazmak yerine kısa
  bir bekleme, tek dokunuşun ürettiği birkaç kaydı tek yazıma indirir ve oyun diski hiç beklemez. Telefon, arka
  plandaki uygulamayı haber vermeden kapatabildiği için "arka plana geçtim" anı son güvenli yazma noktasıdır.
- **Önemli dosyalar:** `lib/features/progress/data/repositories/drift_progress_repository.dart`,
  `lib/features/progress/data/services/play_time_counter.dart`,
  `lib/features/progress/domain/services/progress_autosave.dart`, `lib/app/save_lifecycle.dart`,
  `lib/core/di/register_progress.dart`, `docs/adr/0019-autosave-memory-first-and-play-time.md`.
- **Telefonda nasıl test edilir:**
  `flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json` → heykelden anahtarı al, kapıyı
  aç, mektubu al → uygulamayı son uygulamalar listesinden kaydırarak tamamen kapat → yeniden aç: aynı sahnedesin, kapı
  açık, anahtar kullanılmış, mektup defterde, mesaj geçmişi yerinde. Sıfırdan başlamak için geliştirici menüsü → Reset.
  Windows'ta aynısı: `flutter run -d windows -t lib/main_dev.dart --dart-define-from-file=env/dev.json`; kayıt dosyası
  `%APPDATA%\asklife23\DetectiveDark\detective_dark_dev.sqlite`.
- **Öğrenme notu:** Bu adım **arayüze karşı programlamanın** karşılığını gösterdi: bütün oyun `ProgressRepository`
  arayüzünü tanıdığı için bellekteki depoyu veritabanıyla değiştirmek tek dosyada (`register_progress.dart`) kaldı.
  **Debounce/birleştirme:** sık gelen olayları bekletip tek işe indirmek; burada zamanlayıcı ilk değişiklikte kurulur
  ve sonrakiler onu *yeniden başlatmaz*, yoksa sürekli değişiklik yazımı sonsuza dek erteleyebilirdi. **Uygulama yaşam
  döngüsü** (`resumed` → `inactive` → `hidden` → `paused`): Flutter bunu `AppLifecycleListener` ile bildirir; `paused`
  bir telefonda "her an öldürülebilirim" demektir. **Monoton saat:** oyun süresi duvar saatiyle (`DateTime.now`) değil
  `Stopwatch` ile ölçülür; kullanıcı saati değiştirse veya yaz saatine geçilse bile süre bozulmaz. Bedeli de var
  (ADR 0019): `save` artık disk hatasını bildiremez; hata loglanır ve sonraki fırsatta yeniden denenir.
