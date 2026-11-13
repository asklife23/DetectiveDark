import 'package:detective_dark/core/content/content_texts.dart';
import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/core/error/result.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The story texts of the running game: still loading (both fields null),
/// loaded ([texts]) or failed ([failure]).
class GameTextsState extends Equatable {
  const GameTextsState({this.texts, this.failure});

  final ContentTexts? texts;
  final Failure? failure;

  @override
  List<Object?> get props => [texts, failure];
}

/// Loads the story texts for the language the app runs in.
class GameTextsCubit extends Cubit<GameTextsState> {
  GameTextsCubit({required this._loader, required this._caseId})
    : super(const GameTextsState());

  final ContentTextLoader _loader;
  final String _caseId;

  Future<void> load(String languageCode) async {
    emit(const GameTextsState());
    final result = await _loader.load(_caseId, languageCode);
    if (isClosed) return;
    emit(switch (result) {
      Success(:final value) => GameTextsState(texts: value),
      Failed(:final failure) => GameTextsState(failure: failure),
    });
  }
}
