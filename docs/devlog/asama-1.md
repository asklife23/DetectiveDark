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
