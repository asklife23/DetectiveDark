# CLAUDE.md — DetectiveDark

Bu dosya her oturumda otomatik okunur ve projenin **kalıcı kurallarını** içerir.
- Yol haritası, adımlar ve ilerleme durumu: `plan.md`
- Oyunun nasıl oynandığı (mekanik kararların tek kaynağı): `docs/game_design.md`

Oyun tasarımıyla çelişen bir şey yapman gerekirse önce kullanıcıya sor; kabul edilirse
`docs/game_design.md`'nin "Değişiklik geçmişi"ne tarih ve gerekçeyle yaz.

---

## 1. Proje özeti

**DetectiveDark**: Noir atmosferli, 2.5D point-and-click dedektif oyunu. Flutter ile **Android, iOS ve Steam (Windows)**.
Oyuncu dedektifi yönetir; mekanları keşfeder, eşya ve belge toplar, bulmaca çözer, sonunda polisi kanıtlarla ikna eder.
Tek vaka, 4 bölüm. Mobilde Bölüm 1 ücretsiz, devamı ücretli; Steam'de Bölüm 1 demo, tam oyun peşin ücretli.

Kimlikler: Dart paketi `detective_dark` (`package:detective_dark/...`), uygulama kimliği
`io.github.asklife23.detectivedark` (Android `applicationId` + iOS bundle ID; mağazaya çıktıktan sonra değişmez),
GitHub deposu `asklife23/DetectiveDark`.

İki hedef var, ikisi de eşit derecede önemli:
1. Play Store, App Store ve Steam'de yayınlanıp gelir getiren, mükemmel oynanan bir oyun.
2. GitHub'da CV/portföy kalitesinde, temiz mimarili, test edilmiş bir proje.

**Geliştirici (kullanıcı) Flutter ve backend öğreniyor.** Her adımda ne yaptığını ve
NEDEN yaptığını Türkçe, sade ve öğretici biçimde açıkla. Kavramları atlama; kısa ama net anlat.

---

## 2. plan.md ile çalışma

Kullanıcı terminalde şu tür komutlar yazar (yazım farklılıklarını aynı anla):

| Komut | Ne yaparsın |
|---|---|
| `Aşama 1.2'yi yap` / `aşama 1 kısım 2` | Sadece o adımı uygula, sonra dur. |
| `Aşama 1'i yap` | O aşamanın tamamlanmamış adımlarını sırayla uygula. Her adım ayrı commit. Aşama bitince dur. |
| `Sıradaki adım` | `plan.md`'deki ilk işaretlenmemiş adımı uygula. |
| `Durum` | Biten adımlar, sıradaki adım, açık kararlar. Kod yazma. |
| `Açıkla 1.3` | O adımda ne yapıldığını ve nedenini tekrar anlat. Kod yazma. |

### Her adımın akışı
1. `plan.md`'yi oku. Adımın **Amaç**, **Yapılacaklar** ve **Kabul kriterleri** kısımlarını uygula.
   Önceki adımlar bitmemişse uyar ve devam etmek için onay iste.
2. Başlamadan önce 3–6 satırlık Türkçe mini plan yaz: ne yapacaksın, hangi dosyalara dokunacaksın.
3. Adımda **KULLANICI** etiketli bir iş varsa (hesap açmak, panelde ayar yapmak vb.) o noktada dur,
   adım adım net talimat ver ve kullanıcının "tamam" demesini bekle.
4. Uygula. Plan dışına çıkman gerekirse (listede olmayan paket, farklı yaklaşım) önce gerekçesiyle sor.
5. **Kalite kapısı** (bölüm 4) geçmeden commit etme.
6. `plan.md`'de adımın kutusunu `[x]` yap. Plandan önemli bir sapma olduysa en alttaki "Notlar" bölümüne bir satır ekle.
7. `docs/devlog/asama-N.md` dosyasına adımın öğrenme notunu ekle (format: bölüm 10).
8. Commit + push (bölüm 5).
9. Kullanıcıya adım sonu özetini ver (format: bölüm 10) ve **DUR**.
   Bir sonraki adıma kendiliğinden geçme. Yalnızca "Aşama N'i yap" denmişse aynı aşama içinde devam et.

### Aşama 5 ve sonrası
Bu aşamalar `plan.md`'de daha kısa yazılmıştır. Bir aşamaya ilk kez başlarken:
önce o aşamanın **açık kararlarını** kullanıcıya sor, sonra adımları Aşama 0–4 seviyesinde
detaylandırıp `plan.md`'ye yaz, kullanıcı onaylayınca uygula.

