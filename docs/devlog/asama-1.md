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

### Adım 1.3 — Bellekte ilerleme, etki uygulama ve SceneBloc (2026-11-13)
- **Ne yaptık:** Oyun mantığını çalışır hale getirdik; hâlâ arayüz yok. `InMemoryProgressRepository` ilerlemeyi
  bellekte tutuyor. Üç use case yazdık: `StartGame` (içeriği yükle; kayıt varsa devam et, yoksa yeni oyun kur),
  `EnterScene` (sahneye gir: yığın + ziyaret işareti + ilk giriş etkileri, tek kayıt) ve `TapHotspot` (kuralı seç,
  etkileri uygula, kaydet, olayları yayınla). Hepsinin üstünde `SceneBloc` var: ekrandaki sahneyi, görünümü,
  görünür hotspot'ları, geçiş fazını ve açık inceleme penceresini tutuyor.
- **Neden:** Mantık arayüzden bağımsız olunca kabul senaryosunun 11 adımının tamamı ekran çizilmeden test
  edilebiliyor: `scene_bloc_scenario_test.dart` gerçek JSON içeriği yükleyip oyunu baştan sona oynuyor. Arayüz
  yazılırken (1.4) "mantık mı bozuk, çizim mi?" sorusu baştan cevaplanmış oluyor. Bloc olayları sırayla işliyor,
  çünkü kayıt asenkron: sırasız olsaydı anahtara iki hızlı dokunuş kuralı iki kez çalıştırabilirdi.
- **Önemli dosyalar:** `lib/features/scene_engine/presentation/bloc/scene_bloc.dart`, `scene_event.dart`,
  `scene_state.dart`, `lib/features/scene_engine/domain/usecases/start_game.dart`, `enter_scene.dart`,
  `tap_hotspot.dart`, `lib/features/scene_engine/domain/services/scene_view_resolver.dart`,
  `lib/features/progress/data/repositories/in_memory_progress_repository.dart`, `test/helpers/game_harness.dart`.
- **Telefonda nasıl test edilir:** Bu adım da ekranı etkilemiyor. Senaryoyu çalıştır:
  `flutter test test/features/scene_engine/presentation/bloc/scene_bloc_scenario_test.dart`. Dosyayı okursan
  kabul senaryosunun 1–11. adımlarını sırayla görürsün.
- **Öğrenme notu:** **Bloc**, olayları (event) alır ve durum (state) üretir: `HotspotTapped` girer, yeni `SceneState`
  çıkar. Arayüz sadece durumu çizer ve olay gönderir; karar vermez. Geçişte ilginç bir iş bölümü var: bloc süre
  tutmaz, yalnızca fazı bilir (`idle → covering → revealing → idle`). Ekran tamamen kararınca arayüz
  `TransitionCovered` gönderir ve bloc sahneyi tam o anda değiştirir. Böylece bloc testlerinde zamanlayıcı yoktur,
  testler anında ve kararlı çalışır. **Use case** ise tek bir iş kuralını temsil eder ("hotspot'a dokunuldu") ve
  hep aynı sırayı izler: hesapla → kaydet → başarılıysa olayları yayınla. Kayıt başarısızsa olay yayınlanmaz;
  ekranda olmamış bir şeyin animasyonu oynamaz.

### Adım 1.4 — Sahne görünümü (2026-11-13)
- **Ne yaptık:** Oyun ilk kez ekranda. `GameScreen` içeriği ve metinleri yükleyip sahneyi gösteriyor. Sahne beş
  katmandan oluşuyor: placeholder çizim (ya da gerçek görsel) → oyunun çizdiği yazılar (`OverlayLayer`) → ortak noir
  filtre (`NoirFilter`) → görünmez dokunma alanları (`HotspotLayer`) → siyah geçiş katmanı (`TransitionOverlay`).
  Hepsi 16:9 oranlı `SceneViewport`'un içinde. İnceleme penceresi (`InspectPanel`), sol üstte Geri butonu, Android
  sistem geri tuşu ve dev sürümünde hotspot çerçevelerini gösteren düğme de bu adımda geldi. Dört sahnenin ve
  plaketin noir placeholder çizimleri `core/placeholders` altında.
