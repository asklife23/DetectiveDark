# Aşama 0 — Bağımsız kod incelemesi

- **Tarih:** 2026-11-13
- **Kapsam:** `phase-0` etiketi (`6809850`) ve sonrasındaki commit'ler (`79148d5`, `c827124`, `e544db7`).
  Önceki aşama etiketi olmadığı için deponun tamamı okundu.
- **Okunanlar:** `CLAUDE.md`, `plan.md`, `docs/game_design.md`, `docs/adr/0001–0011`, `docs/devlog/asama-0.md`,
  `lib/` ve `test/` altındaki bütün dosyalar, `.github/workflows/ci.yml`, `pubspec.yaml`, `analysis_options.yaml`,
  `.gitignore`, `env/`, `.run/`, Android / iOS / Windows proje dosyaları, `README.md`.

## Sonuç

Aşama 0 sağlam. **Kritik bulgu yok.** Katman kuralları, l10n, tema tokenları, flavor'lar ve CI planla uyumlu.
3 Önemli bulgu düzeltildi; 2 Önemli bulgu ve birkaç konu senin kararını bekliyor (en altta).

## Doğrulananlar

| Kontrol | Sonuç |
|---|---|
| `dart format .` | 41 dosya, 0 değişiklik |
| `flutter analyze` | 0 sorun |
| `flutter test` | 47/47 geçti (düzeltmelerden sonra da 47/47) |
| `flutter build apk --debug --flavor dev -t lib/main_dev.dart` | Derlendi (`app-dev-debug.apk`) |
| `flutter build windows -t lib/main_steam.dart` | Derlendi (`DetectiveDark.exe`) |
| GitHub Actions | Son 5 çalışma yeşil (`e544db7` dahil); iki iş de (kalite + Windows derlemesi) geçiyor |
| Gizli bilgi | Git geçmişinde `env/` altında yalnızca `example.json` var; anahtar, keystore, `key.properties` yok. Yereldeki `env/*.json` dosyaları takip edilmiyor ve Supabase değerleri boş |
| Katman kuralları | `lib/features/` henüz yok; `core/error` saf Dart (`equatable` dışında import yok); `app/` yalnızca `core/`'u import ediyor |
| Kullanıcıya görünen metin | Koddaki tek sabit metinler geliştirici etiketi (`debugLabel`) ve log mesajları; ekrandaki metinler `app_en.arb`'den geliyor |
| `print` | Yok; `AppLogger` kullanılıyor |
| Etiket | `phase-0` → `6809850`, uzak depoda da var. Dokunulmadı |

## Kritik

Yok.

## Önemli

### Ö1. README'yi izleyen kişi "DEV" etiketini göremiyordu — DÜZELTİLDİ (`d392edf`)
- **Dosya:** `README.md:56-68`, `README.md:76`, `env/example.json:4`, `lib/core/config/app_config.dart:29-37`
- **Sorun:** README "`env/example.json`'ı `env/dev.json` olarak kopyala" diyor. Şablonda `SHOW_DEBUG_OVERLAY: false`
  yazıyor ve `AppConfig`'te açıkça verilen değer dev varsayılanını ezer (`hasOverlayKey ? overlayValue : ...`).
  Yani depoyu klonlayıp README'yi izleyen kişi dev sürümünde etiketi görmez; README ise "varsayılan: dev'de açık"
  diyordu. Senin makinende `env/dev.json` elle `true` yapıldığı için fark edilmemiş.
- **Düzeltme:** README'ye şablonun değeri ve etiketi açmanın iki yolu yazıldı. Şablona dokunmadım: CI'daki Steam
  derlemesi onu kullanıyor ve ADR 0008 "şablon anahtarları belgeler" diyor.

