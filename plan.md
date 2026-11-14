# DetectiveDark — Yol Haritası

Bu dosya projenin aşama aşama yol haritasıdır. Çalışma kuralları `CLAUDE.md`'de,
oyunun nasıl oynandığı `docs/game_design.md`'dedir. Claude her adımı bitirince ilgili kutuyu `[x]` yapar.

## Nasıl kullanılır

Android Studio terminalinde Claude'a yaz:

- `Aşama 0.1'i yap` → sadece o adım
- `Aşama 1'i yap` → aşamanın kalan tüm adımları (her adım ayrı commit)
- `Sıradaki adım` → **çalışma sırasına** göre ilk işaretlenmemiş adım (aşağıya bak)
- `Durum` → ne bitti, sırada ne var
- `Açıkla 1.3` → o adımı tekrar anlat

## Çalışma sırası

Aşamalar numara sırasıyla değil, bu sırayla yapılır. Numaralar değişmez; dosyadaki yerleri de aynı kalır.
Önce oyunun eğlenceli olduğu doğrulanır, sonra hesap ve bulut eklenir.

1. Aşama 0 — Proje temeli ✔
2. Aşama 1 — Oyun motoru (adım 1.1–1.8 bitti, `phase-1` etiketi atıldı)
3. Aşama 1b (adım 1.9–1.20) — motor eksikleri: konuşma, tetikleyiciler, mekan geçişi, içerik düzeni
4. Aşama 2 — Kalıcı kayıt
5. Aşama 5 — Bulmacalar ve vaka akışı
6. Aşama 7, **yalnızca Bölüm 1** (7.0–7.4): repoyu private yapma, hikaye, görseller, Bölüm 1 içeriği ve 10–15 kişiyle oyun testi.
   **9.1 (çökme raporlama) oyun testinden önce yapılır:** sıra 7.0 → 7.1 → 7.2 → 7.3 → 7.4'ün içeriği → 9.1 → oyun testi
7. Aşama 3 — Supabase ve kimlik
8. Aşama 4 — Bulut eşitleme
9. Aşama 6 — Oyun hissi ve uygulama kabuğu
10. Aşama 7'nin kalanı (7.5: Bölüm 2–4)
11. Aşama 8 → 9 (9.1 hariç; öne alındı) → 10 → 11

**Sıradan doğan bağımlılıklar:**
- **Aşama 1b → Aşama 2:** 1b kayıt şekline alan ekler (`spokenLines`, `firedTriggers`, `askedTopics`, not `entries`).
  Kalıcı kayıt (2.2) bu alanlarla **ilk sürüm olarak** yazılır; 1b Aşama 2'den sonra yapılsaydı ilk gerçek kayıt
  sürümü hemen bir migration gerektirirdi.
- **Aşama 1b → Aşama 7:** İçerik dosya düzeni ve bölüm genişletmeleri (1.14) Bölüm 1 yazılmadan önce kesinleşir;
  sonradan değiştirmek yazılmış bölüm dosyalarını yeniden yazmak demektir.
- **Aşama 5 → Aşama 2:** Bulmaca durumu, bölüm ve suçlama hakları ilerlemeye eklenir. Kayıt şekli değişirse payload
  sürümü artar ve 2.2'deki migration zinciriyle taşınır (eski kayıt bozulmaz).
- **Aşama 5 → Aşama 3:** Bölüm 1 sonundaki hesap bağlama önerisi 5.4'ten 3.3'e taşındı. 5.4 bölüm sonu ekranını
  hesapsız kurar; öneri Aşama 3 gelince o ekrana eklenir.
- **Aşama 5 → Aşama 6:** 5.3'teki kayıt inceleme sessiz kurulur; sesi 6.1'de bağlanır (geçişlerdeki `sfx` gibi).
- **Aşama 7 (Bölüm 1) → Aşama 5:** Hikaye ve bulmaca zinciri 5'te hazırlanan bulmaca türleriyle kurulur.
  Yeni bir bulmaca türü gerekirse önce Aşama 5'e adım olarak eklenir.
- **Oyun testi (7.4) Aşama 3, 4 ve 6'dan önce:** Kayıt yereldir (Aşama 2), hesap veya bulut gerekmez. Ses, ana menü ve
  cila henüz yoktur; test bulmacaları, hikayeyi ve akışı ölçer. Test sürümünün dağıtım yolu (APK, Windows zip veya
  Play iç test) 7.4 detaylandırılırken seçilir.
- **9.1 → oyun testi (7.4):** `AppLogger` yalnızca `dart:developer`'a yazar; release derlemede bu hiçbir şey yapmaz.
  Çökme raporlama olmadan testçilerde oluşan hatalar görülemez. Bu yüzden 9.1, test sürümü dağıtılmadan önce kurulur.
  Araç kararı (açık kararlar tablosu) 9.1 başlarken sorulur; test sürümünün dağıtılacağı platformları (Android,
  Windows) desteklemelidir. Hesap henüz yoktur (Aşama 3 sonra): raporlar anonimdir, kullanıcı kimliği Aşama 3'te
  eklenebilir. Aşama 9'un kalanı (9.2–9.4) yerinde kalır.
