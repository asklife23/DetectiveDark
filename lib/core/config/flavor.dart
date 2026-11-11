/// The environment the app runs in.
///
/// - [dev]: daily development; debug tools on, staging backend.
/// - [staging]: release-like test builds; staging backend.
/// - [prod]: real players; production backend.
///
/// The names match the Android `productFlavors`, so `Flavor.dev.name` equals
/// the value passed to `flutter run --flavor dev`.
enum Flavor { dev, staging, prod }