### Ö2. "Flavor adları Android ile eşleşiyor" testi Android'e hiç bakmıyordu — DÜZELTİLDİ (`2d321c7`)
- **Dosya:** `test/core/config/app_config_test.dart:70-83`
- **Sorun:** Test `Flavor.values`'u kodda yazılı `['dev', 'staging', 'prod']` listesiyle karşılaştırıyordu.
  `build.gradle.kts`'te bir flavor yeniden adlandırılsa test yeşil kalır, uygulama ise açılışta
  `matchesBuildFlavor` kontrolüne takılırdı (`lib/app/bootstrap.dart:24-29`).
- **Düzeltme:** Test artık `android/app/build.gradle.kts`'teki `productFlavors` bloğunu okuyup adları oradan alıyor.

### Ö3. README, henüz kodda olmayan teknolojileri varmış gibi gösteriyordu — DÜZELTİLDİ (`759d477`)
- **Dosya:** `README.md:28-30`, `README.md:110`
- **Sorun:** Teknoloji tablosunda Drift ve Supabase yer alıyordu; ikisi de `pubspec.yaml`'da yok (Aşama 2 ve 3).
  Depoyu inceleyen bir işe alımcı için yanıltıcı.
- **Düzeltme:** İkisi "planned (Phase N)" olarak işaretlendi; CI satırına neyi kontrol ettiği yazıldı; devlog
  satırı diğerleri gibi bağlantı yapıldı.

### Ö4. Release derlemede yakalanan hatalar hiçbir yere yazılmıyor — KARAR BEKLİYOR
- **Dosya:** `lib/core/logging/app_logger.dart:29-37`, `lib/app/bootstrap.dart:48-60`,
  `docs/devlog/asama-0.md:36-37`
- **Sorun:** `AppLogger` yalnızca `dart:developer`'ın `log` fonksiyonuna yazıyor; bu fonksiyon release derlemede
  hiçbir şey yapmaz. `PlatformDispatcher.onError` ise hatayı "ele alındı" sayıp `true` döndürüyor. Sonuç: release
  derlemede yakalanmamış bir hata iz bırakmadan yutulur. Devlog'daki "hiçbir hata sessizce kaybolmaz" cümlesi
  yalnızca debug için doğru.
- **Neden şimdi önemli:** Çökme raporlama Aşama 9'da, ama yeni çalışma sırasına göre 10–15 kişilik oyun testi
  (7.4) ondan **önce**. Testçilerde oluşan hataları göremeyeceksin.
- **Neden dokunmadım:** Çözüm (release için ikinci bir log yazıcısı ya da çökme raporlamayı öne almak) planı ve
  paket seçimini etkiliyor. Aşağıda "Kullanıcı kararı bekleyen" K1.

### Ö5. CI Android flavor'larını hiç derlemiyor — KARAR BEKLİYOR
- **Dosya:** `.github/workflows/ci.yml:23-93`
- **Sorun:** CI'da Linux'ta format/analyze/test ve Windows derlemesi var; Android derlemesi yok. `build.gradle.kts`
  veya manifest'teki bir hata (ör. `appName` yer tutucusu) ancak telefonda çalıştırınca fark edilir. Yerelde
  `--flavor dev` derlemesini doğruladım; şu an çalışıyor.
- **Neden dokunmadım:** Plan 0.5 CI adımlarını tek tek sayıyor; yeni bir iş eklemek planı değiştirir (ve private
  depoda Actions kotasını etkiler, bkz. plan 7.0). Aşağıda K2.

## Küçük

1. **Framework hatalarında ayrıntı kayboluyor** — `lib/app/bootstrap.dart:49-55`. `FlutterError.onError`
   varsayılan `FlutterError.presentError`'ı çağırmıyor; log'a yalnızca `exceptionAsString()` gidiyor. Taşma
   (overflow) gibi hatalarda "hataya yol açan widget" ve yerleşim dökümü görünmez. Öneri: Aşama 1.4'te sahne
   yerleşimi yazılırken handler içinde `FlutterError.presentError(details)` de çağrılsın.