- **Aşama 6 → Aşama 3–4:** Ayarlardaki hesap ve eşitleme durumu (6.4) bu sırayla hazır olur; değişiklik gerekmez.

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
| Kural dili | Koşullar: `not`, `atLeast`, `visited`, `inScene`, `topicAsked`; `say` `first/then`; `chatLog` son 200 (ADR 0013) | Yardımcı bayrak ihtiyacı azalır; kayıt boyutu sınırlı kalır |
| Etki hattı | İlerlemeyi değiştiren her use case tek hattan geçer: etkiler → tetikleyiciler → tek atomik kayıt → olaylar (ADR 0014) | Yeni özellik kendi kayıt/olay kodunu yazmaz; yarım durum oluşmaz |
| Tetikleyiciler | `triggers.json`: koşulu tutunca bir kez çalışan kurallar (ADR 0014) | Birleşik koşul ("ikisi de soruldu") tek yerde yazılır |
| Konuşma | Ayrı feature `dialogue`; `talk` etkisi; `dialogues.json`; kanıt gösterme ve eşya verme konu `trigger`'ıyla (ADR 0016) | Karakterler veriyle eklenir; iç ses ve tek yol hikaye değişmez |
| İçerik dosyaları | Tür başına dosya veya klasör; sonraki bölüm öncekini kendi dosyasında genişletir; eksik bölüm atlanır; önek doğrulaması (ADR 0018) | Bölüm dosyaları okunabilir kalır; demo yalnızca Bölüm 1 ile derlenir |
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
| Toplananlar | **Eşyalar** (sağ panel, kullanılır) ve **notlar** (not defteri: belgeler, gözlemler, kişiler). Kişi dosyaları oyun ilerledikçe satır satır güncellenir (ADR 0015) |
| Eşya kullanımı | Dokun-seç → hedefe dokun; yanlış yerde cezasız genel tepki |
| Bulmacalar | Eşya kullanma, şifre/kilit, kayıt inceleme; zincirleme |
| Hikaye | Tek yol; dallanma yok |
| Karakterler | Sahnede silüet; dokununca konuşma paneli doğrudan açılır; oyuncu yalnızca önceden yazılmış soruları seçer; sorular bilgi ortaya çıkarır (ADR 0016) |
| Kanıt ve eşya | Karakterlere eşya ve not gösterilir, eşya verilir; ilgisiz gösterimde cezasız kısa tepki (ADR 0016) |
| Yön bulma | **Harita ve mekan listesi yok.** Mekanlara sahnedeki geçiş noktalarıyla gidilir; keşif oyunun parçası (ADR 0017) |
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
| 7 | Görsel üretim aracı (AI) ve ticari kullanım koşulları | Ticari kullanıma açık lisanslı araç; seçim stil denemeleriyle |
| 8 | Satın alma biçimi, fiyat, ipucu/reklam | Vaka 1'in kalanı tek satın alım; ipucu modeli test sonrası |
| 9 | Çökme raporlama / analitik | Sentry veya Firebase Crashlytics; minimal analitik. Çökme raporlama kararı 9.1 başlarken (7.4'teki oyun testinden önce) sorulur |
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
  `core/error/result.dart` (`sealed class Result<T>`: `Success` / `Failed`) ve `Failure` türleri.
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

### Aşama 1b — motor eksikleri (adım 1.9–1.20)

**Neden:** Dikey dilim "eşyayı al, doğru yerde kullan" döngüsünü kanıtladı; ama Bölüm 1'i yazmaya başlamadan yapılan
motor incelemesi, 40–50 sahnelik bir bölümün dayanacağı parçaların eksik olduğunu gösterdi: karakterlerle konuşma,
birleşik koşullara tepki veren tetikleyiciler, mekanlar arası geçiş, güncellenen kişi dosyaları ve büyük bölümleri
taşıyacak içerik dosya düzeni. Bunlar **kayıt şeklini** (Aşama 2) ve **içerik dosyalarını** (Aşama 7) belirlediği için
o aşamalardan önce yapılır; sonradan eklemek migration ve yazılmış içeriğin yeniden yazılması demektir.
Adımlar aşağıda 1.8'den sonra yer alır. Komut: `Aşama 1b'yi yap` veya `Sıradaki adım`. Devlog `docs/devlog/asama-1.md`'ye
devam eder. Kararlar: ADR 0013–0018.

**Kabul senaryosunun devamı (1b'nin sonunda 1–20 kusursuz çalışmalı; "çarşı demosu"):**
12. Holde ilaç şişesine dokun → panele uçar. Villa Önü'ne dön: mektup alındığı için tabela belirmiş, üstünde yazı.
13. Tabelaya dokun → Çarşı. Geri butonu görünmez. İki silüet: eczacı ve kahveci.
14. Kahveciye dokun → panel doğrudan açılır; iki soru, ikisi de "yeni". Villayı sor → satırlar dokunuşla ilerler;
    soru sorulmuş olarak işaretlenir.
15. Eczacıya dokun → üç soru görünür (ikisi sabit + şişe elde olduğu için "İlacı sor"). Villayı sor → kişi
    dosyasına satır eklenir, defter rozeti yanar; tetikleyici bir kez çalışır: dedektif konuşur, gözlem notu gelir.
16. "İlacı sor" → cevap + dedektifin iç sesi.
17. Panel açıkken sağ panelde şişeye dokun → eczacı cevap verir, şişe panelden düşer, dosyaya satır eklenir.
    "İlacı sor" listede kalır ve yeniden okunabilir; verme konusu listede sorulmuş olarak görünür.
18. "Kanıt göster" → defter seçim modunda → holdeki mektubu kahveciye göster → cevap. Eczacıya göster →
    `noReactionKey`.
19. Paneli kapat, eczacıya tekrar dokun → ikinci karşılama repliği (`greeting.then`). Tetikleyici tekrar çalışmaz.
20. "Villaya dön" → Villa Önü. Heykel gövdesine iki kez dokun: önce uzun, sonra kısa replik.

### [x] 1.1 Domain modelleri ve etkileşim kuralları
**Amaç:** Oyunun dilini saf Dart ile tanımlamak; bütün bulmacaların üzerine kurulacağı koşul + etki sistemini kurmak.
**Yapılacaklar:**
- `scene_engine/domain/entities`:
  - `CaseDefinition` (`id`, `chapters`) ve `ChapterDefinition` (`id`, `entrySceneId`). (Bölüm bitiş koşulları ve
    suçlama Aşama 5'te `case_flow`'a eklenir.)
  - `SceneDefinition` (`id`, `parentId?`, `titleKey`, `visual`, `visualVariants`, `hotspots`, `onFirstEnter`).
    `onFirstEnter` yalnızca `say`, `setFlag`, `addNote`, `giveItem` içerebilir (gezinme, inceleme ve `hideHotspot` yok).
  - `SceneVisual` (`background?` (asset yolu), `placeholderStyle`, `overlays`, `filterPreset?`)
  - `sealed class VisualOverlay` → `TextOverlay` (`rect`, `textKey`, `style`, `rotation?`): görsele gömülmeyen yazı ve
    sayılar (ADR 0011). Analog saat ibreleri gibi yeni türler bir bulmaca gerektirdiğinde (Aşama 5) eklenir.
  - `InspectionDefinition` (`id`, `titleKey?`, `textKey`, `visual: SceneVisual`): inceleme penceresinin içeriği (ADR 0010).
  - `VisualVariant` (`when`, `visual`): koşula göre görünüm (kapı açık/kapalı). İlk tutan kazanır, hiçbiri tutmazsa varsayılan.
  - `NormalizedRect` (`x`, `y`, `width`, `height`; 0–1 doğrulaması; `contains`)
  - `HotspotDefinition` (`id`, `rect`, `labelKey`, `visibleWhen?`, `interactions`, `glint`). `id` sahne içinde
    benzersizdir. `glint`: toplanabilir nesnenin hafif parıltısı (sunum ipucu; mantığı etkilemez).
  - `InteractionRule` (`when?`, `effects`)
  - `sealed class Condition` → `FlagSet`, `FlagNotSet`, `HasItem`, `UsingItem`, `HasNote`, `AllOf`, `AnyOf`
  - `sealed class Effect` → `GoToScene(sceneId, transition?)`, `GiveItem`, `ConsumeItem`, `AddNote`, `SetFlag`,
    `HideHotspot` (bu hotspot'u kalıcı gizler), `Say(messageKey)`,
    `Inspect(inspectionId)` (sahneyi değiştirmeden inceleme penceresi açar).
    `OpenPuzzle` ve `PlayMedia` Aşama 5'te eklenir.
  - `SceneTransition` (`type: fade|cut`, `fadeOutMs`, `holdMs`, `fadeInMs`, `sfx?`; varsayılan 150 / 0 / 150)
- `scene_engine/domain/services` (hepsi saf Dart):
  - `ConditionEvaluator` (koşul + ilerleme + seçili eşya → bool)
  - `InteractionResolver` (hotspot + ilerleme + seçili eşya → çalışacak etki listesi). Kurallar:
    - Kurallar yukarıdan aşağı okunur, koşulu tutan **ilk** kural çalışır.
    - **Eşya seçiliyken** yalnızca koşul ağacında o eşya için `usingItem` geçen kurallar adaydır. Adaylardan koşulu
      tutan ilki çalışır; yoksa yalnızca genel tepki (`Say(generic_item_no_effect)`). Yanlış eşya normal etkileşimi
      tetiklemez.
    - **Eşya seçili değilken** `usingItem` her zaman yanlıştır (o kurallar atlanır).
  - `SceneStackResolver`: gezinme yığını her zaman hedef sahnenin **ata zinciridir** (`parentId` ile kökten hedefe).
    `GoToScene` nereden çağrılırsa çağrılsın Geri hep üst sahneye döner; yığın tek bir sahne ID'sinden yeniden
    kurulabilir. Döngülü veya eksik `parentId` hatadır.
  - `EffectApplier`: (ilerleme, etkiler, bağlam: sahne, hotspot, seçili eşya, şimdiki zaman) →
    `EffectOutcome` (yeni ilerleme, yayınlanacak olaylar, gezinme isteği?, açılacak inceleme?). Yan etkisi yoktur;
    bir kuralın bütün etkileri **tek bir yeni ilerleme** üretir. Aşama 5'te bulmacaların `onSolved` etkileri de bunu kullanır.
    - `Say` iki şey yapar: mesajı ilerlemedeki `chatLog`'a ekler ve `DetectiveSaid` olayı üretir.
    - `HideHotspot` anahtarı sahneyle nitelenir: `sceneId/hotspotId` (150+ sahnede `lock` gibi ID'ler tekrar eder).
- `scene_engine/domain/repositories/scene_content_repository.dart` (abstract; `Result` döner).
- `inventory/domain`: `ItemDefinition` (`id`, `nameKey`, `descriptionKey`, `iconStyle`, `iconAsset?`), `ItemCatalogRepository`.
- `notebook/domain`: `NoteDefinition` (`id`, `category: document | observation | suspect`, `titleKey`, `bodyKey`, `imageAsset?`),
  `NoteCatalogRepository`.
- `progress/domain`:
  - `GameProgress` (`caseId`, `chapterId`, `sceneStack`, `inventory` (sıralı eşya ID'leri), `notes`, `flags`,
    `hiddenHotspots`, `visitedSceneIds`, `chatLog`, `playTimeSeconds`). Kaydedilen her şekil burada tanımlıdır:
    `CollectedNote` (`noteId`, `addedAtUtcMs`, `isRead`), `ChatLogEntry` (`sender: detective | system`, `textKey`,
    `params`, `sentAtUtcMs`). Değişiklikler saf, idempotent kopyalama metotlarıdır (`withItem`, `withoutItem`,
    `withNote`, `withNoteRead`, `withFlag`, `withHiddenHotspot`, `withSceneStack`, `withVisited`, `withChatEntry`).
    Kayıtta metin yok; yalnızca ID, bayrak ve anahtar (ADR 0003).
  - `ProgressRepository` (abstract): `load()` (kayıt yoksa `null`), `current`, `watch()`, `save(GameProgress)`.
    **Tek yazma yolu `save`'dir ve atomiktir:** bir dokunuşun bütün etkileri tek kayıt olur; yarım uygulanmış kural
    (ör. anahtar tükendi ama kapı bayrağı yazılmadı) hiçbir zaman diske veya arayüze ulaşmaz.
- `core/time`: `Clock` (UTC "şimdi"; testte sabit saat). Domain `DateTime.now()` çağırmaz.
- `core/events`: `sealed class GameEvent` → `SceneEntered(sceneId, isFirstVisit)`, `ItemObtained(itemId)`,
  `ItemUsed(itemId, hotspotId)`, `NoteAdded(noteId)`, `DetectiveSaid(messageKey)`; `GameEventBus` (broadcast stream).
  Olaylar arayüz tepkisi içindir (animasyon, daktilo efekti); kalıcı durum her zaman ilerlemeden okunur.
- Unit testler: `ConditionEvaluator` (her koşul türü), `InteractionResolver` (kabul senaryosundaki kapı kurallarının
  tamamı: anahtarsız, yanlış eşyayla, doğru eşyayla, kapı açıkken; `Inspect` içeren kural), `EffectApplier` (her etki,
  idempotentlik, olaylar), `SceneStackResolver`, `GameProgress` kopyalama metotları, `NormalizedRect`, geçiş varsayılanları.
  **Kabul kriterleri:** `domain` klasörlerinde Flutter import'u yok; resolver testleri kapı/anahtar senaryosunu kapsıyor.
  **Commit:** `feat(scene_engine): add domain models and interaction rule system`

### [x] 1.2 İçerik formatı ve dikey dilim içeriği
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
- **Vaka bütün olarak yüklenir.** Eşyalar, notlar ve sohbet geçmişi bölümler arasında taşınır (Bölüm 1'de alınan
  eşya Bölüm 3'te kullanılabilir; Bölüm 1'in notu finalde kanıttır). Bu yüzden kataloglar ve metinler bölüm bazında
  değil **vaka genelinde** çözülür: `case.json`'daki bütün bölümlerin dosyaları açılışta okunur. Sahne, eşya, not,
  inceleme ID'leri ve metin anahtarları vaka içinde benzersizdir (doğrulama testi zorlar). Tembel yükleme ancak
  6.5'teki ölçüm gerektirirse eklenir.
- Paketler: `json_annotation`; dev: `json_serializable`, `build_runner`. CI'daki `build_runner` adımını etkinleştir.
- `data/models` DTO'ları + entity dönüşümleri. Düz DTO'lar `json_serializable` ile (`checked`,
  `disallowUnrecognizedKeys`: yanlış yazılmış alan adı sessizce yok sayılmaz). Koşul ve etkiler JSON'da tek anahtarlı
  nesnelerdir (`{"flag": "front_door_open"}`, `{"giveItem": "brass_key"}`) ve elle ayrıştırılır; bilinmeyen anahtar
  anlaşılır bir hatayla reddedilir. Hatalar `ContentFailure` olarak döner ve dosya adını + konumu içerir.
  `AssetBundle` enjekte edilen veri kaynağı (test edilebilir).
- `core/content/`: aktif dile göre metni anahtarla veren servis (vakanın bütün bölüm metinleri + genel metinler).
  Eksik anahtar çökmez: anahtarın kendisini gösterir ve log'a yazar.
- `ContentValidator` (`scene_engine/domain/services`, saf Dart; sorun listesi döner). Testte kullanılır; 7.2'deki
  editör de aynı sınıfı kullanabilir. Kod tarafında tanımlı adları (overlay stilleri, filtre preset'leri,
  placeholder stilleri) parametre olarak alır.
- Dikey dilim içeriği (koordinatlar placeholder çizimlerle uyumlu ayarlanır):
  - `villa_exterior`: `door` → `villa_door_closeup`'a git; `statue` → `statue_closeup`'a git; ilk girişte dedektif yorumu.
    Kapı yanındaki numara plakası görsele çizilmez, `TextOverlay` olarak gelir.
  - `villa_door_closeup` (parent: `villa_exterior`): görünüm varyantı `front_door_open` bayrağına göre (açık/kapalı).
    `lock` hotspot'u: kapı açıksa → `villa_hall`'a git; `brass_key` kullanılırsa → bayrak + anahtarı tüket + "Açıldı";
    aksi halde → "Kilitli."
  - `statue_closeup` (parent: `villa_exterior`): `statue_key` (`glint`) → `GiveItem(brass_key)` + `HideHotspot` +
    `SetFlag(statue_key_taken)` + yorum; görünüm varyantı bu bayrağa göre (anahtarlı/anahtarsız). `statue_body` → kısa
    yorum; `statue_plaque` → `Inspect(statue_plaque)` (plaket görseli + kazıma yazı overlay'i + metin).
  - `villa_hall` (parent: `villa_door_closeup`): `desk_paper` (`glint`) → `AddNote(hall_letter)` + `HideHotspot` +
    `SetFlag(hall_letter_taken)` + yorum; görünüm varyantı bu bayrağa göre (kağıtlı/kağıtsız).
  - `items.json`: `brass_key`. `notes.json`: `hall_letter` (document). `inspections.json`: `statue_plaque`.
  - Tüm metinler İngilizce; atmosferik, kısa.
- **İçerik doğrulama testi** (CLAUDE.md bölüm 9) `ContentValidator`'ı gerçek içerik üzerinde çalıştırır:
  referanslar (sahne, eşya, not, inceleme), metin anahtarları (desteklenen tüm dillerde), hotspot ve overlay
  koordinatları, "bir kuralda tek `inspect`, `goToScene` ile birlikte değil", "okunan her bayrak bir yerde set
  ediliyor mu", "her sahne bölümün giriş sahnesinden ulaşılabilir mi" (graf taraması). Ek kontroller: ID'ler vaka içinde
  benzersiz; hotspot ID'leri sahne içinde benzersiz; `parentId` var ve döngüsüz; `onFirstEnter` yalnızca izinli
  etkileri içeriyor; overlay stili, filtre preset'i ve placeholder stili kodda tanımlı.
  **Kabul kriterleri:** Tüm içerik yükleniyor; doğrulama testi geçiyor; bilerek bozulan bir ID veya yanlış yazılmış bir
  bayrak testi kırıyor.
  **Commit:** `feat(scene_engine): add JSON content format and vertical slice content`

### [x] 1.3 Bellekte ilerleme, etki uygulama ve SceneBloc
**Amaç:** Oyun mantığını arayüzden bağımsız ve test edilebilir kurmak.
**Yapılacaklar:**
- `progress/data`: `InMemoryProgressRepository` (Aşama 2'de Drift ile değişecek).
- Use case'ler (`scene_engine/domain/usecases`): hepsi aynı kalıbı izler: `EffectApplier` ile yeni ilerlemeyi hesapla →
  `ProgressRepository.save` (tek atomik yazım) → başarılıysa olayları `GameEventBus`'a yayınla.
  - `StartGame`: içeriği yükler; kayıt varsa onu, yoksa giriş sahnesiyle yeni bir `GameProgress` kurar (Aşama 2'de
    "kaldığın yerden devam" aynı yoldan gelir).
  - `TapHotspot` (resolver + etkiler), `EnterScene` (yığın, ziyaret işareti, `SceneEntered`, ilk ziyarette
    `onFirstEnter`; hepsi tek kayıt), `GoBack`.
- `SceneBloc`:
  - Olaylar: `SceneStarted`, `HotspotTapped(hotspotId, usingItemId?)`, `BackPressed`, `TransitionCovered`,
    `TransitionFinished`, `InspectionRequested(inspection)`, `InspectionClosed`.
  - Durum: `status` (`loading` / `ready` / `failed` + `Failure`), `stack`, `currentScene`, `currentVisual` (varyant
    çözülmüş), `visibleHotspots` (`visibleWhen` ve gizlenenler uygulanmış), `transitionPhase` (`idle` / `covering` /
    `revealing`), `pendingTransition`, `canGoBack`, `activeInspection`.
  - **Olaylar sırayla işlenir** (tek olay işleyici, sıralı dönüştürücü; ek paket yok). Kayıt Aşama 2'de asenkron
    olacağı için iki hızlı dokunuş aynı kuralı iki kez çalıştıramaz.
  - İnceleme: `Inspect` etkisi `activeInspection`'ı doldurur. Pencere açıkken hotspot dokunuşları yok sayılır;
    `BackPressed` önce pencereyi kapatır, yığına dokunmaz. İnceleme ilerlemeye yazılmaz. `InspectionRequested`,
    eşya inceleme kartı (1.5) için dışarıdan pencere açar.
  - İlerleme akışı (`watch()`) değiştikçe görünüm ve görünür hotspot'lar yeniden hesaplanır.
  - Geçiş zamanlaması arayüzdeki animasyondadır; Bloc yalnızca fazı tutar. Ekran tamamen karardığında arayüz
    `TransitionCovered` gönderir, Bloc sahneyi o an değiştirir (`EnterScene`).
  - Geçiş sürerken gelen dokunmalar yok sayılır.
  - **Geri geçişi:** sahneye girerken kullanılan geçiş *tipi* (`fade` / `cut`) oturum boyunca hatırlanır ve Geri'de
    varsayılan sürelerle kullanılır (`holdMs` ve `sfx` tekrarlanmaz). Kayıttan dönülen sahnede varsayılan `fade`.
- `bloc_test`: kabul senaryosunun 1–11. adımlarının mantığı, geçiş sırasında çift dokunma, ana sahnede geri (etkisiz),
  inceleme açıkken Geri ve hotspot dokunuşu, içerik yüklenemezse `failed`. Use case testleri: kayıt başarısızsa olay
  yayınlanmaz.
  **Kabul kriterleri:** Kabul senaryosunun tamamı testlerle doğrulanmış (henüz arayüz yok).
  **Commit:** `feat(scene_engine): add scene bloc with effect execution and navigation stack`

### [x] 1.4 Sahne görünümü
**Amaç:** Sahneleri her ekranda doğru oranla çizmek, dokunmaları almak ve sahneler arasında gezinmek.
**Yapılacaklar:**
- `lib/app/game/game_screen.dart`: feature widget'larını birleştiren ekran (CLAUDE.md bölüm 3'teki `app/` kuralı).
  Bu adımda: sahne alanı + Geri butonu; yükleniyor ve hata durumları (metinler ARB'den). Panel, defter ve mesaj barı
  sonraki adımlarda eklenir.
- **Geri:** sol üstte, `canGoBack` iken görünür. Android sistem geri tuşu `PopScope` ile `BackPressed`'e bağlanır;
  ana sahnede "Çıkmak için tekrar bas" mesajı (ARB).
- `SceneViewport`: verilen alana 16:9 oranını koruyarak sığar (contain); boşluklar koyu letterbox.
- Arka plan: `background` doluysa `Image.asset` (ekran boyutuna göre `cacheWidth`), boşsa `placeholderStyle`'a göre
  `CustomPainter`: villa cephesi, kapı yakın planı (kapalı ve açık), heykel yakın planı (anahtarlı ve anahtarsız),
  hol (kağıtlı ve kağıtsız), plaket. Noir: gece mavisi/siyah, ay ışığı, sis katmanları. Görsel olarak anlaşılır ve
  şık olmalı. Gren ve vinyeti placeholder'lar değil ortak noir filtre çizer.
- Placeholder çizimleri `core/placeholders/` altında, stil adıyla kayıtlıdır. Sahne (`scene_engine`) ve eşya ikonları
  (`inventory`) aynı kayıt defterini kullanır; feature'lar birbirinin `presentation` katmanını import etmez.
- `OverlayLayer`: `TextOverlay`'leri görselle aynı normalize koordinatlarla çizer; yazı `rect`'e sığacak şekilde
  ölçeklenir; stil preset'leri (`typewriter`, `handwriting`, `engraved`...) `core/theme`'de.
- `NoirFilter`: gren + vinyet + renk tonu; preset'ler `core/theme`'de, sahne `filterPreset` ile seçer. Uygulama yolu
  (`ColorFilter` matrisi + gradyan + gren dokusu ya da fragment shader) Android, iOS ve Windows'ta ölçülerek seçilir;
  gren varsayılan olarak statik. Katman sırası: arka plan → overlay → filtre → hotspot → geçiş.
- `InspectPanel`: sahnenin üstünde küçük pencere; görsel sahneyle aynı hattan çizilir (görsel + overlay + filtre),
  altında metin. Dışına dokun / kapat / Geri ile kapanır.
- `glint` işaretli hotspot'lar sahnede hafifçe parıldar: dikkat çeker ama bağırmaz.
- `HotspotLayer`: normalize koordinat → piksel; şeffaf dokunma alanları; erişilebilirlik için `Semantics` etiketleri;
  dokunulan noktada kısa bir dalga efekti. Dev flavor'da açılıp kapanabilen **debug overlay**: hotspot dikdörtgenleri ve ID'leri.
- `TransitionOverlay`: siyah katman; `fadeOutMs` → `holdMs` → `fadeInMs`; `cut` tipinde anında.
- Arka plan (görsel + overlay + filtre) ve hotspot katmanı ayrı `RepaintBoundary`.
- Fare tıklaması dokunmayla aynı çalışır; Windows'ta farklı pencere boyutlarında da denenir.
- Widget testleri: viewport oranı, hotspot dokunuşu → olay, Geri butonu görünürlüğü, inceleme penceresinin kapanması.
  **Kabul kriterleri:** Kabul senaryosunun gezinme adımları telefonda ve Windows'ta çalışıyor; tablet emülatöründe ve
  yeniden boyutlanan pencerede hotspot'lar ve overlay yazılar kaymıyor, yazılar okunuyor; inceleme penceresi (adım 11)
  çalışıyor; filtre 60 fps hedefini bozmuyor.
  **Commit:** `feat(scene_engine): render scenes with viewport, overlays, noir filter, hotspots and transitions`
  ve `feat(scene_engine): add inspect panel`

### [x] 1.5 HUD: eşya paneli ve eşya kullanımı
**Amaç:** "Eşyayı al, doğru yerde kullan" hissini kurmak.
**Yapılacaklar:**
- `GameScreen`: solda sahne alanı, sağda sabit genişlikte eşya paneli. Sahne viewport'u panelin solunda kalan alana sığar.
- `inventory/presentation`: `InventoryCubit` (ilerlemedeki eşyalar + katalog → sıralı liste; seçili eşya).
  Dokun → seç / tekrar dokun → bırak. Seçili eşya envanterden çıkarsa seçim kendiliğinden kalkar.
- `GameScreen`, `HotspotTapped`'e seçili eşyayı ekler; dokunuştan sonra seçim temizlenir.
- **Eşya inceleme kartı:** uzun basınca `InventoryCubit` bir "incele" isteği yayar; `GameScreen` eşyayı bir
  `InspectionDefinition`'a çevirir (başlık = ad, metin = açıklama, görsel = eşyanın placeholder stili / asset'i) ve
  `SceneBloc`'a `InspectionRequested` gönderir. Böylece pencere, Geri davranışı ve dokunma kilidi tek yerde kalır;
  `inventory`, `scene_engine`'in `presentation` katmanını import etmez.
- `ItemSidebar`: dikey, yarı saydam koyu yüzey; seçili eşya belirgin çerçeve; boş durum metni (ARB).
- **Uçuş animasyonu:** Alınan nesne sahnedeki konumundan paneldeki yuvasına uçar (~450 ms, `easeInOutCubic`), yuvaya
  oturunca kısa parlama. Tüketilen eşya panelden sönerek çıkar. Başlangıç ve bitiş noktaları `core/widgets` içindeki
  bir çapa kayıt defteriyle (`GlobalKey`) bulunur; uçuşu `app/` katmanı `ItemObtained` olayıyla başlatır (`Overlay`).
- Testler: `InventoryCubit` için `bloc_test` (seçim, tüketme, incele isteği); panel için widget testi.
  **Kabul kriterleri:** Kabul senaryosunun 1–7. adımları telefonda ve Windows'ta çalışıyor (dedektif mesajları hariç).
  **Commit:** `feat(inventory): add item sidebar with selection, use and collect animation`

### [x] 1.6 Not defteri
**Amaç:** Okunan her şeyin toplandığı ve ileride finalde kanıt seçilecek olan defteri kurmak.
**Yapılacaklar:**
- `notebook/domain`: `MarkNoteRead` use case (ilerlemeye yazar). Okundu bilgisi `GameProgress`'tedir; Aşama 2'den
  sonra uygulama kapanıp açılınca rozet geri gelmez.
- `notebook/presentation`: `NotebookCubit` (ilerlemedeki notlar + katalog, kategoriler, okunmamış sayısı).
- HUD'da defter düğmesi (eşya panelinin üstünde) + okunmamış rozeti.
- `NotebookScreen`: sekmeler **Belgeler / Gözlemler / Şüpheliler**; yatay ekrana uygun iki sütun (solda liste,
  sağda içerik); eski kağıt dokusu, daktilo başlıklar. Boş sekme için atmosferik boş durum metni. Sahnenin üstünde
  açılır (router rotası değil); Geri ve sistem geri tuşu önce defteri kapatır.
- Not eklenince kağıt deftere uçar (eşya uçuş animasyonu yeniden kullanılır; tetikleyici `NoteAdded`).
- Testler: `NotebookCubit` (ekleme, okundu işaretleme, kategoriler), `MarkNoteRead`.
  **Kabul kriterleri:** Kabul senaryosunun 8–9. adımları telefonda ve Windows'ta çalışıyor.
  **Commit:** `feat(notebook): add notebook with documents, observations and suspects`

### [x] 1.6b Nesne katmanı
**Amaç:** Alınabilen nesneleri arka plandan ayırmak: bir nesne için iki tam sahne görseli (nesneli / nesnesiz)
yerine tek arka plan + küçük bir nesne görseli (ADR 0012). Gerçek görsellerde (Aşama 7) sanat bütçesini korur.
**Yapılacaklar:**
- `HotspotDefinition`'a opsiyonel `sprite` (`HotspotSprite`: `rect`, `placeholderStyle`, `image?`). `rect` sahne
  görseline göre normalize (0–1) ve hotspot'un dokunma alanından bağımsızdır. JSON: hotspot içinde `"sprite": {...}`.
- Hotspot görünürken nesnesi çizilir; `hideHotspot` veya `visibleWhen` ile gizlenince çizilmez. `image` boşsa
  `placeholderStyle`'daki painter çizer; doluysa şeffaf arka planlı görsel (gerçek görsele geçiş tek satır JSON).
- Katman sırası: arka plan → **nesneler** → overlay → noir filtre → hotspot → geçiş. Nesneler filtrenin altında
  kalır ki arka planla aynı filmden çıkmış görünsün. İnceleme penceresinde nesne katmanı yoktur.
- `ContentValidator`: nesne `rect`'i 0–1 aralığında, `placeholderStyle` kodda tanımlı.
- Dikey dilim: anahtar (`statue_key`) ve kağıt (`desk_paper`) nesne katmanına taşınır; `statue_closeup` ve
  `villa_hall` tek arka plana iner; `statue_key_taken` / `hall_letter_taken` bayrakları ve görünüm varyantları kalkar.
- `CLAUDE.md` bölüm 6, ADR 0012 (ADR 0011'e bağlı), 7.3'e şeffaf arka plan notu.
- Testler: DTO ayrıştırma, doğrulayıcı (bozuk rect, bilinmeyen stil), widget testi (nesne çiziliyor / gizlenince yok).
  **Kabul kriterleri:** Kabul senaryosunun 5., 8. ve 10. adımları aynı görünür: anahtar ve kağıt alınınca sahneden
  kaybolur, geri dönünce yoktur; sahne başına tek arka plan stili kalır.
  **Commit:** `feat(scene_engine): add object layer with hotspot sprites`

### [x] 1.7 Dedektifin iç sesi
**Amaç:** Dedektifin oyuncuya konuştuğu mesaj katmanı (ileride ipucu sistemi de bunu kullanacak).
**Yapılacaklar:**
- Mesajlar zaten ilerlemededir (`chatLog`; `Say` etkisi 1.1'deki `EffectApplier`'da yazar). `detective_chat` yalnızca
  gösterir: kendi kalıcı modeli yoktur.
- `ChatCubit`: geçmişi `ProgressRepository.watch()`'tan okur; `GameEventBus`'taki `DetectiveSaid` yalnızca "yeni mesaj
  geldi" tepkisini (daktilo efekti, okunmamış sayısı) tetikler. Okunmamış sayısı arayüz durumudur (kaydedilmez).
- `ChatBar`: sahne alanının alt kenarında, sahnenin **üstüne** bindirilmiş kompakt bar; son mesaj daktilo efektiyle
  yazılır (dokununca anında tamamlanır). Mesaj okunacak kadar kaldıktan sonra bar kendiliğinden küçük bir düğmeye
  çekilir; böylece sahne küçülmez ve alt kenardaki hotspot'lar kalıcı olarak kapanmaz. Süreler `core/theme`'de.
- `ChatHistorySheet`: bara veya düğmeye dokununca açılan mesaj geçmişi; Geri önce bunu kapatır.
- **Bar hiçbir hotspot'u kapatmaz:** barın (ve küçülmüş düğmenin) kaplayabileceği alt şerit, sahne yüksekliğinin
  oranı olarak tek bir sabittir (`core/theme`). Bar bu şeridin dışına taşmaz; içerik doğrulama testi hiçbir
  hotspot'un bu şeride girmediğini kontrol eder.
- Testler: olay → yeni mesaj tepkisi; okunmamış sayısı; geçmiş sırası.
  **Kabul kriterleri:** Kabul senaryosunun tamamı (1–11) telefonda ve Windows'ta çalışıyor.
  **Commit:** `feat(detective_chat): add detective inner voice bar and history`

### [x] 1.8 Uçtan uca test ve cila
**Amaç:** Aşamayı sağlam kapatmak.
**Yapılacaklar:**
- Kabul senaryosunun tamamı tek bir paylaşılan senaryo fonksiyonu olarak yazılır ve iki yerden çalıştırılır:
  `test/` altında widget testi (her push'ta CI'da) ve `integration_test` (gerçek cihazda: telefon ve Windows).
- Telefonda manuel kontrol listesi: hızlı çift dokunma, eşya seçiliyken Geri, sistem geri tuşu, arka plana alıp dönme, tablet oranı.
- Windows'ta aynı senaryo fareyle.
- `flutter run --profile` ile performans kontrolü (hedef: takılmasız 60 fps); sonuç devlog'a.
- README: mimari diyagramı (Mermaid), etkileşim sisteminin kısa anlatımı ve örnek JSON, nasıl çalıştırılır,
  ekran görüntüsü/GIF alanı (kullanıcı ekler).
  **Kabul kriterleri:** Tüm testler yeşil; CI yeşil; README'de **Features**, **Architecture** ve **License**
  bölümleri dolu (yer tutucu metin yok).
  **Commit:** `test: add end-to-end vertical slice test`
  **Aşama sonu:** `phase-1` etiketi.

<!-- Aşama 1b: Neden ve kabul senaryosunun devamı (adım 12–20) Aşama 1 başlığının altındadır. -->

### [x] 1.9 Koşul eklemeleri: `not`, `atLeast`, `visited`, `inScene`
**Amaç:** Kural dilini, yardımcı bayraklara başvurmadan "değilse", "şunlardan en az ikisi", "oradaydım", "şu an
buradayım" diyebilecek hale getirmek (ADR 0013). Tetikleyiciler (1.12) ve konuşma (1.16) bunların üzerine kurulur.
**Yapılacaklar:**
- `scene_engine/domain/entities/condition.dart`: `Not(condition)`, `AtLeast(count, conditions)`, `Visited(sceneId)`,
  `InScene(sceneId)`. `notFlag` (`FlagNotSet`) kalır.
  ```json
  {"not": {"hasItem": "pill_bottle"}}
  {"atLeast": {"count": 2, "of": [{"flag": "a"}, {"flag": "b"}, {"visited": "market_square"}]}}
  {"visited": "villa_hall"}
  {"inScene": "market_square"}
  ```
- `ConditionEvaluator`: `Not` → tersi; `AtLeast` → doğru olanların sayısı ≥ `count`; `Visited` →
  `progress.hasVisited`; `InScene` → `progress.currentSceneId == sceneId` (yığının tepesi; alttaki sahneler sayılmaz).
- `InteractionResolver._asksFor`: `Not` ve `AtLeast` içine bakılmaz (içlerinde `usingItem` yasak); yeni türler `false`.
- `condition_codec.dart`: dört yeni anahtar. `atLeast` nesnesi yalnızca `count` (tam sayı) ve `of` (boş olmayan liste)
  alır; bilinmeyen anahtar anlaşılır hatayla reddedilir.
- `ContentValidator`: `not` / `atLeast` içinde (her derinlikte) `usingItem` hatadır; `1 ≤ count ≤ of.length`;
  `visited` / `inScene` sahnesi vardır; iç içe koşullardaki bayraklar "okunan bayrak" kontrolüne girer.
- İçerik değişmez (yeni koşullar 1.12 ve 1.15'te kullanılır).
- Testler: evaluator (her tür, iç içe), codec (geçerli + her hata), resolver (`not` içindeki kural eşya adayı olmaz),
  doğrulayıcı (yasak `usingItem`, bozuk `count`, bilinmeyen sahne).
  **Kabul kriterleri:** `sealed` switch'lerin hepsi yeni türleri kapsıyor (derleyici zorlar); mevcut testler aynen
  geçiyor; içerik doğrulama testi yeşil.
  **Commit:** `feat(scene_engine): add not, atLeast, visited and inScene conditions`

### [x] 1.10 `say` `first/then`, `spokenLines` ve `chatLog` sınırı
**Amaç:** Aynı yere ikinci dokunuşta uzun repliğin tekrarlanmasını bayrak yazmadan önlemek; kayıt boyutunu sınırlamak
(ADR 0013).
**Yapılacaklar:**
- `Say` iki biçim alır; codec ikisini de ayrıştırır (nesne biçiminde yalnızca `first` ve `then`, ikisi de zorunlu):
  ```json
  {"say": "say_door_locked"}
  {"say": {"first": "say_statue_body", "then": "say_statue_body_again"}}
  ```
  Entity: `Say(messageKey, {repeatKey})`.
- `GameProgress`: `spokenLines` (küme; anahtar = `first`), `hasSpoken`, `withSpokenLine` (idempotent).
- `EffectApplier`: `repeatKey` yoksa bugünkü davranış. Varsa: `first` daha önce söylenmemişse `first` söylenir ve
  `spokenLines`'a eklenir; söylenmişse `then` söylenir. İkisi de `chatLog` + `DetectiveSaid` üretir.
- `chatLog` sınırı: `GameProgress.chatLogLimit = 200` (tek sabit). `withChatEntry` sınırı aşınca en eski girişi düşürür.
  Hiçbir oyun mantığı `chatLog`'dan okumaz (first/then bu yüzden `spokenLines` kullanır).
- `ContentValidator`: `first` ve `then` metin anahtarları vardır; `first` anahtarları vaka içinde benzersizdir (iki
  ayrı yerde aynı `first` kullanılırsa biri diğerinin "ilk" durumunu tüketir).
- İçerik: `statue_body` repliği `{"first": "say_statue_body", "then": "say_statue_body_again"}` olur;
  `text_en.json`'a kısa ikinci replik eklenir.
- Testler: applier (ilk / sonraki, `spokenLines`, idempotentlik), `GameProgress` (sınır: 201. giriş en eskiyi düşürür),
  codec, doğrulayıcı (yinelenen `first`).
  **Kabul kriterleri:** Heykel gövdesine iki kez dokununca önce uzun, sonra kısa replik (kabul senaryosu 20'nin
  mantığı); mevcut kabul testi (1–11) geçiyor.
  **Commit:** `feat(scene_engine): add first/then lines and cap the chat log`

### [x] 1.11 Tek etki hattı
**Amaç:** "Etkileri uygula → kaydet → olayları yayınla" akışını tek yere toplamak (ADR 0014). Tetikleyiciler, konuşma,
geliştirici menüsü ve Aşama 5'teki bulmacalar kendi kayıt kodunu yazmayacak. **Davranış değişmez.**
**Yapılacaklar:**
- `scene_engine/domain/services/effect_pipeline.dart`: `EffectPipeline` (`ProgressRepository`, `GameEventBus`,
  `EffectApplier` alır). Tek metot: (ilerleme, opsiyonel ön değişiklik (ör. yığın + ziyaret işareti), etkiler, bağlam,
  opsiyonel baştaki olaylar (ör. `SceneEntered`)) → `Result<EffectOutcome>`. Sıra sabittir:
  1. ön değişiklik + etkiler → tek yeni ilerleme (`EffectApplier`, saf);
  2. tetikleyiciler (bu adımda boş bir kanca; 1.12'de dolar);
  3. ilerleme değiştiyse **tek** `save`; başarısızsa `Failed` döner ve olay yayınlanmaz;
  4. olaylar `GameEventBus`'a.
- `TapHotspot` ve `EnterScene` hatta taşınır; kendi `save` / `publish` çağrıları kalkar. `StartGame` zaten
  `EnterScene` üzerinden yazar.
- **Tek istisna `MarkNoteRead`** (ADR 0014): doğrudan `save` çağırmaya devam eder, kodu değişmez. Gerekçe: `isRead`'i
  hiçbir koşul okumaz (tetikleyici ateşleyemez), etki çalıştırmaz, olay üretmez; hatta taşımak `notebook/domain` →
  `scene_engine/domain` import'u doğurur ve `scene_engine` zaten `notebook`'u import ettiği için iki yönlü bağımlılık
  olurdu. Hattı tarafsız bir yere taşımak ise `EffectApplier`, `TriggerRunner`, `Condition` ve `Effect`'i de taşımayı
  gerektirirdi (çok daha büyük değişiklik).
- Mimari testi (`test/architecture`):
  - `ProgressRepository.save` çağrısı `lib/` içinde yalnızca `EffectPipeline`'da, `MarkNoteRead`'de (adıyla izinli
    tek istisna) ve repository uygulamalarının kendisinde bulunur.
  - **Feature'lar arası döngü yok:** import satırlarından feature bağımlılık grafı çıkarılır (A → B: A'nın herhangi
    bir dosyası B'yi import ediyor); graf döngüsüz olmalıdır. İki yönlü import ve daha uzun döngüler testi kırar.
- DI: `EffectPipeline` tek örnek olarak kaydedilir; use case'ler onu alır.
- Testler: hat (kayıt başarısız → olay yok; değişiklik yok → kayıt yok; olay sırası: baştaki olaylar, sonra etkilerin
  olayları). `TapHotspot`, `EnterScene`, `MarkNoteRead`, `SceneBloc` ve kabul testleri **değiştirilmeden** geçer
  (yalnızca kurulum satırları değişebilir). Mimari testinin iki yeni kuralı, bilerek bozulan sahte bir import
  listesiyle de sınanır (döngü ve izinsiz `save` yakalanıyor).
  **Kabul kriterleri:** Oyunda gözle görülür hiçbir fark yok; mevcut testlerin beklentileri aynı; mimari testi iki yeni
  kuralı (tek yazma yolu, döngüsüz feature grafı) zorluyor.
  **Commit:** `refactor(scene_engine): route progress changes through one effect pipeline`

### [x] 1.12 Tetikleyiciler
**Amaç:** "Şu koşullar ilk kez bir araya gelince bir kez çalış" kuralını tek yerde yazabilmek (ADR 0014). Koşulu
tamamlayabilecek her hotspot'a aynı kontrolü kopyalamak sessiz hata kaynağıdır.
**Yapılacaklar:**
- İçerik: bölüm klasöründe opsiyonel `triggers.json` (yoksa boş sayılır).
  ```json
  {"formatVersion": 1, "triggers": [
    {"id": "both_asked_about_villa",
     "when": {"atLeast": {"count": 2, "of": [
       {"topicAsked": "pharmacist/about_villa"}, {"topicAsked": "cafe_owner/about_villa"}]}},
     "do": [{"say": "say_stories_do_not_match"}, {"addNote": "obs_stories_do_not_match"}]}
  ]}
  ```
  (`topicAsked` 1.16'da gelir; bu adımın testleri `flag` / `visited` / `hasNote` koşullarıyla yazılır. Dilime
  tetikleyici 1.16'da eklenir.)
- Domain: `TriggerDefinition` (`id`, `when`, `effects`); `CaseContent.triggers` (bölüm sırası, sonra dosya sırası).
  DTO + `ContentPaths.triggersFile`; yükleme `AssetSceneContentRepository`'de.
- `GameProgress`: `firedTriggers` (küme), `hasFired`, `withFiredTrigger`.
- `scene_engine/domain/services/trigger_runner.dart` (saf): ateşlenmemiş tetikleyicileri dosya sırasıyla dolaşır;
  koşulu tutanın etkilerini `EffectApplier` ile uygular ve ID'sini `firedTriggers`'a yazar. Bir geçişte en az bir
  tetikleyici ateşlendiyse baştan dolaşır (bir tetikleyici diğerinin koşulunu sağlayabilir); hiçbiri ateşlenmeyince
  durur (**sabit nokta**). Geçiş sayısı sabit bir sınırı aşarsa durur ve hatayı log'a yazar (her tetikleyici en fazla
  bir kez ateşlendiği için normalde aşılmaz; motor hatasına karşı emniyet).
- `EffectPipeline`: 1.11'deki kanca `TriggerRunner`'ı çağırır. Tetikleyici etkileri ve olayları aynı tek kayda ve
  aynı olay listesine girer. Bağlam: mevcut sahne, hotspot yok.
- İzinli etkiler: `say`, `setFlag`, `addNote`, `giveItem` (+ `addNoteEntry`, 1.13'te eklenince).
- `ContentValidator`: tetikleyici ID'leri vaka içinde benzersiz; `do` boş değil ve yalnızca izinli etkiler; koşulda
  `usingItem` yok; referanslar ve metinler; tetikleyicilerin `setFlag`'i "set edilen bayrak" sayılır.
- Testler: runner (bir kez çalışma, sıra, zincir: A, B'nin koşulunu sağlar; döngü sınırı), hat (dokunuş + tetikleyici
  tek kayıt; kayıt başarısızsa `firedTriggers` de yazılmaz), DTO, doğrulayıcı.
  **Kabul kriterleri:** Sahte içerikli testte iki bayrak set edilince tetikleyici bir kez çalışıyor, tekrar çalışmıyor;
  `triggers.json` olmayan gerçek içerik aynen yükleniyor.
  **Commit:** `feat(scene_engine): add one-shot triggers`

### [ ] 1.13 Not satırları ve "Kişiler"
**Amaç:** Oyun ilerledikçe güncellenen dosyalar: bir karakterin ifadesi yeni bir not değil, kişi dosyasına eklenen bir
satırdır (ADR 0015).
**Yapılacaklar:**
- Kategori `suspect` → `person`: `NoteCategory`, DTO, ARB anahtarları (`notebookTabPeople`, `notebookEmptyPeople`;
  eski anahtarlar silinir), sekme adı "People", testler. Kimin şüpheli olduğu Aşama 5.5'te `case.json`'da tanımlanır.
- `NoteDefinition.entries` (opsiyonel katalog: `id`, `textKey`); DTO.
  ```json
  {"id": "person_pharmacist", "category": "person", "titleKey": "...", "bodyKey": "...",
   "entries": [{"id": "knows_villa", "textKey": "..."}, {"id": "pills_prescribed", "textKey": "..."}]}
  ```
- Yeni etki `AddNoteEntry(noteId, entryId)`:
  ```json
  {"addNoteEntry": {"note": "person_pharmacist", "entry": "knows_villa"}}
  ```
- Kayıt: `CollectedNote.entries: [{entryId, addedAtUtcMs}]` (`CollectedNoteEntry`); `GameProgress.withNoteEntry`.
- `EffectApplier`: not defterde değilse önce notu ekler (`NoteAdded`), sonra satırı; not defterdeyse satırı ekler,
  notu **yeniden okunmamış** yapar ve `NoteUpdated(noteId, entryId)` üretir. Satır zaten ekliyse hiçbir şey olmaz.
- `core/events`: `NoteUpdated`.
- `addNoteEntry` tetikleyicilerin izinli etkilerine eklenir (1.12).
- Defter arayüzü: sekmeler **Belgeler / Gözlemler / Kişiler**; notun gövdesinin altında satırlar eklenme sırasıyla;
  güncellenen not listede okunmamış görünür, rozet yanar; son eklenen satır not açılana kadar vurgulu. `NoteUpdated`
  gelince defter düğmesi kısa bir tepki verir (uçuş animasyonu yalnızca `NoteAdded`'da).
- `ContentValidator`: satır ID'leri not içinde benzersiz; `textKey` var; `addNoteEntry` var olan not ve satırı gösterir.
- Dilime içerik eklenmez (kişi notları 1.16'da); testler sahte içerikle.
- Testler: applier (not yokken, varken, tekrar), `GameProgress`, `NotebookCubit` (güncellenen not okunmamış olur,
  satır sırası), DTO, doğrulayıcı, widget testi (Kişiler sekmesi, satırların görünmesi).
  **Kabul kriterleri:** Sahte içerikle: satır eklenince rozet yeniden yanıyor, not açılınca satır görünüyor ve rozet
  sönüyor; `suspect` kelimesi `lib/`, `test/` ve `assets/` altında kalmıyor.
  **Commit:** `feat(notebook): add note entries and the People category`

### [ ] 1.14 İçerik düzeni: çoklu dosya, bölüm genişletmeleri, eksik bölüm
**Amaç:** İçerik dosya yapısını Bölüm 1 yazılmadan kesinleştirmek (ADR 0018): büyük bölümler birden çok dosyaya
bölünebilsin, sonraki bölüm öncekini kendi dosyasından genişletebilsin, demo yalnızca ilk bölümle derlenebilsin.
**Yapılacaklar:**
- **Tür başına dosya veya klasör:** bölüm klasöründe `scenes.json` **veya** `scenes/*.json`; aynısı `items`, `notes`,
  `inspections`, `triggers` (ve 1.16'da `dialogues`) için. İkisi birden varsa hata. Klasördeki dosyalar ad sırasıyla
  okunur ve tek dosyaymış gibi birleştirilir. Metinler dil başına tek dosya kalır (`text_xx.json`).
- `ContentAssetSource`'a listeleme: verilen önekin altındaki asset yolları (Flutter'ın asset manifest API'si; güncel
  dokümantasyondan uygulanır). Test paketi (`fake_asset_bundle.dart`) aynı listeyi bellekten verir. Yeni içerik
  klasörleri `pubspec.yaml`'a eklenir (klasör girdisi alt klasörleri kapsamaz).
- **`pubspec.yaml` kontrolü (içerik doğrulama testi):** `assets/content` altında içinde dosya bulunan **her klasör**
  `pubspec.yaml`'ın `flutter.assets` listesinde tanımlı olmalıdır. Test diski dolaşır, `pubspec.yaml`'ı okur ve eksik
  klasörü adıyla bildirerek **kırılır**. (Klasör eklemeyi unutmak "dosya bulunamadı" hatası değil, sessizce eksik
  içerik üretirdi: listeleme yalnızca paketlenen dosyaları görür.) Tersi de kontrol edilir: `pubspec.yaml`'da olup
  diskte olmayan içerik klasörü hatadır.
- **Eksik bölümün atlanması:** `case.json`'da listelenen ama pakette klasöründe **hiç** dosyası olmayan bölüm atlanır.
  Bir kısmı eksik bölüm (ör. `scenes` var, `items` yok) hatadır. İlk bölüm eksikse hata. Kural tek yerde
  (`CaseManifest`) uygulanır; sahne, eşya, not ve metin yükleyicileri aynı "mevcut bölümler" listesini kullanır.
  Demo derlemesinin paketlenmesi Aşama 11'dedir.
- **Bölüm genişletmeleri** (ilgili türün dosyasında, normal listenin yanında):
  ```json
  "sceneExtensions": [{"scene": "villa_hall",
    "hotspots": [ ...yeni hotspot'lar (sona eklenir)... ],
    "rules": [{"hotspot": "chest", "interactions": [ ...mevcut kuralların ÖNÜNE eklenir... ]}],
    "visualVariants": [ ...mevcutların ÖNÜNE eklenir... ]}]
  "noteExtensions": [{"note": "person_pharmacist", "entries": [ ...sona eklenir... ]}]
  ```
  (`dialogueExtensions` 1.16'da.) Birleştirme `data` katmanında yapılır (`scene_engine/data`, `notebook/data`);
  `domain` birleşmiş `CaseContent` ve not kataloğunu görür; kayıt şekli değişmez. Kurallar: hedef **önceki** bir bölümde
  olmalı; hedef sahne / hotspot / not yoksa hata; eklenen hotspot veya satır ID'si mevcutla çakışırsa hata.
  Genişletilen sahne kendi bölümüne ait kalır. Genişletmeler oyuncunun bölümüne göre kendiliğinden açılmaz; yazar
  koşulla kapatır ("bölüme ulaşıldı" koşulu 5.4'te).
- **Önek doğrulaması:** içerik doğrulama testi her bölüm önekini (B1; B1–2; ...) ayrı yükleyip doğrular: erken bölüm,
  geç bölümün ID'sine, bayrağına veya metnine bağımlı olamaz. Yükleyiciler bunun için "ilk N bölüm" ile sınırlanabilir.
- **Uyarı düzeyi:** `ContentIssue.severity` (`error` | `warning`). Test hatalarda kırılır, uyarıları yazdırır.
  İlk uyarı: **kullanılmayan metin anahtarı** (tam vakada; koddan kullanılan genel anahtarlar listesi doğrulayıcıya
  verilir).
- Testler **sahte içerikle** (`test/` altında iki bölümlü fixture): klasörden yükleme, dosya + klasör çakışması, ad
  sırası, her genişletme türü ve hata durumları, önüne/sonuna ekleme sırası, eksik ikinci bölüm (oyun B1 ile açılır),
  yarım bölüm (hata), eksik ilk bölüm (hata), `pubspec.yaml` kontrolü (geçici klasör + sahte pubspec metniyle: eksik
  girdi yakalanır), önek doğrulaması (B1'in B2 bayrağını okuması yakalanır), uyarı (kullanılmayan anahtar).
  Gerçek içerik (`ch01`) bu adımda değişmez.
  **Kabul kriterleri:** Gerçek içerik aynen yükleniyor ve doğrulanıyor; fixture'da B2'nin `villa_hall`'e eklediği
  hotspot ve kural birleşmiş içerikte doğru sırada; B2 klasörü silinince oyun B1 ile açılıyor.
  **Commit:** `feat(content): support multi-file chapters, chapter extensions and missing chapters`

### [ ] 1.15 Mekan geçişi: tabela, çarşı, tuzak kontrolü
**Amaç:** Haritasız mekan geçişini (ADR 0017) içerikle ve doğrulayıcıyla kurmak; dilime ikinci bir kök mekan eklemek.
**Yapılacaklar:**
- `HotspotSprite.overlays` (opsiyonel; sahne görseline göre normalize `TextOverlay` listesi). Nesneyle birlikte
  çizilir ve kaybolur; overlay katmanında (nesnelerin üstünde, noir filtrenin altında) yer alır.
  ```json
  {"id": "market_sign", "labelKey": "hotspot_market_sign",
   "rect": {"x": 0.06, "y": 0.44, "width": 0.14, "height": 0.34},
   "visibleWhen": {"hasNote": "hall_letter"},
   "sprite": {"rect": {"x": 0.07, "y": 0.44, "width": 0.12, "height": 0.34},
              "placeholderStyle": "sprite_market_sign",
              "overlays": [{"type": "text", "textKey": "market_sign_text", "style": "engraved",
                            "rect": {"x": 0.08, "y": 0.47, "width": 0.10, "height": 0.06}}]},
   "interactions": [{"do": [{"goToScene": "market_square"}]}]}
  ```
  (Koordinatlar ve overlay stili placeholder çizimine göre ayarlanır; yeni stil gerekirse `core/theme`'e eklenir.)
- `SceneStackResolver` **değişmez**: kök sahneye gidince yığın tek elemanlıdır, Geri görünmez. Bunu sabitleyen bir
  test eklenir (kökten köke geçiş).
- `ContentValidator`:
  - **hata (tuzak mekan):** her kök sahneden (`parentId` yok), o sahnenin bölümünün giriş sahnesine `goToScene`
    etkileri ve Geri (ebeveyn) üzerinden bir yol olmalı. Koşullar hesaba katılmaz (yolun *yazılmış* olduğu kanıtlanır;
    her zaman *açık* olduğu 7.4'teki walkthrough ile).
  - **uyarı (çapraz bağlantı):** `goToScene` hedefi mevcut sahnenin çocuğu, ebeveyni veya bir kök sahne değilse.
  - Nesne overlay'leri: `rect` 0–1, metin anahtarı ve stil tanımlı.
- İçerik kuralı (yazım kuralı; doğrulayıcı "iç mekan"ı bilemez): her iç mekanın merkez sahnesinde bir çıkış hotspot'u.
- Dilim içeriği:
  - `villa_hall`: `pill_bottle` (alınabilir nesne: `sprite` + `glint`; `giveItem` + `hideHotspot` + `say`).
    `items.json`: `pill_bottle`.
  - `villa_exterior`: `market_sign` (yukarıdaki; `hasNote: hall_letter` ile belirir, üstünde overlay yazı).
  - Yeni kök sahne `market_square` (ilk girişte dedektif yorumu); içinde `villa_road` çıkışı →
    `goToScene: villa_exterior`.
  - Placeholder çizimler (`core/placeholders`): `market_square`, `sprite_market_sign`, `sprite_pill_bottle` ve şişenin
    eşya ikonu. Metinler `text_en.json`'da.
- Testler: DTO, doğrulayıcı (tuzak mekan fixture'ı, çapraz bağlantı uyarısı, bozuk nesne overlay'i), widget testi
  (tabela mektuptan önce yok, sonra yazısıyla birlikte var; gizlenince yazısı da yok), bloc testi (çarşıda
  `canGoBack == false`, `villa_road` ile dönüş).
  **Kabul kriterleri:** Kabul senaryosunun 12–13. adımları (silüetler hariç) ve 20. adımın dönüşü telefonda ve
  Windows'ta çalışıyor; mevcut 1–11 kabul testi geçiyor.
  **Commit:** `feat(scene_engine): add sprite overlays, travel checks and the market square`

### [ ] 1.16 Konuşma: domain ve içerik (arayüz yok)
**Amaç:** Konuşma sisteminin kurallarını saf Dart ile ve testlerle kurmak (ADR 0016). Bu adımın sonunda silüetler
sahnede durur, mantık testlerle kanıtlanmıştır; panel 1.17'de gelir.
**Yapılacaklar:**
- Yeni feature `features/dialogue/`. `domain/entities`: `DialogueDefinition` (`id`, `nameKey`, `portrait`
  (`placeholderStyle`, `image?`), `greeting` (tek anahtar veya `first`/`then`), `noReactionKey`, `topics`),
  `DialogueTopic` (`id`, `promptKey`, `answer` (satır anahtarları), `visibleWhen?`, `trigger?`, `effects`),
  `TopicTrigger` (`showItem` | `showNote`). `DialogueCatalogRepository` (abstract).
- İçerik: bölüm klasöründe opsiyonel `dialogues.json` (veya `dialogues/*.json`):
  ```json
  {"formatVersion": 1, "dialogues": [{
    "id": "pharmacist",
    "nameKey": "char_pharmacist_name",
    "portrait": {"placeholderStyle": "silhouette_pharmacist"},
    "greeting": {"first": "dlg_pharmacist_hello", "then": "dlg_pharmacist_again"},
    "noReactionKey": "dlg_pharmacist_no_reaction",
    "topics": [
      {"id": "about_villa", "promptKey": "...", "answer": ["...", "..."],
       "do": [{"addNoteEntry": {"note": "person_pharmacist", "entry": "knows_villa"}}]},
      {"id": "ask_pills", "visibleWhen": {"hasItem": "pill_bottle"}, "promptKey": "...", "answer": ["..."],
       "do": [{"say": "say_pills_owner_known"}]},
      {"id": "give_pills", "trigger": {"showItem": "pill_bottle"}, "promptKey": "...", "answer": ["..."],
       "do": [{"consumeItem": "pill_bottle"},
              {"addNoteEntry": {"note": "person_pharmacist", "entry": "pills_prescribed"}}]},
      {"id": "show_letter", "trigger": {"showNote": "hall_letter"}, "promptKey": "...", "answer": ["..."]}
    ]}]}
  ```
- `dialogue/data`: konuşmanın **kendi** DTO'ları + `AssetDialogueCatalogRepository`. Koşul ve etkiler
  `scene_engine/domain`'deki `RuleParser` arayüzüyle ayrıştırılır (`parseCondition`, `parseEffects`; uygulaması
  `scene_engine/data`'daki codec'ler; DI ile verilir): bir feature'ın `data` katmanı başka bir feature'ın `data`
  katmanını import edemez. `RuleParser` arayüzü ve uygulaması bu adımda eklenir; sahne DTO'ları codec'leri doğrudan
  kullanmaya devam eder.
- **Bağımlılık yönü tektir: `dialogue` → `scene_engine`** (1.11'deki döngü testi zorlar). `scene_engine` hiçbir
  dosyasında `dialogue`'u import etmez: `Talk` etkisi ve `topicAsked` koşulu yalnızca ID (string) taşır; sahne
  doğrulayıcısı var olan konuşma / konu ID'lerini düz veri olarak (`Map<String, Set<String>>`) parametreyle alır.
- `dialogueExtensions` (1.14'teki düzenle; konular sona eklenir; hedef önceki bölümde; konu ID'si çakışırsa hata):
  ```json
  "dialogueExtensions": [{"dialogue": "pharmacist", "topics": [ ...sona eklenir... ]}]
  ```
- Yeni etki `{"talk": "dialogueId"}` (`Talk`): `EffectApplier` yalnızca `EffectOutcome.dialogueId`'yi doldurur;
  ilerlemeye ve yığına dokunmaz. `TapOutcome.dialogueId`. (`SceneBloc` bu değeri 1.17'de kullanır.)
- Yeni koşul `{"topicAsked": "dialogueId/topicId"}`; `GameProgress.askedTopics` (küme), `hasAsked`, `withAskedTopic`.
- Saf servis `DialogueViewResolver`: **görünürlük = sorulmuş VEYA (`trigger` yok ve `visibleWhen` tutuyor)**; her
  görünür konu için `isAsked` / `isNew`. Bir kez sorulan konu, koşulu sonradan bozulsa bile listede kalır.
- Use case'ler (hepsi `EffectPipeline` üzerinden):
  - `StartConversation(dialogueId)`: karşılama anahtarını döner (`first` daha önce duyulmadıysa `first`, yoksa
    `then`) ve `first`'ü `spokenLines`'a yazar. Bu yazım da **etki hattından** geçer (ön değişiklik =
    `withSpokenLine`, etki yok): tetikleyiciler değerlendirilir, tek `save`. `talk` etkisinin kendisi bir şey kaydetmez.
  - `AskTopic(dialogueId, topicId)`: konu görünür değilse hiçbir şey yapmaz. İlk soruluşta `do` etkilerini uygular,
    `askedTopics`'e yazar, `TopicAsked` olayı üretir; tetikleyiciler aynı kayıtta değerlendirilir. Tekrar soruluşta
    ilerleme değişmez. Her durumda oynatılacak `answer` satırlarını döner.
- Konu `do` izinli etkileri: `say`, `setFlag`, `addNote`, `addNoteEntry`, `giveItem`, `consumeItem`.
  Konuşma satırları `chatLog`'a yazılmaz.
- Doğrulama iki parçadır (döngü olmasın diye): `scene_engine`'deki `ContentValidator` sahne tarafını (`talk` ve
  `topicAsked` referansları, kural kısıtları) verilen ID'lerle kontrol eder; `dialogue/domain`'deki `DialogueValidator`
  konuşmaları kontrol eder ve koşul / etki referans kontrolleri için `ContentValidator`'ın açtığı yardımcıları
  kullanır. İkisi de `ContentIssue` listesi döner; içerik doğrulama testi birleştirir. Kontroller: konuşma ID'leri
  vaka içinde, konu ID'leri konuşma içinde benzersiz; `nameKey`, `greeting`, `noReactionKey`, `promptKey` ve boş olmayan `answer` metinleri var; portre
  stili kodda tanımlı; `do` yalnızca izinli etkiler; koşullarda `usingItem` yok; `trigger` tam olarak bir `showItem`
  veya `showNote` içerir ve gösterdiği eşya / not vardır; `talk` ve `topicAsked` var olan konuşmayı / konuyu gösterir;
  bir kuralda en fazla bir `talk`, `goToScene` / `inspect` ile birlikte değil; `talk` `onFirstEnter`, tetikleyici ve
  konu etkilerinde yok; `greeting.first` anahtarları `say` `first` anahtarlarıyla birlikte benzersiz;
  **uyarı:** hiçbir `talk` ile açılmayan konuşma.
- Dilim içeriği (`market_square`):
  - `pharmacist` ve `cafe_owner` hotspot'ları: silüet `sprite` (`silhouette_pharmacist`, `silhouette_cafe_owner`;
    basit placeholder çizimler bu adımda, cilası 1.20'de), `{"do": [{"talk": "..."}]}`.
  - `pharmacist`: `about_villa` (+ dosyaya satır), bir sabit konu daha, `ask_pills` (`hasItem: pill_bottle`),
    `give_pills` (`showItem: pill_bottle`). **Eczacıda `show_letter` yoktur** (kabul senaryosu 18: `noReactionKey`).
  - `cafe_owner`: `about_villa` (+ dosyaya satır), bir sabit konu daha, `show_letter` (`showNote: hall_letter`).
  - `notes.json`: `person_pharmacist`, `person_cafe_owner` (`person`, satırlarıyla), `obs_stories_do_not_match`
    (`observation`). `triggers.json`: `both_asked_about_villa` (1.12'deki örnek).
- Testler: resolver (görünürlük tablosu: sorulmuş/sorulmamış × koşul × `trigger`), `AskTopic` (ilk / tekrar,
  görünmeyen konu, tek kayıt, tetikleyici bir kez), `StartConversation` (`first` → `then`), codec ve DTO, genişletme,
  doğrulayıcının her yeni kuralı.
  **Kabul kriterleri:** Kabul senaryosunun 14–16. ve 19. adımlarının mantığı use case testleriyle doğrulanmış (arayüz
  yok); içerik doğrulama testi yeşil; `dialogue/domain`'de Flutter import'u yok.
  **Commit:** `feat(dialogue): add dialogue domain, content format and talk effect`

### [ ] 1.17 Konuşma paneli
**Amaç:** Konuşmayı oynanır hale getirmek: silüete dokun, soruyu seç, cevabı satır satır oku.
**Yapılacaklar:**
- `SceneBloc`: `activeDialogueId` (arayüz durumu; kayda girmez), `DialogueClosed` olayı. `talk` sonucu doldurur.
  Panel açıkken hotspot dokunuşları yok sayılır; `BackPressed` önce paneli kapatır, yığına dokunmaz. Paneller üst
  üste binmez: konuşma açıkken `InspectionRequested` (eşyaya uzun basma) yok sayılır.
- `dialogue/presentation`: `DialogueCubit` (konuşma + ilerleme akışı → görünür konular; durum: karşılama veya cevap
  satırları oynuyor / soru listesi). `advance()`: yazılan satır tamamlanmamışsa tamamlar, tamamlanmışsa sonraki
  satıra geçer; son satırdan sonra soru listesine döner. Açılışta `StartConversation`, konu seçilince `AskTopic`.
- `DialoguePanel`: karakterin adı, portresi (placeholder silüet), satır alanı (daktilo efekti; süreler `core/theme`)
  ve soru listesi. Sorulmamış görünür konu **"yeni"** etiketi, sorulmuş konu işaret taşır (metinler ARB'den).
  Sahnedeki silüette işaret yoktur.
- **4 soru kaydırmasız:** en küçük hedef telefon yüksekliğinde (360 dp yükseklik, yatay) dört soru kaydırmadan
  görünür; fazlası kaydırılır. Ölçüler `core/theme`'de (`DialogueLayout`); widget testi 640×360'ta dördüncü sorunun
  görünür ve dokunulabilir olduğunu doğrular.
- Yerleşim (`app/` katmanı birleştirir): panel sahne alanının üstünde açılır; eşya panelini ve mesaj barının alt
  şeridini kapatmaz (dedektifin `say` yorumu konuşma sırasında barda görünür). Güvenli alanlara uyar.
- Geri sırası: not defteri / mesaj geçmişi → konuşma paneli → sahne. Sistem geri tuşu ve `Esc` aynı.
- Fare tıklaması dokunmayla aynı çalışır; hover'a bağlı hiçbir şey yok.
- Testler: `DialogueCubit` (`bloc_test`: açılış karşılaması, satır ilerletme, tamamla-sonra-geç, listeye dönüş, yeni /
  sorulmuş, tekrar sorma), `SceneBloc` (panel açıkken dokunuş yok sayılır, Geri paneli kapatır), widget testleri
  (4 soru, etiketler, panel açıkken sahneye dokunulamaması).
  **Kabul kriterleri:** Kabul senaryosunun 14–16. ve 19. adımları telefonda ve Windows'ta çalışıyor.
  **Commit:** `feat(dialogue): add dialogue panel`

### [ ] 1.18 Eşya verme ve kanıt gösterme
**Amaç:** Toplananların sorguda da işe yaraması: doğru şeyi doğru kişiye göster (ADR 0016).
**Yapılacaklar:**
- `InteractionResolver` (tek yeni kural): eşya seçiliyken önce bugünkü gibi `usingItem` adaylarına bakılır. Hiçbiri
  tutmuyorsa eşyasız dokunuşta çalışacak kural bulunur; o kural `talk` içeriyorsa etkileri döner ve
  `ResolvedInteraction.shownItemId` dolar (genel tepki verilmez, `ItemUsed` üretilmez). `talk` içermiyorsa eskisi
  gibi yalnızca genel tepki. Hotspot'a eşya başına `usingItem` kuralı yazılmaz.
- Use case `ShowToCharacter(dialogueId, item | note)` (`dialogue/domain`, hat üzerinden): oyuncu eşyayı / notu
  taşımıyorsa hiçbir şey yapmaz. `trigger`'ı eşleşen ve (varsa) `visibleWhen` koşulu tutan **ilk** konuyu bulur:
  sorulmamışsa `AskTopic` gibi oynatır (`do` çalışır, `askedTopics`'e yazılır; vermek = `consumeItem`); sorulmuşsa
  yalnızca cevabı yeniden oynatır. Eşleşme yoksa `noReactionKey` satırını döner; ilerleme değişmez, ceza ve işaret yok.
- Sahneden gösterme: `SceneBloc` paneli gösterilecek eşyayla açar; `DialogueCubit` karşılamadan sonra tepkiyi oynatır.
- Panel açıkken: sağ paneldeki eşyaya **tek dokunuş = göster** (seçim yapılmaz). `GameScreen` yönlendirir; `inventory`
  konuşmayı bilmez.
- Not gösterme: panelde **"Kanıt göster"** düğmesi defteri **seçim modunda** açar; açık notta **"Göster"** düğmesi
  (ARB). Seçilince defter kapanır ve tepki oynar. Konuşma açıkken HUD'daki defter düğmesi de defteri seçim modunda
  açar. Not yalnızca kişilere gösterilir; `usingNote` koşulu yoktur.
- Gösterilerek oynayan konu sonra listede `promptKey` ile, sorulmuş olarak görünür.
- Testler: resolver (eşya + `talk` kuralı; açık `usingItem` kuralı önce gelir; `talk` yoksa genel tepki),
  `ShowToCharacter` (eşleşme, tekrar gösterme, koşulu tutmayan, eşleşmeyen → `noReactionKey`, taşınmayan eşya),
  `NotebookCubit` (seçim modu), widget testleri (panel açıkken eşya dokunuşu, "Kanıt göster" akışı).
  **Kabul kriterleri:** Kabul senaryosunun 17–18. adımları telefonda ve Windows'ta çalışıyor; şişe verildikten sonra
  "İlacı sor" listede kalıyor.
  **Commit:** `feat(dialogue): show evidence and give items to characters`

### [ ] 1.19 Geliştirici menüsü (yalnızca dev)
**Amaç:** 50 sahnelik bir bölümde belirli bir duruma saniyeler içinde gelebilmek; her denemede baştan oynamamak.
**Yapılacaklar:**
- `lib/app/dev/`: geliştirici menüsü; mevcut hotspot düğmesinin yanından açılır.
- **Prod, staging ve Steam derlemesinde açılamaz; kodu o derlemelere girmez.** Menü bir çalışma zamanı bayrağına
  (`AppConfig.showDebugOverlay`, `SHOW_DEBUG_OVERLAY`) bağlı **değildir**: yalnızca `lib/main_dev.dart` menüyü
  (`lib/app/dev/`) import eder ve `bootstrap`'e verir; `main_staging.dart`, `main_prod.dart` ve `main_steam.dart`
  vermez. Oyun kodu menüyü yalnızca opsiyonel, enjekte edilmiş bir widget oluşturucu olarak tanır; verilmemişse düğme
  çizilmez. Böylece diğer giriş noktalarından derlenen uygulamada menü kodu hiç yoktur (tree shaking) ve hiçbir env
  değeriyle açılamaz. Mimari testi: `lib/` içinde `app/dev/`'i import eden tek dosya `main_dev.dart`'tır.
- İşlevler: sahne listesinden atlama; eşya / not / bayrak ekleme; ilerlemeyi sıfırlama; adlandırılmış durum yükleme.
  Hepsi etki hattından geçer (atlama = `EnterScene`; ekleme = `giveItem` / `addNote` / `setFlag` etkileri; sıfırlama
  ve preset = yeni bir `GameProgress` + giriş).
- `assets/dev/presets.json`:
  ```json
  {"formatVersion": 1, "presets": [
    {"id": "market_with_pills", "scene": "market_square",
     "items": ["pill_bottle"], "notes": ["hall_letter"], "flags": ["front_door_open"]}
  ]}
  ```
- **Preset dosyası yalnızca dev flavor'ında paketlenir** (Flutter'ın flavor'a bağlı asset paketlemesi; dokümanda
  örnekler klasör yoluyladır, bu yüzden klasör girdisi kullanılır):
  ```yaml
  flutter:
    assets:
      - path: assets/dev/
        flavors:
          - dev
  ```
  Prod ve staging APK'sına girmez. Windows'ta flavor olmadığı için orada (Steam dahil) hiç paketlenmez; bu kabul
  edildi: Windows'ta `main_dev.dart` ile çalışırken menünün diğer işlevleri çalışır, preset listesi boş görünür
  (dosya yoksa menü çökmez). **Adım başlarken doğrulanacak** (doküman açıkça yazmıyor): flavor'sız derlemede
  (`flutter build windows`) ve `--flavor prod` APK'sında dosyanın gerçekten bulunmadığı, `--flavor dev`'de bulunduğu;
  tek dosya yolu ile de çalışıp çalışmadığı. Sonuç devlog'a yazılır.
  **Uygun çıkmazsa yedek yol:** preset'ler asset olmaz; `lib/app/dev/` içinde Dart sabiti olarak durur (yalnızca
  `main_dev.dart`'tan erişildiği için diğer derlemelere girmez). Bu, "ID'ler kodda yazılmaz" kuralının geliştirici
  aracına özel bir istisnası olur ve kullanıcıya sorulur.
- İçerik doğrulama testi preset'lerdeki her sahne, eşya, not ve bayrağın içerikte var olduğunu kontrol eder. Test
  dosyayı **diskten** okur (`flutter test` flavor'sız çalışır; paket içinde dosya yoktur).
- Menü metinleri ARB'de (kodda kullanıcıya görünen literal olmaz).
- Kaydı JSON olarak panoya verme / alma bu adımda **yok**; 2.2'de eklenir (kayıt DTO'su orada doğar).
- Testler: preset ayrıştırma ve doğrulama; menü işlevleri (atla, ekle, sıfırla, preset; preset dosyası yokken boş
  liste) için widget testleri; menü verilmeden kurulan oyunda düğmenin olmadığı; mimari testi (`app/dev/` import'u).
  **Kabul kriterleri:** Android dev'de `market_with_pills` yüklenince oyun çarşıda, şişe panelde, mektup defterde
  açılıyor; prod, staging ve Steam giriş noktalarında menü yok ve `SHOW_DEBUG_OVERLAY` ile de açılmıyor; prod APK'sında
  `assets/dev/presets.json` yok.
  **Commit:** `feat(app): add developer menu`

### [ ] 1.20 Çarşı demosunun kabul testi ve cila
**Amaç:** Aşama 1b'yi sağlam kapatmak: genişleyen kabul senaryosu (1–20) otomatik ve cihazda çalışsın.
**Yapılacaklar:**
- Paylaşılan senaryo fonksiyonu (`test/helpers/acceptance_scenario.dart`) 12–20. adımlarla genişler; iki yerden
  çalışır: CI widget testi (telefon boyutu dokunma + fare, 1280×720 pencere, 4:3) ve `integration_test` (telefon,
  Windows).
- Kenar durumları (`edge_cases_test.dart`): satır yazılırken hızlı çift dokunma, panel açıkken sistem geri tuşu ve
  `Esc`, panel açıkken arka plana alıp dönme, seçim modundaki defterde Geri, eşya seçiliyken silüete dokunma.
- Placeholder çizimlerin cilası: çarşı, iki silüet ve portreleri, tabela, ilaç şişesi (noir, anlaşılır).
- Telefonda manuel kontrol listesi ve `flutter run --profile` ölçümü (panel açılışı ve daktilo efekti 60 fps'i
  bozmuyor); sonuç devlog'a.
- README: Features'a konuşma, kanıt gösterme, tetikleyiciler ve geliştirici menüsü; içerik düzeni ve örnek
  `dialogues.json`; ekran görüntüleri yenilenir (`tool/render_screenshots_test.dart`).
- Devlog: `docs/devlog/asama-1.md`'de 1b özeti.
  **Kabul kriterleri:** Kabul senaryosunun tamamı (1–20) CI'da ve Windows'ta geçiyor; telefonda manuel doğrulandı
  (cihaz yoksa kullanıcıya bırakılan maddeler Notlar'a yazılır); CI yeşil.
  **Commit:** `test: extend the acceptance scenario with the market demo`
  **Aşama sonu:** `phase-1b` etiketi.

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
  Kayıt şekli Aşama 1b'nin alanlarını **ilk sürümden** içerir: `askedTopics`, `firedTriggers`, `spokenLines`, notlarda
  `entries` (`[{entryId, addedAtUtcMs}]`); `chatLog` en fazla 200 giriş.
- Geliştirici menüsüne (1.19) **kaydı JSON olarak panoya verme / panodan alma** eklenir (aynı DTO ve `SaveMigrator`
  ile; hata bildirimlerinde durumu paylaşmak ve yeniden üretmek için). Yalnızca dev.
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
- Açılışta kayıt varsa sahne yığını, eşyalar, notlar (satırlarıyla), bayraklar, gizlenen hotspot'lar, sorulan konular,
  ateşlenen tetikleyiciler, söylenen replikler ve chat geçmişi geri yüklenir.
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
- **Bölüm 1 sonunda hesap bağlama önerisi** (5.4'ten taşındı): 5.4'te kurulan bölüm sonu ekranına, anonim oyuncu için
  "İlerlemeni güvenceye al" önerisi eklenir. Reddedilebilir; oyunu bekletmez.
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
**Sıra:** Aşama 2'den hemen sonra, Aşama 3–4'ten önce yapılır (bkz. "Çalışma sırası"). Hesap ve ses gerektiren
parçalar işaretlidir; ilgili aşama gelince bağlanır.

- [ ] 5.1 Bulmaca altyapısı: `OpenPuzzle` etkisi, `PuzzleDefinition` (tür, çözüm, `onSolved` etkileri), ortak bulmaca çerçevesi (aç, dene, kapat).
- [ ] 5.2 Kilit bulmacaları: rakamlı tuş takımı, döner kombinasyon kilidi, saat kadranı, harf kilidi. Hepsi JSON'dan.
- [ ] 5.3 Kayıt inceleme (`PlayMedia`): oynat / durdur / kare kare, ekranda zaman damgası; biçim kararı (kare dizisi veya video).
  Ses Aşama 6 gelince bağlanır (6.1); bu adımda medya sessiz oynar.
- [ ] 5.4 Bölüm akışı: `case.json`'da bölüm bitiş koşulları, gerilimli bölüm sonu ekranı,
  bölüm kilidi için `EntitlementRepository` arayüzü (dev'de hepsi açık; mobil satın alma Aşama 8'de,
  Steam sahipliği Aşama 11'de). Bölüm 1 sonundaki hesap bağlama önerisi Aşama 3 gelince bağlanır (3.3).
  **"Bölüme ulaşıldı" koşulu** (yeni koşul türü; ADR ile) ve bölüm genişletmelerinin (1.14: `sceneExtensions`,
  `dialogueExtensions`, `noteExtensions`) oyuncunun bölümüne göre açılması: sonraki bölümün eklediği içerik, oyuncu o
  bölüme ulaşmadan görünmez.
- [ ] 5.5 Suçlama: 7 şüpheli; isim + 2–3 kanıt (not defterinden); doğru cevap ve geçerli kanıtlar `case.json`'da;
  2 hak; sonra "Vakayı baştan oyna" / "Cevabı gör"; paylaşılabilir sonuç ekranı (deneme sayısı, süre, ipucu sayısı).
- [ ] 5.6 İpucu sistemi: ilerlemeye göre bağlamsal, kademeli ipuçları (yön → net → cevap); uzun hareketsizlikte
  dedektifin kendiliğinden yönlendirmesi. İpucu tanımları JSON'da, koşullarla.
  **"Dokunulabilir yerleri göster" yardımı:** sahnedeki hotspot'ları kısa süre işaretler. İşaretin türü (geçiş, alınacak
  nesne, kişi, incelenecek yer) hotspot'un o an çalışacak kuralının etkilerinden türetilir (`goToScene`, `giveItem` /
  `addNote`, `talk`, `inspect`); JSON'a yeni alan eklenmez.
- [ ] 5.7 Eşya birleştirme ve eşyanın içini açma: `items.json`'da eşyaya opsiyonel `interactions` (aynı kural dili,
  aynı `InteractionResolver`). **Aç:** inceleme kartında düğme; eşyanın eşyasız kuralını çalıştırır (zarfın içinden
  mektup çıkar). **Birleştir:** A seçiliyken paneldeki B'ye dokunma; iki yön de denenir (B'nin `usingItem: A` kuralı,
  yoksa A'nın `usingItem: B` kuralı), hiçbiri tutmazsa genel tepki. Etkiler etki hattından geçer.

## Aşama 6 — Oyun hissi ve uygulama kabuğu
*(Başlarken: açık kararları sor, adımları detaylandır, onay al.)*

- [ ] 6.1 Ses: ambiyans döngüsü, efektler, geçişlerde `sfx` + `holdMs` (karanlık ses bitene kadar uzayabilir), kayıt
  incelemenin (5.3) sesi, ses ayarları, arka planda susma.
- [ ] 6.2 Dokunsal geri bildirim ve mikro animasyonlar.
- [ ] 6.3 Uygulama ikonu, açılış ekranı (native splash), ana menü (Devam / Yeni Oyun / Ayarlar), yeni oyun onayı.
- [ ] 6.4 Ayarlar: ses, dil (birden fazla dil desteklendiğinde), hesap ve eşitleme durumu, gizlilik politikası bağlantısı, sürüm bilgisi.
- [ ] 6.5 Performans ve erişilebilirlik: komşu sahnelerin önceden yüklenmesi, kullanılmayan görsellerin bellekten atılması,
  bellek ölçümü, yazı ölçeği, kontrast.

## Aşama 7 — Hikaye, içerik ve görseller
*(Başlarken: açık kararları sor, adımları detaylandır, onay al.)*

**Sıra:** İki parçada yapılır (bkz. "Çalışma sırası"). 7.0–7.4 (private repo, Bölüm 1 ve oyun testi) Aşama 5'ten hemen sonra;
7.5 (Bölüm 2–4) Aşama 6'dan sonra. Oyun testinden önce 9.1 (çökme raporlama) kurulur. Oyun testinin sonucu Aşama 3'e geçmeden önce değerlendirilir; bulmaca veya
hikaye değişikliği gerekiyorsa önce o yapılır.

- [ ] 7.0 **Repoyu private yap** — hikaye, bulmaca çözümleri ve görseller repoya girmeden önce (spoiler ve içerik
  koruması). Bu adım bitmeden `docs/story/`, bulmaca çözümü içeren JSON veya gerçek görsel commit edilmez.
  `gh repo edit asklife23/DetectiveDark --visibility private --accept-visibility-change-consequences`
  (dışa dönük ve geri alınması zor bir işlem: çalıştırmadan önce kullanıcıdan onay alınır).
  Private repoda GitHub Actions dakika sınırını kontrol et (ücretsiz planda aylık kota; Windows ve macOS
  makineleri kotadan daha hızlı düşer); gerekirse CI'ı sadece `main` push'larında çalıştır (`pull_request`
  tetikleyicisini kaldır). README'deki CI rozeti private repoda herkese görünmez; portföy görünürlüğü
  (ör. içeriksiz açık bir vitrin reposu) bu adım başlarken konuşulur.
- [ ] 7.1 Vaka 1 kurgusu (kullanıcıyla birlikte): olay, kurban, 7 şüpheli, gerçek çözüm, bulmaca zinciri, bölüm kapanışları.
  Sonuç `docs/story/` altında.
- [ ] 7.2 Dev flavor'da hotspot ve overlay editörü: hotspot ve yazı (overlay) dikdörtgenlerini sürükleyip koordinatları
  JSON'a kopyalayan mini araç (çok sahneli bölümler için şart).
- [ ] 7.3 Sanat yönü ve **AI destekli** üretim hattı (ADR 0011): araç seçimi ve ticari kullanım koşulları; stil rehberi
  (palet, ışık, dönem, kompozisyon, prompt şablonları, referans görseller); görsellerde yazı/sayı olmaması (prompt +
  elle temizlik; kritik yazılar overlay); yakın planları ana görselden kırpma/inpainting ile tutarlılık; noir filtre
  preset'lerinin gerçek görsellerle ayarı; çözünürlük ve boyut bütçesi (WebP); placeholder → `background` geçişi.
  **Alınabilen nesneler (ADR 0012) arka plana çizilmez:** arka plan nesnesiz üretilir; nesne ayrı, **şeffaf arka
  planlı** (alfa kanallı WebP/PNG) bir görsel olarak üretilir ve hotspot'un `sprite` alanına bağlanır. Nesnenin ışığı
  ve perspektifi arka planla uyumlu olmalı; gölgesi nesne görseline dahil edilir.
  Her görsel için üretim kaydı (araç, model, tarih, prompt, elle yapılan düzenlemeler): `docs/art/ai-usage.md`
  (Steam AI açıklamasının kaynağı, bkz. 11.5).
- [ ] 7.4 Bölüm 1 içeriği (sahne sayısı hikayeyle belirlenir; tahmin ~40–50, inceleme pencereleri yakın plan
  ihtiyacını azaltır) ve **10–15 kişiyle oyun testi**. Yön bulma kararı verildi (harita yok, ADR 0017); testte yalnızca
  mekanlar arası yolların uzun gelip gelmediğine bakılır (çözüm yeni bir geçiş noktasıdır).
  **Bölüm başına `walkthrough.json`:** bölümü baştan sona bitiren adım listesi (hotspot'a dokun, eşyayla dokun, konu
  sor, eşya / not göster). CI'da arayüz olmadan **motor üzerinde** oynatılır (use case'ler + etki hattı) ve bölümün
  bitirilebildiği kanıtlanır; içerik değişikliği bölümü kilitlerse test kırılır. Spoiler içerdiği için 7.0'dan sonra
  repoya girer.
  Test sürümü dağıtılmadan önce 9.1 (çökme raporlama) tamamlanmış olmalıdır.
- [ ] 7.5 Bölüm 2–4 içeriği. *(Aşama 6'dan sonra yapılır.)*

## Aşama 8 — Para kazanma (mobil)
*(Başlarken: açık kararları sor, ADR yaz.)*

- [ ] 8.1 Model ayrıntıları: Vaka 1'in kalanı için satın alma biçimi, fiyat, ipucu/reklam kararı; ADR.
- [ ] 8.2 Satın alma altyapısı (RevenueCat önerisi): ürünler, yetkiler, "Satın alımları geri yükle" (iOS zorunlu).
- [ ] 8.3 (Seçilirse) Ödüllü reklam + GDPR/KVKK onay formu + iOS izleme izni.
- [ ] 8.4 `EntitlementRepository`'nin mobil uygulaması: yetki mağazadan doğrulanır; yerel kayıt sadece önbellek.

## Aşama 9 — Kalite ve gözlem
*(Başlarken: açık kararları sor, adımları detaylandır, onay al.)*

- [ ] 9.1 Çökme raporlama (flavor bazlı, kişisel veri gönderilmez). **Öne alındı:** Bölüm 1 oyun testinden (7.4) önce
  yapılır (bkz. "Çalışma sırası"). Yakalanmamış hatalar (`FlutterError.onError`, `PlatformDispatcher.onError`)
  release derlemede de raporlanır; test sürümünün platformlarında (Android, Windows) çalışır.
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
- [ ] 11.2 PC deneyimi: pencere / tam ekran, çözünürlük ve yüksek DPI, klavye kısayolları (`Esc` = geri Aşama 1'de
  eklendi; burada menü ve diğer kısayollar),
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
  macOS gerektiğinde `flutter create --platforms=macos .` ile geri eklenir (adım 11.7).
- 2026-11-11 (0.2): Kullanıcı isteğiyle `.gitattributes` eklendi (`* text=auto eol=lf`, `.bat`/`.cmd` için `crlf`,
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
- 2026-11-13: Aşama sırası değişti: 1 → 2 → 5 → 7 (yalnızca Bölüm 1 ve oyun testi) → 3 → 4 → 6 → 7'nin kalanı
  (Bölüm 2–4) → 8 → 9 → 10 → 11. Numaralar aynı kaldı; sıra "Çalışma sırası" bölümünde. Gerekçe: Önce oyunun
  eğlenceli olduğunu doğrula; bulut eşitleme eğlenceyi etkilemez. Bölüm 1 sonundaki hesap bağlama önerisi 5.4'ten
  3.3'e, kayıt incelemenin sesi 5.3'ten 6.1'e taşındı. `Sıradaki adım` komutu artık bu sırayı izler (CLAUDE.md
  güncellendi).
- 2026-11-13: Aşama 7'nin başına 7.0 eklendi: hikaye, bulmaca çözümleri ve görseller repoya girmeden önce repo
  private yapılır (spoiler ve içerik koruması). Actions kotası ve portföy görünürlüğü o adımda değerlendirilir.
- 2026-11-13 (Aşama 0 incelemesi): 9.1 (çökme raporlama) Bölüm 1 oyun testinin (7.4) önüne alındı. Gerekçe: release
  derlemede `AppLogger` hiçbir yere yazmıyor; testçilerdeki hatalar görünmezdi. Numara aynı kaldı; sıra ve bağımlılık
  "Çalışma sırası"nda. Aşama 9'un kalanı (9.2–9.4) yerinde.
- 2026-11-13 (Aşama 0 incelemesi): CI'a Android derleme işi eklendi (`.github/workflows/android.yml`): `dev` flavor debug
  APK. Yalnızca `android/**`, `pubspec.*`, `lib/main_*.dart` veya iş akışının kendisi değişince çalışır (Actions
  kotasını korumak için ayrı dosya + `paths` filtresi; `ci.yml`'deki işler her push'ta çalışmaya devam eder).
- 2026-11-13 (Aşama 1 öncesi mimari inceleme): Aşama 1 adımları `docs/game_design.md`, `CLAUDE.md` ve ADR'lerle
  karşılaştırılıp düzeltildi. Oyun tasarımı, ADR'ler ve diğer aşamalar değişmedi. Değişiklikler ve gerekçeleri:
  - **Atomik kayıt (1.1, 1.3):** `ProgressRepository`'nin tek tek yazan metotları (`addItem`, `setFlag`...) kaldırıldı;
    tek yazma yolu `save(GameProgress)`. Etkiler saf `EffectApplier` ile tek bir yeni ilerlemeye çevrilir. Eski
    tasarımda üç etkili bir kural üç ayrı yazım demekti: Aşama 2'de araya uygulama kapanması girerse anahtar tükenmiş
    ama kapı kapalı kalabilirdi (çözülemeyen oyun), arayüz de ara durumları çizerdi.
  - **Sohbet ve okundu durumu ilerlemede (1.1, 1.6, 1.7):** `ChatBloc`'un `DetectiveSaid` olayını dinleyip ilerlemeye
    yazması kaldırıldı (sunum katmanından ikinci bir yazma yolu; bloc ayakta değilse mesaj kaybolurdu). `Say` mesajı
    aynı atomik kayıtta `chatLog`'a ekler. `ChatMessage` yerine `progress/domain`'de `ChatLogEntry`; notlara `isRead`
    eklendi (yoksa rozet her açılışta geri gelirdi). `uuid` gerektiren mesaj `id`'si kaldırıldı.
  - **Vaka genelinde katalog ve metin (1.2):** Eski plan metinleri ve katalogları bölüm bazında çözüyordu; Bölüm 2'de
    Bölüm 1'in eşyası, notu veya sohbet mesajı gösterilemezdi. ID'ler ve metin anahtarları vaka içinde benzersiz.
  - **Yığın = ata zinciri (1.1):** `GoToScene`'in yığına ne yaptığı tanımsızdı. Artık yığın hedef sahnenin `parentId`
    zinciridir; Geri her zaman üst sahneye döner.
  - **Gizlenen hotspot anahtarı `sceneId/hotspotId` (1.1):** Hotspot ID'leri yalnızca sahne içinde benzersiz.
  - **Resolver kuralı netleşti (1.1):** eşya seçiliyken yalnızca o eşya için `usingItem` içeren kurallar aday.
  - **Alınan nesnenin görseli (1.2):** "Anahtar sahneden kaybolur" için mevcut model yeterli değildi (`hideHotspot`
    yalnızca dokunma alanını kaldırır). Şimdilik bayrak + görünüm varyantı kullanılıyor (`statue_key_taken`,
    `hall_letter_taken`); hotspot'a sunum ipucu olarak `glint` eklendi.
  - **`onFirstEnter` kısıtı (1.1):** yalnızca `say`, `setFlag`, `addNote`, `giveItem`.
  - **Sıralı olay işleme, `status`, `StartGame` (1.3):** çift dokunma yarışı; içerik yüklenemezse hata ekranı; yeni
    oyun / kayıttan devam tek yoldan.
  - **Geri butonu 1.5'ten 1.4'e alındı:** 1.4'ün kabul kriteri gezinmeyi istiyor, Geri olmadan doğrulanamaz.
  - **Feature sınırları (1.4, 1.5):** placeholder çizimleri `core/placeholders`'ta; eşya inceleme kartı ve uçuş
    animasyonu `app/` katmanında birleşir. Eski planda `inventory`, `scene_engine`'in `InspectPanel`'ini doğrudan
    kullanıyordu (yasak: feature başka feature'ın `presentation`'ını import edemez).
  - **`ContentValidator` test yerine `lib/`'te (1.2);** ek kontroller eklendi. Bilinmeyen JSON alanı reddedilir.
  - **Mesaj barı sahnenin üstünde ve kendiliğinden küçülür (1.7):** 20:9 telefonda altta boş alan yok; sabit bar
    ya sahneyi ~%12 küçültür ya da alt kenardaki hotspot'ları kalıcı kapatırdı.
  - **1.8:** senaryo CI'da widget testi olarak da çalışır (`integration_test` cihaz ister).
- 2026-11-13: **Kullanıcı kararı bekleyen** (Aşama 1 bunlar olmadan ilerliyor):
  1. **Nesne katmanı (sprite).** Alınan her nesne için şimdi iki tam sahne görseli gerekiyor (nesneli / nesnesiz); bir
     sahnede iki toplanabilir nesne varsa dört görsel. Gerçek görsellerde (Aşama 7) bu sanat bütçesini katlar. Öneri:
     hotspot'a opsiyonel bir `sprite` (görsel) alanı; görünürken sahneye çizilir, gizlenince kaybolur. Katman sırasını
     (arka plan → **nesneler** → overlay → filtre → ...) ve dolayısıyla `CLAUDE.md` bölüm 6 ile ADR 0011'i etkiler.
     7.3'ten önce karar verilmeli.
  2. **Geri geçişi (ADR 0007: "Back uses the same transition type").** Giriş geçişinin tipi yalnızca oturum boyunca
     hatırlanıyor; kayıttan dönülünce varsayılan `fade`. Kalıcı olması isteniyorsa yığın girdileri geçiş tipini de
     saklamalı (kayıt şekli ve ADR 0003 etkilenir).
  3. **Mesaj barının yeri.** `CLAUDE.md` "alt: kompakt mesaj barı" diyor; sahnenin üstüne binip kendiliğinden küçülmesi
     benim yorumum. Telefonda gördükten sonra onaylanmalı ya da "sahne küçülsün, bar sabit kalsın" denmeli.
  4. **`Esc` = Geri (oyun tasarımı 5.7).** Plan bunu 11.2'ye bırakıyor; Windows'ta her gün fareyle test edildiği için
     Aşama 1'de eklemek ucuz olurdu. Aşama 11'i değiştirdiği için dokunulmadı.
- 2026-11-13 (1.1): `one_member_abstracts` lint kuralı kapatıldı: tek metotlu repository arayüzleri (ör.
  `ItemCatalogRepository`) Clean Architecture'da bilinçli soyutlamalardır. `ItemObtained` ve `NoteAdded` olaylarına
  `sceneId` / `hotspotId` eklendi (uçuş animasyonunun başlangıç noktası için). `ItemUsed` olayını `EffectApplier`
  üretir (bağlamdaki `usedItemId`). Sahne ve inceleme içeriği tek bir `CaseContent` olarak döner. Katman kurallarını
  import satırlarından denetleyen `test/architecture/dependency_rules_test.dart` eklendi.
- 2026-11-13 (1.2): Paketler: `json_annotation` 4.12.0, `json_serializable` 6.15.2, `build_runner` 2.15.1. Bu
  `build_runner` sürümünde `--delete-conflicting-outputs` bayrağı kaldırılmış (verilirse uyarıyla yok sayılıyor); CI ve
  yerelde komut `dart run build_runner build`. `CLAUDE.md` bölüm 4 hâlâ eski bayrağı yazıyor (**kullanıcı kararı:**
  kural metni güncellensin mi). JSON ayarları (`checked`, `disallow_unrecognized_keys`) `build.yaml`'da tek yerde.
  Kapı kilidi iki hotspot'a ayrıldı: `lock` (kapı kapalıyken görünür) ve `doorway` (kapı açıkken görünür, tüm kapı
  alanı): açık kapıda küçük kilit alanına dokunmak yerine kapının kendisine dokunulur; `visibleWhen` de böylece
  dilimde kullanılmış olur. Overlay stilleri `typewriter` / `engraved` / `brass` (el yazısı fontu paketlenmediği için
  `handwriting` yok; gerektiğinde font kararıyla eklenir). Filtre preset'leri `night` / `interior` / `close_up`.
  Hotspot'lar listede sonra gelen üstte olacak şekilde sıralanır (üst üste binen alanlarda sonuncu kazanır).
- 2026-11-13 (1.3): Ayrı bir `GoBack` use case'i yazılmadı: Geri, yığındaki bir önceki sahneye aynı `EnterScene` ile
  gider (tek satırlık bir hedef seçimi için sınıf gereksizdi). Görünüm ve görünür hotspot hesabı saf
  `SceneViewResolver` servisine alındı (bloc ve `TapHotspot` ortak kullanır). `TapHotspot`, oyuncunun taşımadığı bir
  eşyayı seçili saymaz ve gizli hotspot'a gelen dokunuşu yok sayar. Kayıt başarısız olursa bloc durumu değiştirmez ve
  hatayı `addError` ile `AppBlocObserver`'a (log) iletir; oyuncuya gösterilecek hata mesajı Aşama 2'de kalıcı kayıtla
  birlikte tasarlanmalı.
- 2026-11-13 (1.4): Tek commit atıldı (planda iki commit vardı): `SceneView` inceleme penceresini doğrudan içerdiği
  için ikiye bölmek derlenmeyen bir ara commit bırakırdı. Noir filtre: renk tonu + radyal vinyet + bir kez üretilip
  döşenen 128 px'lik gren görseli (`ImageShader`); shader veya `ColorFilter` gerekmedi, kare başına üç dikdörtgen
  çizimi. Gren cihaz pikseline göre ölçeklenir (telefonda kaba görünüyordu). Ölçüm 1.8'de profil modunda yapılacak.
  Hikaye metinleri arayüze `ContentTextScope` (InheritedWidget) ile iner; metinleri `GameTextsCubit` yükler.
  `core/di` bileşim kökü olduğu için mimari testinde "core feature import etmez" kuralından muaf tutuldu. Geliştirici
  aracı eklendi: `flutter test tool/render_scenes_test.dart` her sahneyi hotspot çerçeveleriyle
  `build/scene_previews/` altına PNG olarak çizer. Tablet emülatörü kurulu değil; 4:3 oranı widget testiyle
  (`SceneViewport`) ve Windows'ta pencere yeniden boyutlandırılarak doğrulandı. Görsellerin önceden yüklenmesi
  (`precacheImage`) gerçek görseller gelince (6.5 / 7.3) eklenecek; placeholder'larda yüklenecek dosya yok.
- 2026-11-13 (1.5): "İncele" isteği cubit durumundan değil, `ItemSidebar`'ın `onExamine` geri çağrısından geçer
  (tek seferlik bir olayı duruma koymak, aynı eşyaya iki kez uzun basıldığında ikinci isteği yutardı). Uçuşun başlangıç
  noktası dokunma anında kaydedilir, çünkü alınan nesnenin hotspot'u olay gelmeden önce gizlenir. Uçan kopya inene
  kadar paneldeki yuva boş kalır, inince ikon belirerek oturur (ayrı bir "parlama" efekti yok; 6.2'deki mikro
  animasyonlarla birlikte ele alınabilir). Tüketilen eşya `AnimatedSwitcher` ile söner.
  **Gözlem (kullanıcı kararı):** Eşya seçiliyken bir geçiş hotspot'una (ör. kapı) dokunmak kural gereği yalnızca
  genel tepkiyi verir ve seçimi temizler; oyuncu sahne değiştirmek için ikinci kez dokunmak zorunda kalır. Kural
  `CLAUDE.md` bölüm 6'da açıkça yazılı olduğu için değiştirilmedi; oyun testinde rahatsız ederse "eşya kuralı olmayan
  hotspot'ta seçimi bırak ve normal etkileşimi çalıştır" seçeneği değerlendirilebilir.
- 2026-11-13 (1.6): Defterin açık/kapalı durumu `NotebookCubit`'te (arayüz durumu); `GameHud` açıkken
  `NotebookScreen`'i sahnenin üstüne koyar ve sistem Geri tuşunda önce onu kapatır. Okunmamış not listede kalın
  yazılır; nota dokununca `MarkNoteRead` ilerlemeye yazar. Kağıt dokusu yerine düz kağıt rengi kullanıldı (doku görseli
  7.3'teki sanat işiyle gelir). `GameHud` state sınıfı 150 satırı aştı; 1.8'deki cilada uçuş mantığı ayrı bir sınıfa
  alınacak.
- 2026-11-14: **Kullanıcı kararları** (yukarıdaki "Kullanıcı kararı bekleyen" maddeleri ve 1.2 / 1.5 gözlemleri):
  1. **Nesne katmanı: onaylandı.** Yeni adım 1.6b (1.7'den önce), ADR 0012, `CLAUDE.md` bölüm 6; 7.3'e şeffaf arka
     planlı nesne görseli notu eklendi.
  2. **Geri geçiş tipi:** kayıttan dönünce varsayılan kararma kabul edildi; geçiş tipi kayda yazılmaz (ADR 0007'ye
     işlendi, kayıt şekli değişmedi).
  3. **Mesaj barı:** sahnenin üstüne binen tasarım uygun; şart: bar hiçbir hotspot'u kapatmaz. Barın alt şeridi tek
     sabit, içerik doğrulama testi hotspot'ların şeride girmediğini kontrol eder (1.7'ye eklendi). Kullanıcı 1.7
     bitince telefonda bakıp onaylayacak.
  4. **`Esc` = Geri:** Windows'ta Aşama 1'de eklenir (11.2 güncellendi).
  5. **Eşya seçiliyken geçiş noktası:** kural aynı kalır (yalnızca genel tepki, seçim temizlenir); **oyun testinde
     (7.4) tekrar bakılacak**.
  6. **`build_runner` komutu:** `CLAUDE.md` bölüm 4 kurulu sürüme göre düzeltildi (`dart run build_runner build`).
- 2026-11-14 (1.6b): Nesne görseli alanının adı `sprite` (`rect`, `placeholderStyle`, `image?`). Nesne `rect`'i
  dokunma alanından bağımsız: anahtarda ikisi aynı, kağıtta dokunma alanı biraz daha büyük. Gerçek görsel `rect`'e
  `BoxFit.fill` ile oturur (sanatçı nesneyi tam o kutuya kırparak dışa aktarır). `statue_key_taken` ve
  `hall_letter_taken` bayrakları içerikten kalktı; placeholder stilleri `statue_closeup_key` / `villa_hall_letter`
  silindi, `sprite_brass_key` / `sprite_letter` eklendi. Bilinen sınır (ADR 0012): nesne arka plandaki bir şeyin
  arkasında kısmen kalamaz; gerekirse ileride ön plan katmanı. 1.6'nın Windows doğrulaması
  `integration_test/notebook_mouse_test.dart` ile yapıldı (gerçek Windows derlemesi, test tarafından üretilen fare
  olayları); `integration_test` paketi bu yüzden 1.8'den önce eklendi.
- 2026-11-14 (1.7): Barın alt şeridi `SceneLayout.chatStripHeight = 0.13` (sahne yüksekliğinin %13'ü; 360 dp
  yüksekliğindeki telefonda ≈ 47 dp: iki satır yazı). Bar ve küçüldüğü düğme yalnızca bu şeridin içine yerleşir
  (`app/game/scene_chat_strip.dart`); `ContentValidator` şeride giren hotspot'u reddeder. Bu yüzden `doorway`
  (alt kenar 0.92 → 0.86) ve `statue_plaque` (0.89 → 0.87) dokunma alanları kısaltıldı. Okunmamış sayısı: her yeni
  mesajda +1; bar mesajı okunacak kadar gösterip küçülünce −1; geçmiş açılınca 0. Yani rozet yalnızca üstüne yeni
  mesaj geldiği için okunamadan geçen mesajları sayar. Bar en fazla iki satır gösterir, uzun mesajın tamamı
  geçmiştedir. `ChatCubit` `lazy: false` ile ekran açılırken kurulur ve olay dinlemeye constructor'da başlar: oyunun
  ilk cümlesi sahne yüklenirken söylenir, tembel kurulan cubit onu kaçırırdı. Rozet widget'ı `core/widgets/hud_badge.dart`'a
  taşındı (defter ve mesaj düğmesi ortak kullanır). Geliştirici hotspot düğmesi sol alttan sağ üste alındı (sol alt
  artık mesaj barının). `Esc` = Geri ayrı commit: kısayol `CallbackShortcuts` yerine erişilebilirlik düğümü olmayan
  tek bir `Focus` ile yazıldı (`CallbackShortcuts`'ın kendi düğümü hotspot etiketlerini yutuyordu). `Esc` ana sahnede
  hiçbir şey yapmaz (çıkış uyarısı yalnızca sistem geri tuşunda). **Kullanıcı onayı bekliyor:** barın telefondaki
  görünümü (karar 3).
- 2026-11-14 (1.8): Kabul senaryosu tek fonksiyon: `test/helpers/acceptance_scenario.dart`. İki yerden çalışır:
  `test/app/game/acceptance_scenario_test.dart` (CI; telefon boyutu dokunma + fare, 1280×720 pencere, 4:3 tablet) ve
  `integration_test/acceptance_test.dart` (gerçek uygulama; Windows'ta dokunma + fare ile geçti). 1.6 için yazılan
  `notebook_mouse_test.dart` bu senaryoya katıldığı için silindi. Manuel kontrol listesinin test edilebilen maddeleri
  `test/app/game/edge_cases_test.dart`'ta (hızlı çift dokunma, geçiş sırasında dokunma, eşya seçiliyken Geri, sistem
  geri tuşu, arka plana alıp dönme). `GameHud` bölündü: `pickup_flights.dart` (uçuşlar), `back_shortcut.dart`,
  `scene_buttons.dart`, `hud_side_panel.dart`. Performans: `integration_test/performance_test.dart` +
  `test_driver/performance_driver.dart` (`flutter drive --profile`). **Windows, profil modu, 350 kare:** build ortalama
  0,44 ms (en kötü 5,4 ms), raster ortalama 1,9 ms (%99: 13,0 ms, en kötü 44,6 ms); 16,6 ms bütçesini aşan 3 raster
  karesi, hiç build karesi yok. README'ye oyundan üretilen ekran görüntüleri eklendi
  (`tool/render_screenshots_test.dart` → `docs/screenshots/*.jpg`; gren yüzünden PNG'ler 1 MB'ı geçtiği için JPEG).
  **Yapılamayan (cihaz bağlı değildi), kullanıcıda:** telefonda kabul senaryosu ve manuel kontrol listesi, telefonda
  profil modu ölçümü, mesaj barının telefondaki görünümünün onayı (karar 3). Komutlar `docs/devlog/asama-1.md`'de.
- 2026-11-14 (motor incelemesi → Aşama 1b): Bölüm 1 yazılmadan önce motor, 40–50 sahnelik bir bölümün ihtiyaçlarıyla
  karşılaştırıldı. Kararların hepsi kullanıcı onaylı (yeni koşul / etki türleri ve oyun tasarımı değişiklikleri dahil).
  Bu commit yalnızca belgedir (`plan.md`, `CLAUDE.md`, `docs/game_design.md`, ADR 0013–0018); kod 1.9'dan itibaren.
  - **Eklenenler:** koşullar `not` / `atLeast` / `visited` / `inScene` / `topicAsked`; `say` `first/then` +
    `spokenLines`; `chatLog` sınırı 200 (ADR 0013). Tek etki hattı ve tetikleyiciler (ADR 0014). Not satırları,
    `suspect` → `person` (ADR 0015). Konuşma sistemi, `talk` etkisi, kanıt gösterme ve eşya verme (ADR 0016). Haritasız
    mekan geçişi, `sprite.overlays`, tuzak mekan kontrolü (ADR 0017). Tür başına çoklu dosya, bölüm genişletmeleri,
    eksik bölümün atlanması, önek doğrulaması, uyarı düzeyi (ADR 0018). Geliştirici menüsü.
  - **Plan:** Aşama 1'e 1.9–1.20 adımları ("Aşama 1b") ve kabul senaryosunun 12–20. adımları eklendi; çalışma sırasında
    Aşama 2'den önce. 2.2 (kayıt şekli + kayıt dışa/içe aktarma), 5.4 ("bölüme ulaşıldı"), 5.6 ("dokunulabilir yerleri
    göster"), yeni 5.7 (eşya birleştirme / açma), 7.4 (`walkthrough.json`) güncellendi. Yön bulma açık kararı kapandı.
  - **Oyun tasarımı değişti:** "karakterler görünmez" kuralı kalktı (`docs/game_design.md` değişiklik geçmişi).
  - **Bölüm genişletmeleri (`extends`) neden şimdi:** `sceneExtensions` / `dialogueExtensions` / `noteExtensions`
    kayıt şeklini değil, **içerik dosya yapısını** etkiler. Kayıt şekli sonradan migration ile taşınabilir (2.2); ama
    içerik düzeni Bölüm 1 yazıldıktan sonra değişirse yazılmış 40–50 sahnelik dosyalar elle yeniden düzenlenir ve
    Bölüm 2, ücretsiz Bölüm 1'in dosyalarını düzenlemek zorunda kalırdı (ücretli içerik demoya sızar, B1 B2'ye bağımlı
    olur). Bu yüzden Aşama 7'yi beklemeden, tek bölüm varken ve sahte iki bölümlü fixture ile kurulur (1.14).
  - **Mevcut kodla çelişen / kodda karşılığı olmayan noktalar** (uydurulmadı; ilgili adımda böyle ele alınacak):
    1. **Katman kuralı × konuşma DTO'su (1.16):** koşul / etki codec'leri `scene_engine/data`'da; `dialogue/data` onları
       import edemez (feature yalnızca başka feature'ın `domain`'ini import eder; mimari testi kırılır). Plan:
       `scene_engine/domain`'de `RuleParser` arayüzü, uygulaması `scene_engine/data`, DI ile `dialogue/data`'ya verilir.
       Aşama 5.7'deki eşya `interactions`'ı da aynı yolu kullanır. **Kullanıcı onayı bekliyor** (alternatif:
       konuşma DTO'larını `scene_engine/data`'da tutmak).
    2. **Dosya listeleme (1.14):** `ContentAssetSource` yalnızca bilinen yolu okuyor, listeleme yok; `pubspec.yaml` her
       içerik klasörünü tek tek sayıyor (klasör girdisi alt klasörü kapsamaz). `scenes/*.json` için hem manifest'ten
       listeleme hem her yeni klasörün `pubspec.yaml`'a eklenmesi gerekir.
    3. **Eksik bölüm (1.14):** bugün eksik dosya `ContentFailure`'dır ve üç yükleyici (sahne, eşya, not) + metin servisi
       `case.json`'ı ayrı ayrı dolaşır. "Atla" kuralı tek yerde (`CaseManifest`) uygulanacak. Yorumum: bölüm "eksik" =
       klasöründe **hiç** dosya yok; yarım bölüm ve eksik ilk bölüm hatadır.
    4. **`talk` kayda girmez × `greeting.first/then`:** ikinci karşılamanın farklı olması kalıcı durum ister. Yorumum:
       `talk` etkisi hiçbir şey kaydetmez; panel açılınca `StartConversation` karşılamanın `first` anahtarını
       `spokenLines`'a yazar (ayrı bir kayıt alanı açılmadı).
    5. **`MarkNoteRead` doğrudan `save` çağırıyor.** "İlerlemeyi değiştiren her use case hattı kullanır" kuralına
       uyması için hatta taşınacak (1.11). Sonuç: `notebook/domain` → `scene_engine/domain` import'u doğar;
       `scene_engine/domain` zaten `notebook/domain`'i import ediyor (doğrulayıcı). Kurallar buna izin veriyor
       (domain → başka feature'ın domain'i) ama iki yönlü bağımlılıktır.
    6. **`EnterScene` her zaman, `TapHotspot` yalnızca değişiklik varsa kaydediyor.** Hat "değişiklik varsa kaydet"
       kuralını kullanacak; sahneye giriş yığını her zaman değiştirdiği için davranış aynı kalır.
    7. **A4'teki örnek JSON × kabul senaryosu 18:** örnekte `show_letter` eczacıdadır; senaryoda mektuba kahveci cevap
       verir, eczacı `noReactionKey` söyler. Örnek biçim örneği olarak korundu; dilim içeriğinde `show_letter`
       `cafe_owner`'dadır.
    8. **`assets/dev/presets.json` (1.19):** `pubspec.yaml`'daki asset'ler flavor'a göre ayrılmıyor (Windows'ta flavor
       yok); dosya prod paketine de girer. Küçük ve zararsız ama sahne / eşya ID'leri içerir; hariç tutma yolu 1.19'da
       değerlendirilecek.
  - **Benim yorumlarım** (kararlarda açık yazmıyordu; itiraz edilirse ilgili adım başlamadan düzeltilir):
    - `inScene` = yığının tepesindeki sahne (alttaki ata sahneler sayılmaz).
    - Çoklu dosya bütün türlere uygulanır (`items`, `notes`, `inspections` dahil); `dialogues` ve `triggers`
      opsiyoneldir; metinler dil başına tek dosya kalır; klasördeki dosyalar ad sırasıyla okunur.
    - Genişletmeler ilgili türün dosyasında üst düzey anahtardır ve yalnızca **önceki** bir bölümü hedefler.
    - Tuzak mekan kontrolü kök sahnenin **kendi** bölümünün girişine bakar ve koşulları hesaba katmaz.
    - Not defterde değilken `addNoteEntry` yalnızca `NoteAdded` üretir; `NoteUpdated` yalnızca var olan nota satır
      eklenince. Satırlar eklenme sırasıyla gösterilir.
    - Tetikleyicilerde `consumeItem` yok (izinli listede sayılmadı); `usingItem` tetikleyici ve konu koşullarında yasak.
    - Sahneden eşya gösterilince önce karşılama, sonra tepki oynar; `ItemUsed` üretilmez.
    - Gösterilerek açılmış bir konu yeniden gösterilirse yalnızca cevabı tekrar oynar. Aynı `trigger`'a birden çok konu
      yazılabilir; koşulu tutan ilki oynar.
    - Paneller üst üste binmez: konuşma açıkken eşyaya uzun basma (inceleme kartı) yok sayılır. Konuşma açıkken HUD'daki
      defter düğmesi de defteri seçim modunda açar.
    - Uyarılar testi kırmaz, yazdırılır; kullanılmayan metin anahtarı yalnızca tam vakada aranır.
    - Yeni olaylar: `NoteUpdated` (istenen) ve `TopicAsked` (benim eklemem; arayüz tepkisi ve 9.2 analitiği için).
    - Aşama 5'in yeni adımı 5.7 olarak numaralandı. 1b için ayrı devlog dosyası açılmaz; `asama-1.md` sürer.
    - "En küçük hedef telefon yüksekliği" = 360 dp (1.7'deki ölçüyle aynı).
- 2026-11-14 (Aşama 1b kararları, kullanıcı): Yukarıdaki sekiz çelişki maddesi karara bağlandı; yorumların hepsi
  onaylandı. İlgili adımlar, `CLAUDE.md` ve ADR 0014 / 0016 / 0018 güncellendi.
  1. **`RuleParser`: onaylandı.** Arayüz `scene_engine/domain`'de, uygulaması `scene_engine/data`'da, DI ile verilir;
     `dialogue/data` kendi DTO'larını tutar (1.16).
  2. **Dosya listeleme: onaylandı.** Ek: içerik doğrulama testi `assets/content` altındaki her klasörün
     `pubspec.yaml`'da tanımlı olduğunu kontrol eder; unutulan klasör testi kırar (1.14).
  3. **Eksik bölüm: onaylandı.** Klasörde hiç dosya yoksa atlanır; yarım bölüm ve eksik ilk bölüm hatadır (1.14).
  4. **`greeting.then`: onaylandı;** `spokenLines`'a yazma da tek etki hattından geçer (`StartConversation`, 1.16).
  5. **`MarkNoteRead`: hattın tek istisnası** (iki seçenekten daha az değişiklik isteyeni). Hattı tarafsız bir yere
     taşımak `EffectApplier`, `TriggerRunner`, `Condition` ve `Effect`'i de `scene_engine`'den çıkarmayı gerektirirdi;
     istisna ise sıfır kod değişikliğidir ve `isRead`'i hiçbir koşul okumadığı için tetikleyicileri etkilemez. Gerekçe
     ADR 0014'te. **Feature'lar arasında iki yönlü import yasak;** mimari testi feature grafındaki döngüyü yakalar (1.11).
     Aynı kural yüzünden konuşma doğrulaması ikiye bölündü: bağımlılık yalnızca `dialogue` → `scene_engine` (1.16).
  6. **Kayıt "değişiklik varsa":** onaylandı (1.11).
  7. **`show_letter` kahvecide:** onaylandı (1.16).
  8. **`presets.json` prod ve Steam paketine girmez.** Flutter dokümanı (docs.flutter.dev, flavors ve pubspec sayfaları,
     2026-11-14) `assets` girdisinde `path` + `flavors` alt alanını tanımlıyor; örnekler klasör yoluyla. Doküman
     flavor'sız derlemede ne olduğunu ve Windows desteğini **açıkça yazmıyor**; 1.19 başlarken derleme çıktısıyla
     doğrulanacak, uygun çıkmazsa yedek yol (Dart sabiti) sorulacak. Windows'ta paketlenmemesi kabul edildi.
     Menü kodu yalnızca `main_dev.dart`'tan bağlanır; prod, staging ve Steam derlemesinde yoktur, env bayrağıyla
     açılamaz (1.19). Not: bu, menüyü `staging`'de de kapatır (karar "prod ve Steam" diyordu; staging'i de dışarıda
     bırakmak daha güvenli taraf, istenirse `main_staging.dart` da bağlayabilir).