---

## 3. Mimari

**Feature-first Clean Architecture.**

```
lib/
  main_dev.dart / main_staging.dart / main_prod.dart / main_steam.dart
  app/                 # App widget, router, bootstrap, DI kökü, GameScreen (feature'ları birleştirir)
  core/
    config/            # AppConfig, flavor
    di/                # get_it kayıtları
    error/             # Result<T>, Failure türleri
    events/            # GameEvent (sealed) + GameEventBus
    content/           # lokalize hikaye metinleri servisi
    l10n/              # ARB dosyaları ve üretilen kod
    logging/
    theme/             # renk/tipografi/ölçü tokenları
    widgets/           # ortak, feature'dan bağımsız widget'lar
  features/
    scene_engine/      # sahneler, hotspot'lar, koşul + etki sistemi, gezinme yığını, geçişler
    inventory/         # eşya kataloğu, sağ panel, eşya seçimi ve kullanımı
    notebook/          # not defteri: belgeler, gözlemler, şüpheliler
    detective_chat/    # dedektifin iç sesi, mesaj geçmişi
    progress/          # GameProgress, kayıt (Aşama 1: bellekte, Aşama 2: Drift)
    auth/              # Aşama 3
    sync/              # Aşama 4
    puzzles/           # Aşama 5: kilitler, kayıt inceleme
    case_flow/         # Aşama 5: bölümler, suçlama, ipuçları
    settings/ main_menu/ monetization/   # sonraki aşamalar
```

Her feature içinde:
```
<feature>/
  domain/        # entities, repositories (abstract), usecases — saf Dart
  data/          # datasources, models (DTO), repositories (impl)
  presentation/  # bloc/cubit, pages, widgets
```

### Bağımlılık kuralları (ihlal etme)
- `domain` hiçbir katmana bağımlı değildir. Flutter import'u yok; paket olarak sadece `equatable`.
- `data` → `domain`. `presentation` → `domain`. `presentation` asla `data`'yı import etmez.
- Bir feature, başka bir feature'ın **sadece `domain`** katmanını import edebilir. `data` ve `presentation` asla.
- `app/` katmanı, feature'ların `presentation` katmanlarını birleştirebilen **tek** yerdir (ör. `GameScreen`:
  sahne + eşya paneli + not defteri + mesaj barı). Seçili eşyayı sahneye ileten de odur.
- Feature'lar arası olaylar `core/events` içindeki `GameEventBus` üzerinden akar
  (`SceneEntered`, `ItemObtained`, `ItemUsed`, `NoteAdded`, `DetectiveSaid`...).
- DTO (`data/models`) ile entity (`domain/entities`) ayrıdır; dönüşüm `data` katmanında yapılır.
- Hata yönetimi: `data` katmanı exception'ları yakalar, `domain`'e `Result<T>` (Success / Failure) döner.
  UI'a exception sızmaz.
- İlerlemenin tek doğruluk kaynağı `ProgressRepository`'dir. Sahne, eşya paneli, not defteri ve chat bu kaynaktan okur.
- **Platforma özel servisler** (satın alma / sahiplik, hesap, bulut kaydı) domain arayüzleri arkasındadır
  (`EntitlementRepository`, `AuthRepository`, `CloudSaveRepository`...). Hangi uygulamanın kullanılacağı DI'da
  derleme hedefine göre seçilir: mobil (mağaza + Supabase) veya Steam (Steam sahipliği + Steam Cloud).
  Domain ve widget'larda `Platform.isX` kontrolü yapılmaz; oyun kodu hangi platformda çalıştığını bilmez.

### Durum yönetimi
- `flutter_bloc`. Karmaşık olay akışları için Bloc (ör. `SceneBloc`), basit durumlar için Cubit.
- State'ler immutable; `equatable` ve Dart 3 `sealed class` kullan.
- Bloc'lar `BuildContext` ve widget bilmez. Bağımlılıklar constructor ile verilir (use case veya repository arayüzü).
- Her Bloc/Cubit için `bloc_test` testi yazılır.

### DI ve yönlendirme
- `get_it`. Kayıtlar `core/di/` altında feature bazlı fonksiyonlarda (`registerSceneEngine(getIt)` gibi).
  Widget'lar `get_it`'i sadece `BlocProvider` oluştururken kullanır.
- `go_router` sadece uygulama ekranları içindir (splash, ana menü, oyun, ayarlar).
  Oyun içi sahne geçişleri router değildir; `SceneBloc`'un gezinme yığınıdır (stack).