2. **Flavor uyuşmazlığı "hızlı başarısız" değil, "sessiz donma"** — `lib/app/bootstrap.dart:24-29`.
   `StateError` hata yakalayıcılar kurulduktan sonra fırlatılıyor; `PlatformDispatcher.onError` onu log'layıp
   yutuyor ve `runApp` hiç çağrılmıyor. Debug'da konsolda mesaj görünür, ekranda ise boş açılış ekranı kalır.
   Bu yol için test de yok (`appFlavor` global sabit olduğu için enjekte edilemiyor; parametre yapılırsa test
   edilebilir).
3. **`bootstrap()`'ın kendisi test edilmiyor** — `test/app/bootstrap_test.dart`. Yalnızca
   `registerErrorHandlers` test ediliyor; sıra (hata yakalayıcı → DI → `runApp`) ve `Bloc.observer` ataması
   doğrulanmıyor.
4. **`AppConfig.fromEnvironment` yalnızca tanımsız değerlerle test ediliyor** —
   `test/core/config/app_config_test.dart:9-29`. `SHOW_DEBUG_OVERLAY`'in açıkça verildiği dal (Ö1'deki hatanın
   dalı) hiç çalışmıyor. Öneri: CI'da `flutter test --dart-define-from-file=...` ile ikinci, küçük bir tur.
5. **Test klasörü `lib/`'i tam aynalamıyor** — `lib/app/router/app_router.dart` için
   `test/app/router/app_router_test.dart` yok (dolaylı olarak `test/app/app_test.dart:21-30` kapsıyor).
   `app_colors`, `app_durations`, `app_typography` tek dosyada (`test/core/theme/app_theme_test.dart`) test ediliyor.
6. **Sabiti kendisiyle karşılaştıran testler** — `test/core/theme/app_theme_test.dart:34-38` (150 ms),
   `test/core/logging/app_logger_test.dart:45-56` (`returnsNormally`). Zararsız ama davranış doğrulamıyor.
7. **`AppBlocObserver` release'te de metin üretiyor** — `lib/app/app_bloc_observer.dart:14-17`. Her durum
   değişiminde iki state'in `toString()`'i birleştiriliyor; release'te log yazılmasa da metin oluşturuluyor.
   Şimdilik ihmal edilebilir; Aşama 1'de `GameProgress` büyüyünce ölçülmeli.
8. **Bir dosyada birden fazla public sınıf** — `lib/core/theme/app_spacing.dart:2,12` (`AppSpacing`, `AppRadii`),
   `lib/core/theme/app_typography.dart:4,16` (`AppFonts`, `AppTypography`). CLAUDE.md bölüm 7 "küçük yardımcılar
   hariç" dediği için kabul edilebilir; not olarak yazıyorum.
9. **Token dışı sabit** — `lib/app/flavor_badge.dart:19` (`_alpha = 0.6`). Adlandırılmış ve yerel; ama
   CLAUDE.md'ye göre ölçüler `core/theme`'de durmalı.
10. **Android şablon yorumları duruyor** — `android/app/build.gradle.kts:19-20` ve `:51-53` (`TODO`, release
    derleme debug anahtarıyla imzalanıyor). Aşama 10.1'e kadar beklenen durum; `TODO`'ya "Phase 10.1" yazılabilir.
11. **Steam giriş noktası Android'de de derlenebiliyor** — `lib/main_steam.dart:10-12`,
    `lib/core/config/app_config.dart:66-67`. `--flavor prod -t lib/main_steam.dart` uyuşmazlık kontrolünden geçer
    ve telefonda `BuildTarget.steam` ile açılır. Platform servisleri gelince (Aşama 8/11) DI'da korunmalı.
12. **CI action'ları sürüm etiketiyle sabitli** — `.github/workflows/ci.yml:31,34,79,82` (`@v7`, `@v2`).
    Tedarik zinciri açısından commit SHA'sı daha güvenli; tek geliştiricili proje için kabul edilebilir.
