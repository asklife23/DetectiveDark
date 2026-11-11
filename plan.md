# DetectiveDark — Yol Haritası

Bu dosya projenin aşama aşama yol haritasıdır. Çalışma kuralları `CLAUDE.md`'de,
oyunun nasıl oynandığı `docs/game_design.md`'dedir. Claude her adımı bitirince ilgili kutuyu `[x]` yapar.

## Nasıl kullanılır

Android Studio terminalinde Claude'a yaz:

- `Aşama 0.1'i yap` → sadece o adım
- `Aşama 1'i yap` → aşamanın kalan tüm adımları (her adım ayrı commit)
- `Sıradaki adım` → ilk işaretlenmemiş adım
- `Durum` → ne bitti, sırada ne var
- `Açıkla 1.3` → o adımı tekrar anlat

---

## Kesinleşen kararlar

### Teknik
| Konu | Karar | Neden |
|---|---|---|
| Platform | Flutter; Android + iOS + Steam (Windows) | Tek kod tabanı, üç mağaza |
| Platform servisleri | Satın alma, hesap ve bulut kaydı arayüz arkasında; mobil ve Steam için ayrı uygulamalar | Oyun kodu ortak; platforma göre değişen tek katman |
| Oyun çizimi | Flutter widget'ları + `CustomPainter` (Flame yok) | Point-and-click sahneler statik katmanlardan oluşur; oyun döngüsüne gerek yok. Flutter'ın dokunma, yerleşim ve erişilebilirlik sistemi yeterli |
| Mimari | Feature-first Clean Architecture | Büyüdükçe düzen bozulmaz, test edilebilir, backend değişimi tek katmanda kalır |
| Durum yönetimi | `flutter_bloc` + `equatable` | Olay akışı açık ve izlenebilir, test araçları güçlü, sektörde yaygın |
| DI | `get_it` | Sade, kod üretimi gerektirmez |
| Yönlendirme | `go_router` (ekranlar), `SceneBloc` yığını (sahneler) | Sahneler oyun durumudur, URL rotası değil |
| Etkileşim | **Koşul + etki kuralları**, tamamen JSON'dan | Yeni bulmaca = yeni veri, yeni kod değil; 150+ sahneye ölçeklenir |
| Yerel veri | Drift (SQLite); ayarlar için `shared_preferences` | Migration sistemi, SQL bilgisi Supabase/FastAPI'ye aktarılır |
| Kayıt modeli | Tek tablo: özet + eşitleme sütunları + JSON payload; **tek kayıt yuvası** | Tek yol hikaye; yarım kayıt oluşmaz; bulut ile aynı şekil |
| Backend | Supabase (Auth + Postgres + RLS + Edge Functions) | Hazır kimlik ve veritabanı; açık kaynak |
| FastAPI | İleride, `CloudSaveRepository` arayüzü arkasına; Auth Supabase'de kalır | Geçiş tek veri kaynağı değişikliği olur |
| Giriş | Anonim başlangıç → Bölüm 1 sonunda Google/Apple bağlama önerisi | Oyuncu ilk açılışta form görmez |
| Çakışma | `revision` ile tespit; sadece gerçek çakışmada oyuncuya sor | Sessiz ilerleme kaybı olmaz |
| Ortamlar | `dev` / `staging` / `prod` flavor; 2 Supabase projesi | Gerçek oyuncu verisi testlerden ayrı |
| Sahne geçişi | Zoom yok. 150 ms siyaha kararma/açılma; kural bazında ayarlanabilir (`cut`, `holdMs`, `sfx`) | Noir hissi, göz yormaz, ses efektiyle uzatılabilir |
| Ekran yönü | Yatay kilitli, tam ekran; sahne 16:9 viewport | Point-and-click için doğal; koordinatlar her ekranda tutarlı |
| Diller | İlk çıkış sadece İngilizce (`en`); l10n altyapısı ilk günden, diğer diller sonra | Global pazar tek dille daha hızlı çıkar; altyapı hazır olduğu için yeni dil = yeni dosya |
| Lint | `very_good_analysis` | Sıkı kurallar, temiz kod |
| CI | GitHub Actions: format, analyze, test | Her push'ta otomatik kontrol, README'de rozet |
| Dil | Kod/commit/README/ADR İngilizce; açıklamalar, devlog ve oyun tasarımı Türkçe | Global CV + öğrenme |

### Oyun tasarımı (ayrıntı: `docs/game_design.md`)
| Konu | Karar |
|---|---|
| Oyuncu | Dedektifi yönetir; dedektif görünmez, iç sesiyle tek yönlü konuşur |
| Toplananlar | **Eşyalar** (sağ panel, kullanılır) ve **notlar** (not defteri: belgeler, gözlemler, şüpheliler) |
| Eşya kullanımı | Dokun-seç → hedefe dokun; yanlış yerde cezasız genel tepki |
| Bulmacalar | Eşya kullanma, şifre/kilit, kayıt inceleme; zincirleme |
| Hikaye | Tek yol; karakterler görünmez |
| Yapı | Tek vaka, 4 bölüm (B1 30–45 dk, B2–B4 45–60 dk); Vaka 2 ileride |
| Para (mobil) | Bölüm 1 ücretsiz; devamı ücretli; Vaka 2 ayrı ücretli |
| Para (Steam) | Bölüm 1 ücretsiz demo; Vaka 1 peşin ücretli; Vaka 2 DLC; reklam yok |
| Platformlar arası | İlerleme ve satın alımlar taşınmaz; mobil: Supabase hesabı, Steam: Steam Cloud |
| Final | 7 şüpheli; isim + 2–3 kanıt; 2 hak; sonra "Baştan oyna" / "Cevabı gör" |
| İnceleme | Sahneyi değiştirmeden küçük görsel + metin penceresi (`inspect` etkisi, ADR 0010) |
| Görseller | AI destekli; kritik yazı/sayılar görsele gömülmez, oyun üstüne çizer (overlay); ortak noir filtre (ADR 0011) |
| Sahne sayısı | Kesin değil; hikaye yazılırken belirlenir (tahmin: Bölüm 1 ~40–50) |

## Açık kararlar (ilgili aşamanın başında sorulacak)

| Aşama | Konu | Öneri |
|---|---|---|
| 5 | Kayıt inceleme biçimi | Kare dizisi + ses (ucuz, hafif); sanat yönüne göre video |
| 5 | İsim doğru, kanıt yetersizse hak düşer mi | Düşer; polis "kanıtlar zayıf" der |
| 6 | Ses kütüphanesi | `flutter_soloud` (düşük gecikme, oyun odaklı) veya `audioplayers` |
| 7 | Yön bulma (harita / mekan listesi) | İlk 15–20 sahne oynandıktan sonra ihtiyaca göre |
| 7 | Görsel üretim aracı (AI) ve ticari kullanım koşulları | Ticari kullanıma açık lisanslı araç; seçim stil denemeleriyle |
| 8 | Satın alma biçimi, fiyat, ipucu/reklam | Vaka 1'in kalanı tek satın alım; ipucu modeli test sonrası |
| 9 | Çökme raporlama / analitik | Sentry veya Firebase Crashlytics; minimal analitik |
| 10 | iOS derleme yolu | Mac veya bulut CI (Codemagic / GitHub Actions macOS) |
| 11 | Steam fiyatı, başarımlar | Fiyat benzer oyunlara göre; başarımlar sona bırakılır |
| 11 | PC'de imleç hotspot üzerinde değişsin mi | Tür standardı değişmesi; mobil ile denge düşünülerek |
| 11 | Steamworks API gerekli mi | Önce API'siz yollar (Auto-Cloud, DLC depot); gerekirse `steamworks` paketi |

---

## Aşama 0 — Proje temeli

**Neden:** Lint, ortamlar ve CI baştan kurulursa her satır kurallara uygun doğar.
Sonradan kurmak, yazılmış kodu toptan düzeltmek demektir.

