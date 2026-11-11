/// What the app is built for. DI uses it to pick the platform services
/// (ADR 0009); game code never checks the platform itself.
///
/// - [mobile]: Play Store / App Store builds. Supabase account and cloud
///   save, store purchases.
/// - [steam]: the Windows build sold on Steam. Steam ownership and
///   Steam Cloud; no Supabase account.
///
/// The mobile entry points also run on Windows for quick testing during
/// development; that is still the [mobile] target.
enum BuildTarget { mobile, steam }