13. **`cancel-in-progress` `main`'de de geçerli** — `.github/workflows/ci.yml:15-17`. Art arda push'larda önceki
    commit'in çalışması iptal olur ve o commit "iptal edildi" görünür.
14. **Doküman yazım farkları** — `plan.md:141` ve `CLAUDE.md:113` hâlâ `Success / Failure` diyor; kodda ve
    ADR 0001'de `Success / Failed` (sapma `plan.md:689`'da kayıtlı). `docs/devlog/asama-0.md:139` başlığı
    "Telefonda nasıl test edilir" yerine "Nasıl test edilir (Windows)" (içerik doğru).
15. **README henüz işe alımcıya hazır değil** — `README.md:14` (Features: "Coming soon"), `:34` (Architecture boş),
    `:114` (License: "To be decided"). Plan bunu 9.4'e bırakıyor; bkz. K3 ve K4.

## Olumlu bulgular

- `Result` / `Failure` sealed hiyerarşisi temiz; testler eşitliği ve kapsamlı `switch`'i gerçekten doğruluyor.
- `system_ui_test.dart` platform kanalını taklit edip çağrıların sırasını ve argümanlarını kontrol ediyor;
  `flavor_badge_test.dart` dokunmanın alttaki widget'a geçtiğini gerçekten test ediyor.
- CI'daki "üretilen kod güncel mi" kontrolü `git status --porcelain` ile yeni dosyaları da yakalıyor.
- `.gitignore` + `.gitattributes` eksiksiz; `permissions: contents: read` ile CI en az yetkiyle çalışıyor.
- Windows penceresi içerik alanını 16:9 tutuyor ve DPI'a göre ölçekliyor; şablondan sapma kaynakta işaretli.
- `plan.md` kutuları, "Notlar" bölümü, devlog ve ADR'ler kodla tutarlı.

## Kullanıcı kararı bekleyen

- **K1 (Ö4) — Release'te hata görünürlüğü.** Oyun testi (7.4) çökme raporlamadan (Aşama 9) önce. Seçenekler:
  (a) 9.1'i 7.4'ün önüne almak; (b) 7.4'ten önce `AppLogger`'a release'te yerel dosyaya yazan basit bir yazıcı
  eklemek ve testçilerden dosyayı istemek; (c) olduğu gibi bırakmak. Önerim (a) ya da (b). Plan değişikliği.
- **K2 (Ö5) — CI'a Android derlemesi.** `flutter build apk --debug --flavor dev` işi eklensin mi? Süre: çalışma
  başına birkaç dakika. Depo private olunca (7.0) Actions kotası sınırlı. Önerim: eklensin, yalnızca `android/`,
  `pubspec.*` veya `lib/main_*.dart` değişince çalışsın.
- **K3 — Lisans.** Depo public ve `LICENSE` dosyası yok; bu, hukuken "tüm hakları saklı" demek. Ticari bir oyun
  için bilinçli bir seçim olabilir; README'de "To be decided" yerine kararı yazmak gerekir.
- **K4 — Portföy hedefi ile 7.0 (repoyu private yapma) çelişkisi.** README'nin son hali 9.4'te, repo ise 7.0'da
  kapanıyor; yani public olduğu sürece README hep iskelet halinde. Aşama 1 bitince kısa bir README turu (ekran
  görüntüsü/GIF, mimari şeması) plana eklenebilir. Plan değişikliği.
- **K5 — `CLAUDE.md:113` ve `plan.md:141`'deki `Success / Failure` yazımı** `Success / Failed` olarak
  düzeltilsin mi? Kural ve plan dosyaları olduğu için dokunmadım.

## Bu incelemede yapılan commit'ler

| Commit | Mesaj |
|---|---|
| `2d321c7` | `test(config): read flavor names from the Gradle file` |
| `d392edf` | `docs(readme): explain the debug badge value in the env template` |
| `759d477` | `docs(readme): mark planned tech and link the devlog` |

Her biri kalite kapısından geçti (format 0 değişiklik, analyze 0 sorun, test 47/47).