### [x] 0.1 Proje sağlık kontrolü, Git ve GitHub
**Amaç:** Mevcut Flutter projesini incelemek ve sürüm kontrolünü kurmak.
**Yapılacaklar:**
- `flutter --version` ve `flutter doctor` çalıştır, sonucu özetle.
- `pubspec.yaml` proje adını, Android `applicationId`/`namespace` değerini, min/target SDK'yı raporla.
  `applicationId` mağazaya çıktıktan sonra **değiştirilemez**; kalıcı ve anlamlı değilse
  (ör. `com.example...`) yeni bir değer öner ve kullanıcı onayıyla değiştir.
- Flutter'ın varsayılan sayaç (counter) demo kodunu ve testini temizle.
- `.gitignore`: Flutter standardına ek olarak `env/*.json` (`!env/example.json`), `*.jks`, `*.keystore`,
  `key.properties`, `.env`, `coverage/`.
- Git yoksa `git init`, varsayılan dal `main`.
- **KULLANICI:** GitHub'da depo oluştur (CV için public önerilir). `gh` CLI kuruluysa Claude `gh repo create`
  ile yapabilir; değilse kullanıcı github.com'da oluşturup adresi verir. Uzak depo bağlanır.
- `README.md` iskeleti (İngilizce): proje tanımı, teknoloji yığını, nasıl çalıştırılır (sonra doldurulacak).
  **Kabul kriterleri:** Repo GitHub'da görünüyor; gizli dosya yok; uygulama telefonda hâlâ açılıyor.
  **Commit:** `chore: initialize repository and clean up template`

### [x] 0.2 Lint, klasör yapısı ve uygulama iskeleti
**Amaç:** Kod kalitesi kurallarını ve mimarinin iskeletini kurmak.
**Yapılacaklar:**
- `very_good_analysis` + `analysis_options.yaml` (`public_member_api_docs: false`; üretilen dosyalar analiz dışı).
- Paketler: `flutter_bloc`, `equatable`, `get_it`, `go_router`; dev: `bloc_test`, `mocktail`.
  Diğer paketler ilgili adımda eklenir.
- `CLAUDE.md` bölüm 3'teki klasör yapısını, klasörleri ilk dosyalarıyla birlikte oluşturarak kur
  (Git boş klasörü takip etmez; boş klasör açma).
- `app/app.dart` (`MaterialApp.router`), `app/bootstrap.dart` (hata yakalama: `FlutterError.onError`,
  `PlatformDispatcher.instance.onError`; `Bloc.observer`), `core/logging/app_logger.dart`,
  `core/error/result.dart` (`sealed class Result<T>`: `Success` / `Failure`) ve `Failure` türleri.
- Yatay yön kilidi ve tam ekran: `SystemChrome.setPreferredOrientations`, `SystemUiMode.immersiveSticky`,
  Android manifest `screenOrientation="sensorLandscape"`, iOS `Info.plist` yön ayarları.
  **Kabul kriterleri:** `flutter analyze` 0 sorun; uygulama yatay ve tam ekran açılıyor (boş koyu ekran).
  **Commit:** `chore: add lints, base packages and app skeleton`

### [x] 0.3 Ortamlar: dev / staging / prod
**Amaç:** Geliştirme, test ve gerçek oyuncu ortamlarını birbirinden ayırmak.
**Yapılacaklar:**
- Android `productFlavors`: `dev` (`.dev`, uygulama adı "DD Dev"), `staging` (`.stg`, "DD Staging"), `prod`.
- `lib/main_dev.dart`, `main_staging.dart`, `main_prod.dart` → `bootstrap(AppConfig)`.
- `core/config/app_config.dart`: `flavor`, `supabaseUrl`, `supabaseAnonKey`, `showDebugOverlay`.
  Değerler `String.fromEnvironment` ile `--dart-define-from-file`'dan okunur.
- `env/example.json` commit edilir; `env/dev.json`, `staging.json`, `prod.json` boş Supabase değerleriyle
  oluşturulur ve gitignore'da kalır (değerler Aşama 3'te dolacak).
- Android Studio çalıştırma yapılandırmaları `.run/` klasöründe paylaşılabilir dosyalar olarak
  (dev / staging / prod, tek tıkla çalışsın). Format güncel Android Studio ile doğrulanır; olmazsa
  kullanıcıya elle nasıl oluşturacağı anlatılır.
- Dev flavor'da ekranda küçük bir "DEV" etiketi.
  **Kabul kriterleri:** Üç flavor aynı telefona yan yana kurulabiliyor.
  **Commit:** `build: add dev, staging and prod flavors`

### [x] 0.4 Tema, yerelleştirme ve yönlendirme
**Amaç:** Görsel kimliğin ve yerelleştirme altyapısının temelini atmak.
**Yapılacaklar:**
- `core/theme/`: noir renk tokenları (koyu zemin, soluk amber/sepya vurgu, gece mavisi, soluk kırmızı uyarı),
  tipografi, boşluk ve süre sabitleri (`kSceneFadeDuration = 150 ms` vb.).
- Fontlar `assets/fonts/` içine paketlenir (internetten çalışma anında indirilmez; oyun offline çalışmalı):
  daktilo hissi veren bir başlık fontu + okunaklı bir gövde fontu. **Latin Extended** desteklemeli (ileride Türkçe,
  Almanca, İspanyolca vb. eklenebilsin); lisans OFL veya Apache 2.0, lisans dosyalarıyla.
- l10n: `flutter_localizations`, `intl`, `l10n.yaml`, sadece `app_en.arb`. Desteklenen diller ARB dosyalarından üretilen
  listeden gelir (tek kaynak); cihaz dili desteklenmiyorsa EN. Yeni dil = yeni `app_xx.arb`, kod değişmez.
  Flutter'ın güncel `gen-l10n` çıktı davranışını kontrol et; çıktı `lib/core/l10n/` altında olsun.
- `go_router`: şimdilik `/` → oyun ekranı. Splash ve menü Aşama 6'da.
  **Kabul kriterleri:** Örnek metin `app_en.arb`'den geliyor; telefon dili Türkçe olsa da EN gösteriliyor; tema ve
  fontlar uygulanmış.
  **Commit:** `feat(core): add noir theme, localization and routing`

### [x] 0.5 CI ve karar kayıtları
**Amaç:** Her push'u otomatik kontrol etmek ve verilen kararları belgelemek.
**Yapılacaklar:**
- `.github/workflows/ci.yml` (push ve PR'da): checkout → Flutter kurulumu (`subosito/flutter-action`, sürüm
  projede kullanılanla aynı) → `pub get` → `dart format --set-exit-if-changed .` → `flutter analyze` → `flutter test`.
- `build_runner` ve "üretilen kod güncel mi" (`git diff --exit-code`) adımları yorum satırı olarak hazır bekler;
  `build_runner` projeye eklendiğinde (adım 1.2) etkinleştirilir.
