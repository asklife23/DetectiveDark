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
