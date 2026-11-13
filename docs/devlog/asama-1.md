# Aşama 1 — Oyun motoru (devlog)

### Adım 1.1 — Domain modelleri ve etkileşim kuralları (2026-11-13)
- **Ne yaptık:** Oyunun "dilini" saf Dart ile yazdık; ekranda henüz hiçbir şey değişmedi. Sahne, hotspot, koşul
  (`Condition`), etki (`Effect`), geçiş, overlay ve inceleme tanımları `scene_engine/domain/entities` altında.
  Dört saf servis yazdık: `ConditionEvaluator` (koşul doğru mu?), `InteractionResolver` (hangi kural çalışacak?),
  `SceneStackResolver` (Geri yığını) ve `EffectApplier` (etkileri uygula). İlerlemenin tamamı `GameProgress`'te;
  `ProgressRepository` arayüzünün tek yazma yolu `save`. Eşya ve not tanımları kendi feature'larında. Feature'lar
  arası haberleşme için `GameEventBus`, zaman için `Clock` eklendi.
- **Neden:** Bütün bulmacalar bu kural sisteminin üstünde duracak. Saf Dart olduğu için Flutter açılmadan, milisaniyeler
  içinde test edilebiliyor: kapı/anahtar senaryosunun bütün yolları (anahtarsız, yanlış eşyayla, doğru eşyayla, kapı
  açıkken) şimdiden testlerle korunuyor. `EffectApplier` hiçbir şeyi kaydetmez; sadece "bu etkilerden sonra ilerleme
  şöyle olur" der. Böylece bir kuralın bütün etkileri tek bir kayıt olur: anahtar tükenip kapının kapalı kalması gibi
  yarım bir durum oluşamaz.
- **Önemli dosyalar:** `lib/features/scene_engine/domain/entities/condition.dart`, `effect.dart`,
  `hotspot_definition.dart`, `lib/features/scene_engine/domain/services/interaction_resolver.dart`,
  `effect_applier.dart`, `lib/features/progress/domain/entities/game_progress.dart`,
  `lib/features/progress/domain/repositories/progress_repository.dart`, `lib/core/events/game_event.dart`,
  `test/architecture/dependency_rules_test.dart`.
- **Telefonda nasıl test edilir:** Bu adım ekranı etkilemiyor. Testleri çalıştır: `flutter test` → 124 test geçmeli.
  Kapı kurallarını görmek için `test/features/scene_engine/domain/services/interaction_resolver_test.dart`
  dosyasını oku; test adları senaryoyu cümle cümle anlatır.
- **Öğrenme notu:** **Saf fonksiyon**, aynı girdiye her zaman aynı çıktıyı veren ve dışarıda hiçbir şeyi
  değiştirmeyen fonksiyondur. `EffectApplier.apply(ilerleme, etkiler, bağlam)` böyledir: eski `GameProgress`'e
  dokunmaz, yenisini döndürür (`withItem`, `withFlag` gibi metotlar kopya üretir; buna *immutable* / değişmez veri
  denir). Kazancı üç tane: test yazmak çok kolaydır (mock gerekmez), hatalar tekrarlanabilir olur ve "kaydet" adımı
  tek bir yere toplanır. `sealed class` ise derleyiciye bütün koşul ve etki türlerini bildirir: yeni bir etki ekleyip
  `EffectApplier`'daki `switch`'e yazmayı unutursan kod derlenmez. Ayrıca `test/architecture` altındaki test, katman
  kurallarını (domain'de Flutter yok, feature başka feature'ın sadece domain'ini görür) import satırlarını okuyarak
  denetler; kural artık sadece yazılı değil, otomatik korunuyor.

### Adım 1.2 — İçerik formatı ve dikey dilim içeriği (2026-11-13)
- **Ne yaptık:** Oyunun içeriğini koddan ayırdık. `assets/content/` altında vaka (`case.json`), sahneler, eşyalar,
  notlar, incelemeler ve İngilizce metinler artık JSON dosyaları. Bu dosyaları okuyan veri katmanını yazdık: DTO
  sınıfları (`json_serializable` ile üretilen kod), koşul ve etkileri elle ayrıştıran `ConditionCodec` /
  `EffectCodec`, üç repository (sahne, eşya, not) ve hikaye metinlerini anahtarla veren `ContentTexts`. Dört sahnelik
  dikey dilimi yazdık: villa önü, kapı yakın planı, heykel yakın planı, hol. Son olarak içeriği baştan sona denetleyen
  `ContentValidator` ve onu gerçek dosyalar üzerinde çalıştıran içerik doğrulama testini ekledik.
- **Neden:** Hikaye ve bulmacalar koda dokunmadan yazılabilsin diye. Yeni sahne = yeni JSON + görsel. Ama JSON'da
  derleyici yok: yanlış yazılmış bir sahne ID'si ya da bayrak adı ancak oyuncu oraya gelince patlar. Doğrulama testi
  bu yüzden var; her push'ta bütün referansları, metin anahtarlarını, koordinatları, bayrakları ve sahnelere
  ulaşılabilirliği kontrol eder. Vaka bütün olarak yüklenir, çünkü Bölüm 1'de alınan eşya ya da not sonraki
  bölümlerde de gösterilecek.
- **Önemli dosyalar:** `assets/content/cases/case01/chapters/ch01/scenes.json`, `text_en.json`,
  `lib/features/scene_engine/data/models/scene_dto.dart`, `condition_codec.dart`, `effect_codec.dart`,
  `lib/features/scene_engine/data/repositories/asset_scene_content_repository.dart`,
  `lib/features/scene_engine/domain/services/content_validator.dart`, `lib/core/content/content_texts.dart`,
  `build.yaml`, `test/content/content_validation_test.dart`.
- **Telefonda nasıl test edilir:** Bu adım da ekranı etkilemiyor. `flutter test test/content` çalıştır: 5 test geçmeli.
  Denemek için `scenes.json`'da bir `goToScene` hedefini bilerek boz (`villa_hall` → `villa_hal`) ve testi tekrar
  çalıştır: test hangi sahnenin hangi hotspot'unda sorun olduğunu söyleyerek kırılır. Sonra geri düzelt.
- **Öğrenme notu:** **DTO** (Data Transfer Object), verinin dış dünyadaki biçimidir (burada JSON); **entity** ise
  oyunun kendi içindeki biçimi. İkisini ayırınca JSON'un şekli değişse bile domain kodu değişmez; dönüşüm tek yerde,
  `data` katmanındaki `toEntity()` metotlarında kalır. `json_serializable` düz alanlar için `fromJson` kodunu bizim
  yerimize üretir (`*.g.dart`); üretimi `dart run build_runner build` başlatır ve üretilen dosyalar commit edilir.
  `build.yaml`'daki `disallow_unrecognized_keys` ayarı önemli: `hotspots` yerine `hotspotz` yazarsan alan sessizce
  yok sayılmaz, hata olur. Koşul ve etkiler ise `{"flag": "x"}` gibi "anahtarın adı türü belirler" biçiminde olduğu
  için elle ayrıştırılır. Veri katmanı hata fırlatmaz; her sorunu dosya adıyla birlikte `ContentFailure` olarak döner.