- **Neden:** Hotspot koordinatları ekrana değil görsele göre (0–1 arası) tanımlı. Görsel ve dokunma katmanı aynı
  16:9 kutunun içinde olduğu için telefon, tablet ya da yeniden boyutlanan pencerede birlikte ölçeklenir; kapının
  dokunma alanı hiçbir ekranda kapıdan kaymaz. Yazılar görsele gömülmez, üstüne çizilir: yapay zekâ ile üretilecek
  görsellerde yazı bozuk çıksa bile "17" ve plaket yazısı her zaman doğru ve okunur olur.
- **Önemli dosyalar:** `lib/app/game/game_screen.dart`, `game_hud.dart`,
  `lib/features/scene_engine/presentation/widgets/scene_view.dart`, `scene_viewport.dart`, `hotspot_layer.dart`,
  `overlay_layer.dart`, `noir_filter.dart`, `transition_overlay.dart`, `inspect_panel.dart`,
  `lib/core/placeholders/`, `lib/core/di/register_scene_engine.dart`, `tool/render_scenes_test.dart`.
- **Telefonda nasıl test edilir:** `flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json`.
  Villa görünmeli, kapının yanında "17" yazmalı. Kapıya dokun: ekran kısa bir kararmayla kapı yakın planına geçer ve
  sol üstte Geri belirir. Geri'ye (ya da telefonun geri tuşuna) bas, heykele git, kulağındaki parlayan anahtara
  dokun: anahtar kaybolur. Kaidedeki plakete dokun: sahne değişmeden pencere açılır; dışına dokununca kapanır.
  Sol alttaki ızgara düğmesi dokunma alanlarını çerçeveyle gösterir (yalnızca dev). Windows'ta:
  `flutter run -d windows -t lib/main_dev.dart --dart-define-from-file=env/dev.json`; aynı adımları fareyle dene ve
  pencereyi yeniden boyutlandır.
- **Öğrenme notu:** Flutter'da ekran bir **widget ağacıdır** ve her kare yalnızca "kirlenen" kısım yeniden çizilir.
  `RepaintBoundary` bir alt ağacı ayrı bir katmana alır: anahtarın parıltısı saniyede 60 kez animasyon yaparken
  arka plandaki çizim tekrar çizilmez. `BlocSelector` de aynı fikrin durum tarafıdır: her katman durumun yalnızca
  kendi parçasını dinler (görünüm, hotspot listesi, inceleme, geçiş fazı); biri değişince diğerleri yeniden
  kurulmaz. `CustomPainter` ise doğrudan tuvale çizmemizi sağlar; `shouldRepaint` "önceki çizim hâlâ geçerli mi?"
  sorusunun cevabıdır. `LayoutBuilder` bir widget'a kendisine ayrılan alanın boyutunu verir; normalize koordinatı
  piksele çeviren yer orasıdır (`rect.x * genişlik`).

### Adım 1.5 — HUD: eşya paneli ve eşya kullanımı (2026-11-13)
- **Ne yaptık:** Ekranın sağına eşya panelini (`ItemSidebar`) ekledik; sahne artık panelin solunda kalan alana
  sığıyor. `InventoryCubit` taşınan eşyaları ilerlemeden okuyup katalogdaki ad ve ikonla birleştiriyor ve seçili
  eşyayı tutuyor. Eşyaya dokununca seçilir (altın çerçeve), tekrar dokununca bırakılır. Seçiliyken sahnede bir yere
  dokununca o eşya "kullanılır" ve seçim kalkar. Uzun basınca eşyanın inceleme kartı açılır (1.4'teki pencerenin
  aynısı). Alınan eşya sahnedeki yerinden paneldeki yuvasına uçar; tüketilen eşya panelden sönerek çıkar.
- **Neden:** "Eşyayı al, doğru yerde kullan" point-and-click türünün kalbidir. Mimari açıdan ilginç kısım, üç
  parçanın birbirini tanımaması: sahne (`scene_engine`) panelin varlığından, panel (`inventory`) sahnenin
  varlığından habersiz. İkisini `app/` katmanındaki `GameHud` bağlıyor: dokunuşa seçili eşyayı o ekliyor, uçuşu o
  başlatıyor, eşyayı inceleme penceresinin anlayacağı biçime (`inspectionForItem`) o çeviriyor.
