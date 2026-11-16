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
4. Aşama 2 — Kalıcı kayıt ✔ (`phase-2`)
5. Aşama 5 — Bulmacalar ve vaka akışı. Adım sırası:
   **5.1 → 5.2 → 5.7 → 5.9 → 5.4a → 5.4b → 5.4c → 5.6a → 5.6b → 5.8 → 5.5a → 5.5b → 5.5c → 5.10.**
   5.3 (kayıt inceleme) ertelendi: `Sıradaki adım` onu atlar, aşama onsuz biter.
6. Aşama 7, **yalnızca Bölüm 1**: repoyu private yapma, hikaye, Bölüm 1 içeriği, görseller ve 10–15 kişiyle oyun testi.
   Sıra: **7.0 → 7.1 → 7.4a** (Bölüm 1 içeriği yer tutucu çizimlerle; kullanıcı kendi oynar ve düzeltir) **→ 7.2 → 7.3**
   (görseller) **→ 7.4b** (görsellerin bağlanması) **→ 9.1** (çökme raporlama) **→ 7.4c** (oyun testi).
   Gerekçe: görsel üretilmeden hikayeyi değiştirmek ucuzdur.
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
- **Aşama 5 → Aşama 2:** Aşama 5 kayda şu alanları ekler; her biri payload sürümünü bir artırır:
  - **v2 (5.1) bulmaca durumu:** `solvedPuzzles`, `puzzleStates` (yarım ayarlar; ör. yön bulmacasında parçaların yönü);
  - **v3 (5.4a) bölüm ilerlemesi:** `completedChapters` (zamanlarıyla), `reachedChapters`;
  - **v4 (5.6a) ipucu:** `hintsUsed`, `hintTiers` (hedef → açılan basamak);
  - **v5 (5.5a) suçlama:** `accusation` (denemeler ve sonuç; kalan hak denemelerden hesaplanır).

  Her sürüm 2.2'deki migration zinciriyle taşınır (eski kayıt bozulmaz) ve gerçek eski payload'la test edilir.
  **Satın alma kilidi kayda girmez** (CLAUDE.md §8: satın alma ve kilit durumuna yerel kayıttan güvenilmez; sahiplik
  `EntitlementRepository`'den sorulur). **Bölüm başı kayıt kopyası yoktur; tek kayıt yuvası kalır.**
- **Aşama 5 → Aşama 3:** Bölüm 1 sonundaki hesap bağlama önerisi 5.4'ten 3.3'e taşındı. 5.4, Bölüm 1 sonu ekranını
  (satın alma / demo sonu) hesapsız kurar; öneri Aşama 3 gelince mobildeki o ekrana eklenir.
- **Aşama 5 → Aşama 8 / 11:** 5.4b'deki `EntitlementRepository` gerçek mağaza gelene kadar dev dışındaki derlemelerde
  yalnızca Bölüm 1'i açar; 5.4c'deki satın alma düğmesi yer tutucudur. Mobil satın alma 8.2 / 8.4'te, Steam sahipliği
  11.3'te bağlanır; oyun kodu değişmez.
- **Aşama 5 → Aşama 6:** 5.3'teki kayıt inceleme (ertelendi; yapılırsa) sessiz kurulur; sesi 6.1'de bağlanır.
  5.5c'deki "Baştan oyna" oyun süresi sayacını sıfırlayan arayüzü kurar; 6.3'teki "Yeni Oyun" aynısını kullanır.
- **Aşama 7 (Bölüm 1) → Aşama 5:** Hikaye ve bulmaca zinciri 5'te hazırlanan bulmaca türleriyle kurulur.
  Yeni bir bulmaca türü gerekirse önce Aşama 5'e adım olarak eklenir. 7.4a, 5.10'daki genel yer tutucu çizimlere
  dayanır.
- **7.4a → 7.2 / 7.3:** Görsel listesi ve koordinat ince ayarı, oynanıp düzeltilmiş içerikten çıkar; bu yüzden editör
  (7.2) ve görsel üretimi (7.3) içerikten **sonra** gelir.
- **Oyun testi (7.4c) Aşama 3, 4 ve 6'dan önce:** Kayıt yereldir (Aşama 2), hesap veya bulut gerekmez. Ses, ana menü ve
  cila henüz yoktur; test bulmacaları, hikayeyi ve akışı ölçer. Test sürümünün dağıtım yolu (APK, Windows zip veya
  Play iç test) 7.4 detaylandırılırken seçilir.
- **9.1 → oyun testi (7.4c):** `AppLogger` yalnızca `dart:developer`'a yazar; release derlemede bu hiçbir şey yapmaz.
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
| Bulmacalar | Ayrı feature `puzzles`; `puzzles.json`; `openPuzzle` etkisi, `puzzleSolved` koşulu; bulmaca genel bir panel değil, yakın plan görselinin üstünde sahneyle aynı çizim hattında oynanır; çözüm etki hattından (ADR 0020) | Her bulmaca kendi görselinde yaşar; yeni bulmaca = yeni veri + görsel |
| Bölüm akışı | `case.json`'da `completeWhen`; bitiş etki hattında aynı kayıtta; `chapterReached` koşulu; sonraki bölümün genişletmeleri birleştirmede `chapterReached` ile sarılır; sahiplik `EntitlementRepository`'den, kayda girmez (ADR 0021) | Oyun durmaz; ücretli içerik sahip olunmadan açılmaz; resolver'lar değişmez |
| İpucu | `hints.json`: sıralı hedefler ve kademeler; metin etki hattından, dedektifin iç sesiyle; 60 sn bekleme; kendiliğinden yönlendirme kapalı (ADR 0022) | Yardım yalnızca istenince gelir; ipuçları veriyle yazılır |
| Suçlama | `case.json`'da `accusation`; `openAccusation` etkisi; saf `AccusationJudge`; denemeler kayıtta (ADR 0023) | Final de veridir; kurallar arayüzsüz test edilir |
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
| Oyuncu | Dedektifi yönetir; dedektif görünmez, iç sesiyle tek yönlü konuşur. Adı **Detective Dark**; ön adı geçmez |
| Toplananlar | **Eşyalar** (sağ panel, kullanılır) ve **notlar** (not defteri: belgeler, gözlemler, kişiler). Kişi dosyaları oyun ilerledikçe satır satır güncellenir (ADR 0015) |
| Eşya kullanımı | Dokun-seç → hedefe dokun; yanlış yerde cezasız genel tepki |
| Ortam | 1950'ler, kurgusal küçük kasaba; oyun hep gece. **Saat / zaman mekaniği yok:** hiçbir şey süreye bağlı değil, dükkanlar kapanmaz, karakterler yer değiştirmez; yeni kişiler ve mekanlar bölümle açılır |
| Sahne kuralı | Dokunulan her şey ayrı sahnedir (yalnızca bakılan ayrıntı da). İstisnalar: toplanan nesneler, geçiş noktaları, karakterler |
| Mekanlar | Villa (giriş holü, 4 oda kapısı, bodrum, üst kat, çatı katı, bahçe; içinde kimse yok) ve çarşı (sokak, iki yanda dükkanlar, dipte yetimhane; karakterler dükkanların içinde); suçlama karakolda |
| Bulmacalar | Eşya kullanma, eşya birleştirme, rakamlı tuş takımı, sembol eşleştirme (içerikle), karanlık sahnede ışık kaynağı, yön bulmacası, sürüklemesiz delikli kağıt, çelişki yakalama; zincirleme. Tuş takımı ve yön bulmacası **yakın plan görselinin üstünde** oynanır; yanlış denemenin cezası yok. Diğer kilitler yazılmaz; kayıt inceleme ertelendi (hikaye kullanmıyor) |
| Çelişki yakalama | Yeni arayüz yok: çelişen kanıt konuşmada "Kanıt göster" ile gösterilir; cevap + dedektifin gözlem notu kayda geçirir, not finalde kanıt olabilir |
| Belgeler | Mektup, gazete kupürü, çok sayfalı günlük, fotoğraf arkası; hepsi deftere not olarak girer |
| Hikaye | Tek yol; dallanma yok |
| Karakterler | Sahnede silüet (yalnızca çarşı mekanlarında; villada kimse yok); konuşma kutusunda ve kişi dosyasında çizilmiş portre; dokununca konuşma paneli doğrudan açılır; oyuncu yalnızca önceden yazılmış soruları seçer; sorular bilgi ortaya çıkarır (ADR 0016). Telefona dokunmak da paneli açar; numara çevirme yok |
| Kanıt ve eşya | Karakterlere eşya ve not gösterilir, eşya verilir; ilgisiz gösterimde cezasız kısa tepki (ADR 0016) |
| Yön bulma | **Harita ve mekan listesi yok.** Mekanlara sahnedeki geçiş noktalarıyla gidilir; keşif oyunun parçası (ADR 0017) |
| Yapı | Tek vaka, 4 bölüm (B1 30–45 dk, B2–B4 45–60 dk); Vaka 2 ileride |
| Bölüm geçişi | Oyun durmaz; üstte kısa bildirim ("Bölüm 1 tamamlandı — <ad>"). Tek istisna Bölüm 1'in sonu: mobilde Bölüm 2–4 için tek satın alım ekranı, Steam demosunda demo sonu ekranı. Ekran **kapatılabilir**: oyuncu Bölüm 1 dünyasında dolaşmaya devam eder, HUD'da "tam oyunu aç" girişi kalır |
| Yardım | **Oyuncuya hiçbir şey doğrudan buldurulmaz;** dedektif gördüğünü söyler, yön göstermez. İpucu yalnızca oyuncu isteyince: sınırsız ve ücretsiz, iki basış arasında 60 sn; ilk basış "dokunulabilir yerleri göster", sonra yön → net → cevap; kendiliğinden yönlendirme yok; kullanılan ipucu sayısı sonuç ekranında |
| Para (mobil) | Bölüm 1 ücretsiz; Bölüm 2–4 tek satın alım; Vaka 2 ayrı ücretli; **reklam yok**, ipucu satılmaz |
| Para (Steam) | Bölüm 1 ücretsiz demo; Vaka 1 peşin ücretli; Vaka 2 DLC; reklam yok |
| Platformlar arası | İlerleme ve satın alımlar taşınmaz; mobil: Supabase hesabı, Steam: Steam Cloud |
| Final | Karakolda; 9 şüpheli (tanıkların dosyası olur ama suçlama ekranında görünmez); isim + en fazla 3 kanıt (not veya dosya satırı); kabul = isim doğru ve en az 2 kanıt geçerli (ilgisiz ek kanıt zarar vermez); 2 hak, isim doğru ama kanıt zayıfsa da hak düşer; sonra "Baştan oyna" / "Çözümü gör"; paylaşılabilir sonuç ekranı. Önemli her kanıt ilerlemek için zorunlu; kaçırılabilen kanıt yok |
| İnceleme | Sahneyi değiştirmeden küçük görsel + metin penceresi (`inspect` etkisi, ADR 0010). Gerçek içerikte yalnızca eşyaya uzun basınca açılan kart için; motor ve dikey dilim değişmez |
| Ses | Mekan başına ambiyans döngüsü (yağmur, rüzgar, barda uzaktan caz); kapı / adım / gıcırtı efektleri; müzik az |
| Görseller | AI destekli; kritik yazı/sayılar görsele gömülmez, oyun üstüne çizer (overlay); ortak noir filtre (ADR 0011) |
| Sahne sayısı | Kesin değil; hikaye yazılırken belirlenir (eski tahmin: Bölüm 1 ~40–50; sahne kuralıyla artabilir) |

## Açık kararlar (ilgili aşamanın başında sorulacak)

| Aşama | Konu | Öneri |
|---|---|---|
| 5.7 | Eşya kurallarının kodda yeri | `scene_engine` okur (`CaseContent.itemRules`); `inventory` → `scene_engine` import'u döngü olurdu. Adım başlarken onaylanır (Notlar 2026-11-16) |
| 5.5c | Sonuç paylaşımı: paket mi, pano mu | Önce `share_plus`'ın Windows desteği kontrol edilir; yoksa veya istenmezse panoya kopyala |
| 6 | Ses kütüphanesi | `flutter_soloud` (düşük gecikme, oyun odaklı) veya `audioplayers` |
| 7 | Görsel üretim aracı (AI) ve ticari kullanım koşulları | Ticari kullanıma açık lisanslı araç; seçim stil denemeleriyle |
| 8 | Mobil fiyat; satın alma altyapısı | Fiyat benzer oyunlara göre; RevenueCat. (Biçim kapandı: Bölüm 2–4 tek satın alım. İpucu / reklam kapandı: ücretsiz ipucu, reklam yok) |
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

### [x] 1.13 Not satırları ve "Kişiler"
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

### [x] 1.14 İçerik düzeni: çoklu dosya, bölüm genişletmeleri, eksik bölüm
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

### [x] 1.15 Mekan geçişi: tabela, çarşı, tuzak kontrolü
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

### [x] 1.16 Konuşma: domain ve içerik (arayüz yok)
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

### [x] 1.17 Konuşma paneli
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

### [x] 1.18 Eşya verme ve kanıt gösterme
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

### [x] 1.19 Geliştirici menüsü (yalnızca dev)
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

### [x] 1.20 Çarşı demosunun kabul testi ve cila
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

### [x] 2.1 Drift kurulumu ve save_slots tablosu
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

### [x] 2.2 Sürümlü payload ve migration zinciri
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

### [x] 2.3 DriftProgressRepository ve otomatik kayıt
**Yapılacaklar:**
- `DriftProgressRepository`, aynı `ProgressRepository` arayüzüyle. DI'da **tek satır** değişir; arayüz kodu değişmez
  (commit gövdesinde ve devlog'da vurgula).
- Otomatik kayıt: her ilerleme değişikliğinde (yakın değişiklikler ~500 ms içinde birleştirilir);
  `AppLifecycleState.paused`'da anında yazım. Her yazışta `localRevision++`, `isDirty = true`, `updatedAtUtcMs`.
- `playTimeSeconds` sadece uygulama ön plandayken sayar.
- Açılışta kayıt varsa sahne yığını, eşyalar, notlar (satırlarıyla), bayraklar, gizlenen hotspot'lar, sorulan konular,
  ateşlenen tetikleyiciler, söylenen replikler ve chat geçmişi geri yüklenir.
  **Commit:** `feat(progress): persist game progress with autosave`

### [x] 2.4 Testler
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
- **Bölüm 1 sonunda hesap bağlama önerisi** (5.4'ten taşındı): 5.4'te kurulan Bölüm 1 sonu satın alma ekranına,
  anonim oyuncu için "İlerlemeni güvenceye al" önerisi eklenir. Reddedilebilir; oyunu bekletmez.
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

**Neden:** Oyunu "sahne gezme"den "dedektif oyunu"na çeviren aşama: kilitler, bölümler, ipuçları ve final.
Motor bu aşamadan sonra Bölüm 1'in tamamını taşıyabilmelidir; Aşama 7 yalnızca içerik ve görsel üretir.
**Sıra:** Aşama 2'den hemen sonra, Aşama 3–4'ten önce (bkz. "Çalışma sırası"). Adımlar numara sırasıyla değil şu
sırayla yapılır: **5.1 → 5.2 → 5.7 → 5.9 → 5.4 (a, b, c) → 5.6 (a, b) → 5.8 → 5.5 (a, b, c) → 5.10.** 5.3 ertelendi;
aşama onsuz biter. Aşağıda adımlar yapılış sırasıyla yazılıdır. Kararlar: ADR 0020–0023 (yön bulmacası ve eşya
etkileşimlerinin ADR'leri kendi adımlarında yazılır). Devlog: `docs/devlog/asama-5.md`.

**Ortak kurallar (her adım için):**
- Harfli alt adımlar (5.4a, 5.4b...) ayrı adımlardır: her biri tek başına kalite kapısından geçer, commit edilir ve
  `Sıradaki adım` ile sürdürülür. `Aşama 5.4'ü yap` = o adımın kalan alt adımları.
- **Kayda alan ekleyen her adım payload sürümünü bir artırır** ve `SaveMigrator`'a migration + gerçek eski payload'lı
  testini yazar (2.2 zinciri). Bu aşamanın sürümleri: 5.1 → **v2**, 5.4a → **v3**, 5.6a → **v4**, 5.5a → **v5**.
  Diğer adımlar kayıt şeklini değiştirmez.
- İlerlemeyi değiştiren her yeni use case `EffectPipeline`'ı kullanır (ADR 0014); yeni yazma yolu açılmaz.
- Yeni feature'ların bağımlılık yönü: `puzzles` → `scene_engine`, `case_flow` → `scene_engine` (+ `notebook`,
  `progress`). `puzzles`, `case_flow` ve `dialogue` birbirini import etmez. `scene_engine` bu feature'lara yalnızca
  düz veriyle (ID kümesi) ulaşır.
- Yeni içerik türleri (`puzzles`, `hints`) bölüm klasöründe opsiyoneldir; tek dosya veya klasör (ADR 0018).
- **Repo public:** bu aşamadaki bütün örnekler ve demo içeriği dikey dilime aittir; gerçek hikayeyle ilgisizdir.
- Her arayüz adımı telefon boyutunda dokunmayla ve 1280×720'de fareyle test edilir.

**Kabul senaryosunun devamı (aşamanın sonunda 1–30 kusursuz çalışmalı; "bulmaca demosu"):**
21. Holde kasaya dokun → sahne yığını değişmeden kasanın yakın planı açılır (bulmaca görünümü); Geri görünür. Yanlış
    bir kod gir → gösterge temizlenir, dedektif kısa bir yorum yapar; ceza yok. Geri → hol.
22. Kasayı yeniden aç, villa önündeki kapı numarasını gir (oyunun çizdiği overlay yazısı) → kasa çözülür: yarım
    fotoğraf panele gelir, iki sayfalı defter not defterine girer, dedektif konuşur, bulmaca kapanır. Kasaya tekrar
    dokun → yalnızca "boş" repliği; bulmaca yeniden açılmaz.
23. Not defterinde iki sayfalı defteri aç → sayfa çevir (ileri / geri).
24. Çarşıdaki diğer yarım fotoğrafı al. Panelde bir yarımı seç → diğer yarıma dokun → ikisi panelden düşer, tek
    fotoğraf gelir. (Ters sırayla da aynı sonuç.)
25. Fotoğraf birleşince bölüm biter: üstte "Chapter 1 complete — <ad>" bildirimi çıkar ve kendiliğinden kaybolur;
    oyun durmaz, sahneye dokunulabilir.
26. (Geliştirici menüsünde sahiplik **kapalı**.) Bildirimden sonra kapı ekranı açılır (mobilde satın alma, düğmesi
    yer tutucu). Kapat → oyun sürer; HUD'da "tam oyunu aç" girişi durur; `ch02`'nin eklediği soru kahvecide
    **görünmez**. Geliştirici menüsünden sahipliği aç → bölüm ilerler, giriş kaybolur, yeni soru görünür.
27. İpucu düğmesine bas → sahnedeki dokunulabilir yerler ~1,5 sn türlerine göre işaretlenir. Düğme 60 sn bekler
    (geri sayım görünür). Sonraki basışlar: yön → net → cevap; hepsi mesaj barında ve geçmişte. Son kademeden sonra
    aynı metin tekrar gelir.
28. Çarşıdaki vana kutusuna dokun → yön bulmacası. İki vanayı çevir, Geri, yeniden aç → vanalar bıraktığın yönde.
    Hepsini doğru yöne getir → çözülür, dedektif konuşur; kutu bir daha açılmaz.
29. Çarşıdaki polis telefonuna dokun → suçlama: iki şüphelinin portresi → birini seç → defterden kanıt seç → onayla.
    Yanlış isim → "ikna olmadım", 1 hak kalır. Doğru isim + 2 geçerli kanıt (+ 1 ilgisiz) → kabul → sonuç ekranı:
    deneme sayısı 2, toplam süre, ipucu sayısı; "Kopyala" metni panoya verir.
30. Uygulamayı tamamen kapat, aç → kasa çözülmüş, vanalar çözülmüş, bölüm ilerlemiş, suçlama sonucu duruyor.

### [ ] 5.1 Bulmaca altyapısı
**Amaç:** Bulmacaların ortak iskeletini kurmak: içerik formatı, açma / çözme akışı, kayıt ve çizim. Bulmaca, oyunun
çizdiği genel bir panel **değildir**: yakın plan görselinin üstünde oynanır (ADR 0020).
**Yapılacaklar:**
- Yeni feature `features/puzzles/` (`domain`, `data`, `presentation`).
- **İçerik:** `ContentType.puzzles` (opsiyonel; `puzzles.json` veya `puzzles/*.json`). Ortak alanlar:
  ```json
  {"formatVersion": 1,
   "puzzles": [
     {"id": "hall_strongbox", "type": "keypad",
      "visual": {"placeholderStyle": "strongbox_closeup", "filterPreset": "close_up"},
      "wrongSay": "say_strongbox_wrong",
      "onSolved": [{"giveItem": "photo_half_a"}, {"say": "say_strongbox_open"}]}
   ]}
  ```
  `visual` sahne görseliyle aynı şekildir (`background?`, `placeholderStyle`, `overlays`, `filterPreset?`). `type`
  türe özel alanları belirler (5.2 `keypad`, 5.8 `directions`). `onSolved`'da izinli etkiler: `say`, `setFlag`,
  `addNote`, `addNoteEntry`, `giveItem`. `wrongSay` opsiyoneldir (`say` gibi tek anahtar veya `first`/`then`).
  Bulmaca ID'leri vaka içinde benzersizdir.
- **Domain (`puzzles/domain`):** `PuzzleDefinition` (soyut taban: `id`, `visual`, `onSolved`, `wrongSay?`; her tür
  bir alt sınıf), `PuzzleCatalogRepository`, use case'ler:
  - `SolvePuzzle`: hatta `prepare` = "çözüldü" işareti + o bulmacanın `puzzleStates` girdisinin silinmesi; etkiler =
    `onSolved`; öndeki olay `PuzzleSolved(puzzleId)`. Tetikleyiciler aynı kayıtta çalışır. Zaten çözülmüşse hiçbir şey
    yapmaz.
  - `SavePuzzleState(puzzleId, List<int>)`: yarım ayarı hattan kaydeder (5.8 kullanır).
  - `ReportWrongAttempt`: `wrongSay` varsa hattan `say` olarak çalıştırır; yoksa hiçbir şey yapmaz.
- **`scene_engine/domain`:**
  - Yeni etki `OpenPuzzle(puzzleId)` (`{"openPuzzle": "id"}`): `talk` / `inspect` gibi arayüz durumudur; yığını
    değiştirmez, kayda girmez. `EffectOutcome.puzzleId`. **Çözülmüş bulmaca için etki yok sayılır** (`EffectApplier`
    ilerlemeye bakar); içerik hotspot'u koşulla değiştirir. Yalnızca hotspot kuralında kullanılır.
  - Yeni koşul `{"puzzleSolved": "id"}`; sınıf adı `HasSolved` (`PuzzleSolved` adı olayla çakışmasın; `HasAsked`
    örneği gibi).
  - `RuleParser` arayüzüne `visual` ayrıştırması eklenir: `puzzles/data`, `scene_engine/data`'daki `SceneVisualDto`'yu
    import edemez (`data` → `data` yasak).
- **`core/events`:** `PuzzleSolved(puzzleId)`.
- **Kayıt (v1 → v2):** `GameProgress.solvedPuzzles` (küme) ve `puzzleStates` (`Map<String, List<int>>`; yarım
  ayarlar). Kopyalama metotları: `withSolvedPuzzle`, `withPuzzleState`. DTO'da küme sıralı liste olarak yazılır.
  Migration eski kayda iki boş alan ekler.
- **Arayüz:**
  - `SceneBloc`: `activePuzzleId` (arayüz durumu), `PuzzleClosed` olayı. Bulmaca açıkken sahne dokunuşları yok
    sayılır; `BackPressed` önce bulmacayı kapatır. Paneller üst üste binmez: bulmaca açıkken inceleme ve konuşma
    açılmaz, eşya paneline dokunuş ve uzun basma yok sayılır.
  - `PuzzleCubit` (`puzzles/presentation`): açık bulmacanın tanımı ve geçici durumu; çözülünce kapanır.
  - **Çizim:** bulmaca görünümü sahne alanını kaplayan bir katmandır ve sahneyle aynı hattan çizilir: arka plan →
    overlay ve bulmacanın çizdiği yazı / parçalar → noir filtre → etkileşim bölgeleri. `puzzles/presentation`,
    `scene_engine/presentation`'ı import edemeyeceği için birleştirme `app/game/scene_puzzle_area.dart`'tadır
    (`SceneDialogueArea` örneği gibi): `SceneVisualView`'a filtrenin **altında** çizilecek ek içerik için bir yuva
    eklenir; bulmaca iki widget verir (filtre altı çizim katmanı, filtre üstü dokunma katmanı).
  - Bulmaca, mesaj barının alt şeridini kapatmaz (dedektifin yorumu orada görünür). Bulmaca açıkken sol üstteki
    Geri, yığın tek elemanlı olsa da görünür. Açılış / kapanış kısa bir kararmayla olur (`AppDurations`; sahne
    geçişi değildir).
- **Doğrulama:** `PuzzleValidator` (`puzzles/domain`; `DialogueValidator` gibi aynı `ContentChecks`'e yazar):
  metin anahtarları, `visual` adları, `onSolved`'da yalnızca izinli etkiler, referanslar. `ContentValidator`
  `puzzleIds` kümesini düz veri olarak alır: `openPuzzle` / `puzzleSolved` referansı vardır; bir kuralda en fazla bir
  `openPuzzle`; `goToScene`, `inspect`, `talk` ile birlikte olmaz; yalnızca hotspot kuralında. **Uyarı:** hiçbir
  `openPuzzle` ile açılmayan bulmaca.
- **Geliştirici menüsü:** "bulmacayı çöz" (liste; `SolvePuzzle` üzerinden).
- **Testler:** `EffectApplier` (açma, çözülmüşü yok sayma), `ConditionEvaluator`, `SolvePuzzle` (tek kayıt,
  tetikleyici, olay; kayıt başarısızsa olay yok), migration v1 → v2 (gerçek v1 payload'ı), `SceneBloc` (açıkken
  dokunuş ve Geri), doğrulayıcı (bozuk referans, yasak etki). Bu adımda gerçek tür yoktur: testler sahte bir
  `PuzzleDefinition` alt sınıfıyla çalışır.
  **Kabul kriterleri:** Sahte türle uçtan uca: hotspot → bulmaca açılır → çözülür → `onSolved` + tetikleyici tek
  kayıtta → hotspot'a tekrar dokununca açılmaz. v1 kaydı v2 olarak açılır.
  **Commit:** `feat(puzzles): add puzzle framework, openPuzzle effect and puzzleSolved condition`

### [ ] 5.2 Rakamlı tuş takımı
**Amaç:** İlk gerçek bulmaca türü: şifreli kilit. Tuş takımı dışındaki kilit türleri yazılmaz.
**Yapılacaklar:**
- `KeypadPuzzle` (`type: "keypad"`):
  ```json
  {"id": "hall_strongbox", "type": "keypad",
   "visual": {"placeholderStyle": "strongbox_closeup", "filterPreset": "close_up"},
   "keys": {"rect": {"x": 0.35, "y": 0.30, "width": 0.30, "height": 0.50}, "rows": 4, "columns": 3,
            "values": ["1","2","3","4","5","6","7","8","9","clear","0","enter"]},
   "display": {"rect": {"x": 0.35, "y": 0.18, "width": 0.30, "height": 0.09}, "style": "brass"},
   "solution": "17", "wrongSay": "say_strongbox_wrong",
   "onSolved": [{"giveItem": "photo_half_a"}, {"addNote": "strongbox_ledger"}, {"say": "say_strongbox_open"}]}
  ```
  - `keys` iki biçim alır: **ızgara** (`rect` + `rows` + `columns` + `values`, satır satır) veya **tek tek**
    (`[{"value": "1", "rect": {...}}, ...]`; görseldeki tuşlar düzgün ızgara değilse).
  - Özel değerler: `clear` (göstergeyi siler), `enter` (dener). `enter` tuşu yoksa hane sayısı çözümün uzunluğuna
    ulaşınca kendiliğinden denenir. Hane sayısı çözümün uzunluğunu aşamaz.
  - `display.style` bir overlay yazı stilidir (`core/theme`); haneleri **oyun çizer** (ADR 0011), filtrenin altında.
  - Tuşlar görseldedir; oyun tuş çizmez, yalnızca dokunma bölgesi ve basış tepkisi (kısa parlama) verir.
- **Girilen haneler kaydedilmez:** `PuzzleCubit`'in geçici durumudur; bulmaca kapanınca sıfırlanır.
- Yanlış deneme: gösterge temizlenir, `ReportWrongAttempt`. Doğru deneme: `SolvePuzzle`, bulmaca kapanır.
- **Doğrulama:** `solution` boş değil ve yalnızca tuşlarda bulunan değerlerden oluşur; tuş ve gösterge `rect`'leri
  0–1 aralığında ve mesaj barı şeridinin dışında; ızgarada `values` sayısı = `rows × columns`; `display.style`
  kodda tanımlı.
- **Demo içeriği (dikey dilim):** `villa_hall`'e `strongbox` hotspot'u (`sprite`'lı). Kurallar: `puzzleSolved` ise
  kısa replik; değilse `openPuzzle`. Şifre, villa önündeki kapı numarası overlay'inden okunur (mevcut
  `villa_house_number`). `onSolved`: `photo_half_a` eşyası + `strongbox_ledger` notu (5.9'da sayfalanır) + replik.
  Yeni placeholder çizimleri: `strongbox_closeup`, `sprite_strongbox`, `item_photo_half`.
- `assets/dev/presets.json`'a "kasa çözülmüş" durumu; `tool/render_scenes_test.dart` bulmaca görsellerini de çizer.
- **Testler:** `PuzzleCubit` (`bloc_test`: hane ekleme, sınır, `clear`, yanlış, doğru, `enter`'sız otomatik deneme),
  DTO (iki `keys` biçimi, bozuk ızgara), widget testi (bölgeye dokunma → gösterge), kabul senaryosu 21–22.
  **Kabul kriterleri:** Kabul senaryosunun 21–22. adımları telefonda ve Windows'ta fareyle çalışıyor; şifre hiçbir
  görsele gömülü değil.
  **Commit:** `feat(puzzles): add keypad puzzle and the strongbox demo`

### [ ] 5.7 Eşya birleştirme ve eşyanın içini açma
**Amaç:** Eşyalar yalnızca sahnede değil, birbirleriyle ve kendi başlarına da kullanılabilsin.
**Yapılacaklar:**
- ADR (bu adımda yazılır): eşya etkileşimleri.
- **İçerik:** `items.json`'da eşyaya opsiyonel `interactions` (aynı kural dili):
  ```json
  {"id": "photo_half_a", "nameKey": "...", "descriptionKey": "...", "iconStyle": "item_photo_half",
   "interactions": [
     {"when": {"usingItem": "photo_half_b"},
      "do": [{"consumeItem": "photo_half_a"}, {"consumeItem": "photo_half_b"},
             {"giveItem": "restored_photo"}, {"say": "say_photo_restored"}]}
   ]}
  ```
  İzinli etkiler: `say`, `setFlag`, `addNote`, `addNoteEntry`, `giveItem`, `consumeItem` (gezinme, `inspect`, `talk`,
  `openPuzzle`, `hideHotspot` yok).
- **Kuralların yeri (kodla çelişki, bkz. Notlar 2026-11-16):** `ItemDefinition` `inventory/domain`'dedir ve
  `scene_engine` → `inventory` yönü sabittir; `inventory`, `InteractionRule`'u import ederse döngü oluşur. Bu yüzden
  eşya kuralları `scene_engine` tarafından okunur: `CaseContent.itemRules` (`itemId` → kurallar). `ItemDto`
  `interactions` alanını tanır ama yorumlamaz (bilinmeyen alan reddedildiği için gerekli). **Adım başlarken
  kullanıcıya onaylatılır.**
- **Use case'ler (`scene_engine/domain`):** `InteractionResolver` hotspot yerine kural listesi alacak şekilde
  genelleştirilir (davranış aynı).
  - `OpenItem(itemId)`: eşyanın eşyasız dokunuş kuralını çalıştırır (zarfın içinden mektup çıkar).
  - `CombineItems(selected: A, target: B)`: önce B'nin `usingItem: A` kuralı, yoksa A'nın `usingItem: B` kuralı;
    hiçbiri tutmazsa genel tepki (`generic_item_no_effect`). Etkiler etki hattından geçer.
- **Arayüz (`app/` birleştirir):**
  - **Aç:** inceleme kartında düğme; yalnızca eşyanın o an çalışacak eşyasız kuralı varsa görünür. Basınca kart
    kapanır, kural çalışır.
  - **Birleştir:** A seçiliyken paneldeki B'ye dokunma. Seçim her durumda temizlenir. (Seçimi değiştirmek için önce
    A'ya dokunup bırakılır.) Konuşma paneli açıkken eşya dokunuşu eskisi gibi "göster"dir; birleştirme denenmez.
- **Doğrulama:** eşya kurallarında yalnızca izinli etkiler; referanslar; `usingItem` yalnızca var olan eşyayı gösterir.
- **Demo içeriği:** çarşıda alınan `photo_half_b` (`sprite`'lı hotspot) ve `restored_photo`. "Aç" için demo içeriği
  yoktur; fixture'la test edilir.
- **Testler:** resolver (iki yön, hiçbiri, koşullu kural), use case'ler (tek kayıt, olaylar), `InventoryCubit`,
  inceleme kartı widget testi ("Aç" görünür / görünmez), kabul senaryosu 24.
  **Kabul kriterleri:** İki yarım her iki sırayla da birleşiyor; ilgisiz iki eşya yalnızca genel tepki veriyor.
  **Commit:** `feat(inventory): combine items and open an item from its card`

### [ ] 5.9 Sayfalı not
**Amaç:** Çok sayfalı belgeler (günlük) defterde sayfa sayfa okunsun.
**Yapılacaklar:**
- `notes.json`'da nota opsiyonel `pages` (metin anahtarı listesi): `{"id": "strongbox_ledger", "category":
  "document", "titleKey": "...", "pages": ["note_ledger_p1", "note_ledger_p2"]}`. Bir notta `bodyKey` **veya**
  `pages` bulunur (tam olarak biri); domain'de not her zaman sayfa listesi taşır (tek gövde = tek sayfa).
- Defterde sayfa çevirme: ileri / geri düğmeleri ve "2 / 5" göstergesi (ARB). Hangi sayfada kalındığı arayüz
  durumudur; **kayıt şekli değişmez**. Not, hangi sayfası açık olursa olsun bütün olarak kanıttır.
- Not satırları (`entries`) sayfalı notta son sayfanın altında değil, bütün sayfalarda ortak bölümde görünür.
- Doğrulama: `pages` boş değil; her sayfa anahtarı desteklenen dillerde var; `bodyKey` ile birlikte kullanılmaz.
- Demo: `strongbox_ledger` iki sayfa.
- Testler: DTO, `NotebookCubit` (sayfa sınırları), widget testi, kabul senaryosu 23.
  **Kabul kriterleri:** İki sayfalı not çevriliyor; tek gövdeli notlarda sayfa düğmesi görünmüyor.
  **Commit:** `feat(notebook): add multi-page notes`

### 5.4 Bölüm akışı
**Amaç:** Bölümler bitebilsin, oyun durmadan sıradaki bölüme geçilsin, Bölüm 1'in sonunda satın alma / demo sonu
kapısı çıksın ve sonraki bölümün içeriği o bölüme ulaşılmadan görünmesin (ADR 0021). Yeni feature
`features/case_flow/`.

#### [ ] 5.4a Bitiş koşulu, `chapterReached` ve genişletmelerin sarılması
**Yapılacaklar:**
- **`case.json`:** bölüme `titleKey` ve opsiyonel `completeWhen` (koşul; `usingItem` içermez):
  ```json
  {"id": "ch01", "entrySceneId": "villa_exterior", "titleKey": "chapter_ch01_title",
   "completeWhen": {"hasItem": "restored_photo"}}
  ```
  `ChapterDefinition`'a iki alan eklenir; `CaseManifest` yeni anahtarları tanır. `titleKey` bölümün kendi metin
  dosyasındadır. `completeWhen`'i olmayan bölüm bu yolla bitmez (son bölüm suçlamayla biter).
- **Kayıt (v2 → v3):** `completedChapters` (`[{chapterId, completedAtUtcMs}]`) ve `reachedChapters` (küme).
  Migration: `reachedChapters = [chapterId]`, `completedChapters = []`. Yeni oyunda ilk bölüm baştan kümededir.
- **Yeni koşul `{"chapterReached": "ch02"}`:** kümeye bakar; saftır.
- **Bitiş (etki hattında):** tetikleyicilerden sonra, bulunulan bölümün (`progress.chapterId`) `completeWhen`'i
  tutuyorsa ve bölüm henüz tamamlanmamışsa, bölüm **aynı kayıtta** tamamlandı işaretlenir; olay
  `ChapterCompleted(chapterId)`. Hat bunun için bölüm tanımlarına ihtiyaç duyar: `run`'ın `triggers` parametresi
  `rules` (tetikleyiciler + bölümler) olur; bütün çağıranlar güncellenir. Hiçbir koşul `completedChapters`'ı
  okumadığı için tetikleyiciler yeniden çalıştırılmaz.
- **Genişletmelerin bölüme göre açılması (birleştirme, `data` katmanı):** bölüm N'in **önceki bölümlere eklediği**
  her şeyin koşulu `all[chapterReached N, <kendi koşulu>]` ile sarılır (kendi koşulu yoksa yalnızca
  `chapterReached N`):
  - `sceneExtensions`: yeni hotspot'ların `visibleWhen`'i, eklenen kuralların `when`'i, görünüm varyantlarının `when`'i;
  - `dialogueExtensions`: eklenen konuların `visibleWhen`'i;
  - bölüm N'in tetikleyicilerinin `when`'i (ve 5.6'da ipucu hedeflerinin `when`'i).
  İlk bölümün içeriği sarılmaz. Bölüm N'in **kendi** sahneleri sarılmaz (onlara ancak sarılmış bir geçişle
  ulaşılır). `noteExtensions` sarılmaz (satır ancak bir etkiyle açılır). Resolver'lar ve `ConditionEvaluator`'ın
  geri kalanı değişmez; `all` içindeki `usingItem` resolver'da zaten tanınıyor.
- **Doğrulama:** `chapterReached` `case.json`'da listeli ve o önekte var olan bir bölümü gösterir (Bölüm 1 içeriği
  `chapterReached ch02` yazamaz; önek doğrulaması yakalar); `titleKey` metni; `completeWhen` kuralları.
- **Geliştirici menüsü / preset:** sahneye göre bölüm seçen kod `reachedChapters`'ı o bölüme kadar doldurur.
- **Testler:** hat (bitiş tek kayıtta, olay bir kez, ikinci kez işaretlenmez), birleştirme (sarılmış hotspot /
  kural / varyant / konu / tetikleyici; iki bölümlü fixture), `ConditionEvaluator`, migration v2 → v3, doğrulayıcı.
  **Kabul kriterleri:** İki bölümlü fixture'da B2'nin eklediği hotspot, soru ve tetikleyici, `reachedChapters`'ta
  B2 yokken görünmüyor / çalışmıyor; B1'in bitiş koşulu tutunca `ChapterCompleted` tam bir kez yayınlanıyor.
  **Commit:** `feat(case_flow): add chapter completion, chapterReached and chapter-gated extensions`

#### [ ] 5.4b Sahiplik ve bölüm ilerletme
**Yapılacaklar:**
- **`case_flow/domain`:** `EntitlementRepository` ("bu bölüm açık mı": `isChapterUnlocked(caseId, chapterId)` +
  değişiklik akışı). **Satın alma kilidi kayda girmez** (CLAUDE.md §8).
- **Uygulamalar (`case_flow/data`; seçim DI'da, flavor'a göre):** `dev` → hepsi açık, geliştirici menüsünde aç /
  kapat anahtarı (menü `data`'yı import edemediği için küçük bir domain arayüzü üzerinden); diğer derlemeler →
  gerçek mağaza gelene kadar (Aşama 8 / 11) **yalnızca Bölüm 1 açık** (güvenli varsayılan).
- **`AdvanceChapter` use case:** bulunulan bölüm tamamlanmışsa sıradaki bölüme geçmeyi dener. Sıradaki bölüm
  pakette yoksa (`CaseContent`'te yok: demo derlemesi) veya sahiplik yoksa bölüm ilerlemez → **kapı durumu**.
  Varsa hattan tek kayıt: `chapterId` = sıradaki, `reachedChapters`'a eklenir; aynı kayıtta o bölümün artık koşulu
  tutan tetikleyicileri çalışır. Oyuncu ışınlanmaz: `entrySceneId` yalnızca doğrulamanın ve geliştirici menüsünün
  başlangıç noktasıdır.
- **Ne zaman denenir:** `ChapterCompleted` olayında, açılışta ve sahiplik değişince (`app/` katmanında küçük bir
  koordinatör; `SaveLifecycle` örneği gibi).
- **Kapı durumu türetilir, kaydedilmez:** "bulunulan bölüm tamamlandı ve sıradaki bölüme geçilemedi".
  `ChapterGateCubit` (`case_flow/presentation`) ilerleme + içerik + sahiplikten hesaplar; nedenini de taşır
  (`notInBuild` / `notOwned`).
- **Demo içeriği:** bitiş koşullu `ch01` (5.4a örneği) ve küçük bir `ch02`: kahveciye tek soru ekleyen bir
  `dialogueExtensions` + zorunlu boş dosyalar + metinler. `pubspec.yaml`'a yeni klasör. `case.json`'a `ch02`.
- **Testler:** `AdvanceChapter` (sahip / sahip değil / pakette yok / bölüm bitmemiş / son bölüm), kapı cubit'i,
  dev anahtarı, içerik doğrulama (B1 öneki tek başına geçer).
  **Kabul kriterleri:** Sahiplik açıkken bölüm bitince `chapterId` `ch02` oluyor ve kahvecideki yeni soru görünüyor;
  kapalıyken ilerlemiyor, açılınca (olay beklemeden) ilerliyor.
  **Commit:** `feat(case_flow): add entitlement repository and chapter advancing`

#### [ ] 5.4c Bölüm bildirimi ve kapı ekranı
**Yapılacaklar:**
- **Bildirim:** `ChapterCompleted` gelince sahne alanının üstünde kısa bir bant: "Chapter 1 complete — <ad>" (ARB
  şablonu `chapterCompleteBanner(number, title)` + içerikten `titleKey`). Birkaç saniye sonra kendiliğinden kaybolur
  (tek sabit); dokunmaları engellemez; hiçbir şeyi durdurmaz.
- **Kapı ekranı (yalnızca kapı durumunda; pratikte Bölüm 1 sonu):** hangi ekranın çıkacağını DI belirler
  (derleme hedefine göre kayıtlı bir değer; widget'larda `Platform.isX` yok): mobilde **satın alma ekranı** (düğme
  Aşama 8'e kadar yer tutucu: "yakında"), Steam'de **demo sonu ekranı**. Metinler ARB'de.
  - Bildirimden sonra, açık bir panel (konuşma, bulmaca, inceleme) varsa o kapanınca **bir kez** kendiliğinden açılır.
  - **Kapatılabilir:** oyuncu Bölüm 1 dünyasında dolaşmaya devam eder; Bölüm 2 içeriği açılmaz.
  - Kapı durumu sürdükçe HUD'da "tam oyunu aç" girişi kalır (ekranı yeniden açar). Sonraki açılışlarda ekran
    kendiliğinden açılmaz; yalnızca giriş görünür.
  - Ekran `GameScreen` içinde bir katmandır (rota değil); Geri sırasına girer (defter / geçmiş → kapı ekranı →
    panel → üst sahne).
- Hesap bağlama önerisi burada yoktur (3.3'te bu ekrana eklenir).
- **Testler:** bildirim (görünür, kaybolur, dokunmayı engellemez), iki ekran türü, kapatma, HUD girişi, sahiplik
  açılınca girişin kaybolması, Geri sırası, kabul senaryosu 25–26.
  **Kabul kriterleri:** Kabul senaryosunun 25–26. adımları; Steam giriş noktasıyla demo sonu ekranı çıkıyor.
  **Commit:** `feat(case_flow): add chapter banner and the chapter-one gate screen`

### 5.6 İpucu sistemi
**Amaç:** Takılan oyuncu, istediğinde kademeli yardım alsın (ADR 0022). **İlke:** oyuncuya hiçbir şey doğrudan
buldurulmaz; dedektif gördüğünü söyler, yön göstermez; ipucu yalnızca oyuncu isteyince gelir. **Kendiliğinden
yönlendirme kapalıdır:** bu aşamada kodu yazılmaz (bkz. Notlar 2026-11-16).

#### [ ] 5.6a İpucu hedefleri ve kademeler (arayüz yok)
**Yapılacaklar:**
- **İçerik:** `ContentType.hints` (opsiyonel; `hints.json` veya `hints/*.json`). Sıralı hedefler:
  ```json
  {"formatVersion": 1,
   "hints": [
     {"id": "open_strongbox",
      "when": {"not": {"puzzleSolved": "hall_strongbox"}},
      "tiers": ["hint_strongbox_1", "hint_strongbox_2", "hint_strongbox_3"]}
   ]}
  ```
  `when` = "bu hedef hâlâ açık". Koşulu tutan **ilk** hedef şu anki hedeftir (bölüm sırası, sonra dosya sırası).
  Kademeler: yön → net → cevap; sayısı serbest (en az 1). Hedef ID'leri vaka içinde benzersizdir. Bölüm N'in
  hedefleri birleştirmede `chapterReached N` ile sarılır (5.4a).
- **Kayıt (v3 → v4):** `hintsUsed` (sayı) ve `hintTiers` (hedef ID → açılan basamak). Migration: `0` ve boş.
- **`HintResolver` (saf, `case_flow/domain`):** ilerleme + hedefler → sıradaki basış ne yapar:
  1. hedefin ilk basışı: **dokunulabilir yerleri göster** (metin yok);
  2. sonraki basışlar: sırayla kademe metinleri;
  3. son kademeden sonra: son metin tekrar, **sayılmaz**;
  4. açık hedef yok: genel bir cümle (`common` metni), **sayılmaz**.
- **`RequestHint` use case:** yeni bir basamak açan her basış hattan tek kayıttır: `hintTiers` ilerler, `hintsUsed`
  bir artar, kademe metni `say` etkisiyle gelir (mesaj barı ve geçmiş; dedektifin iç sesi). Sayılmayan basışlar
  yalnızca `say` çalıştırır.
- **Bekleme:** iki basış arasında 60 sn (`HintRules.cooldown`, tek sabit). `Clock` ile ölçülür, **kaydedilmez**
  (uygulama yeniden açılınca sıfırdan başlar). Yalnızca yeni basamak açan basış beklemeyi başlatır.
- **"Dokunulabilir yerleri göster" için tür (`scene_engine/domain`, saf):** `HotspotKindResolver`, görünür her
  hotspot'un eşyasız dokunuşta **o an çalışacak** kuralının etkilerinden türü türetir; JSON'a alan eklenmez.
  Öncelik sırası: `talk` → kişi; `openPuzzle` → bulmaca; `goToScene` → geçiş; `giveItem` / `addNote` → alınacak
  nesne; diğer.
- **Doğrulama:** hedef referansları ve metinleri; `when` içinde `usingItem` yok; genel cümlenin anahtarı `common`'da.
- **Testler:** `HintResolver` (her dal, hedef değişince baştan), `RequestHint` (sayaç, tek kayıt, sayılmayanlar),
  `HotspotKindResolver` (her tür, koşullu kural), migration v3 → v4, doğrulayıcı.
  **Kabul kriterleri:** Demo hedefinde basış sırası testte: göster → 1 → 2 → 3 → 3 (sayılmaz); kasa çözülünce
  sıradaki hedefe geçiliyor.
  **Commit:** `feat(case_flow): add hint objectives and tiers`

#### [ ] 5.6b İpucu düğmesi ve dokunulabilir yerleri gösterme
**Yapılacaklar:**
- **HUD:** sağ panelde, not defteri düğmesinin yanında ipucu düğmesi. Bekleme sürerken soluk çizilir ve kalan süreyi
  gösterir; basınca hiçbir şey olmaz. Bir panel (konuşma, bulmaca, inceleme, defter) açıkken etkisizdir.
- `HintCubit` (`case_flow/presentation`): bekleme sayacı (`Clock`), `RequestHint` çağrısı, "göster" isteği.
- **İşaretleme:** görünür hotspot'lar ~1,5 sn (tek sabit) türüne göre küçük bir simgeyle işaretlenir; işaret
  dokunma alanının ortasındadır, dokunmayı engellemez, oyun mantığını etkilemez (yalnızca sunum). Çizim
  `scene_engine/presentation`'daki hotspot katmanında; istek `app/` üzerinden iletilir.
- **Demo içeriği:** `ch01` için birkaç hedef (kasa, fotoğrafı birleştirme, vana kutusu 5.8'de eklenir).
- Yeni ARB metinleri (düğme etiketi, bekleme bilgisi).
- **Testler:** `HintCubit` (`bloc_test`, sahte saat: bekleme, sayılmayan basış beklemeyi başlatmaz), widget testleri
  (işaretler görünür ve kaybolur, düğme beklemede etkisiz), kabul senaryosu 27.
  **Kabul kriterleri:** Kabul senaryosunun 27. adımı; ipucu metinleri mesaj geçmişinde; kapat-aç sonrası açılmış
  kademeler ve sayaç yerinde.
  **Commit:** `feat(case_flow): add hint button and tappable-spot markers`

### [ ] 5.8 Yön bulmacası
**Amaç:** İkinci bulmaca türü: birkaç parçanın yönünü bir metindeki tarife göre ayarlamak.
**Yapılacaklar:**
- ADR (bu adımda yazılır): yön bulmacası.
- `DirectionsPuzzle` (`type: "directions"`):
  ```json
  {"id": "demo_valves", "type": "directions",
   "visual": {"placeholderStyle": "valves_closeup"},
   "pieces": [
     {"id": "v1", "rect": {"x": 0.20, "y": 0.35, "width": 0.14, "height": 0.25},
      "sprite": {"placeholderStyle": "sprite_valve"}, "initial": "up", "solution": "left"},
     {"id": "v2", "rect": {"x": 0.43, "y": 0.35, "width": 0.14, "height": 0.25},
      "sprite": {"placeholderStyle": "sprite_valve"}, "initial": "up", "solution": "down"}
   ],
   "onSolved": [{"setFlag": "valves_set"}, {"say": "say_valves_done"}]}
  ```
  - Yönler: `up`, `right`, `down`, `left`. Dokunuş parçayı **saat yönünde 90°** çevirir (sürükleme yok).
  - Parça görseli: tek görsel döndürülür (`up` konumunda çizilmiş) **veya** yön başına ayrı görsel
    (`"sprite": {"images": {"up": "...", "right": "...", ...}}`; ışığı yöne göre değişen nesneler için). Parçalar
    filtrenin altında çizilir.
- **Ara durum kayıttadır:** her dokunuş `SavePuzzleState` ile `puzzleStates[id]`'e yazılır (parça sırasıyla yön
  indeksleri). Kayıtta durum yoksa `initial` değerleri kullanılır. Hepsi doğru olunca `SolvePuzzle`: çözülür,
  kilitlenir, ara durum silinir. "Dene" düğmesi yoktur; yanlış ara durumlarda yorum yapılmaz (`wrongSay` bu türde
  kullanılmaz; doğrulayıcı reddeder).
- **Doğrulama:** en az iki parça; parça ID'leri bulmaca içinde benzersiz; `rect` 0–1 ve şerit dışında; başlangıç
  durumu çözümle aynı değil; yön adları geçerli; `images` verildiyse dört yön de var.
- **Demo içeriği:** çarşıda `valve_box` hotspot'u → `demo_valves` (üç vana). Tarif mevcut bir notun metnindedir.
  Yeni placeholder'lar: `valves_closeup`, `sprite_valve`. İpucu hedefi eklenir.
- **Testler:** `PuzzleCubit` (çevirme, sarma `left → up`, çözülme), kaydedilen durumdan açılma, DTO, doğrulayıcı,
  widget testi, kabul senaryosu 28.
  **Kabul kriterleri:** Kabul senaryosunun 28. adımı; kapat-aç sonrası yarım ayar yerinde.
  **Commit:** `feat(puzzles): add directions puzzle`

### 5.5 Suçlama
**Amaç:** Vakanın finali: polise bir isim ve kanıt sunmak (ADR 0023).

#### [ ] 5.5a Suçlama kuralları (arayüz yok)
**Yapılacaklar:**
- **`case.json`:** `accusation` (demo değerleri; gerçek hikayeyle ilgisiz):
  ```json
  "accusation": {
    "suspects": ["person_pharmacist", "person_cafe_owner"],
    "culprit": "person_cafe_owner",
    "evidence": [{"note": "hall_letter"},
                 {"note": "person_cafe_owner", "entry": "recognised_paper"},
                 {"note": "strongbox_ledger"}],
    "minValid": 2, "maxPicked": 3, "attempts": 2,
    "solutionTextKey": "accusation_solution",
    "onSolved": [{"say": "say_case_closed"}]
  }
  ```
  `suspects` kişi notu ID'leridir (tanıkların dosyası olur ama listede yer almaz). `evidence` geçerli kanıtlardır:
  bir not veya bir dosya satırı. `onSolved` opsiyoneldir; izinli etkiler: `say`, `setFlag`, `addNote`,
  `addNoteEntry`, `giveItem`, `goToScene` (ör. final sahnesi). `accusation` anahtarını `case_flow/data` okur;
  `CaseManifest` yalnızca tanır.
- **Yeni etki `{"openAccusation": true}`** (`scene_engine/domain`): arayüz durumudur (`talk` gibi); yalnızca hotspot
  kuralında; `goToScene`, `inspect`, `talk`, `openPuzzle` ile birlikte olmaz; bir kuralda en fazla bir tane.
  Koşulunu içerik yazar (karakoldaki hotspot). `EffectOutcome.opensAccusation`.
- **Kayıt (v4 → v5):** `accusation`: `attempts` (`[{suspect, evidence: [{note, entry?}], atUtcMs, verdict}]`) ve
  `outcome` (`none` / `solved` / `revealed`). Migration: boş liste + `none`.
- **`AccusationJudge` (saf):** kabul = isim doğru **VE** seçilenlerin en az `minValid` tanesi geçerli; ilgisiz ek
  kanıt zarar vermez. Kararlar: `accepted`; `wrongSuspect` ("ikna olmadım"); `weakEvidence` (isim doğru, kanıt
  yetersiz: "kanıtlar zayıf"). **İkisinde de hak düşer.** İsim yanlışsa kanıtlara bakılmaz (yanlış isim + iyi
  kanıt da `wrongSuspect`'tir).
- **Use case'ler (hepsi hattan):**
  - `SubmitAccusation(suspect, evidence)`: denemeyi kaydeder; kabulse `outcome = solved` + `onSolved` aynı kayıtta.
    Seçim kuralları: 1 ile `maxPicked` arası kanıt; yalnızca oyuncunun defterindeki notlar / satırlar; hak kalmışsa.
  - `RevealSolution`: haklar bitince; `outcome = revealed`. `onSolved` çalışmaz.
  - `RestartCase`: haklar bitince; ilerleme **ve oyun süresi** sıfırlanır (yeni oyun, ilk bölümün giriş sahnesi).
    Süreyi kayıt katmanı saydığı için sayacı sıfırlayan küçük bir domain arayüzü gerekir (bkz. Notlar 2026-11-16).
- **Şüpheli portresi:** kişi notuna opsiyonel `portrait` (`placeholderStyle` + `image?`; konuşmadaki şekille aynı).
  Şüpheli listesindeki her not için zorunludur (doğrulayıcı). 7.3'teki "kişi dosyasında portre" de bu alanı kullanır.
- **Olay:** `AccusationJudged(verdict)` (arayüz tepkisi ve 9.2 analitiği için).
- **Doğrulama:** şüpheliler `person` kategorisinde var olan notlar; `culprit` listede; kanıt notları / satırları var;
  `1 ≤ minValid ≤ maxPicked`; geçerli kanıt sayısı ≥ `minValid`; `attempts ≥ 1`; metinler; `openAccusation` varsa
  `accusation` tanımlı; `onSolved` izinli etkiler. **Uyarı:** `accusation` var ama hiçbir `openAccusation` yok.
- **Testler:** `AccusationJudge` (her karar, sınırlar, ilgisiz ek kanıt), use case'ler (hak düşmesi, hak yokken ret,
  tek kayıt, `onSolved`), migration v4 → v5, doğrulayıcı.
  **Kabul kriterleri:** Demo suçlaması testte: yanlış isim → 1 hak; doğru isim + 1 geçerli → zayıf, 0 hak; yeni
  oyunda doğru isim + 2 geçerli + 1 ilgisiz → `solved`.
  **Commit:** `feat(case_flow): add accusation rules and the openAccusation effect`

#### [ ] 5.5b Suçlama ekranı
**Yapılacaklar:**
- `SceneBloc`: suçlama açık / kapalı arayüz durumu (bulmaca gibi; paneller üst üste binmez).
- `AccusationCubit` + ekran (`case_flow/presentation`; `GameScreen` içinde katman):
  1. **Şüpheli seç:** portre ızgarası (9 şüpheli telefonda kaydırmadan sığar: 5 + 4 veya 3 × 3) + isim.
  2. **Kanıt seç:** defter seçim modunda açılır (1.18'deki "Göster" akışı çoklu seçime genişletilir): notlar ve
     kişi dosyalarının satırları tek tek seçilebilir; en fazla `maxPicked`; seçilenler ekranda özetlenir.
  3. **Onay:** isim + kanıtlar + kalan hak; "Suçla".
  4. **Karar:** polisin cevabı (`common` içerik metinleri) ve kalan hak. Kabul → `onSolved` → sonuç ekranı (5.5c).
- Geri her adımda bir önceki adıma, ilk adımda sahneye döner; deneme yalnızca "Suçla" ile harcanır.
- `outcome` `none` değilken `openAccusation` yeniden suçlama başlatmaz; sonuç ekranını gösterir.
- Yeni ARB metinleri.
- **Testler:** cubit (`bloc_test`: adımlar, seçim sınırı, geri), widget testleri (ızgara 640×360'ta sığar, çoklu
  seçim), Geri sırası.
  **Kabul kriterleri:** Akış telefonda ve fareyle baştan sona çalışıyor; yarıda bırakılan suçlama hak harcamıyor.
  **Commit:** `feat(case_flow): add accusation screen`

#### [ ] 5.5c Haklar bitince, sonuç ekranı ve aşama kabulü
**Yapılacaklar:**
- **Haklar bitince:** iki seçenek: "Baştan oyna" (onay sorar; `RestartCase`) ve "Çözümü gör" (`RevealSolution` →
  `solutionTextKey` metni → sonuç ekranı).
- **Sonuç ekranı:** sonuç (çözüldü / çözüm gösterildi), deneme sayısı, toplam süre, kullanılan ipucu sayısı.
  Toplam süre için güncel oyun süresi kayıt katmanından okunur (bellekteki ilerlemede süre canlı değildir; küçük bir
  domain arayüzü, bkz. Notlar 2026-11-16).
- **Paylaşım:** sonuç, spoiler içermeyen kısa bir metin olarak paylaşılır (şüpheli adı ve kanıt yazılmaz). Adım
  başlarken paylaşım paketinin (`share_plus`) Windows desteği pub.dev'den kontrol edilir ve **kullanıcıya sorulur**;
  paket eklenmezse "Kopyala" metni panoya verir.
- **Demo içeriği:** çarşıda `police_phone` hotspot'u → `openAccusation` (koşul: fotoğraf birleştirilmiş). İki
  şüpheli (eczacı, kahveci), portreleri, metinler.
- **Aşama kabulü:** kabul senaryosu 21–30 `acceptance_scenario.dart`'a eklenir (CI widget testi + Windows
  `integration_test`); kapat-aç testi yeni alanlarla genişler; profil ölçümü (bulmaca açılışı, suçlama ekranı);
  README ve ekran görüntüleri güncellenir.
- **Testler:** restart (süre dahil sıfır), reveal, sonuç ekranı, paylaşım metni (spoiler yok), kabul senaryosu 29–30.
  **Kabul kriterleri:** Kabul senaryosunun tamamı (1–30) CI'da ve Windows'ta geçiyor; telefonda manuel kontrol
  listesi devlog'da.
  **Commit:** `feat(case_flow): add case result screen and restart` ve `test: extend acceptance scenario for phase 5`

### [ ] 5.10 Genel yer tutucu çizim
**Amaç:** Gerçek içeriği, görseller üretilmeden yazıp oynayabilmek (7.4a). Her sahne için kodda ayrı painter
yazmak gerekmesin.
**Yapılacaklar:**
- Tek bir genel sahne stili: `placeholderStyle: "blockout"`. Sahnenin adını ve görünür her hotspot'un etiketini
  kendi `rect`'inde bir kutu içinde çizer (noir palet; ortak filtre yine üstünde). `PlaceholderArt` bugün yalnızca
  stil adını alır ve `core`'dadır (feature import edemez): başlık ve (etiket, dikdörtgen) listesi **düz veri** olarak
  parametreyle verilir; metinleri `scene_engine/presentation` çözer.
- Genel nesne ve kişi stilleri: `sprite_generic` (etiketli kutu), `silhouette_generic`, `portrait_generic`,
  `item_generic` (eşya adının baş harfi). Bulmaca görselleri için de `blockout` kullanılabilir (bölgeler kutu olarak).
- Stiller `PlaceholderStyles.names`'e eklenir (doğrulayıcı tanır). Dikey dilimin elle çizilmiş placeholder'ları kalır.
- `tool/render_scenes_test.dart` blockout sahneleri de çizer.
- **Testler:** painter'ların çökmemesi (boş liste, uzun etiket), golden gerekmez; bir fixture sahnesiyle widget testi.
  **Kabul kriterleri:** Yalnızca JSON yazarak (`placeholderStyle: "blockout"`) eklenen bir sahne, kodda yeni painter
  olmadan okunaklı çiziliyor ve oynanıyor.
  **Commit:** `feat(core): add generic blockout placeholders`
  **Aşama sonu:** `phase-5` etiketi.

### [ ] 5.3 Kayıt inceleme (`PlayMedia`) — **ERTELENDİ**
Hikaye kullanmıyor (2026-11-16). Kutu açık kalır; **Aşama 5 bu adım olmadan biter** ve `phase-5` etiketi onsuz
atılır. `Sıradaki adım` bu adımı atlar. Hikaye ileride isterse: döneme uyar (1950'ler; güvenlik kamerası yok),
makaralı ses bandı (dinle / durdur / geri sar) veya film şeridi (kare kare); ses 6.1'de bağlanır. O zaman adım
detaylandırılır ve ADR yazılır.

**Yeni adım gerektirmeyen bulmaca türleri** (mevcut kural diliyle, içerik olarak kurulur): sembol eşleştirme;
karanlık sahnede ışık kaynağı (eşya kullanma + görünüm varyantı); delikli kağıt (şablon eşyası seçilip hedefe
dokunulur; yalnızca deliklerin altındaki yazı overlay olarak okunur); çelişki yakalama (konuşmada "Kanıt göster" +
konunun `do` listesinde gözlem notu, 1.18).
**Plan dışı:** tuş takımı dışındaki kilit türleri (döner kilit, saat kadranı, harf kilidi); delikli kağıdın
sürüklemeli sürümü; kendiliğinden yönlendirme (kapalı).

## Aşama 6 — Oyun hissi ve uygulama kabuğu
*(Başlarken: açık kararları sor, adımları detaylandır, onay al.)*

- [ ] 6.1 Ses: **mekan başına ambiyans döngüsü** (yağmur, rüzgar, barda uzaktan caz), kapı / adım / gıcırtı
  efektleri; müzik az. Geçişlerde `sfx` + `holdMs` (karanlık ses bitene kadar uzayabilir), kayıt incelemenin (5.3,
  yapılırsa) sesi, ses ayarları, arka planda susma.
- [ ] 6.2 Dokunsal geri bildirim ve mikro animasyonlar.
- [ ] 6.3 Uygulama ikonu, açılış ekranı (native splash), ana menü (Devam / Yeni Oyun / Ayarlar), yeni oyun onayı.
- [ ] 6.4 Ayarlar: ses, dil (birden fazla dil desteklendiğinde), hesap ve eşitleme durumu, gizlilik politikası bağlantısı, sürüm bilgisi.
- [ ] 6.5 Performans ve erişilebilirlik: komşu sahnelerin önceden yüklenmesi, kullanılmayan görsellerin bellekten atılması,
  bellek ölçümü, yazı ölçeği, kontrast.

## Aşama 7 — Hikaye, içerik ve görseller
*(Başlarken: açık kararları sor, adımları detaylandır, onay al.)*

**Sıra:** İki parçada yapılır (bkz. "Çalışma sırası"). Bölüm 1 parçası Aşama 5'ten hemen sonra, şu sırayla:
**7.0 → 7.1 → 7.4a → 7.2 → 7.3 → 7.4b → 9.1 → 7.4c.** 7.5 (Bölüm 2–4) Aşama 6'dan sonra.
**Önce içerik, sonra görsel:** Bölüm 1 önce yer tutucu çizimlerle (5.10) yazılır ve kullanıcı kendi oynayıp
düzeltir; görseller ancak ondan sonra üretilir. Gerekçe: görsel üretilmeden hikayeyi, sahne listesini ve bulmaca
zincirini değiştirmek ucuzdur; üretilmiş görseli atmak pahalıdır. Oyun testinin sonucu Aşama 3'e geçmeden önce
değerlendirilir; bulmaca veya hikaye değişikliği gerekiyorsa önce o yapılır.

- [ ] 7.0 **Repoyu private yap** — hikaye, bulmaca çözümleri ve görseller repoya girmeden önce (spoiler ve içerik
  koruması). Bu adım bitmeden `docs/story/`, bulmaca çözümü içeren JSON veya gerçek görsel commit edilmez.
  `gh repo edit asklife23/DetectiveDark --visibility private --accept-visibility-change-consequences`
  (dışa dönük ve geri alınması zor bir işlem: çalıştırmadan önce kullanıcıdan onay alınır).
  Private repoda GitHub Actions dakika sınırını kontrol et (ücretsiz planda aylık kota; Windows ve macOS
  makineleri kotadan daha hızlı düşer); gerekirse CI'ı sadece `main` push'larında çalıştır (`pull_request`
  tetikleyicisini kaldır). README'deki CI rozeti private repoda herkese görünmez; portföy görünürlüğü
  (ör. içeriksiz açık bir vitrin reposu) bu adım başlarken konuşulur.
- [ ] 7.1 Vaka 1 kurgusu: **hikaye iskeleti kullanıcıda hazırdır** (olay, kişiler, 9 şüpheli, çözüm, bölüm
  kapanışları); repo private olunca (7.0) `docs/story/`'ye eklenir, sonra birlikte bulmaca zincirine, sahne listesine,
  ipucu hedeflerine ve suçlama tanımına dökülür. Repo public iken hikaye, çözüm ve bulmaca cevabı hiçbir belgeye
  yazılmaz.
  **İçerik kuralı:** dokunulan her şey ayrı sahnedir (yalnızca bakılan ayrıntı da); istisnalar toplanan nesneler,
  geçiş noktaları ve karakterler. Gerçek içerikte hotspot'tan `inspect` kullanılmaz. Villada karakter yoktur;
  silüetler yalnızca çarşı mekanlarındadır. Dedektifin adı **Detective Dark**'tır (ön adı geçmez).
- [ ] 7.4 Bölüm 1 içeriği ve oyun testi (üç parça; sahne sayısı hikayeyle belirlenir; eski tahmin ~40–50, "her
  dokunulabilir şey sahne" kuralıyla artabilir):
  - **7.4a İçerik, yer tutucu çizimlerle** *(7.1'den hemen sonra)*: Bölüm 1'in bütün sahneleri, eşyaları, notları,
    konuşmaları, tetikleyicileri, bulmacaları, ipucu hedefleri ve bitiş koşulu JSON olarak yazılır; görseller
    `blockout` ve genel nesne / kişi stilleridir (5.10). Koordinatlar kabadır. **Bölüm başına `walkthrough.json`:**
    bölümü baştan sona bitiren adım listesi (hotspot'a dokun, eşyayla dokun, eşyaları birleştir, konu sor, eşya / not
    göster, bulmacayı çöz). CI'da arayüz olmadan **motor üzerinde** oynatılır (use case'ler + etki hattı) ve bölümün
    bitirilebildiği kanıtlanır; içerik değişikliği bölümü kilitlerse test kırılır. **KULLANICI:** bölümü kendi
    oynar, hikayeyi ve bulmacaları düzeltir; bu tur bitmeden görsel üretimine geçilmez.
  - **7.4b Görsellerin bağlanması** *(7.3'ten sonra)*: üretilen arka planlar, nesneler ve portreler JSON'a bağlanır;
    hotspot ve overlay koordinatları editörle (7.2) gerçek görsele göre düzeltilir.
  - **7.4c 10–15 kişiyle oyun testi** *(9.1'den sonra)*: yön bulma kararı verildi (harita yok, ADR 0017); testte
    yalnızca mekanlar arası yolların uzun gelip gelmediğine bakılır (çözüm yeni bir geçiş noktasıdır). İpucu
    bekleme süresi (60 sn) ve "eşya seçiliyken geçiş noktası" kuralı da bu testte değerlendirilir. Test sürümü
    dağıtılmadan önce 9.1 (çökme raporlama) tamamlanmış olmalıdır.
- [ ] 7.2 Dev flavor'da hotspot ve overlay editörü: hotspot, yazı (overlay) ve bulmaca bölgesi dikdörtgenlerini
  sürükleyip koordinatları JSON'a kopyalayan mini araç (çok sahneli bölümler için şart). İçerik yazıldıktan sonra
  yapılır: gerçek görsele göre ince ayar o zaman gerekir.
- [ ] 7.3 Sanat yönü ve **AI destekli** üretim hattı (ADR 0011): araç seçimi ve ticari kullanım koşulları; stil rehberi
  (palet, ışık, dönem, kompozisyon, prompt şablonları, referans görseller); görsellerde yazı/sayı olmaması (prompt +
  elle temizlik; kritik yazılar overlay); yakın planları ana görselden kırpma/inpainting ile tutarlılık; noir filtre
  preset'lerinin gerçek görsellerle ayarı; çözünürlük ve boyut bütçesi (WebP); placeholder → `background` geçişi.
  Üretilecek görsellerin listesi 7.4a'da oynanıp düzeltilmiş içerikten çıkar.
  **Alınabilen nesneler (ADR 0012) arka plana çizilmez:** arka plan nesnesiz üretilir; nesne ayrı, **şeffaf arka
  planlı** (alfa kanallı WebP/PNG) bir görsel olarak üretilir ve hotspot'un `sprite` alanına bağlanır. Nesnenin ışığı
  ve perspektifi arka planla uyumlu olmalı; gölgesi nesne görseline dahil edilir.
  **Bulmaca yakın planları (ADR 0020):** tuş takımı ve yön bulmacası görselleri de bu hatla üretilir; tuşlar görselde
  çizilidir ama üstlerinde rakam yoktur ya da rakamlar overlay'dir; gösterge boş üretilir. Yön bulmacasının parçaları
  şeffaf arka planlı ayrı görsellerdir.
  **Portreler:** her karakter için çizilmiş bir portre üretilir; konuşma kutusunda (`dialogues.json` → `portrait.image`),
  kişi dosyasında ve suçlama ekranında (kişi notunun `portrait` alanı, 5.5a) kullanılır. Sahnede karakter silüet
  kalır. Kişi dosyasında portre gösterimi henüz yoktur; bu adımda eklenir.
  Her görsel için üretim kaydı (araç, model, tarih, prompt, elle yapılan düzenlemeler): `docs/art/ai-usage.md`
  (Steam AI açıklamasının kaynağı, bkz. 11.5).
- [ ] 7.5 Bölüm 2–4 içeriği. *(Aşama 6'dan sonra yapılır; aynı sıra: önce yer tutucularla içerik, sonra görsel.)*

## Aşama 8 — Para kazanma (mobil)
*(Başlarken: açık kararları sor, ADR yaz.)*

**Kapanan kararlar:** Bölüm 2–4 tek satın alım; ipuçları ücretsiz; **reklam yok** (gelir yalnızca bölüm satışından).

- [ ] 8.1 Model ayrıntıları: fiyat; ADR. (Satın alma biçimi ve ipucu / reklam kararı kapandı.)
- [ ] 8.2 Satın alma altyapısı (RevenueCat önerisi): ürünler, yetkiler, "Satın alımları geri yükle" (iOS zorunlu).
  5.4'te kurulan Bölüm 1 sonu satın alma ekranı gerçek satın almaya bağlanır.
- ~~8.3 Ödüllü reklam~~ — kaldırıldı (2026-11-15: reklam yok). Numara yeniden kullanılmaz.
- [ ] 8.4 `EntitlementRepository`'nin mobil uygulaması: yetki mağazadan doğrulanır; yerel kayıt sadece önbellek.

## Aşama 9 — Kalite ve gözlem
*(Başlarken: açık kararları sor, adımları detaylandır, onay al.)*

- [ ] 9.1 Çökme raporlama (flavor bazlı, kişisel veri gönderilmez). **Öne alındı:** Bölüm 1 oyun testinden (7.4c) önce
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
- 2026-11-14 (1.13): "Son eklenen satır not açılana kadar vurgulu" şöyle yorumlandı: satırların okundu bilgisi kayıtta
  tutulmaz (kayıt şekli plandaki gibi `entries: [{entryId, addedAtUtcMs}]`). Okunmamış bir not açıldığında **en yeni
  satırı** o görüntüleme boyunca işaretli çizilir; defter kapanınca veya not yeniden açılınca işaret kalkar
  (`NotebookState.highlightedLineId`, arayüz durumu). Bir kuralda birden çok satır eklenirse yalnızca sonuncusu
  işaretlenir. Düğme tepkisi için `NotebookCubit` `GameEventBus`'ı dinler (`NoteUpdated` → `updatePulse`). Not sayfası
  `note_page.dart` dosyasına ayrıldı (`notebook_screen.dart` 150 satır sınırına yaklaşmıştı). README'deki "suspects"
  ifadesi de "people" yapıldı.
- 2026-11-14 (1.14): Plandan küçük sapmalar ve yorumlar. (a) Sabit dosya adları (`ContentPaths.scenesFile`...) yerine
  `ContentType` enum'u geldi (`scenes`, `items`, `notes`, `inspections`, `triggers`; 1.16'da `dialogues`); 1.12'de
  eklenen `readOptionalObject` gereksiz kaldığı için silindi (opsiyonel tür = listede dosya yok). (b) Klasörde yalnızca
  **doğrudan içindeki `.json`** dosyaları okunur; alt klasörler ve başka uzantılar yok sayılır. (c) Bir dosyada `scenes`
  / `notes` listesi artık opsiyonel: yalnızca genişletme içeren dosya yazılabilir. (d) Ek kural: eksik bir bölümden
  **sonra** gelen var olan bölüm hatadır (B1 var, B2 yok, B3 var): B3, B2'yi genişletiyor olabilir. (e) "Yarım bölüm"
  = klasöründe en az bir dosya var ama zorunlu bir tür (`scenes`, `items`, `notes`, `inspections`) yok; eksik metin
  dosyası eskisi gibi metin yükleyicide hatadır. Eksik zorunlu dosyanın mesajı "file is missing" yerine "chapter ... is
  incomplete" oldu (mevcut bir testin beklentisi buna göre güncellendi). (f) Kullanılmayan metin uyarısı doğrulayıcının
  içinde değil yanında: `ContentValidator.validate(usedTextKeys: ...)` kullanılan anahtarları toplar,
  `ContentValidator.unusedTextWarnings` uyarıları üretir; böylece 1.16'da konuşma doğrulayıcısının kullandığı metinler
  de aynı kümeye eklenebilir. Koddan kullanılan tek genel anahtar (`generic_item_no_effect`) zaten doğrulayıcıda
  işaretli olduğu için ayrı bir liste parametresi gerekmedi. (g) `pubspec.yaml` kontrolü ve fixture yardımcıları
  `test/helpers/` altında (diski okudukları için `lib/`'e konmadı). Test paketi (`FakeAssetBundle`) gerçek paket gibi
  `AssetManifest.bin` de sunar.
- 2026-11-14 (1.15): Tabela, plandaki örnek koordinatlar yerine villanın soluna alındı (`x: 0.015`; örnekteki `0.06`
  cepheyle çakışıyordu). Çarşının üç tabelası (PHARMACY, CAFÉ, VILLA) sahnenin kendi overlay'idir; yalnızca villa
  önündeki "MARKET" yazısı nesne overlay'idir (tabela koşulla belirdiği için). Yeni overlay stili gerekmedi
  (`engraved`). Tuzak mekan kontrolü, girişten **ulaşılamayan** kök sahneyi ayrıca tuzak diye raporlamaz (zaten
  "ulaşılamıyor" hatası alır; çift hata gürültü olurdu). Bu kural yüzünden doğrulayıcı testindeki bir fixture'a
  (giriş sahnesi çocuk sahne olan vaka) dönüş yolu eklendi; bloc senaryo testinde holün kalan hotspot beklentisi
  `['pill_bottle']` oldu. Çapraz bağlantı uyarısı gerçek içerikte tetiklenmiyor. **Telefonda doğrulanacak (kullanıcı):**
  kabul senaryosunun 12–13. adımları (silüetler hariç) ve dönüş; CI widget testleri ve bloc testleri geçti, Windows
  ve telefon doğrulaması 1.20'deki toplu kontrolde.
- 2026-11-14 (1.16): Plandan küçük sapmalar ve yorumlar. (a) **Adlar:** `topicAsked` koşulunun sınıfı `HasAsked`
  (JSON anahtarı aynı): `TopicAsked` adı `core/events`'teki olayla çakışıyordu. (b) **Use case imzaları:** plan
  `StartConversation(dialogueId)` / `AskTopic(dialogueId, topicId)` diyordu; `TapHotspot` gibi entity alıyorlar
  (`dialogue`, `progress`, `triggers`): saf ve test etmesi kolay, katalog ve içerik yüklemesi çağırana (1.17'de
  `DialogueCubit`) kalır. `AskTopic.play` (görünürlük sormadan oynat) 1.18'deki `ShowToCharacter` için açıldı.
  (c) **Doğrulayıcının paylaşılan parçası:** "ContentValidator'ın açtığı yardımcılar" = yeni `ContentChecks` sınıfı
  (`scene_engine/domain`): metin, koşul, etki, izinli-etki, `first` satırı ve bayrak kontrolleri + sorun listesi.
  `ContentValidator.validateWith(checks)` ve `DialogueValidator.validate(checks: ...)` aynı nesneye yazar; bayrak
  kontrolü (`checks.flagIssues()`) en sonda çağrılır, çünkü bir konunun set ettiği bayrağı bir hotspot okuyabilir.
  Eski `ContentValidator.validate(...)` imzası aynen duruyor (mevcut testler değişmedi). `ContentIssue` ayrı dosyaya
  alındı (`content_issue.dart`, `content_validator.dart` dışa aktarır). (d) Karşılama (`greeting`) ayrıştırması
  `dialogue/data`'da (15 satır); `RuleParser` yalnızca koşul ve etki ayrıştırır. (e) `trigger`'ın "tam olarak bir
  `showItem` / `showNote`" kuralı yükleme anında uygulanır (bozuk dosya `ContentFailure`); doğrulayıcı gösterilen eşya
  / notun var olduğuna bakar. (f) Dilimde eczacının ikinci sabit konusu `about_last_night`, kahvecininki
  `about_pharmacist`; kahvecinin `show_letter` konusu dosyasına `recognised_paper` satırını ekler. (g) Silüetler
  portre olarak da aynı çizimi kullanır (`silhouette_pharmacist`, `silhouette_cafe_owner`); cilası 1.20'de.
  (h) Mimari testine iki açık kural eklendi: `scene_engine` → `dialogue` import'u yok; bir feature'ın `data` katmanı
  başka feature'ın `data` katmanını import etmez.
- 2026-11-15 (1.17): Küçük sapmalar. (a) `DialogueCubit` tetikleyicileri `SceneContentRepository`'den okur; aynı
  vakanın iki kez ayrıştırılmaması için `AssetSceneContentRepository` yüklenen vakayı bellekte tutar (başarısız
  yükleme tutulmaz; "tekrar dene" gerçekten yeniden okur). (b) Panel sahne görselinin üst %87'sini kaplar
  (`1 - SceneLayout.chatStripHeight`); 640×360'ta ≈ 278 dp, `DialogueLayout.minPanelHeight` = 252 dp. (c) Konuşma
  açılamazsa (kayıt hatası, içerikte olmayan konuşma) `app/` katmanı `SceneBloc`'a `DialogueClosed` gönderir; sahne
  görünmeyen bir panelin altında kilitli kalmaz. (d) Yeni ARB metinleri: `dialogueTopicNew`, `dialogueTopicAsked`,
  `dialogueContinueHint`, `dialogueNoTopics`. (e) `tool/render_screenshots_test.dart` çarşı ve konuşma görüntülerini de
  üretir (`06_market`, `07_dialogue_line`, `08_dialogue_questions`); README'ye 1.20'de eklenecek. **Telefonda
  doğrulanacak (kullanıcı):** kabul senaryosunun 14–16. ve 19. adımları ve devlog'daki "bakılacak yerler" listesi;
  CI'daki widget testleri (telefon boyutu dokunma, 1280×720 fare, 640×360 ve 800×360) geçti.
- 2026-11-15 (1.18): Küçük sapmalar ve yorumlar. (a) `ShowToCharacter(dialogueId, item | note)` imzası: gösterilen şey
  için ayrı bir tür açılmadı, konunun `TopicTrigger`'ı kullanıldı (`ShowItem(id)` / `ShowNote(id)`); eşleşme tek bir
  eşitlik karşılaştırması. (b) Eşleşme kuralı bir noktada genişletildi: **daha önce oynamış** bir konu, `visibleWhen`
  koşulu sonradan bozulsa da yeniden gösterilince cevabını tekrar oynar ("bir kez sorulan konu listede kalır" kuralının
  karşılığı). Oynamamış konu için koşul tutmalıdır. (c) Sahneden gösterimde eşya, karşılama **okunduktan sonra**
  gösterilir (`DialogueCubit` bekleyen gösterimi son karşılama satırından sonra çalıştırır); böylece şişe, karakter
  daha "merhaba" derken panelden kaybolmaz. (d) Karakter konuşurken eşya dokunuşu ve "Show evidence" düğmesi
  etkisizdir (düğme gizlenir): kanıt iki cevap arasında gösterilir. (e) `SceneState.shownItemId` eklendi (arayüz
  durumu; konuşma kapanınca sıfırlanır). (f) Yeni ARB metinleri: `dialogueShowEvidence`, `notebookShowButton`,
  `notebookPickEvidenceHint`. **Telefonda doğrulanacak (kullanıcı):** kabul senaryosunun 17–18. adımları ve devlog'daki
  "bakılacak yerler"; CI widget testleri (telefon boyutu, dokunma) geçti.
- 2026-11-15 (tasarım kararları, kullanıcı onaylı): Bu commit yalnızca belgedir (`docs/game_design.md`, `plan.md`,
  `CLAUDE.md`); kod, test ve içerik değişmedi. Repo public olduğu için yalnızca mekanik kararlar yazıldı (7.0).
  - **Kararlar** (ayrıntı ve gerekçe: `docs/game_design.md` değişiklik geçmişi): 1950'ler küçük kasaba, hep gece,
    zaman mekaniği yok; dokunulan her şey ayrı sahne (`inspect` gerçek içerikte yalnızca eşya kartı); villada kimse yok,
    silüetler yalnızca çarşıda, panelde ve dosyada çizilmiş portre, telefonla konuşma; villa ve çarşı düzeni; durmayan
    bölüm geçişi + Bölüm 1 sonu satın alma / demo sonu ekranı; suçlama karakolda, 9 şüpheli, kaçırılabilen kanıt yok;
    çelişki yakalama "Kanıt göster" ile; bulmaca türleri; belgeler; ücretsiz sınırsız ipucu, reklam yok; ses.
  - **Plan:** 5.2–5.6 güncellendi; yeni adımlar 5.8 (yön bulmacası) ve 5.9 (sayfalı not); delikli kağıdın sürüklemeli
    sürümü plan dışı. "Aşama 5 → Aşama 2" bağımlılığına kayda eklenecek alanlar yazıldı (satın alma kilidi kayda
    girmez; bölüm başı kayıt kopyası yok). 6.1, 7.1, 7.3, 7.4 güncellendi; 8.3 (reklam) kaldırıldı. ADR yazılmadı
    (yeni teknik karar yok; yön bulmacasının ADR'si 5.8'de).
  - **Koddan doğrulanan:** konuşma `portrait` alanı gerçek görsel kabul ediyor (`DialoguePortrait.image` → `PortraitDto`
    → `DialoguePanel`'de `Image.asset`, görsel yüklenemezse placeholder). **Eksik:** kişi dosyasında portre henüz
    çizilmiyor (`NoteDefinition.imageAsset` yalnızca veride); 7.3'e iş olarak yazıldı, `CLAUDE.md`'ye "var" diye
    yazılmadı.
  - **Benim yorumlarım** (kararlarda açık yazmıyordu; itiraz edilirse düzeltilir):
    - İpucu kademeleri dört oldu: dokunulabilir yerleri göster → yön → net → cevap.
    - "Zaman mekaniği yok" oyun dünyası içindir; ipuçları arasındaki bekleme ve uzun hareketsizlikte dedektifin
      kendiliğinden yönlendirmesi (5.6) arayüz davranışı olarak kaldı.
    - Ayrı bölüm sonu ekranı kalktığı için hesap bağlama önerisi (3.3) mobildeki Bölüm 1 sonu satın alma ekranına
      eklenir.
    - Sembol eşleştirme, ışık kaynağı ve sürüklemesiz delikli kağıt için adım açılmadı (yalnızca yön bulmacası ve
      sayfalı not istendi); mevcut kural diliyle içerik olarak kurulacakları varsayıldı, Aşama 5 detaylandırılırken
      doğrulanır.
    - Telefon, `talk` etkili sıradan bir hotspot'tur (silüet `sprite`'ı olmadan); yeni etki gerekmez.
    - 5.6'daki işaret türlerinde `inspect` (incelenecek yer) motor yeteneği olarak kaldı; gerçek içerikte karşılığı
      olmayacak.
    - Karakolun hangi mekanda ve hangi bölümde açıldığı yazılmadı (hikaye).
    - Yeni Aşama 5 adımları 5.8 ve 5.9 olarak numaralandı; 8.3 silinmedi, üstü çizildi (numaralar değişmez).
- 2026-11-16 (1.19): Kod 2026-11-15'te commit'lendi (`fa4a8f7`); oturum yarıda kesildiği için devlog notu ayrı bir
  commit'le eklendi. Derleme doğrulaması: klasör girdisiyle (`path: assets/dev/` + `flavors: [dev]`) `presets.json` dev
  APK'sında var; prod ve staging APK'sında ve Windows derlemesinde yok; yedek yola (Dart sabiti) gerek kalmadı. Tek
  dosya yoluyla da çalışıp çalışmadığı **doğrulanmadı** (kullanılan çözümü etkilemiyor).
- 2026-11-16 (1.20): Kabul senaryosu 1–20 CI widget testinde (dokunma, fare, 1280×720, 4:3) ve Windows'ta
  `integration_test` ile geçti. **Windows, profil modu, 775 kare:** build ortalama 0,54 ms (en kötü 3,7 ms), raster
  ortalama 1,6 ms (%99: 7,6 ms, en kötü 29,2 ms); bütçeyi aşan 6 raster karesi, hiç build karesi yok. Sapmalar ve
  yorumlar: (a) **Portreler ayrı çizim oldu:** yeni placeholder stilleri `portrait_pharmacist` / `portrait_cafe_owner`
  (`PortraitPainter`); `dialogues.json`'daki `portrait.placeholderStyle` bunlara çevrildi. Sahnedeki silüet stilleri
  aynı adla kaldı. (b) **Mimari testi daraltıldı:** kayıt kuralı argümansız `save()` çağrısını (`Canvas.save()`)
  artık saymıyor; argümanlı her çağrı yakalanmaya devam ediyor, iki durum da testle sabit. (c) Planın saydığı kenar
  durumlarından "seçim modundaki defterde Geri" ve "eşya seçiliyken silüete dokunma" 1.18'in testlerinde zaten vardı;
  `edge_cases_test.dart`'a aynıları kopyalanmadı, daha sert çeşitleri yazıldı (`Esc`, cevabın ortasında geri, hızlı
  çift dokunma, ilgisiz karakter). (d) Senaryonun 18. adımında defter mektubu açık getirir (son okunan not hatırlanır);
  senaryo "Pick the note to show." ipucunu beklemez. **Yapılamayan (cihaz bağlı değildi), kullanıcıda:** telefonda
  kabul senaryosunun 12–20. adımları ve 1.20 kontrol listesi, telefonda profil modu ölçümü (panel açılışı ve daktilo
  efekti), 1.15–1.19'dan devreden telefon doğrulamaları. Komutlar `docs/devlog/asama-1.md`'de (Adım 1.20).
- 2026-11-16 (2.1): `drift` **2.34.0'a sabitlendi** (`^` yok). Flutter 3.44.8'in sabitlediği `test` paketi `analyzer`'ı
  12.x'te tutuyor; `drift_dev` 2.35 `analyzer` 13 istediği için çözülebilen son sürüm `drift_dev` 2.34.0. Bu sürümün
  komut satırı aracı (`make-migrations`, `schema generate`) `drift` 2.34.1+ ile **derlenmiyor**; kod üretimi çalışsa da
  şema dökümü alınamıyor. Flutter yükselince ikisi birlikte güncellenir.
- 2026-11-16 (2.1): Plandaki listeye **`path_provider`** eklendi (doğrudan bağımlılık). `drift_flutter` onu zaten
  getiriyordu; veritabanını planın istediği uygulama destek klasöründe açmak için `getApplicationSupportDirectory`'yi
  kendi kodumuzdan çağırmak gerekiyor (`drift_flutter`'ın varsayılanı belgeler klasörü).
- 2026-11-16 (2.1): Şemaya plandaki `save_slots`'a ek olarak **`save_backups`** tablosu girdi (okunamayan kaydın
  yedeği; 2.2'deki "bozuk kayıt silinmez, yedeklenir" kuralının yeri). Henüz yayın yokken ilk şema sürümüne koymak,
  2.3'te şema sürümü 2'ye migration yazmaktan ucuz. `GameProgressDto` 2.2'den 2.1'e çekildi (dönüştürücü onsuz
  yazılamıyor); 2.2 ona sürüm numarasını, `SaveMigrator`'ı ve hata türlerini ekler.
- 2026-11-16 (2.1): Tek sürüm varken `make-migrations` yalnızca şema dökümünü yazar; migration testini 2. sürümde
  üretir. Bu yüzden test altyapısı elle kuruldu: `drift_dev schema generate` çıktısı (`test/drift/app_database/
  generated/`) + `schema_test.dart` (kodun oluşturduğu tablolar dökümle aynı mı; eski sürümden açılıyor mu).
  Veritabanı dosya adı flavor'a göre değişir (`detective_dark`, `detective_dark_dev`, `_staging`): Windows'ta flavor
  olmadığı için dev çalıştırması Steam derlemesiyle aynı klasörü paylaşır. `shared_preferences` küçük bir
  `KeyValueStore` arayüzünün arkasında (`core/storage`); `deviceId` `core/device`'ta.
- 2026-11-16 (2.2): (a) Kayıt metnini üreten/okuyan şey domain'de küçük bir arayüz oldu: `SaveCodec`
  (`progress/domain/services`); uygulaması `JsonSaveCodec` (`progress/data/migrations`). Geliştirici menüsü `data`'yı
  import edemediği için panoya verme/alma bu arayüzden geçer; Drift dönüştürücüsü de aynı codec'i kullanır (tek format).
  (b) Plan yalnızca `SaveTooNewFailure`'ı adlandırıyordu; bozuk kayıt için **`SaveCorruptFailure`** eklendi. (c) **Bozuk
  kaydın yedeğe taşınması bu adımda bağlanmadı:** parçalar hazır (`moveSlotToBackup` 2.1'de, `SaveCorruptFailure` ve
  "yeni oyun" ekranı 2.2'de), ama taşımayı yapacak olan `DriftProgressRepository` 2.3'te geliyor. Oyun hâlâ bellekteki
  kaydı kullandığı için iki hata ekranı da 2.3'e kadar yalnızca testlerde görünür. (d) Geliştirici menüsünde kaydı
  kopyala / yapıştır **simge düğmesi** oldu (ipucu metinli): üç metin düğmesi başlıkta telefon genişliğine sığmadı.
  İçe aktarılan kayıt başka vakaya aitse veya sahnesi yoksa reddedilir; eşya/not ID'leri içerikle karşılaştırılmaz.
- 2026-11-16 (2.3): Kararlar ADR 0019'da. (a) **"DI'da tek satır" tam tutmadı:** arayüzü kullanan hiçbir dosya
  değişmedi (use case, bloc, cubit, widget: sıfır değişiklik), ama `register_progress.dart`'ta tek satır yerine kayıt
  bloğu değişti (veritabanı + depo + yaşam döngüsü arayüzü) ve `configureDependencies`'e testler için
  `progressRepository` parametresi eklendi. (b) Planda olmayan iki parça: domain arayüzü `ProgressAutosave` ve `app/`
  katmanında `SaveLifecycle` (uygulama arka plana geçince yazım; presentation `data`'yı import edemediği için arayüz
  gerekti). (c) **`save` artık disk hatasını bildirmiyor:** bellek hemen güncellenir, disk 500 ms sonra yazılır; yazım
  hatası loglanır ve bir sonraki fırsatta yeniden denenir, oyuncuya gösterilmez. (d) Oyun süresi bellekteki ilerlemede
  canlı değil; diske yazarken damgalanır. Süresi 0 olan kayıttan "yeni oyun" başlatmak sayacı kendiliğinden
  sıfırlamaz: **6.3'teki "Yeni Oyun" sayacı açıkça sıfırlamalı.** (e) Widget ve entegrasyon testleri bellek içi depoyla
  çalışır (zamanlayıcı ve dosya yok); Drift deposu kendi testlerinde bellek içi SQLite kullanır. (f) Windows'ta gerçek
  derlemeyle doğrulandı: dosya `%APPDATA%\asklife23\DetectiveDark\detective_dark_dev.sqlite`, ikinci açılış aynı
  kayıttan devam etti. Telefonda doğrulama kullanıcıda (2.4'ün manuel testi).
- 2026-11-16 (2.4): Depo testlerinin çoğu 2.3'ün commit'inde geldi (testsiz depo commit edilmedi); 2.4 kapat-aç
  senaryosunu ekledi (`test/features/progress/close_and_reopen_test.dart`: gerçek içerik + gerçek SQLite dosyası, her
  "açılış" yeni bellek). **Cihazda doğrulanan** (2201116TG, Android 13, dev derlemesi, adb ile): kayıt dosyası oluştu,
  ana ekrana dönünce yazıldı, `force-stop` + yeniden açılışta aynı kayıttan devam edildi (açılış repliği tekrarlanmadı,
  oyun süresi 7 sn → 16 sn, `localRevision` 2 → 3). **Kullanıcıda kalan:** planın manuel testinin oynanış kısmı (uçak
  modunda anahtarı al, kapıyı aç, mektubu al → tamamen kapat → aç); adb ile sahneye dokunulmadı.
- 2026-11-16 (Aşama 5 planı, kullanıcı onaylı kararlar): Bu commit yalnızca belgedir (`plan.md`, `CLAUDE.md`,
  `docs/game_design.md`, ADR 0020–0023); kod, test ve içerik değişmedi. Repo public olduğu için bütün örnekler dikey
  dilimin demo içeriğidir.
  - **Plan:** Aşama 5 adımları Aşama 1 ayrıntısında yazıldı; yapılış sırası 5.1 → 5.2 → 5.7 → 5.9 → 5.4 → 5.6 → 5.8 →
    5.5 → 5.10 (numaralar aynı). 5.4, 5.5 ve 5.6 alt adımlara bölündü. Yeni adım 5.10 (genel yer tutucu çizim).
    **5.3 ertelendi** (hikaye kullanmıyor; kutusu açık, aşama onsuz biter). Tuş takımı dışındaki kilitler yazılmaz.
    Aşama 7 sırası değişti: içerik yer tutucularla önce (7.4a), editör ve görseller sonra; 7.4 üç parçaya ayrıldı.
    Açık kararlardan üçü kapandı (kayıt inceleme, "kanıt zayıfsa hak düşer", bekleme 60 sn); ikisi eklendi.
  - **Yeni kural dili (ADR'li):** koşullar `puzzleSolved`, `chapterReached`; etkiler `openPuzzle`, `openAccusation`.
    `playMedia` 5.3 ile birlikte ertelendi.
  - **Kodla çelişen / kodda karşılığı farklı olan noktalar** (uydurulmadı; ilgili adımda böyle ele alınacak, itiraz
    edilirse adım başlamadan düzeltilir):
    1. **Eşya `interactions`'ının yeri (5.7).** Karar "eşyaya opsiyonel `interactions`" diyor; `ItemDefinition`
       `inventory/domain`'de ve `scene_engine` → `inventory` yönü sabit (doğrulayıcı `ItemDefinition`'ı import ediyor).
       `inventory`, `InteractionRule`'u import ederse feature döngüsü oluşur ve mimari testi kırılır. 2026-11-14
       notundaki "5.7 de `RuleParser` yolunu kullanır" cümlesi bu yüzden tutmuyor (o yol `dialogue` için çalışıyor,
       çünkü `scene_engine` `dialogue`'u import etmiyor). **Önerim:** JSON aynı kalır (kural eşyanın içinde yazılır),
       ama kuralları `scene_engine` okur (`CaseContent.itemRules`), `OpenItem` / `CombineItems` `scene_engine/domain`'de
       olur; `ItemDto` alanı yalnızca tanır. **Kullanıcı onayı 5.7 başlarken.**
    2. **"Sahneyle aynı hattan çizilir" (5.1).** Hattı çizen `SceneVisualView` `scene_engine/presentation`'da;
       `puzzles/presentation` onu import edemez. Çözüm: birleştirme `app/game`'de; `SceneVisualView`'a filtrenin
       altına ek içerik yuvası; bulmaca iki katman verir (filtre altı çizim, filtre üstü dokunma).
    3. **Bulmaca `visual`'ının ayrıştırılması (5.1).** `SceneVisualDto` `scene_engine/data`'da; `data` → `data`
       import'u yasak. `RuleParser` arayüzü `visual` ayrıştırmasını da sunacak.
    4. **Bölüm bitişi hattın içinde (5.4a).** Hat `scene_engine/domain`'de ve bugün yalnızca tetikleyicileri alıyor.
       `ChapterDefinition` zaten `scene_engine/domain`'de olduğu için bitiş kontrolü de orada kalır (yeni `case_flow`
       feature'ında değil); `run(triggers: ...)` imzası `rules` (tetikleyiciler + bölümler) olur, bütün çağıranlar
       değişir. `case_flow` ilerletmeyi, sahipliği, kapıyı, ipucunu ve suçlamayı taşır.
    5. **`chapterId` × `reachedChapters` (5.4a).** `GameProgress.chapterId` (tek bölüm) duruyor ve kopyalama
       metotlarıyla değiştirilemiyor; "bulunulan bölüm" o alandır, `reachedChapters` yeni kümedir. Geliştirici
       menüsünün preset'i bölümü sahneden seçiyor; kümeyi de doldurmalı.
    6. **`CaseManifest` bilinmeyen anahtarı reddediyor** (`case.json` üst düzeyinde ve bölümde); `titleKey`,
       `completeWhen` (5.4a) ve `accusation` (5.5a) için güncellenir.
    7. **Oyun süresi (5.5).** Süre bellekteki ilerlemede canlı değil (diske yazarken damgalanır, ADR 0019) ve yeni
       oyun sayacı kendiliğinden sıfırlamıyor (2.3 notu). Sonuç ekranındaki "toplam süre" ve "Baştan oyna" için kayıt
       katmanına küçük bir domain arayüzü gerekir (güncel süreyi oku, sayacı sıfırla).
    8. **Şüpheli portresi (5.5a).** Portre bugün yalnızca konuşmada (`dialogues.json`); kişi notunda yalnızca
       `imageAsset` var, placeholder stili yok, ve bir şüphelinin konuşması olmayabilir. Kişi notuna `portrait`
       (`placeholderStyle` + `image?`) eklenir; 7.3'teki "kişi dosyasında portre" aynı alanı kullanır.
    9. **Genel yer tutucu (5.10).** `PlaceholderArt` yalnızca stil adı alıyor ve `core`'da; sahne adı ve hotspot
       etiketleri düz veri olarak parametreyle verilecek.
    10. **Genişletme sarmalama (5.4a) kodla uyuşuyor;** alternatif gerekmedi. `InteractionResolver` `usingItem`'ı
        `all` içinde zaten arıyor; `trigger`'lı konuların `visibleWhen`'i gösterim anında denetleniyor. Sarmalama
        `SceneExtensionDto.applyTo` / `DialogueExtensionDto.applyTo` ve tetikleyici yüklemesinde yapılır.
    11. **Demo kasanın şifresi (5.2).** "Mevcut bir overlay yazısı" olarak içerikte yalnızca kapı numarası var ve iki
        hanelidir (A3 örneği dört haneliydi). Plan mevcut overlay'i kullanıyor; dört hane istenirse dilime yeni bir
        overlay eklenir.
  - **Benim yorumlarım** (kararlarda açık yazmıyordu):
    - Koşul sınıfı `HasSolved` (JSON anahtarı `puzzleSolved`): `PuzzleSolved` adı olayda.
    - `openPuzzle` ve `openAccusation` yalnızca hotspot kuralında. Bulmaca açıkken eşya paneli etkisiz; bulmaca mesaj
      barının şeridini kapatmaz; Geri düğmesi kök sahnede de görünür.
    - Tuş takımında `enter` yoksa hane sayısı dolunca denenir. Yanlış denemede gösterge temizlenir.
    - 5.1'de gerçek tür yok; testler sahte bir türle çalışır (tür 5.2'de gelir).
    - Birleştirmede seçim her durumda temizlenir; konuşma açıkken eşya dokunuşu "göster" kalır. "Aç" için demo
      içeriği yok (fixture).
    - Sayfalı notta `bodyKey` veya `pages` (tam olarak biri). Kalınan sayfa kaydedilmez.
    - `completeWhen` opsiyonel (son bölüm suçlamayla biter). Bölüm ilerleyince oyuncu ışınlanmaz; `entrySceneId`
      doğrulama ve geliştirici menüsü içindir. Bölüm N'in kendi sahneleri ve `noteExtensions` sarılmaz.
    - Kapı durumu kaydedilmez, türetilir. Kapı ekranı bildirimden sonra **bir kez** kendiliğinden açılır (açık panel
      varsa kapanınca); sonraki açılışlarda yalnızca HUD girişi. Ekran rota değil, `GameScreen` katmanıdır. Türünü
      (satın alma / demo sonu) DI derleme hedefinden seçer; "pakette yok" ve "sahip değil" aynı ekranı gösterir.
    - Dev dışındaki bütün derlemeler (staging, prod, Steam) şimdilik yalnızca Bölüm 1'i açar.
    - İpucu: hedefin ilk basışı "göster"dir ve sayılır; yeni basamak açan her basış sayılır ve beklemeyi başlatır;
      tekrar ve "hedef yok" basışları sayılmaz, beklemeyi başlatmaz. Bir panel açıkken düğme etkisizdir (bulmacanın
      içindeyken ipucu için bulmaca kapatılır; **oyun testinde bakılacak**). Düğme sağ panelde, defterin yanında.
    - "Kendiliğinden yönlendirme kapalı (tek sabit)": bu aşamada yönlendirme kodu yazılmaz; sabit eklenirse okuyanı
      olmaz. Sabit ancak özellik yazılırsa eklenecek şekilde planlandı.
    - İşaret türü önceliği: kişi → bulmaca → geçiş → alınacak nesne → diğer. Yakın plana giden `goToScene` de "geçiş".
    - Suçlama: polisin cevapları `common` içerik metinleri; `onSolved` yalnızca kabulde çalışır, "Çözümü gör"de
      çalışmaz; sonuç ekranı iki durumda da gösterilir (sonuç etiketiyle); paylaşım metni spoiler içermez. Sonuç
      belli olduktan sonra `openAccusation` sonuç ekranını açar. Yeni olay `AccusationJudged` (benim eklemem).
    - Demo suçlamasının hotspot'u çarşıda bir polis telefonu (karakol sahnesi dilimde yok).
    - 7.4 üç parçaya bölündü (7.4a içerik, 7.4b görsellerin bağlanması, 7.4c oyun testi); numara aynı.