---

## 4. Kalite kapısı (her commit öncesi zorunlu)

Sırayla çalıştır:
1. Kod üretimi olan adımlarda: `dart run build_runner build --delete-conflicting-outputs`
2. `dart format .`
3. `flutter analyze` → **0 sorun** (info dahil)
4. `flutter test` → **tamamı geçmeli**

Biri başarısızsa düzelt ve baştan çalıştır. Düzeltemiyorsan commit etme;
sorunu, denediklerini ve önerini kullanıcıya anlat.

Üretilen dosyalar (`*.g.dart`, l10n çıktısı) **commit edilir**: repoyu klonlayan herkes
`build_runner` çalıştırmadan uygulamayı açabilir. CI, üretilen kodun güncel olduğunu kontrol eder.

---

## 5. Git kuralları

- **Conventional Commits**, İngilizce, kapsamlı:
  `feat(scene_engine): add hotspot layer`, `fix(progress): ...`, `test: ...`, `refactor: ...`,
  `chore: ...`, `docs: ...`, `ci: ...`, `build: ...`, `perf: ...`, `style: ...`
- Commit gövdesine plan referansı ekle: `Plan: 1.3`
- Her plan adımı en az bir commit'tir. Büyük adımları mantıklı parçalara böl.
- Kalite kapısı geçtiyse kullanıcıya **sormadan** `git push`.
- Aşama bitince etiket: `git tag -a phase-N -m "Phase N: <başlık>"` ve `git push --tags`.
- Tek geliştirici olduğumuz için `main` dalında ilerlenir.
- **Asla:** force push, geçmişi yeniden yazma, gizli dosya commit'leme
  (`env/*.json` (example hariç), `*.jks`, `*.keystore`, `key.properties`, `.env`, servis anahtarları).
  Commit'ten önce `git status` ile listeyi kontrol et.

---

## 6. Oyun mekaniği kuralları

Ayrıntılı tasarım `docs/game_design.md`'dedir; burası koda dökülmüş kurallardır.

- **Veri odaklı içerik:** Sahneler, hotspot'lar, eşyalar, notlar ve bulmacalar `assets/content/` altındaki JSON'dan
  yüklenir (`cases/<vaka>/chapters/<bölüm>/`). Kodda sahne metni, eşya/not metni, koordinat veya bulmaca çözümü yazılmaz.
  Sahne sayısı koda bağlı değildir: yeni sahne = yeni JSON + görsel.
- **Hiyerarşi:** Sahneler Parent → Child yapısındadır. Gezinme bir yığındır: `[villa_exterior, statue_closeup]`.
- **Koşul + etki sistemi:** Hotspot'ların türü yoktur; her hotspot sıralı `interactions` kuralları taşır.
  - Kural = `when` (opsiyonel koşul) + `do` (etki listesi). Yukarıdan aşağı, koşulu tutan **ilk** kural çalışır.
  - Koşullar (`sealed class Condition`): `flag`, `notFlag`, `hasItem`, `usingItem`, `hasNote`, `all`, `any`.
  - Etkiler (`sealed class Effect`): `goToScene`, `giveItem`, `consumeItem`, `addNote`, `setFlag`, `hideHotspot`, `say`;
    Aşama 5'te `openPuzzle`, `playMedia`.
  - Seçili eşyayla dokunulduysa ve hiçbir kural o eşyayı karşılamıyorsa yalnızca genel tepki verilir
    (`generic_item_no_effect`); yanlış eşya normal etkileşimi tetiklemez. Dokunuştan sonra seçim temizlenir.
  - Hotspot'lar `visibleWhen` ile koşullu görünür; `hideHotspot` ile kalıcı gizlenir (alınan nesne bir daha görünmez).
  - Sahneler `visualVariants` ile duruma göre görünüm değiştirir (kapı açık/kapalı).
  - Bu sistemin çözümleyicisi (`InteractionResolver`) saf Dart'tır ve kapsamlı unit testlerle korunur.
    Yeni bir etki/koşul türü eklemek mimari bir karardır: önce sor, sonra ADR yaz.
- **Toplananlar iki türlüdür:** **Eşyalar** (sağ panelde, kullanılır, `consumeItem` ile tükenebilir) ve
  **notlar** (not defterinde: `document` / `observation` / `suspect`; okunur, finalde kanıt olarak seçilir).