- **Önemli dosyalar:** `lib/features/inventory/presentation/cubit/inventory_cubit.dart`,
  `lib/features/inventory/presentation/widgets/item_sidebar.dart`, `lib/app/game/game_hud.dart`,
  `lib/app/game/item_inspection.dart`, `lib/core/widgets/flight_layer.dart`, `lib/core/widgets/fly_anchors.dart`,
  `lib/core/di/register_inventory.dart`.
- **Telefonda nasıl test edilir:** Oyunu aç (dev). Heykele git, anahtara dokun: anahtar sağdaki panele uçmalı.
  Paneldeki anahtara dokun (çerçeve altın olur), sonra heykelin gövdesine dokun: hiçbir şey olmaz, seçim kalkar.
  Anahtara uzun bas: inceleme kartı açılır. Geri → kapıya git → anahtarı seç → kilide dokun: kapı açık görünüme
  geçer, anahtar panelden kaybolur ve panelde "Nothing yet" yazar. Windows'ta aynısını fareyle yap (uzun basma =
  fare tuşunu basılı tutma).
- **Öğrenme notu:** **Cubit**, Bloc'un sade halidir: olay sınıfları yoktur, doğrudan metot çağrılır
  (`toggle`, `clearSelection`) ve `emit` ile yeni durum yayılır. Basit durumlar için yeterlidir. Burada önemli bir
  ayrım var: *hangi eşyaları taşıdığımız* ilerlemededir (kaydedilir, tek doğruluk kaynağı), *hangisinin seçili
  olduğu* ise yalnızca arayüz durumudur (kaydedilmez). Cubit ilerlemeyi `watch()` ile dinler; bu yüzden anahtarı
  kim, nereden verirse versin panel kendiliğinden güncellenir. Uçuş animasyonunda `GlobalKey` kullandık: bir
  widget'ın ekrandaki gerçek konumunu ve boyutunu (`RenderBox`) öğrenmenin yolu budur. `FlyAnchors` bu anahtarları
  isimle saklar ("hotspot:statue_key", "item:brass_key"), böylece başlangıç ve bitiş noktaları farklı feature'larda
  olsa da `app/` katmanı ikisini de bulabilir.

### Adım 1.6 — Not defteri (2026-11-13)
- **Ne yaptık:** Not defterini ekledik. Eşya panelinin üstünde defter düğmesi var; okunmamış not varsa üstünde sayı
  rozeti çıkıyor. Düğmeye basınca defter sahnenin üstünde açılıyor: üç sekme (Documents / Observations / Suspects),
  solda not listesi, sağda seçilen notun metni. `NotebookCubit` toplanan notları ilerlemeden okuyup katalogdaki
  başlık ve metinle birleştiriyor. Bir nota dokununca `MarkNoteRead` use case'i onu ilerlemede "okundu" işaretliyor.
  Holdeki kağıt alınınca küçük bir kağıt ikonu defter düğmesine uçuyor.
- **Neden:** Bulmacaların cevapları çoğu zaman notlarda olacak ve finalde kanıtlar buradan seçilecek; defter oyunun
  hafızası. "Okundu" bilgisini ekranda değil ilerlemede tutuyoruz: Aşama 2'de kayıt kalıcı olunca uygulamayı kapatıp
  açtığında rozet yeniden belirmeyecek. Defter bir router sayfası değil, sahnenin üstündeki bir katman; böylece
  alttaki oyun durumu (sahne, seçim, geçiş) hiç bozulmuyor ve Geri tuşu önce defteri kapatıyor.
- **Önemli dosyalar:** `lib/features/notebook/presentation/cubit/notebook_cubit.dart`,
  `lib/features/notebook/presentation/widgets/notebook_screen.dart`, `notebook_button.dart`,
  `lib/features/notebook/domain/usecases/mark_note_read.dart`, `lib/core/di/register_notebook.dart`,
  `lib/app/game/game_hud.dart`, `test/app/game/notebook_flow_test.dart`.
- **Telefonda nasıl test edilir:** Oyunu aç (dev), anahtarı al, kapıyı aç, açık kapıdan hole gir. Masadaki parlayan
  kağıda dokun: kağıt kaybolur, sağ üstteki defter düğmesinde "1" rozeti belirir. Düğmeye bas, "Unsigned letter"
  satırına dokun: mektup sağda okunur. Defteri kapat: rozet gitmiş olmalı. Diğer sekmelerde atmosferik boş metinler
  görünmeli. Telefonun geri tuşu defteri kapatmalı, sahneyi değiştirmemeli.
