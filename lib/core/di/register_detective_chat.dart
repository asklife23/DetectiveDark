import 'package:detective_dark/core/events/game_event_bus.dart';
import 'package:detective_dark/features/detective_chat/presentation/cubit/chat_cubit.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:get_it/get_it.dart';

/// Detective chat: only a cubit. The messages themselves are part of the
/// progress, so this feature needs no repository of its own.
void registerDetectiveChat(GetIt getIt) {
  getIt.registerFactory<ChatCubit>(
    () => ChatCubit(
      progressRepository: getIt<ProgressRepository>(),
      eventBus: getIt<GameEventBus>(),
    ),
  );
}
