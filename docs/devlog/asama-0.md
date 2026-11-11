# Aşama 0 — Proje temeli (devlog)

### Adım 0.1 — Proje sağlık kontrolü, Git ve GitHub (2026-11-11)
- **Ne yaptık:** Flutter ortamını kontrol ettik (Flutter 3.44.8 / Dart 3.12.2; `flutter doctor` sadece kabul
  edilmemiş Android lisanslarını gösteriyor). Sayaç demosunu sildik, yerine boş, koyu bir ekran koyduk.
  `.gitignore`'a gizli dosya kurallarını ekledik (`env/*.json`, `*.jks`, `key.properties`, `.env`...).
  Proje adının yazımını **DetectiveDark** olarak düzelttik. Dart paketi `detective_dark`, uygulama kimliği
  `io.github.asklife23.detectivedark` oldu. Hedefimiz olmayan `linux/`, `macos/` ve `web/` klasörlerini sildik.
  README iskeletini yazdık, oyun tasarımı dokümanını `docs/game_design.md` olarak ekledik. GitHub'da public
  `asklife23/DetectiveDark` deposunu açtık.
- **Neden:** Uygulama kimliği (`applicationId` / bundle ID) mağazaya bir kez yüklendikten sonra **asla**
  değiştirilemez. Değiştirirsen mağaza onu yepyeni bir uygulama sayar, yorumlar ve indirmeler sıfırlanır.
  Bu yüzden `com.example` gibi geçici bir değerle yola çıkmadık. Kullanmadığımız platform klasörleri ise
  bakım yükü ve gereksiz analiz demek.
- **Önemli dosyalar:** `pubspec.yaml`, `android/app/build.gradle.kts`,
  `android/app/src/main/kotlin/io/github/asklife23/detectivedark/MainActivity.kt`,
  `ios/Runner.xcodeproj/project.pbxproj`, `windows/runner/Runner.rc`, `.gitignore`, `README.md`,
  `docs/game_design.md`.
- **Telefonda nasıl test edilir:** `flutter run` → uygulama siyah, boş bir ekranla açılmalı.
  Eski `com.example.dedectivedark` sürümü telefonda kuruluysa onu silebilirsin; yeni kimlik ayrı bir uygulama sayılır.
- **Öğrenme notu:** Android'de iki ayrı kimlik vardır. `applicationId`, uygulamanın mağazadaki ve telefondaki
  benzersiz adıdır. `namespace` ise Kotlin/Java kodunun paket adıdır (`R` sınıfı ve `MainActivity` burada durur).
  İkisi genelde aynı tutulur. Ters alan adı biçimi (`io.github.asklife23...`) çakışmayı önler, çünkü
  `asklife23.github.io` alan adı sadece sana aittir. Dart tarafındaki paket adı (`detective_dark`) ise
  bunlardan bağımsızdır: sadece `import 'package:detective_dark/...'` satırlarında kullanılır ve
  `snake_case` olmak zorundadır.

### Adım 0.2 — Lint, klasör yapısı ve uygulama iskeleti (2026-11-11)
- **Ne yaptık:** `flutter_lints` yerine daha sıkı olan `very_good_analysis` kuralını koyduk. Temel paketleri ekledik:
  `flutter_bloc`, `equatable`, `get_it`, `go_router`, ayrıca testler için `bloc_test` ve `mocktail`.
  Uygulamanın iskeletini kurduk: `bootstrap` (açılış sırası ve global hata yakalama), `App`
  (`MaterialApp.router`), `AppBlocObserver`, `AppLogger`, `Result<T>` (`Success` / `Failed`), `Failure` türleri ve
  DI giriş noktası (`configureDependencies`). Telefonda ekranı yataya kilitledik ve tam ekran (immersive) yaptık.
  `.gitattributes` ile satır sonlarını sabitledik.
- **Neden:** Kurallar ilk satırdan uygulanırsa sonradan toplu düzeltme gerekmez. `bootstrap` bütün giriş
  noktalarının (0.3'te dev/staging/prod, 0.6'da steam) ortak açılış kodu olacak; hata yakalayıcılar en başta
  kurulduğu için açılışta bile hiçbir hata sessizce kaybolmaz. `Result` sayesinde "başarısız olabilir" bilgisi
  fonksiyonun tipinde görünür, UI'a exception sızmaz. `.gitattributes` olmadan Windows (CRLF) ile CI'daki Linux (LF)
  aynı dosyayı farklı görür. Bu da gereksiz diff'lere ve `dart format` uyarılarına yol açar.
- **Önemli dosyalar:** `analysis_options.yaml`, `.gitattributes`, `lib/app/bootstrap.dart`, `lib/app/app.dart`,
  `lib/app/system_ui.dart`, `lib/app/router/app_router.dart`, `lib/core/error/result.dart`,
  `lib/core/error/failure.dart`, `lib/core/logging/app_logger.dart`, `lib/core/di/injection.dart`,
  `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`.
- **Telefonda nasıl test edilir:** `flutter run` → uygulama siyah, boş bir ekranla **yatay** açılmalı. Durum çubuğu ve
  gezinme çubuğu görünmemeli. Telefonu dik tutsan bile ekran yatay kalmalı. Kenardan kaydırınca çubuklar kısa süre
  görünüp kendiliğinden kaybolmalı (`immersiveSticky`).
- **Öğrenme notu:** **`sealed class`** (Dart 3), bir sınıfın alt türlerini aynı dosyayla sınırlar. Böylece derleyici
  bütün alt türleri bilir ve `switch (result) { case Success(): ... case Failed(): ... }` ifadesinde bir durumu
  unutursan derleme hatası verir. Buna "exhaustiveness checking" (kapsamlılık kontrolü) denir. `Result<T>` ve `Failure`
  bu yüzden sealed: yeni bir hata türü eklendiğinde onu ele almayan her `switch` hemen kırmızı yanar.
  Exception'lar ise fonksiyon imzasında görünmez ve kolayca unutulur. Biz exception'ları `data` katmanında
  yakalayıp `Failed(...)` olarak döndürüyoruz.
