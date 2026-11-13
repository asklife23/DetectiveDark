import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/content/content_texts.dart';
import 'package:detective_dark/core/events/game_event_bus.dart';
import 'package:detective_dark/core/time/clock.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

/// Shared infrastructure: content files, story texts, events and time.
void registerCore(GetIt getIt, {required AssetBundle assetBundle}) {
  getIt
    ..registerSingleton<Clock>(const SystemClock())
    ..registerSingleton<GameEventBus>(
      GameEventBus(),
      dispose: (bus) => bus.dispose(),
    )
    ..registerSingleton<ContentAssetSource>(ContentAssetSource(assetBundle))
    ..registerLazySingleton<ContentTextLoader>(
      () => ContentTextLoader(getIt<ContentAssetSource>()),
    );
}
