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
| `Aşama 1'i yap` | O aşamanın tamamlanmamış adımlarını sırayla uygula. Her adım ayrı commit. Aşama bitince dur. (`Aşama 1b'yi yap` = adım 1.9–1.20; devlog `asama-1.md`'ye devam eder.) |
| `Sıradaki adım` | `plan.md`'deki **"Çalışma sırası"na** göre ilk işaretlenmemiş adımı uygula (dosyadaki ilk kutu değil). |
| `Durum` | Biten adımlar, sıradaki adım, açık kararlar. Kod yazma. |
| `Açıkla 1.3` | O adımda ne yapıldığını ve nedenini tekrar anlat. Kod yazma. |

### Her adımın akışı
1. `plan.md`'yi oku. Adımın **Amaç**, **Yapılacaklar** ve **Kabul kriterleri** kısımlarını uygula.
   Çalışma sırasına göre önceki adımlar bitmemişse uyar ve devam etmek için onay iste.
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
    scene_engine/      # sahneler, hotspot'lar, koşul + etki sistemi, gezinme yığını, geçişler,
                       # inceleme penceresi, overlay yazılar, noir filtre
    inventory/         # eşya kataloğu, sağ panel, eşya seçimi ve kullanımı
    notebook/          # not defteri: belgeler, gözlemler, kişiler; güncellenen dosyalar (not satırları)
    dialogue/          # karakterlerle konuşma: konular, kanıt gösterme, eşya verme, konuşma paneli
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
  (`SceneEntered`, `ItemObtained`, `ItemUsed`, `NoteAdded`, `NoteUpdated`, `DetectiveSaid`, `TopicAsked`...). Olaylar arayüz tepkisi içindir; kalıcı durum her zaman ilerlemeden okunur.
- DTO (`data/models`) ile entity (`domain/entities`) ayrıdır; dönüşüm `data` katmanında yapılır.
- Hata yönetimi: `data` katmanı exception'ları yakalar, `domain`'e `Result<T>` (`Success` / `Failed`; `Failed` bir `Failure` taşır) döner.
  UI'a exception sızmaz.
- İlerlemenin tek doğruluk kaynağı `ProgressRepository`'dir. Sahne, eşya paneli, not defteri, konuşma paneli ve chat
  bu kaynaktan okur.
- **Tek etki hattı (ADR 0014):** İlerlemeyi değiştiren her use case (hotspot dokunuşu, sahneye giriş, konuşma konusu,
  kanıt gösterme, notu okundu işaretleme, geliştirici menüsü, ileride bulmaca `onSolved`) `EffectPipeline`'ı kullanır:
  etkiler (`EffectApplier`, saf) → tetikleyiciler (sabit noktaya kadar) → **tek** atomik `save` → olaylar (yalnızca
  kayıt başarılıysa). `ProgressRepository.save` hattın dışında hiçbir yerden çağrılmaz (mimari testi denetler).
  Yeni bir yazma yolu eklemek yerine hatta yeni bir çağıran eklenir.
- Koşul ve etkileri JSON'dan ayrıştıran kod `scene_engine/data`'dadır. Başka bir feature'ın `data` katmanı
  (ör. `dialogue`) buna `scene_engine/domain`'deki `RuleParser` arayüzü üzerinden ulaşır; `data` → `data` import'u yoktur.
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
1. Kod üretimi olan adımlarda: `dart run build_runner build`
   (kurulu `build_runner` 2.15'te `--delete-conflicting-outputs` bayrağı kaldırıldı; çakışan çıktılar kendiliğinden silinir)
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

- **Veri odaklı içerik:** Sahneler, hotspot'lar, eşyalar, notlar, konuşmalar, tetikleyiciler ve bulmacalar
  `assets/content/` altındaki JSON'dan yüklenir (`cases/<vaka>/chapters/<bölüm>/`). Kodda sahne metni, eşya/not metni,
  konuşma metni, koordinat veya bulmaca çözümü yazılmaz. Sahne sayısı koda bağlı değildir: yeni sahne = yeni JSON + görsel.
- **İçerik dosya düzeni (ADR 0018):**
  - Bölüm klasöründe her tür tek dosya (`scenes.json`) **veya** klasör (`scenes/*.json`) olabilir: `scenes`, `items`,
    `notes`, `inspections`, `dialogues`, `triggers`. İkisi birden hatadır. Dosyalar asset manifest'inden listelenir ve
    ad sırasıyla okunur; yeni içerik klasörü `pubspec.yaml`'a eklenir. `dialogues` ve `triggers` opsiyoneldir.
    Metinler dil başına tek dosyadır (`text_xx.json`).
  - **Sonraki bölüm önceki bölümün içeriğini kendi dosyasında genişletir:** `sceneExtensions` (yeni hotspot'lar sona;
    `rules` ve `visualVariants` mevcutların **önüne**), `dialogueExtensions` (konular sona), `noteExtensions` (satırlar
    sona). Önceki bölümün dosyası sonraki bölüm için düzenlenmez. Birleştirme `data` katmanındadır; `domain` birleşmiş
    `CaseContent` görür; kayıt şekli değişmez. Genişletmeler oyuncunun bölümüne göre kendiliğinden açılmaz; yazar
    koşulla kapatır.
  - `case.json`'da listelenen ama pakette hiç dosyası olmayan bölüm atlanır (demo derlemesi); yarım bölüm hatadır.
- **Hiyerarşi:** Sahneler Parent → Child yapısındadır. Gezinme bir yığındır: `[villa_exterior, statue_closeup]`.
- **Koşul + etki sistemi:** Hotspot'ların türü yoktur; her hotspot sıralı `interactions` kuralları taşır.
  - Kural = `when` (opsiyonel koşul) + `do` (etki listesi). Yukarıdan aşağı, koşulu tutan **ilk** kural çalışır.
  - Koşullar (`sealed class Condition`): `flag`, `notFlag`, `hasItem`, `usingItem`, `hasNote`, `all`, `any`, `not`,
    `atLeast` (`{"count": 2, "of": [...]}`), `visited`, `inScene` (yığının tepesindeki sahne), `topicAsked`
    (`"dialogueId/topicId"`) (ADR 0013, 0016). `usingItem` yalnızca hotspot kuralının `when`'inde anlamlıdır; `not` ve
    `atLeast` içinde, tetikleyici ve konuşma konusu koşullarında kullanılamaz. `usingNote` koşulu yoktur.
  - Etkiler (`sealed class Effect`): `goToScene`, `giveItem`, `consumeItem`, `addNote`, `addNoteEntry`, `setFlag`,
    `hideHotspot`, `say`, `inspect`, `talk`; Aşama 5'te `openPuzzle`, `playMedia`.
  - **Etki nerede kullanılabilir:** hotspot kuralı: hepsi. `onFirstEnter`: `say`, `setFlag`, `addNote`, `giveItem`.
    Tetikleyici: `say`, `setFlag`, `addNote`, `addNoteEntry`, `giveItem`. Konuşma konusu: `say`, `setFlag`, `addNote`,
    `addNoteEntry`, `giveItem`, `consumeItem`.
  - **`say` iki biçim alır (ADR 0013):** `{"say": "key"}` ve `{"say": {"first": "key_long", "then": "key_short"}}`
    (ilk seferde `first`, sonra hep `then`). Söylenenler kayıtta `spokenLines` kümesindedir (anahtar: `first`); `first`
    anahtarları vaka içinde benzersizdir. `chatLog` son 200 girişle sınırlıdır (tek sabit) ve **hiçbir oyun mantığı
    `chatLog`'dan okumaz**.
  - **Tetikleyiciler (ADR 0014):** `triggers.json`'daki kurallar (`id`, `when`, `do`) koşulu ilk tuttuğunda **bir kez**
    çalışır; ateşlenenler `firedTriggers`'a yazılır. Etki hattının içinde, dosya sırasıyla, sabit noktaya kadar
    (döngü sınırıyla) değerlendirilir. "Her ikisi de soruldu" gibi birleşik koşullar her kurala kopyalanmaz, tek
    tetikleyici olarak yazılır.
  - **`inspect`** (ADR 0010): sahneyi ve gezinme yığınını değiştirmeden sahnenin üstünde küçük bir inceleme penceresi
    açar (görsel + metin). İçerik bölümün `inspections.json` kataloğundan ID ile gelir. Pencere açıkken sahneye
    dokunulamaz; dışına dokunmak, kapat düğmesi veya Geri (Android sistem geri dahil) yalnızca pencereyi kapatır.
    İlerlemeye kaydedilmez (arayüz durumudur); kalıcı olması gereken şey aynı kuralda ayrı etkiyle eklenir (`addNote`).
    Bir kuralda en fazla bir `inspect` olur ve `goToScene` ile birlikte kullanılmaz. Eşyaya uzun basınca açılan
    inceleme kartı da aynı pencereyi kullanır.
  - **`talk`** (ADR 0016): konuşma panelini açar. `inspect` gibi arayüz durumudur: yığını değiştirmez, kayda girmez.
    Bir kuralda en fazla bir `talk` olur; `goToScene` veya `inspect` ile birlikte kullanılmaz.
  - Seçili eşyayla dokunulduysa ve hiçbir kural o eşyayı karşılamıyorsa yalnızca genel tepki verilir
    (`generic_item_no_effect`); yanlış eşya normal etkileşimi tetiklemez. Dokunuştan sonra seçim temizlenir.
    **Tek istisna:** eşyasız dokunuşta çalışacak kural `talk` içeriyorsa panel açılır ve eşya karaktere gösterilir
    (resolver'da tek kural; hotspot'a eşya başına `usingItem` kuralı yazılmaz). Hotspot'taki açık bir `usingItem`
    kuralı yine önce gelir.
  - Hotspot'lar `visibleWhen` ile koşullu görünür; `hideHotspot` ile kalıcı gizlenir (alınan nesne bir daha görünmez).
  - **Nesne katmanı (ADR 0012):** Hotspot'un opsiyonel `sprite` alanı sahnede duran nesnenin görselidir: normalize
    `rect` (sahne görseline göre, dokunma alanından bağımsız), `placeholderStyle` ve opsiyonel `image` (şeffaf arka
    planlı görsel; boşsa placeholder painter çizer). Nesne yalnızca hotspot'u görünürken çizilir; `hideHotspot`
    veya `visibleWhen` ile gizlenince görseli de kaybolur. Alınan nesne için bayrak + görünüm varyantı yazılmaz.
    `sprite` opsiyonel `overlays` taşıyabilir (sahne görseline göre normalize; nesneyle birlikte görünür/kaybolur):
    koşullu beliren tabelanın yazısı gibi (ADR 0017). Karakterler de silüet `sprite`'lı sıradan hotspot'lardır.
  - Sahneler `visualVariants` ile duruma göre görünüm değiştirir (kapı açık/kapalı). Varyant sahnenin kendisi
    değiştiğinde kullanılır; sahnede duran, alınabilen nesneler için `sprite` kullanılır.
  - Bu sistemin çözümleyicisi (`InteractionResolver`) saf Dart'tır ve kapsamlı unit testlerle korunur.
    Yeni bir etki/koşul türü eklemek mimari bir karardır: önce sor, sonra ADR yaz.
- **Toplananlar iki türlüdür:** **Eşyalar** (sağ panelde, kullanılır, `consumeItem` ile tükenebilir) ve
  **notlar** (not defterinde: `document` / `observation` / `person`; okunur, finalde kanıt olarak seçilir).
  `person` = "Kişiler" sekmesi: şüpheli ve tanık dosyaları; kimin şüpheli olduğu `case.json`'dadır (Aşama 5.5).
- **Not satırları (ADR 0015):** Nota opsiyonel `entries` kataloğu (`id`, `textKey`); `addNoteEntry`
  (`{"note": ..., "entry": ...}`) bir satırı açar. Kayıtta `CollectedNote.entries: [{entryId, addedAtUtcMs}]`. Satır
  eklenince not yeniden okunmamış olur ve `NoteUpdated` çıkar; not defterde değilse etki önce notu ekler (`NoteAdded`).
  Karakter ifadeleri kişi dosyasına satır olarak girer; ifade başına ayrı not açılmaz.
- **Eşya kullanımı:** Panelde eşyaya dokun → seçili olur → sahnede hedefe dokun. Uzun bas → inceleme kartı.
- **Dedektifin iç sesi:** Tek yönlüdür; oyuncu cevap vermez. Tüm mesajlar `say` etkisi ve `DetectiveSaid` olayıyla gelir.
  Karakterlerin konuşmaları iç ses değildir: ayrı konuşma panelinden gelir ve `chatLog`'a yazılmaz. Dedektifin bir
  cevaba yorumu, konunun `do` listesindeki `say` ile yine mesaj barından gelir.
- **Konuşma (ADR 0016; `features/dialogue/`, içerik `dialogues.json`):**
  - Karakter sahnede silüet `sprite`'lı hotspot'tur; dokununca panel **doğrudan** açılır ("Konuş" ara adımı yok).
    Sahnedeki silüette "yeni soru" işareti yoktur.
  - Konuşma: `id`, `nameKey`, `portrait`, `greeting` (`say` gibi tek anahtar veya `first`/`then`; aynı `spokenLines`),
    `noReactionKey`, `topics`. Konu: `id`, `promptKey`, `answer` (karakterin satırları), opsiyonel `visibleWhen`,
    `trigger`, `do`.
  - Satırlar tek tek, daktilo efektiyle gelir: dokunuş yazılan satırı tamamlar, bir dokunuş daha sonraki satıra geçer;
    son satırdan sonra soru listesine dönülür.
  - `do` yalnızca konu **ilk kez** sorulduğunda (etki hattından) çalışır; tekrar sorunca yalnızca cevap okunur.
    Sorulanlar kayıttadır: `askedTopics` (`dialogueId/topicId`).
  - **Görünürlük = sorulmuş VEYA (`trigger` yok ve `visibleWhen` tutuyor).** Bir kez sorulan konu, koşulu sonradan
    bozulsa bile listede kalır. Görünür ama sorulmamış konu "yeni" etiketi, sorulmuş konu işaret taşır.
  - Panel en küçük hedef telefon yüksekliğinde **4 soruyu kaydırmadan** gösterir; fazlası kaydırılır.
  - Konu etkilerinde gezinme, `inspect`, `talk`, `hideHotspot` yoktur; karakterin gitmesi bayrak + hotspot
    `visibleWhen` ile yazılır.
  - Oyuncu yalnızca önceden yazılmış soruları seçer; hikaye dallanmaz, sorular yalnızca bilgi ortaya çıkarır.
- **Kanıt gösterme ve eşya verme (ADR 0016):**
  - `trigger` (`{"showItem": id}` veya `{"showNote": id}`) taşıyan konu listede baştan görünmez; eşya/not gösterilince
    oynar, sonra `promptKey` ile sorulmuş olarak kalır. Vermek = `do` içinde `consumeItem`.
  - Eşya: sahnede eşya seçiliyken karaktere dokunmak (yukarıdaki resolver kuralı) veya panel açıkken sağ paneldeki
    eşyaya tek dokunuş. Not: panelde "Kanıt göster" defteri seçim modunda açar; notta "Göster" düğmesi.
  - Not yalnızca kişilere gösterilir; sahne nesnelerinde `hasNote` kullanılır.
  - Eşleşen konu yoksa veya koşulu tutmuyorsa karakter `noReactionKey` repliğini söyler; ceza, işaret ve kayıt yoktur.
- **Mekanlar arası geçiş (ADR 0017): harita yok.** Mekanlara yalnızca sahnedeki geçiş hotspot'larıyla gidilir (tabela,
  çıkış). Geri her zaman `parentId` zincirindeki üst sahneye döner; kök mekana gidince yığın tek elemanlıdır (Geri
  görünmez). Her iç mekanın merkez sahnesinde bir çıkış hotspot'u bulunur; hiçbir mekan tuzak olamaz (doğrulayıcı).
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
  Gerçek görsele geçiş tek satırlık JSON değişikliği olmalı. Gerçek görseller yapay zekâ destekli üretilir (ADR 0011).
- **Yazı ve sayılar görsele gömülmez (overlay, ADR 0011):** Okunması gereken veya bulmaca için kritik her yazı ve sayı
  (saat, şifre, mektup metni, tabela, plaka) görselin JSON'undaki `overlays` ile tanımlanır ve oyun tarafından
  görselin üstüne çizilir: normalize `rect` (görsele göre, 0–1), `textKey` (l10n), `style` (kodda tanımlı
  adlandırılmış preset: daktilo, el yazısı, kazıma...), opsiyonel `rotation`. Sahne görselinde, görünüm
  varyantlarında ve inceleme görsellerinde kullanılır. Bulmaca cevabı her zaman okunur ve doğrudur; yeni dil yeni
  görsel gerektirmez.
- **Noir filtre (ADR 0011):** Tüm arka planlara ve inceleme görsellerine ortak bir filtre katmanı uygulanır:
  film greni, vinyet, renk tonu. Ayarlar `core/theme`'de adlandırılmış preset'lerdir; sahne JSON'u yalnızca preset
  adı seçer (sayısal değer yazmaz). Katman sırası: **arka plan → nesneler → overlay → noir filtre → hotspot → geçiş**
  (nesne katmanı ADR 0012). Nesneler ve overlay filtrenin altında kalır ki görsele kaynaşsın; hiçbir preset kritik
  yazıyı okunmaz hale getiremez. İnceleme görsellerinde nesne katmanı yoktur.
  Placeholder çizimler kendi gren/vinyetini çizmez, ortak filtreyi kullanır.
- **Ekran yönü:** Mobilde yatay (landscape) kilitli, tam ekran (immersive). Windows'ta pencere veya tam ekran;
  sahne her durumda 16:9 viewport içinde çizilir.
- **Girdi:** Dokunma ve fare tıklaması aynı etkileşimi tetikler. Oyun mantığı fareyle üzerine gelmeye (hover)
  asla bağlanmaz (mobilde hover yok). Her etkileşim Windows'ta fareyle de test edilir.

### HUD
- Sol üst: Geri butonu. Sağ: dikey, yarı saydam **eşya paneli**; üstünde rozetli **not defteri** düğmesi.
  Alt: kompakt dedektif mesaj barı (dokununca mesaj geçmişi açılır).
- **Mesaj barı sahnenin üstüne biner ama hiçbir hotspot'u kapatmaz:** bar (ve mesaj okununca küçüldüğü düğme) yalnızca
  sahnenin alt şeridine yerleşir. Şeridin yüksekliği tek sabittir (`SceneLayout.chatStripHeight`, `core/theme`);
  içerikte hiçbir hotspot bu şeride giremez (içerik doğrulama testi reddeder).
- **Konuşma paneli:** sahne alanının üstünde açılır; eşya panelini (eşya göstermek için dokunulur) ve mesaj barının
  alt şeridini (dedektifin yorumu orada görünür) kapatmaz. Açıkken sahneye dokunulamaz. Paneller üst üste binmez:
  konuşma açıkken inceleme penceresi açılmaz.
- **Geri sırası:** önce en üstteki katman kapanır (not defteri / mesaj geçmişi → konuşma paneli veya inceleme
  penceresi), hiçbiri açık değilse üst sahneye dönülür. Sistem geri tuşu ve `Esc` aynı sırayı izler.
- Klavye: `Esc` = Geri (açık pencereyi kapatır, yoksa üst sahneye döner; ana sahnede etkisizdir).
- **Geliştirici menüsü (yalnızca dev):** sahneye atlama, eşya/not/bayrak ekleme, ilerlemeyi sıfırlama,
  `assets/dev/presets.json`'dan adlandırılmış durum yükleme. Değişiklikler etki hattından geçer.
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
  - Referans verilen her sahne, eşya, not, not satırı, inceleme, konuşma ve konu (`dialogueId/topicId`) ID'si vardır.
  - Her metin anahtarı **desteklenen tüm dillerin** dosyalarında bulunur (şimdilik sadece `en`).
  - Koordinatlar (hotspot, nesne, overlay ve nesne overlay'i) 0–1 aralığındadır; nesne ve portre placeholder stilleri
    kodda tanımlıdır.
  - Bir kuralda en fazla bir `inspect` ve en fazla bir `talk` vardır; `inspect`, `talk` ve `goToScene` aynı kuralda
    birlikte kullanılmaz.
  - Her etki yalnızca izinli olduğu yerde kullanılır (`onFirstEnter`, tetikleyici, konuşma konusu listeleri: bölüm 6).
  - `usingItem`, `not` / `atLeast` içinde, tetikleyici ve konu koşullarında yoktur; `atLeast.count` 1 ile koşul sayısı
    arasındadır.
  - `say` ve `greeting` `first` anahtarları, tetikleyici ID'leri ve konuşma ID'leri vaka içinde; konu ID'leri konuşma
    içinde; satır ID'leri not içinde benzersizdir.
  - Konu `trigger`'ı tam olarak bir `showItem` veya `showNote` içerir.
  - Hiçbir hotspot mesaj barının alt şeridine (`SceneLayout.chatStripHeight`) girmez.
  - Okunan (`flag`, `notFlag`) her bayrak bir yerde `setFlag` ile set edilir (yazım hatası yakalanır).
  - Her sahne, bölümün giriş sahnesinden ulaşılabilirdir (graf taraması; kopuk sahne yakalanır).
  - **Tuzak mekan yok:** her kök sahneden, o sahnenin bölümünün giriş sahnesine dönen bir yol vardır.
  - Genişletmeler (`sceneExtensions`, `dialogueExtensions`, `noteExtensions`) yalnızca önceki bir bölümün var olan
    içeriğini hedefler; ekledikleri ID'ler mevcutlarla çakışmaz.
  - **Bölüm önekleri ayrı doğrulanır** (B1; B1–2; ...): erken bölüm, geç bölümün ID'sine, bayrağına veya metnine
    bağımlı olamaz (demo derlemesi yalnızca ilk bölümle çalışır).
  - **Uyarılar** testi kırmaz, raporlanır: kullanılmayan metin anahtarı; hedefi mevcut sahnenin çocuğu, ebeveyni veya
    bir kök sahne olmayan `goToScene`; hiçbir `talk` ile açılmayan konuşma.
  - `assets/dev/presets.json`'daki her sahne, eşya, not ve bayrak içerikte vardır.

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