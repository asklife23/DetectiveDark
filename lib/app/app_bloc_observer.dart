import 'package:detective_dark/core/logging/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Watches every Bloc and Cubit in the app: logs state changes at debug
/// level and errors thrown inside blocs at error level.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver(this._logger);

  final AppLogger _logger;

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    _logger.debug(
      '${bloc.runtimeType}: '
      '${change.currentState} -> ${change.nextState}',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _logger.error(
      'Error in ${bloc.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }
}