- **Öğrenme notu:** Bu adımda **use case**'in neden ayrı bir sınıf olduğunu görmek kolay: `MarkNoteRead` üç satırlık
  bir iş kuralı ("not okunmamışsa okundu yap ve kaydet"), ama arayüzden bağımsız olduğu için widget'sız test
  ediliyor ve yarın başka bir yerden (ör. finalde kanıt seçerken) de çağrılabilir. Cubit'te iki tür veri yan yana
  duruyor: ilerlemeden gelen kalıcı veri (hangi notlar var, okundu mu) ve yalnızca ekrana ait geçici veri (defter
  açık mı, hangi sekme, hangi not seçili). Kural basit: uygulama kapanıp açılınca geri gelmesi gereken şey
  ilerlemeye, gerisi cubit durumuna yazılır. `BlocSelector` ile düğme yalnızca okunmamış sayısını dinliyor; defterin
  içinde sekme değiştirmek düğmeyi yeniden çizdirmiyor.

### Adım 1.6b — Nesne katmanı (2026-11-14)
- **Ne yaptık:** Hotspot'a opsiyonel bir `sprite` alanı ekledik: sahnede duran nesnenin görseli (konum + placeholder
  stili + ileride gerçek görsel). Yeni `SpriteLayer` widget'ı bu nesneleri arka plan ile overlay yazılar arasına
  çiziyor. Heykeldeki anahtar ve holdeki kağıt artık arka planın parçası değil, ayrı nesneler. "Anahtarlı heykel" /
  "kağıtlı hol" placeholder varyantlarını ve `statue_key_taken` / `hall_letter_taken` bayraklarını sildik.
- **Neden:** Eskiden bir nesne alınınca sahnenin ikinci bir tam görseli gerekiyordu (nesneli / nesnesiz). Bir sahnede
  iki nesne varsa dört, üç nesne varsa sekiz görsel. Gerçek görsellere geçince bu hem bütçeyi katlar hem de AI her
  üretimde resmin geri kalanını da değiştirdiği için tutarlılığı bozar. Artık tek arka plan + küçük, şeffaf arka planlı
  nesne görselleri yetiyor. Nesne, hotspot'u görünür olduğu sürece çizilir; `hideHotspot` ikisini birden kaldırır.
- **Önemli dosyalar:** `lib/features/scene_engine/domain/entities/hotspot_sprite.dart`,
  `lib/features/scene_engine/presentation/widgets/sprite_layer.dart`, `scene_visual_view.dart`, `scene_view.dart`,
  `lib/features/scene_engine/data/models/scene_dto.dart` (`SpriteDto`), `content_validator.dart`,
  `lib/core/placeholders/` (`BrassKeySpritePainter`, `LetterSpritePainter`),
  `assets/content/cases/case01/chapters/ch01/scenes.json`, `docs/adr/0012-object-layer.md`.
- **Telefonda nasıl test edilir:** Oyunu aç, heykele git: anahtar eskisi gibi kulağın arkasında parlıyor olmalı.
  Anahtara dokun: sahneden kaybolur, panele uçar. Geri dönüp tekrar gel: anahtar yok. Holde kağıt için aynısı.
  Görünüşte hiçbir şey değişmemiş olmalı; değişen, resmin nasıl kurulduğu.
- **Öğrenme notu:** Bu adım **katmanlı çizim** fikrini gösteriyor. Flutter'da `Stack` çocuklarını sırayla üst üste
  çizer; sahnemiz de böyle bir yığın: arka plan → nesneler → overlay yazılar → noir filtre → hotspot'lar → geçiş.
  Nesneleri filtrenin *altına* koymak bilinçli: gren ve vinyet nesnenin de üstünden geçtiği için nesne arka planla
  aynı fotoğrafın parçası gibi görünür. İkinci kavram **veri odaklı tasarım**: nesnenin görünüp görünmeyeceğini
  söyleyen ayrı bir kod yok; ilerlemedeki `hiddenHotspots` zaten "bu hotspot artık yok" diyor, katman da aynı
  listeyi okuyor. Tek doğruluk kaynağı olduğu için "anahtar alındı ama resimde hâlâ duruyor" hatası oluşamaz.
  `json_serializable` tarafında yeni alan = DTO'ya bir alan + `dart run build_runner build`.

