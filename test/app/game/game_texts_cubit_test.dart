import 'package:bloc_test/bloc_test.dart';
import 'package:detective_dark/app/game/game_texts_cubit.dart';
import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/content/content_texts.dart';
import 'package:detective_dark/core/error/failure.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_asset_bundle.dart';

void main() {
  GameTextsCubit cubit() => GameTextsCubit(
    loader: ContentTextLoader(ContentAssetSource(minimalCaseBundle())),
    caseId: 'case01',
  );

  blocTest<GameTextsCubit, GameTextsState>(
    'loads the texts of the requested language',
    build: cubit,
    act: (cubit) => cubit.load('en'),
    expect: () => [
      const GameTextsState(),
      isA<GameTextsState>().having(
        (state) => state.texts?.text('scene_yard'),
        'text',
        'Yard',
      ),
    ],
  );

  blocTest<GameTextsCubit, GameTextsState>(
    'reports a failure for a language without files',
    build: cubit,
    act: (cubit) => cubit.load('tr'),
    skip: 1,
    expect: () => [
      isA<GameTextsState>()
          .having((state) => state.texts, 'texts', isNull)
          .having((state) => state.failure, 'failure', isA<ContentFailure>()),
    ],
  );
}