- ADR'ler (`docs/adr/`): 0001 architecture, 0002 state management (bloc), 0003 local database (drift),
  0004 backend (supabase + fastapi path), 0005 anonymous-first auth, 0006 sync and conflicts,
  0007 scene transitions, 0008 flavors. Gerekçeler "Kesinleşen kararlar" tablosundan.
  (0010 inspect ve 0011 overlay + noir filtre + AI görseller önceden yazıldı; 0009 adım 0.6'ya ayrılı.)
- README'ye CI rozeti; `docs/devlog/asama-0.md`.
  **Kabul kriterleri:** GitHub Actions yeşil.
  **Commit:** `ci: add GitHub Actions workflow` ve `docs: add architecture decision records`

### [x] 0.6 Windows masaüstü hedefi
**Amaç:** Steam sürümünün temelini baştan atmak; her özelliğin ilk günden Windows'ta da çalıştığından emin olmak.
Yan fayda: geliştirme sırasında telefonu bağlamadan bilgisayarda hızlı test.
**Yapılacaklar:**
- `flutter create --platforms=windows .` ile Windows hedefini ekle (mevcut dosyalara dokunmadan).
- **KULLANICI:** `flutter doctor` Windows için eksik gösterirse Visual Studio 2022 "Desktop development with C++"
  iş yükünü kur (Visual Studio Code değil).
- `lib/main_steam.dart` giriş noktası ve `env/steam.json` (gitignore'da; örneği `env/example.json`'da).
  `AppConfig`'e derleme hedefi (`mobile` / `steam`) eklenir.
- Pencere: başlık, 16:9 başlangıç boyutu, makul bir minimum boyut. Tam ekran ve çözünürlük ayarları Aşama 11'de.
- CI'a Windows derleme kontrolü (`windows-latest`, `flutter build windows`).
- ADR 0009: platform hedefleri ve platform servisleri yaklaşımı.
  **Kabul kriterleri:** `flutter run -d windows -t lib/main_dev.dart --dart-define-from-file=env/dev.json` ile uygulama
  Windows'ta açılıyor; CI'da Windows derlemesi yeşil.
  **Commit:** `build: add Windows desktop target`
  **Aşama sonu:** `phase-0` etiketi.

---

## Aşama 1 — Oyun motoru (oynanabilir dikey dilim)

**Neden:** Oyunun kalbi. Bu aşamada kurulan **koşul + etki sistemi**, ileride 150+ sahnenin ve tüm bulmacaların
üzerinde duracağı temel. Sahne sayısı koda bağlı değil: yeni sahne = yeni JSON + görsel.
İlerleme şimdilik bellekte tutulur (uygulama kapanınca sıfırlanır). Aşama 2'de kalıcı kayda geçerken arayüz kodu
**hiç değişmeyecek**; bu Clean Architecture'ın somut kanıtı olacak.

**Kabul senaryosu (aşamanın sonunda bu akış kusursuz çalışmalı):**
1. "Villa Önü" açılır, dedektif ilk yorumunu yapar. Ortada/solda Villa Kapısı, sağda Bahçe Heykeli. Geri butonu görünmez.
2. Kapıya dokun → 150 ms kararma → "Villa Kapısı" yakın planı. Geri butonu görünür.
3. Kilide dokun → dedektif: "Kilitli."
4. Geri → Villa Önü → Heykel → "Heykel Yakın Plan". Kulakta hafifçe parlayan bir anahtar var.
5. Anahtara dokun → anahtar sahneden kaybolur, sağ panele uçarak yerleşir; dedektif yorum yapar.
6. Paneldeki anahtara dokun (seçili olur) → heykelin kendisine dokun → genel tepki ("Bu burada işe yaramaz."), seçim kalkar.
7. Geri → Kapı yakın planı → anahtarı seç → kilide dokun → kapı **açık** görünüme geçer, anahtar panelden düşer,
   dedektif: "Açıldı."
8. Açık kapıya dokun → "Hol". Masadaki kağıda dokun → kağıt kaybolur, not defteri düğmesinde rozet belirir.
9. Not defterini aç → kağıdı oku.
10. Geri, Geri → Villa Önü → Heykel: anahtar **yok**. Kapı yakın planı: kapı **açık** kalmış.
11. Heykel yakın planında kaidedeki plakete dokun → sahne değişmeden **inceleme penceresi** açılır: plaket görseli,
    üstünde oyunun çizdiği kazıma yazı ve kısa bir metin. Geri → yalnızca pencere kapanır; bir daha Geri → Villa Önü.

### [ ] 1.1 Domain modelleri ve etkileşim kuralları
**Amaç:** Oyunun dilini saf Dart ile tanımlamak; bütün bulmacaların üzerine kurulacağı koşul + etki sistemini kurmak.
**Yapılacaklar:**
- `scene_engine/domain/entities`:
  - `SceneDefinition` (`id`, `parentId?`, `titleKey`, `visual`, `visualVariants`, `hotspots`, `onFirstEnter`)
  - `SceneVisual` (`background?` (asset yolu), `placeholderStyle`, `overlays`, `filterPreset?`)
  - `sealed class VisualOverlay` → `TextOverlay` (`rect`, `textKey`, `style`, `rotation?`): görsele gömülmeyen yazı ve
    sayılar (ADR 0011). Analog saat ibreleri gibi yeni türler bir bulmaca gerektirdiğinde (Aşama 5) eklenir.
  - `InspectionDefinition` (`id`, `titleKey?`, `textKey`, `visual: SceneVisual`): inceleme penceresinin içeriği (ADR 0010).
  - `VisualVariant` (`when`, `visual`): koşula göre görünüm (kapı açık/kapalı). İlk tutan kazanır, hiçbiri tutmazsa varsayılan.
  - `NormalizedRect` (`x`, `y`, `width`, `height`; 0–1 doğrulaması; `contains`)
  - `HotspotDefinition` (`id`, `rect`, `labelKey`, `visibleWhen?`, `interactions`)
  - `InteractionRule` (`when?`, `effects`)
  - `sealed class Condition` → `FlagSet`, `FlagNotSet`, `HasItem`, `UsingItem`, `HasNote`, `AllOf`, `AnyOf`
  - `sealed class Effect` → `GoToScene(sceneId, transition?)`, `GiveItem`, `ConsumeItem`, `AddNote`, `SetFlag`,
    `HideHotspot` (bu hotspot'u kalıcı gizler), `Say(messageKey)`,
    `Inspect(inspectionId)` (sahneyi değiştirmeden inceleme penceresi açar).
    `OpenPuzzle` ve `PlayMedia` Aşama 5'te eklenir.
  - `SceneTransition` (`type: fade|cut`, `fadeOutMs`, `holdMs`, `fadeInMs`, `sfx?`; varsayılan 150 / 0 / 150)
- `scene_engine/domain/services`:
  - `ConditionEvaluator` (saf fonksiyon: koşul + ilerleme + seçili eşya → bool)
  - `InteractionResolver` (hotspot + ilerleme + seçili eşya → çalışacak etki listesi). Kurallar:
    - Kurallar yukarıdan aşağı okunur, koşulu tutan **ilk** kural çalışır.
    - Seçili bir eşyayla dokunulduysa ve hiçbir kural o eşyayı (`usingItem`) karşılamıyorsa: yalnızca genel tepki
      (`Say(generic_item_no_effect)`). Yanlış eşya normal etkileşimi tetiklemez.
- `scene_engine/domain/repositories/scene_content_repository.dart` (abstract).
- `inventory/domain`: `ItemDefinition` (`id`, `nameKey`, `descriptionKey`, `iconStyle`, `iconAsset?`), `ItemCatalogRepository`.
- `notebook/domain`: `NoteDefinition` (`id`, `category: document | observation | suspect`, `titleKey`, `bodyKey`, `imageAsset?`),
  `NoteCatalogRepository`.
- `progress/domain`: `GameProgress` (`caseId`, `chapterId`, `sceneStack`, `inventory` (sıralı eşya ID'leri), `notes`
  (sıralı, zaman damgalı), `flags`, `hiddenHotspotIds`, `visitedSceneIds`, `chatLog`, `playTimeSeconds`) ve
  `ProgressRepository` (abstract): `watch()`, `current`, `addItem`, `removeItem`, `addNote`, `setFlag`, `hideHotspot`,
  `updateSceneStack`, `markVisited`, `appendChatMessage`. Ekleme işlemleri idempotent'tir.
- `core/events`: `sealed class GameEvent` → `SceneEntered(sceneId, isFirstVisit)`, `ItemObtained(itemId)`,
  `ItemUsed(itemId, hotspotId)`, `NoteAdded(noteId)`, `DetectiveSaid(messageKey)`; `GameEventBus` (broadcast stream).
- Unit testler: `ConditionEvaluator` (her koşul türü), `InteractionResolver` (kabul senaryosundaki kapı kurallarının
  tamamı: anahtarsız, yanlış eşyayla, doğru eşyayla, kapı açıkken; `Inspect` içeren kural), `NormalizedRect`,
  geçiş varsayılanları.
  **Kabul kriterleri:** `domain` klasörlerinde Flutter import'u yok; resolver testleri kapı/anahtar senaryosunu kapsıyor.
  **Commit:** `feat(scene_engine): add domain models and interaction rule system`

### [ ] 1.2 İçerik formatı ve dikey dilim içeriği
**Amaç:** Oyunu koddan ayırmak; hikaye ve bulmacalar koda dokunmadan JSON ile kurulabilsin.
**Yapılacaklar:**
- Yapı:
  ```
  assets/content/
    common/text_en.json                    # genel metinler (ör. generic_item_no_effect)
    cases/case01/
      case.json                            # bölümler ve her bölümün giriş sahnesi
      chapters/ch01/
        scenes.json  items.json  notes.json  inspections.json
        text_en.json                       # yeni dil = yeni text_xx.json
  ```
  Her dosyada `"formatVersion": 1`. Arayüz metinleri ARB'de, hikaye metinleri içerik dosyalarında.
- Paketler: `json_annotation`; dev: `json_serializable`, `build_runner`. CI'daki `build_runner` ve üretilen kod
  kontrolü adımlarını etkinleştir.
- `data/models` DTO'ları + entity dönüşümleri. Koşul ve etkiler JSON'da tek anahtarlı nesnelerdir
  (`{"flag": "front_door_open"}`, `{"giveItem": "brass_key"}`); bilinmeyen anahtar anlaşılır bir hatayla reddedilir.
  `AssetBundle` enjekte edilen veri kaynağı (test edilebilir).
- `core/content/`: aktif dile göre metni anahtarla veren servis (önce bölüm metinleri, sonra genel metinler).
- Dikey dilim içeriği (koordinatlar placeholder çizimlerle uyumlu ayarlanır):
  - `villa_exterior`: `door` → `villa_door_closeup`'a git; `statue` → `statue_closeup`'a git; ilk girişte dedektif yorumu.
    Kapı yanındaki numara plakası görsele çizilmez, `TextOverlay` olarak gelir.
  - `villa_door_closeup` (parent: `villa_exterior`): görünüm varyantı `front_door_open` bayrağına göre (açık/kapalı).
    `lock` hotspot'u: kapı açıksa → `villa_hall`'a git; `brass_key` kullanılırsa → bayrak + anahtarı tüket + "Açıldı";
    aksi halde → "Kilitli."
  - `statue_closeup` (parent: `villa_exterior`): `statue_key` → `GiveItem(brass_key)` + `HideHotspot` + yorum;
    `statue_body` → kısa yorum; `statue_plaque` → `Inspect(statue_plaque)` (plaket görseli + kazıma yazı overlay'i + metin).
  - `villa_hall` (parent: `villa_door_closeup`): `desk_paper` → `AddNote(hall_letter)` + `HideHotspot` + yorum.
  - `items.json`: `brass_key`. `notes.json`: `hall_letter` (document). `inspections.json`: `statue_plaque`.
  - Tüm metinler İngilizce; atmosferik, kısa.
- **İçerik doğrulama testi** (CLAUDE.md bölüm 9): referanslar (inceleme ID'leri dahil), metin anahtarları (desteklenen
  tüm dillerde), hotspot ve overlay koordinatları, "bir kuralda tek `inspect`, `goToScene` ile birlikte değil",
  "okunan her bayrak bir yerde set ediliyor mu" ve "her sahne bölümün giriş sahnesinden ulaşılabilir mi" (graf taraması).
  **Kabul kriterleri:** Tüm içerik yükleniyor; doğrulama testi geçiyor; bilerek bozulan bir ID veya yanlış yazılmış bir
  bayrak testi kırıyor.
  **Commit:** `feat(scene_engine): add JSON content format and vertical slice content`

### [ ] 1.3 Bellekte ilerleme, etki uygulama ve SceneBloc
**Amaç:** Oyun mantığını arayüzden bağımsız ve test edilebilir kurmak.
**Yapılacaklar:**
- `progress/data`: `InMemoryProgressRepository` (Aşama 2'de Drift ile değişecek).
- Use case'ler: `TapHotspot` (resolver + etkileri uygula), `ApplyEffects` (etkileri sırayla uygular: ilerleme
  değişiklikleri ve olay yayını; `GoToScene` gezinme isteği olarak döner), `GoBack`.
- `SceneBloc`:
  - Olaylar: `SceneStarted`, `HotspotTapped(hotspotId, usingItemId?)`, `BackPressed`, `TransitionCovered`, `TransitionFinished`.
  - Durum: `stack`, `currentScene`, `currentVisual` (varyant çözülmüş), `visibleHotspots` (`visibleWhen` ve gizlenenler
    uygulanmış), `transitionPhase` (`idle` / `covering` / `revealing`), `pendingTransition`, `canGoBack`,
    `activeInspection`.
  - İnceleme: `Inspect` etkisi `activeInspection`'ı doldurur; yeni olay `InspectionClosed`. Pencere açıkken hotspot
    dokunuşları yok sayılır; `BackPressed` önce pencereyi kapatır, yığına dokunmaz. İnceleme ilerlemeye yazılmaz.
  - İlerleme akışı (`watch()`) değiştikçe görünüm ve görünür hotspot'lar yeniden hesaplanır.
  - Geçiş zamanlaması arayüzdeki animasyondadır; Bloc yalnızca fazı tutar. Ekran tamamen karardığında arayüz
    `TransitionCovered` gönderir, Bloc sahneyi o an değiştirir.
  - Geçiş sürerken gelen dokunmalar yok sayılır.
  - Sahneye girişte: `markVisited`, `updateSceneStack`, `SceneEntered`; ilk ziyaretse `onFirstEnter` etkileri.
- `bloc_test`: kabul senaryosunun 1–11. adımlarının mantığı, geçiş sırasında çift dokunma, ana sahnede geri (etkisiz),
  inceleme açıkken Geri ve hotspot dokunuşu.
  **Kabul kriterleri:** Kabul senaryosunun tamamı testlerle doğrulanmış (henüz arayüz yok).
  **Commit:** `feat(scene_engine): add scene bloc with effect execution and navigation stack`

### [ ] 1.4 Sahne görünümü
**Amaç:** Sahneleri her ekranda doğru oranla çizmek ve dokunmaları almak.
**Yapılacaklar:**
- `SceneViewport`: verilen alana 16:9 oranını koruyarak sığar (contain); boşluklar koyu letterbox.
- Arka plan: `background` doluysa `Image.asset` (ekran boyutuna göre `cacheWidth`), boşsa `placeholderStyle`'a göre
  `CustomPainter`: villa cephesi, kapı yakın planı (kapalı ve açık), heykel yakın planı, hol (masa ve kağıt).
  Noir: gece mavisi/siyah, ay ışığı, sis katmanları. Görsel olarak anlaşılır ve şık olmalı. Gren ve vinyeti
  placeholder'lar değil ortak noir filtre çizer.
- `OverlayLayer`: `TextOverlay`'leri görselle aynı normalize koordinatlarla çizer; yazı `rect`'e sığacak şekilde
  ölçeklenir; stil preset'leri (`typewriter`, `handwriting`, `engraved`...) `core/theme`'de.
- `NoirFilter`: gren + vinyet + renk tonu; preset'ler `core/theme`'de, sahne `filterPreset` ile seçer. Uygulama yolu
  (`ColorFilter` matrisi + gradyan + gren dokusu ya da fragment shader) Android, iOS ve Windows'ta ölçülerek seçilir;
  gren varsayılan olarak statik. Katman sırası: arka plan → overlay → filtre → hotspot → geçiş.
- `InspectPanel`: sahnenin üstünde küçük pencere; görsel sahneyle aynı hattan çizilir (görsel + overlay + filtre),
  altında metin. Dışına dokun / kapat / Geri ile kapanır.
- Toplanabilir nesneler (anahtar, kağıt) sahnede hafifçe parıldar: dikkat çeker ama bağırmaz.
- `HotspotLayer`: normalize koordinat → piksel; şeffaf dokunma alanları; erişilebilirlik için `Semantics` etiketleri;
  dokunulan noktada kısa bir dalga efekti. Dev flavor'da açılıp kapanabilen **debug overlay**: hotspot dikdörtgenleri ve ID'leri.
- `TransitionOverlay`: siyah katman; `fadeOutMs` → `holdMs` → `fadeInMs`; `cut` tipinde anında.
- Arka plan (görsel + overlay + filtre) ve hotspot katmanı ayrı `RepaintBoundary`.
- Fare tıklaması dokunmayla aynı çalışır; Windows'ta farklı pencere boyutlarında da denenir.
  **Kabul kriterleri:** Kabul senaryosunun gezinme adımları telefonda ve Windows'ta çalışıyor; tablet emülatöründe ve
  yeniden boyutlanan pencerede hotspot'lar ve overlay yazılar kaymıyor, yazılar okunuyor; inceleme penceresi (adım 11)
  çalışıyor; filtre 60 fps hedefini bozmuyor.
  **Commit:** `feat(scene_engine): render scenes with viewport, overlays, noir filter, hotspots and transitions`
  ve `feat(scene_engine): add inspect panel`

### [ ] 1.5 HUD: Geri butonu, eşya paneli ve eşya kullanımı
**Amaç:** Sabit arayüzü ve "eşyayı al, doğru yerde kullan" hissini kurmak.
**Yapılacaklar:**
- `lib/app/game/game_screen.dart`: feature widget'larını birleştiren ekran (CLAUDE.md bölüm 3'teki `app/` kuralı).
  Solda sahne alanı, sağda sabit genişlikte eşya paneli, sol üstte Geri butonu.
- Geri butonu `canGoBack` iken görünür. Android sistem geri tuşu `PopScope` ile `BackPressed`'e bağlanır;
  ana sahnede "Çıkmak için tekrar bas" mesajı.
- `inventory/presentation`: `InventoryCubit` (ilerlemedeki eşyalar + katalog → sıralı liste; seçili eşya).
  Dokun → seç / tekrar dokun → bırak. Uzun bas → inceleme kartı (1.4'teki `InspectPanel` yeniden kullanılır).
- `GameScreen`, `HotspotTapped`'e seçili eşyayı ekler; dokunuştan sonra seçim temizlenir.
- `ItemSidebar`: dikey, yarı saydam koyu yüzey; seçili eşya belirgin çerçeve; boş durum metni.
- **Uçuş animasyonu:** Alınan nesne sahnedeki konumundan paneldeki yuvasına uçar (`Overlay` + `GlobalKey`;
  ~450 ms, `easeInOutCubic`), yuvaya oturunca kısa parlama. Tüketilen eşya panelden sönerek çıkar.
- Testler: `InventoryCubit` için `bloc_test` (seçim, tüketme); Geri butonu görünürlüğü için widget testi.
  **Kabul kriterleri:** Kabul senaryosunun 1–7. adımları telefonda çalışıyor (dedektif mesajları hariç).
  **Commit:** `feat(inventory): add item sidebar with selection, use and collect animation`

### [ ] 1.6 Not defteri
**Amaç:** Okunan her şeyin toplandığı ve ileride finalde kanıt seçilecek olan defteri kurmak.
**Yapılacaklar:**
- `notebook/presentation`: `NotebookCubit` (notlar, kategoriler, okunmamış sayısı).
- HUD'da defter düğmesi (eşya panelinin üstünde) + okunmamış rozeti.
- `NotebookScreen`: sekmeler **Belgeler / Gözlemler / Şüpheliler**; yatay ekrana uygun iki sütun (solda liste,
  sağda içerik); eski kağıt dokusu, daktilo başlıklar. Boş sekme için atmosferik boş durum metni.
- Not eklenince kağıt deftere uçar (eşya uçuş animasyonu yeniden kullanılır).
- Testler: `NotebookCubit` (ekleme, okundu işaretleme, kategoriler).
  **Kabul kriterleri:** Kabul senaryosunun 8–9. adımları çalışıyor.
  **Commit:** `feat(notebook): add notebook with documents, observations and suspects`

### [ ] 1.7 Dedektifin iç sesi
**Amaç:** Dedektifin oyuncuya konuştuğu mesaj katmanı (ileride ipucu sistemi de bunu kullanacak).
**Yapılacaklar:**
- `detective_chat/domain`: `ChatMessage` (`id`, `sender: detective | system`, `textKey`, `params`, `timestamp`). Tek yönlüdür.
- `ChatBloc`: `GameEventBus`'taki `DetectiveSaid` olaylarını dinler; mesajları `ProgressRepository.appendChatMessage`
  ile ilerlemeye yazar; okunmamış sayısını tutar.
- `ChatBar`: alt kenarda kompakt; son mesaj daktilo efektiyle yazılır (dokununca anında tamamlanır).
- `ChatHistorySheet`: dokununca açılan mesaj geçmişi.
- Testler: olay → mesaj; okunmamış sayısı; geçmiş sırası.
  **Kabul kriterleri:** Kabul senaryosunun tamamı (1–11) telefonda çalışıyor.
  **Commit:** `feat(detective_chat): add detective inner voice bar and history`

### [ ] 1.8 Uçtan uca test ve cila
**Amaç:** Aşamayı sağlam kapatmak.
**Yapılacaklar:**
- `integration_test`: kabul senaryosunun tamamı otomatik.
- Telefonda manuel kontrol listesi: hızlı çift dokunma, eşya seçiliyken Geri, sistem geri tuşu, arka plana alıp dönme, tablet oranı.
- Windows'ta aynı senaryo fareyle.
- `flutter run --profile` ile performans kontrolü (hedef: takılmasız 60 fps); sonuç devlog'a.
- README: mimari diyagramı (Mermaid), etkileşim sisteminin kısa anlatımı ve örnek JSON, nasıl çalıştırılır,
  ekran görüntüsü/GIF alanı (kullanıcı ekler).
  **Kabul kriterleri:** Tüm testler yeşil; CI yeşil.
  **Commit:** `test: add end-to-end vertical slice test`
  **Aşama sonu:** `phase-1` etiketi.

---

## Aşama 2 — Kalıcı kayıt (Drift, internetsiz)

**Neden:** Oyuncu uygulamayı kapatıp açtığında kaldığı yerden devam etmeli. Bu aşamada internet hiç kullanılmaz.

### [ ] 2.1 Drift kurulumu ve save_slots tablosu
**Yapılacaklar:**
- Paketler: `drift`, `drift_flutter`, `shared_preferences`, `uuid`; dev: `drift_dev`.
- `progress/data/datasources/local`: `AppDatabase`, `SaveSlots` tablosu, `SaveSlotsDao`, `GameProgressConverter`.
- Veritabanı dosyası her platformda bilinen, sabit bir klasörde durur (uygulama destek klasörü). Steam sürümünde
  Steam Cloud bu dosyayı eşitleyecek (Aşama 11); yol devlog'a yazılır.
- `SaveSlots` sütunları: `slotIndex` (PK), `ownerUserId?`, `schemaVersion`, `payload` (JSON, TypeConverter),
  özet (`caseId`, `chapterId`, `sceneId`, `playTimeSeconds`), eşitleme (`localRevision`, `cloudRevision?`, `isDirty`,
  `updatedAtUtcMs`, `lastSyncedAtUtcMs?`). Zamanlar UTC milisaniye.
- Drift şema sürümü 1; şema dökümü ve migration test altyapısı (Drift'in güncel `make-migrations` akışı).
- `deviceId`: ilk açılışta UUID üretilir, `shared_preferences`'ta saklanır.
- DAO testleri bellek içi veritabanıyla.
  **Commit:** `feat(progress): add drift database and save slots table`

### [ ] 2.2 Sürümlü payload ve migration zinciri
**Yapılacaklar:**
- `GameProgressDto` (JSON), payload `schemaVersion = 1`. Kayıtta metin değil sadece ID'ler, bayraklar ve anahtarlar tutulur.
- `SaveMigrator`: `v1 → v2 → ...` zinciri (saf Dart fonksiyonları).
- Kayıt sürümü desteklenenden yeniyse `SaveTooNewFailure`: kayıt okunmaz, **üzerine yazılmaz**,
  kullanıcıya "Oyunu güncelle" mesajı.
- Bozuk JSON: kayıt silinmez, yedeklenir; oyuncuya yeni oyun önerilir.
- Unit testler: her senaryo için.
  **Commit:** `feat(progress): add versioned save payload with migrations`

### [ ] 2.3 DriftProgressRepository ve otomatik kayıt
**Yapılacaklar:**
- `DriftProgressRepository`, aynı `ProgressRepository` arayüzüyle. DI'da **tek satır** değişir; arayüz kodu değişmez
  (commit gövdesinde ve devlog'da vurgula).
- Otomatik kayıt: her ilerleme değişikliğinde (yakın değişiklikler ~500 ms içinde birleştirilir);
  `AppLifecycleState.paused`'da anında yazım. Her yazışta `localRevision++`, `isDirty = true`, `updatedAtUtcMs`.
- `playTimeSeconds` sadece uygulama ön plandayken sayar.
- Açılışta kayıt varsa sahne yığını, eşyalar, notlar, bayraklar, gizlenen hotspot'lar ve chat geçmişi geri yüklenir.
  **Commit:** `feat(progress): persist game progress with autosave`

### [ ] 2.4 Testler
**Yapılacaklar:**
- Repository testleri; kapat-aç senaryosu (aynı veritabanını okuyan yeni repository örneği).
- Manuel: uçak modunda oyna → uygulamayı tamamen kapat → aç → her şey yerinde (kapı açık, anahtar kullanılmış, not defterde).
  **Aşama sonu:** `phase-2` etiketi.

---

## Aşama 3 — Supabase ve kimlik

**Neden:** Buluta yedekleyebilmek için sunucunun oyuncuyu tanıması gerekir.
**Kapsam:** Mobil sürüm. Steam sürümünde hesap ve Supabase kullanılmaz; kayıt Steam Cloud ile korunur (Aşama 11).
Bu aşamadaki kod platform servisi arayüzlerinin arkasında kalır.

### [ ] 3.1 Supabase projeleri ve veritabanı şeması
**Yapılacaklar:**
- **KULLANICI:** supabase.com'da iki proje: `detectivedark-staging` ve `detectivedark-prod`
  (bölge: oyunculara yakın, ör. Frankfurt). URL ve anon/publishable anahtarı `env/*.json` dosyalarına yazar.
- **KULLANICI:** Supabase CLI kurulumu (Windows: `npx supabase` veya scoop). `supabase init`, `supabase link`.
  Yerel Supabase (`supabase start`) Docker ister ve opsiyoneldir.
- `supabase/migrations/<zaman>_create_save_games.sql`:
  - `save_games`: `user_id` (auth.users'a bağlı, kullanıcı silinince kayıtları da silinir), `slot_index`,
    `payload jsonb`, `schema_version`, `revision`, `device_id`, `updated_at`; birincil anahtar `(user_id, slot_index)`.
  - RLS: her işlem yalnızca `auth.uid() = user_id` için.
  - `upsert_save(...)` fonksiyonu: **atomik karşılaştır-ve-yaz**. Buluttaki `revision` beklenene eşitse yazar ve
    yeni `revision`'ı döndürür; değilse çakışma bilgisini (mevcut kayıt özeti) döndürür.
- `supabase db push` ile önce staging'e. Prod'a sadece yayın sürecinde.
- SQL'in her bölümü devlog'da satır satır açıklanır.
  **Commit:** `feat(backend): add save_games table with RLS and upsert function`

### [ ] 3.2 Anonim giriş
**Yapılacaklar:**
- Paket: `supabase_flutter`; başlatma `bootstrap`'te, config'ten. İnternet yokken başlatma oyunu bekletmez.
- `auth/domain`: `AppUser` (`id`, `isAnonymous`, `providers`), `AuthRepository`.
- Akış: oturum yoksa ve internet varsa anonim giriş; yoksa oyun yine açılır, internet gelince tekrar denenir.
  Başarılı girişte sahipsiz yerel kayıt bu kullanıcıya atanır (`ownerUserId`).
- **KULLANICI:** Panelde Anonymous sign-ins ve manual identity linking açılır; kötüye kullanıma karşı
  hız sınırları gözden geçirilir.
  **Commit:** `feat(auth): add anonymous-first authentication`

### [ ] 3.3 Google / Apple bağlama, giriş ve hesap silme
**Yapılacaklar:**
- Paketler: `google_sign_in` (güncel API ile), `sign_in_with_apple`, `crypto` (nonce).
- **Hesabı bağla:** anonim kullanıcıya `linkIdentityWithIdToken`. Kullanıcı kimliği değişmez, kayıtlar korunur.
- **Hesabım var, giriş yap:** silip yeniden yükleyen oyuncu içindir. Google hesabı zaten başka bir kullanıcıya
  bağlıysa bağlama değil giriş yapılır (`signInWithIdToken`); bulut kaydı Aşama 4'teki akışla gelir.
- **KULLANICI:** Google Cloud Console OAuth istemcileri (her flavor/imza için Android SHA-1, Web client ID) ve
  Supabase Google sağlayıcı ayarı. Apple tarafı Apple Developer hesabı ister: kod hazırlanır, iOS testi Aşama 10'da.
- Geçici hesap ekranı (Aşama 6'da ayarlarla birleşir): durum (Misafir / Google ile bağlı), "İlerlemeni güvenceye al",
  "Hesabım var", "Hesabı sil".
- **Hesap silme** (iki mağazada da zorunlu): Supabase Edge Function `delete-account` (secret anahtar sadece
  fonksiyon ortamında) → kullanıcı ve kayıtları silinir; yerel veriler temizlenir.
  **Commit:** `feat(auth): link Google and Apple identities and add account deletion`
  **Aşama sonu:** `phase-3` etiketi.

---

## Aşama 4 — Bulut eşitleme

**Neden:** "İnternet gelince buluta eşitlensin" ve "silip yükleyince ilerleme geri gelsin" hedefleri burada tamamlanır.
**Kapsam:** Mobil sürüm. Steam sürümünde `SyncService` kayıtlı değildir.

### [ ] 4.1 CloudSaveRepository
**Yapılacaklar:**
- `sync/domain`: `CloudSaveRepository` → `fetch(slot)` → `CloudSave?`; `push(slot, payload, expectedRevision)` →
  `PushResult` (`Pushed(newRevision)` | `Conflict(cloudSave)`).
- `sync/data`: `SupabaseCloudSaveDataSource` (`upsert_save` çağrısı); ağ / yetki / sunucu hatalarının `Failure`'a eşlenmesi.
- Testler sahte istemciyle.
  **Commit:** `feat(sync): add cloud save repository backed by Supabase`

### [ ] 4.2 SyncService
**Yapılacaklar:**
- Paket: `connectivity_plus`.
- Tetikleyiciler: açılış, uygulama öne gelince, otomatik kayıttan ~5 sn sonra, bağlantı değişince.
  Aynı anda tek eşitleme çalışır.
- **Push:** `isDirty` ve sahip mevcut kullanıcıysa `push(expected = cloudRevision)`. Başarıda korumalı güncelleme:
  `isDirty` sadece gönderilen `localRevision` hâlâ güncelse temizlenir (gönderim sırasında yapılan kayıt kaybolmaz).
- **Pull:** Buluttaki `revision` yereldekinden yeniyse ve yerel kirli değilse indir, migrate et, yerele yaz.
  İkisi de değişmişse çakışma.
- Hata: artan aralıklarla tekrar deneme (2 sn, 4 sn, 8 sn ... en fazla 5 dk).
- Eşitleme durumu (eşitlendi / bekliyor / çevrimdışı) ayarlar ekranında gösterilecek şekilde akış olarak sunulur.
  **Commit:** `feat(sync): add background sync service with retry`

### [ ] 4.3 Geri yükleme ve çakışma ekranı
**Yapılacaklar:**
- Silip-yükleme akışı: yeni kurulum → "Hesabım var" → bulut kaydı indirilir → kaldığı sahneden devam.
- Çakışma diyaloğu: iki kartta özet (bölüm, sahne, not sayısı, oynama süresi, tarih); seçilen kazanır.
- Seçilmeyen kayıt silinmeden önce `save_backups` tablosuna tek kopya olarak yazılır.
  Bu, Drift şemasını v2'ye taşır: migration sistemini gerçek bir değişiklikle deneme fırsatı.
  **Commit:** `feat(sync): restore progress after reinstall and resolve conflicts`

### [ ] 4.4 Senaryo testleri
**Yapılacaklar:**
- Otomatik (sahte bulutla): offline oyna → online push; yeniden kurulum → pull; iki cihaz → çakışma;
  push sırasında yeni kayıt → kirli kalır.
- Manuel (telefon + emülatör, staging): uçak modu, silip yükleme, iki cihaz.
  **Aşama sonu:** `phase-4` etiketi.

---

## Aşama 5 — Bulmacalar ve vaka akışı
*(Başlarken: açık kararları sor, adımları Aşama 1 seviyesinde detaylandır, onay al.)*

**Neden:** Oyunu "sahne gezme"den "dedektif oyunu"na çeviren aşama: kilitler, kayıtlar, bölümler ve final.

- [ ] 5.1 Bulmaca altyapısı: `OpenPuzzle` etkisi, `PuzzleDefinition` (tür, çözüm, `onSolved` etkileri), ortak bulmaca çerçevesi (aç, dene, kapat).
- [ ] 5.2 Kilit bulmacaları: rakamlı tuş takımı, döner kombinasyon kilidi, saat kadranı, harf kilidi. Hepsi JSON'dan.
- [ ] 5.3 Kayıt inceleme (`PlayMedia`): oynat / durdur / kare kare, ekranda zaman damgası; biçim kararı (kare dizisi veya video).
- [ ] 5.4 Bölüm akışı: `case.json`'da bölüm bitiş koşulları, gerilimli bölüm sonu ekranı, Bölüm 1 sonunda hesap bağlama önerisi,
  bölüm kilidi için `EntitlementRepository` arayüzü (dev'de hepsi açık; mobil satın alma Aşama 8'de,
  Steam sahipliği Aşama 11'de).
- [ ] 5.5 Suçlama: 7 şüpheli; isim + 2–3 kanıt (not defterinden); doğru cevap ve geçerli kanıtlar `case.json`'da;
  2 hak; sonra "Vakayı baştan oyna" / "Cevabı gör"; paylaşılabilir sonuç ekranı (deneme sayısı, süre, ipucu sayısı).
- [ ] 5.6 İpucu sistemi: ilerlemeye göre bağlamsal, kademeli ipuçları (yön → net → cevap); uzun hareketsizlikte
  dedektifin kendiliğinden yönlendirmesi. İpucu tanımları JSON'da, koşullarla.

## Aşama 6 — Oyun hissi ve uygulama kabuğu
*(Başlarken: açık kararları sor, adımları detaylandır, onay al.)*

- [ ] 6.1 Ses: ambiyans döngüsü, efektler, geçişlerde `sfx` + `holdMs` (karanlık ses bitene kadar uzayabilir), ses ayarları, arka planda susma.
- [ ] 6.2 Dokunsal geri bildirim ve mikro animasyonlar.
- [ ] 6.3 Uygulama ikonu, açılış ekranı (native splash), ana menü (Devam / Yeni Oyun / Ayarlar), yeni oyun onayı.
- [ ] 6.4 Ayarlar: ses, dil (birden fazla dil desteklendiğinde), hesap ve eşitleme durumu, gizlilik politikası bağlantısı, sürüm bilgisi.
- [ ] 6.5 Performans ve erişilebilirlik: komşu sahnelerin önceden yüklenmesi, kullanılmayan görsellerin bellekten atılması,
  bellek ölçümü, yazı ölçeği, kontrast.

## Aşama 7 — Hikaye, içerik ve görseller
*(Başlarken: açık kararları sor, adımları detaylandır, onay al.)*

- [ ] 7.1 Vaka 1 kurgusu (kullanıcıyla birlikte): olay, kurban, 7 şüpheli, gerçek çözüm, bulmaca zinciri, bölüm kapanışları.
  Sonuç `docs/story/` altında.
- [ ] 7.2 Dev flavor'da hotspot ve overlay editörü: hotspot ve yazı (overlay) dikdörtgenlerini sürükleyip koordinatları
  JSON'a kopyalayan mini araç (çok sahneli bölümler için şart).
- [ ] 7.3 Sanat yönü ve **AI destekli** üretim hattı (ADR 0011): araç seçimi ve ticari kullanım koşulları; stil rehberi
  (palet, ışık, dönem, kompozisyon, prompt şablonları, referans görseller); görsellerde yazı/sayı olmaması (prompt +
  elle temizlik; kritik yazılar overlay); yakın planları ana görselden kırpma/inpainting ile tutarlılık; noir filtre
  preset'lerinin gerçek görsellerle ayarı; çözünürlük ve boyut bütçesi (WebP); placeholder → `background` geçişi.
  Her görsel için üretim kaydı (araç, model, tarih, prompt, elle yapılan düzenlemeler): `docs/art/ai-usage.md`
  (Steam AI açıklamasının kaynağı, bkz. 11.5).
- [ ] 7.4 Bölüm 1 içeriği (sahne sayısı hikayeyle belirlenir; tahmin ~40–50, inceleme pencereleri yakın plan
  ihtiyacını azaltır) ve oyun testi; yön bulma (harita / mekan listesi) kararı.
- [ ] 7.5 Bölüm 2–4 içeriği.

## Aşama 8 — Para kazanma (mobil)
*(Başlarken: açık kararları sor, ADR yaz.)*

- [ ] 8.1 Model ayrıntıları: Vaka 1'in kalanı için satın alma biçimi, fiyat, ipucu/reklam kararı; ADR.
- [ ] 8.2 Satın alma altyapısı (RevenueCat önerisi): ürünler, yetkiler, "Satın alımları geri yükle" (iOS zorunlu).
- [ ] 8.3 (Seçilirse) Ödüllü reklam + GDPR/KVKK onay formu + iOS izleme izni.
- [ ] 8.4 `EntitlementRepository`'nin mobil uygulaması: yetki mağazadan doğrulanır; yerel kayıt sadece önbellek.

## Aşama 9 — Kalite ve gözlem
*(Başlarken: açık kararları sor, adımları detaylandır, onay al.)*

- [ ] 9.1 Çökme raporlama (flavor bazlı, kişisel veri gönderilmez).
- [ ] 9.2 Minimal analitik: bölüm tamamlama, takılınan bulmacalar, suçlama sonuçları.
- [ ] 9.3 Golden testler (HUD, panel, not defteri), test kapsamı raporu.
- [ ] 9.4 Kod kalitesi turu ve README'nin son hali (GIF, diyagram, kurulum, testler).

## Aşama 10 — Mobil yayın
*(Başlarken: açık kararları sor, adımları detaylandır, onay al.)*

- [ ] 10.1 Android imzalama: upload keystore (kullanıcı saklar, repoya girmez), Play App Signing.
- [ ] 10.2 Gizlilik politikası ve uygulama dışı hesap silme sayfası (ör. GitHub Pages).
- [ ] 10.3 Play Console: mağaza kaydı, Data safety, içerik derecelendirmesi, hedef API seviyesi kontrolü,
  kapalı test (en az 12 kişi, 14 gün kesintisiz; yedek kişi ekle), üretime başvuru.
- [ ] 10.4 iOS: Apple Developer Program, iOS flavor/scheme, Sign in with Apple, App Store Connect, TestFlight.
- [ ] 10.5 Supabase prod → Pro plan, prod migration'ları, yedekler; sürüm numaralandırma, CHANGELOG, release etiketleri.
- [ ] 10.6 Yayın sonrası: çökme takibi, yorumlar, güncelleme planı.

## Aşama 11 — Steam (Windows)
*(Başlarken: açık kararları sor, adımları detaylandır, onay al.)*

**Neden:** Bu tür PC'de güçlü bir kitleye sahip; Steam'de peşin ücretli satış ve Bölüm 1 demosu doğal bir model;
yayıncıların çoğu PC'den yayın yapar. Oyun kodu ortak olduğu için bu aşama çoğunlukla platform servisleri,
PC deneyimi ve mağaza işleridir.

**Zamanlama notu:** Steam'de istek listesi (wishlist) toplamak aylar sürer. 11.1 ve 11.5'in mağaza sayfası kısmı,
gerçek görseller hazırlanırken (Aşama 7) öne alınabilir; Bölüm 1 hazır olunca demo yayınlanabilir.

- [ ] 11.1 **KULLANICI:** Steamworks hesabı, vergi ve banka bilgileri, oyun başına $100 Steam Direct ücreti
  (oyun $1.000 gelire ulaşınca geri ödenir). Uygulama kimlikleri: oyun, demo, Vaka 2 DLC.
  Ücret ödendikten sonra yayın için bekleme süresi ve en az 2 hafta "Yakında" sayfası şartı var; takvime yazılır.
- [ ] 11.2 PC deneyimi: pencere / tam ekran, çözünürlük ve yüksek DPI, klavye kısayolları (`Esc` = geri / menü),
  fare imleci davranışı, ayarlar ekranına görüntü seçenekleri.
- [ ] 11.3 Steam platform servisleri: sahiplik ve DLC kontrolü (önce API gerektirmeyen yol: DLC içeriği ayrı
  depot olarak yalnızca sahibine yüklenir), kayıt için Steam Auto-Cloud (Drift dosyasının yolu tanımlanır),
  Steam sürümünde Supabase hesap/eşitleme kapalı. Steamworks API gerekirse `steamworks` Dart paketi değerlendirilir
  (yalnızca Windows; olgunluğu kontrol edilir).
- [ ] 11.4 (Opsiyonel) Başarımlar ve Steam arayüz katmanı (overlay) kontrolü.
- [ ] 11.5 Mağaza: sayfa görselleri, fragman, açıklama (EN; diğer diller oyuna eklendikçe), "Yakında" sayfası, istek listesi toplama;
  Bölüm 1 demosu ve Steam Next Fest'e katılım.
  **AI içerik açıklaması (zorunlu):** Steamworks içerik anketinde önceden üretilmiş AI içeriği (görseller) ve nasıl
  kullanıldığı açıklanır; açıklama mağaza sayfasında görünür. Oyun çalışırken AI ile içerik üretmez. Kaynak: 7.3'teki
  üretim kaydı (`docs/art/ai-usage.md`).
- [ ] 11.6 Derleme ve yükleme hattı: SteamPipe ile build yükleme, beta dalı, GitHub Actions'tan Windows derlemesi.
- [ ] 11.7 (Sonra) Steam Deck uyumu (kontrolcü ile sanal imleç), macOS sürümü (Mac gerekir).

---

## Notlar
<!-- Claude plandan önemli sapmaları buraya tarih ve adım numarasıyla yazar. -->
- 2026-11-11: Oyun tasarımı netleşti (`docs/game_design.md`). Aşama 1 koşul + etki sistemine göre yeniden yazıldı;
  Aşama 5 (Bulmacalar ve vaka akışı) eklendi, sonraki aşamalar bir numara kaydı.
- 2026-11-11: Steam (Windows) hedefi eklendi: adım 0.6 (Windows hedefi) ve Aşama 11 (Steam). Platforma özel servisler
  arayüz arkasında; Aşama 3–4 ve 8 mobil kapsamlı.
- 2026-11-11 (0.1): Proje adının yazımı düzeltildi: `DedectiveDark` → **DetectiveDark**. Dart paketi `detective_dark`,
  uygulama kimliği `io.github.asklife23.detectivedark`, GitHub deposu `asklife23/DetectiveDark`.
  Yerel klasör de sonradan `C:\flutter\DetectiveDark` olarak yeniden adlandırıldı.
- 2026-11-11 (0.1): Hedef olmayan `linux/`, `macos/`, `web/` platform klasörleri silindi. `windows/` kaldı (adım 0.6).
  macOS gerektiğinde `flutter create --platforms=macos .` ile geri eklenir (adım 11.7).- 2026-11-11 (0.2): Kullanıcı isteğiyle `.gitattributes` eklendi (`* text=auto eol=lf`, `.bat`/`.cmd` için `crlf`,
  görseller/fontlar/sesler `binary`); depo LF'ye normalleştirildi. Ayrı commit.
- 2026-11-11 (0.2): `Result<T>` alt sınıfları `Success` / **`Failed`** olarak adlandırıldı; `Failure` adı hata
  türlerinin (`ContentFailure`, `StorageFailure`, `NetworkFailure`, `UnexpectedFailure`) sealed üst sınıfına kaldı.
- 2026-11-11 (0.2): `very_good_analysis` 10.3.0 (11.x Dart 3.13 istiyor; Flutter yükselince güncellenir).
- 2026-11-11 (0.2): iOS'ta yön kilidi için `UIRequiresFullScreen` + `UIStatusBarHidden` eklendi. `UIRequiresFullScreen`
  iPadOS 26'da kullanımdan kalkıyor; Aşama 10'da Mac/Xcode ile doğrulanacak.
- 2026-11-11 (0.2): `SystemChrome` çağrıları sadece Android/iOS'ta yapılır (Windows bu kanalı uygulamaz,
  `MissingPluginException` fırlatır). 0.6'da `AppConfig` derleme hedefi gelince bu kontrol yeniden değerlendirilir.
- 2026-11-11 (0.3): Uygulama adı flavor başına `resValue` yerine `manifestPlaceholders["appName"]` ile verildi
  (AGP 9'da `resValues` varsayılan kapalı; manifest yolu ek ayar istemez).
- 2026-11-11 (0.3): `bootstrap`, giriş noktasının flavor'ı ile `--flavor` değeri (`appFlavor`) uyuşmazsa açılışta
  hata verir (ör. `--flavor prod -t lib/main_dev.dart`). Env'e `SHOW_DEBUG_OVERLAY` anahtarı eklendi
  (yoksa sadece dev'de açık). `.run/` formatı kurulu Flutter eklentisinin (95.0.0) alan adlarıyla doğrulandı.
- 2026-11-11: Dil kararı değişti: ilk çıkış sadece İngilizce (`en`). l10n altyapısı yine kuruluyor; yeni dil = yeni
  `app_xx.arb` + `text_xx.json`. 0.4 ve 1.2 buna göre güncellendi; fontlar Latin Extended desteklemeli.
- 2026-11-11 (0.4): Fontlar: başlık **Courier Prime** (Regular/Bold), gövde **IBM Plex Sans** (Regular/Medium/Bold);
  ikisi de OFL 1.1, statik TTF (değişken fontlarda `FontWeight` her platformda eksene güvenilir bağlanmıyor).
  Latin Extended-A kapsamı fontTools ile doğrulandı (Courier Prime'da sadece `ĸ ŉ ſ ẞ` yok). Lisanslar
  `LicenseRegistry`'ye eklendi (lisans sayfasında görünür). Süre sabitleri `kSceneFadeDuration` yerine
  `AppDurations.sceneFadeOut / sceneHold / sceneFadeIn` (JSON'daki `fadeOutMs/holdMs/fadeInMs` varsayılanları).
  Router 0.2'de kurulmuştu (`/` → `GameScreen`); bu adımda değişmedi.
- 2026-11-11 (0.4): 0.3'ün kabul kriteri cihazda doğrulandı: üç flavor telefona yan yana kuruldu.
- 2026-11-11: Tasarım kararları: `inspect` etkisi (ADR 0010); AI destekli görseller, kritik yazı/sayılar overlay,
  ortak noir filtre (ADR 0011). Aşama 1 (kabul senaryosuna 11. adım, 1.1–1.5), Aşama 7 (7.2–7.4) ve 11.5
  güncellendi. Sahne sayısı kesin değil; hikaye yazılırken belirlenecek.
- 2026-11-11 (0.5): CI'da "üretilen kod güncel mi" kontrolü 1.2'yi beklemeden açıldı: `gen-l10n` çıktısı 0.4'ten beri
  commit ediliyor. Kontrol `git status --porcelain` ile yapılır (yeni, takip edilmeyen üretilmiş dosyaları da yakalar).
  `build_runner` adımları yorum satırı olarak hazır. `docs/adr/README.md` dizin + şablon olarak eklendi.
- 2026-11-11 (0.6): `windows/` 0.1'den beri vardı; `flutter create` çalıştırmak yerine aynı Flutter sürümünün temiz
  şablonuyla karşılaştırıldı (yalnızca bilinçli ad farkları). Visual Studio 2026 kuruluydu, KULLANICI adımı gerekmedi.
  Şablondaki pencere boyutu dış çerçeveyi kapsıyordu; runner, boyutu içerik alanı sayacak şekilde değiştirildi
  (1280×720 mantıksal, 16:9) ve 960×540 minimum eklendi (`WM_GETMINMAXINFO`, DPI'a göre). Steam girişi `prod`
  flavor + `BuildTarget.steam`; debug etiketi `AppConfig.debugLabel` (ör. "PROD · STEAM"). `.run/steam` eklendi.