### Adım 1.7 — Dedektifin iç sesi (2026-11-14)
- **Ne yaptık:** Dedektifin konuştuğu katmanı kurduk. `ChatCubit` mesaj geçmişini ilerlemeden okuyor; "şu an yeni bir
  mesaj geldi" bilgisini ise `DetectiveSaid` olayından alıyor. `ChatBar` sahnenin alt kenarında açılıyor, mesajı
  daktilo gibi harf harf yazıyor (dokununca hemen tamamlanıyor), okunacak kadar bekleyip küçük bir düğmeye çekiliyor.
  Düğmeye ya da bitmiş bara dokununca `ChatHistorySheet` açılıyor: söylenen her şey, en yenisi altta. Geri, sistem
  geri tuşu ve artık `Esc` önce bu paneli kapatıyor. Ayrıca barın kaplayabileceği alt şeridi tek bir sabit yaptık ve
  içerik doğrulama testine "hiçbir hotspot bu şeride giremez" kuralını ekledik.
- **Neden:** Oyuncuya ne olduğunu anlatan tek ses bu ("Kilitli.", "Açıldı."); ileride ipuçları da buradan gelecek.
  Barı sahnenin üstüne bindirdik çünkü 20:9 telefonda altta boş yer yok; sabit bir bar sahneyi küçültürdü. Üste binen
  bir barın tek riski bir hotspot'u kapatmasıdır; bunu "dikkat ederiz" diye değil, testle garanti ettik.
- **Önemli dosyalar:** `lib/features/detective_chat/presentation/cubit/chat_cubit.dart`,
  `.../widgets/chat_bar.dart`, `.../widgets/chat_history_sheet.dart`, `lib/app/game/scene_chat_strip.dart`,
  `lib/core/theme/scene_layout.dart`, `lib/core/di/register_detective_chat.dart`, `lib/app/game/game_hud.dart`,
  `lib/features/scene_engine/domain/services/content_validator.dart`, `test/app/game/chat_flow_test.dart`.
- **Telefonda nasıl test edilir:** Oyunu aç: altta bar açılır ve ilk cümle harf harf yazılır. Yazarken bara dokun:
  cümle hemen tamamlanır. Birkaç saniye bekle: bar sol alttaki küçük düğmeye çekilir. Kapıya git, kilide dokun:
  "Locked. Of course it is." Düğmeye dokun: geçmişte iki cümle sırayla durur; telefonun geri tuşu yalnızca geçmişi
  kapatır. Bakılacak şey: bar açıkken altında kalan, dokunamadığın bir şey var mı? (Olmamalı.) Windows'ta aynısı
  fareyle; `Esc` yakın plandan çıkarır, açık pencereyi kapatır.
- **Öğrenme notu:** Bu adımın ana fikri **kalıcı durum ile anlık olayın ayrılması**. Mesajların kendisi kalıcıdır:
  `say` etkisi onları ilerlemeye yazar, cubit oradan okur; uygulama kapanıp açılsa da geçmiş durur. "Şimdi yeni bir
  şey söylendi, daktilo efektini oynat" ise kalıcı değildir; bir olaydır (`GameEventBus`). Bunu duruma koysaydık,
  kayıttan dönünce son mesaj yeniden yazılmaya başlardı. İkinci fikir **kuralı teste çevirmek**: "bar hotspot'u
  kapatmasın" bir niyet; `SceneLayout.chatStripHeight` sabiti + doğrulama testi ise 150 sahne sonra bile kendiliğinden
  uygulanan bir kural. Üçüncü küçük ders: Flutter'da klavye olayları odaktaki widget'tan yukarı doğru akar; `Focus`
  widget'ı bu yolun üstünde durup `Esc`'yi yakalar. `Focus` varsayılan olarak erişilebilirlik ağacına da bir düğüm
  ekler; bunu kapatmayınca hotspot etiketleri o düğüme karıştı ve testler bunu hemen yakaladı.
