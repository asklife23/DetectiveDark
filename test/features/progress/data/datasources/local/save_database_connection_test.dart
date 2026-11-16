import 'package:detective_dark/core/config/flavor.dart';
import 'package:detective_dark/features/progress/data/datasources/local/save_database_connection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('real players get the plain file name', () {
    expect(saveDatabaseName(Flavor.prod), 'detective_dark');
  });

  test('test flavors never share a file with a real playthrough', () {
    expect(saveDatabaseName(Flavor.dev), 'detective_dark_dev');
    expect(saveDatabaseName(Flavor.staging), 'detective_dark_staging');
    expect(
      {for (final flavor in Flavor.values) saveDatabaseName(flavor)},
      hasLength(Flavor.values.length),
    );
  });
}