- **Eşya kullanımı:** Panelde eşyaya dokun → seçili olur → sahnede hedefe dokun. Uzun bas → inceleme kartı.
- **Dedektifin iç sesi:** Tek yönlüdür; oyuncu cevap vermez. Tüm mesajlar `say` etkisi ve `DetectiveSaid` olayıyla gelir.
- **Koordinatlar:** 0.0–1.0 arası normalize `x, y, width, height`, **sahne görseline göre** (ekrana göre değil).
  Sahne, sabit 16:9 oranlı bir `SceneViewport` içinde çizilir; hotspot katmanı da bu viewport'un içinde
  olduğu için her ekranda görselle birlikte ölçeklenir.
- **Sahne geçişi: zoom YOK.** Varsayılan: 150 ms siyaha kararma → sahne değişir → 150 ms açılma.
  Her `goToScene` etkisinde JSON'dan ayarlanabilir:
  `type` (`fade` | `cut`), `fadeOutMs`, `holdMs` (karanlıkta bekleme; ör. ses efekti çalarken uzar),
  `fadeInMs`, `sfx` (opsiyonel; ses Aşama 6'da bağlanır).
  Geçiş sırasında dokunmalar kilitlidir (çift tıklama koruması).
- **Geri tuşu:** Yığın derinliği 1'den büyükken sol üstte görünür. Basınca aynı geçiş tipiyle üst sahneye döner.
  Ana sahnede gizlidir. Android sistem geri tuşu da aynı davranışı tetikler.
- **Görseller:** Şimdilik `CustomPainter` ile noir placeholder çizimler. Her sahne tanımında opsiyonel
  `background` alanı vardır: doluysa gerçek görsel (WebP/PNG) çizilir, boşsa placeholder.
  Gerçek görsele geçiş tek satırlık JSON değişikliği olmalı.
- **Ekran yönü:** Mobilde yatay (landscape) kilitli, tam ekran (immersive). Windows'ta pencere veya tam ekran;
  sahne her durumda 16:9 viewport içinde çizilir.
- **Girdi:** Dokunma ve fare tıklaması aynı etkileşimi tetikler. Oyun mantığı fareyle üzerine gelmeye (hover)
  asla bağlanmaz (mobilde hover yok). Her etkileşim Windows'ta fareyle de test edilir.

### HUD
- Sol üst: Geri butonu. Sağ: dikey, yarı saydam **eşya paneli**; üstünde rozetli **not defteri** düğmesi.
  Alt: kompakt dedektif mesaj barı (dokununca mesaj geçmişi açılır).
- Sahne viewport'u panelin solunda kalan alana sığdırılır; hotspot'lar asla panelin altında kalmaz.
- HUD güvenli alanlara (çentik, kamera deliği) uyar.

---

## 7. Kod stili

- Lint: `very_good_analysis` (`public_member_api_docs` kapalı).
- **Dil:** Kod, isimler, kod yorumları, commit mesajları, README ve ADR'ler İngilizce.
  Kullanıcıya açıklamalar ve devlog Türkçe. **Oyun içi metinler İngilizce** ve l10n üzerinden gelir; kodda kullanıcıya
  görünen string literal olmaz. İlk çıkışta tek dil `en`; altyapı çok dillidir: yeni dil = yeni `app_xx.arb` +
  içerik `text_xx.json` dosyaları, kod değişmez.
- **Desteklenen diller kodda tek yerde tanımlıdır:** ARB dosyalarından üretilen `AppLocalizations.supportedLocales`.
  `MaterialApp`, içerik metin servisi ve içerik doğrulama testi bu listeyi kullanır; başka yerde dil listesi yazılmaz.
- Dosya adları `snake_case`; bir dosyada bir public sınıf (küçük yardımcılar hariç).
- `print` yok; `core/logging` kullanılır.
- Sihirli sayı yok; ölçüler, renkler, süreler `core/theme` veya ilgili sabit dosyasında.
- Widget'lar küçük ve odaklı; 150 satırı aşan widget'ı böl. `build` içinde iş mantığı olmaz.
- Performans: `const` constructor'lar; gereksiz yeniden çizimi önlemek için `BlocSelector` / `buildWhen`;
  `CustomPainter.shouldRepaint` doğru yazılır; arka plan ve hotspot katmanları `RepaintBoundary` ile ayrılır;
  görseller `precacheImage` ile önceden yüklenir.

---

## 8. Ortamlar (flavors) ve güvenlik

- Flavor'lar: `dev`, `staging`, `prod`. Android `productFlavors` + `applicationIdSuffix` (`.dev`, `.stg`)
  sayesinde üçü aynı telefonda yan yana kurulabilir.
- Giriş noktaları: `lib/main_dev.dart`, `lib/main_staging.dart`, `lib/main_prod.dart`.
- Yapılandırma: `--dart-define-from-file=env/<flavor>.json`. `env/*.json` gitignore'da; `env/example.json` commit edilir.
- Çalıştırma örneği:
  `flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json`
- Supabase projeleri: `dev` ve `staging` → `detectivedark-staging`; `prod` → `detectivedark-prod`.
- Uygulamada sadece Supabase **anon / publishable** anahtarı bulunur. **service_role / secret** anahtarı
  asla uygulamaya veya repoya girmez (sadece Edge Function ortam değişkeninde).
- Her Supabase tablosunda RLS açıktır; politikasız tablo oluşturulmaz. Şema değişiklikleri sadece
  `supabase/migrations/` altındaki SQL dosyalarıyla yapılır.
- Satın alma ve kilit durumuna yerel kayıttan asla güvenilmez.
- iOS flavor/scheme kurulumu Mac veya bulut CI erişimi olunca yapılır (Aşama 10).
- **Steam (Windows) sürümü:** Windows'ta Android tarzı flavor kullanılmaz; ayrım giriş noktasıyla yapılır:
  `flutter run -d windows -t lib/main_steam.dart --dart-define-from-file=env/steam.json`.
  Geliştirme sırasında hızlı test için mobil giriş noktaları da Windows'ta çalıştırılabilir:
  `flutter run -d windows -t lib/main_dev.dart --dart-define-from-file=env/dev.json`.
- Steamworks kimlik bilgileri ve derleme yükleme hesapları repoya girmez.

---

## 9. Paket ve test politikası

### Paketler
- Yeni paket eklemeden önce `plan.md`'de listeli mi kontrol et. Değilse gerekçesiyle kullanıcıya sor.
- pub.dev'de güncel sürümü ve bakım durumunu kontrol et. API'yi hafızadan değil, güncel dokümantasyondan uygula
  (ör. `google_sign_in`'in API'si yakın zamanda büyük ölçüde değişti).
- Paketin desteklediği platformları (Android, iOS, **Windows**) kontrol et. Windows'u desteklemeyen bir paket
  (ör. mağaza satın alma, Google girişi) yalnızca mobil uygulamada, platform servisi arayüzünün arkasında kullanılır;
  ortak oyun kodu ona doğrudan bağımlı olmaz.
- `flutter pub add` kullan.

### Testler
- `domain` ve use case'ler: unit test. Bloc/Cubit: `bloc_test` + `mocktail`. Kritik widget'lar: widget test.
  Uçtan uca akış: `integration_test`.
- `test/` klasörü `lib/` yapısını aynalar.
- **İçerik doğrulama testi** her zaman çalışır ve 50+ sahneli bölümlerde güvenlik ağıdır:
  - Tüm JSON'lar yüklenir; bilinmeyen koşul/etki anahtarı yoktur.
  - Referans verilen her sahne, eşya ve not ID'si vardır.
  - Her metin anahtarı **desteklenen tüm dillerin** dosyalarında bulunur (şimdilik sadece `en`).
  - Koordinatlar 0–1 aralığındadır.
  - Okunan (`flag`, `notFlag`) her bayrak bir yerde `setFlag` ile set edilir (yazım hatası yakalanır).
  - Her sahne, bölümün giriş sahnesinden ulaşılabilirdir (graf taraması; kopuk sahne yakalanır).

### Karar kayıtları (ADR)
`docs/adr/NNNN-kebab-title.md`, İngilizce, kısa: **Context / Decision / Consequences**.
Önemli her yeni teknik karar için yeni bir ADR yazılır.

---

## 10. Formatlar

### Devlog (`docs/devlog/asama-N.md`, Türkçe)
```
### Adım N.M — <Başlık> (<YYYY-AA-GG>)
- **Ne yaptık:** ...
- **Neden:** ...
- **Önemli dosyalar:** ...
- **Telefonda nasıl test edilir:** ...
- **Öğrenme notu:** <adımdaki ana kavramın 3–6 satırlık açıklaması>
```

### Adım sonu özeti (terminalde, Türkçe)
```
ADIM N.M TAMAMLANDI — <Başlık>
- Ne yaptım: ...
- Neden: ...
- Kalite kapısı: format OK | analyze 0 sorun | test X/X geçti
- Commit: <hash> <mesaj>  (push edildi)
- Telefonda test: <flutter run komutu ve neye bakılacağı>
- Sıradaki adım: N.M+1 — <başlık>
```