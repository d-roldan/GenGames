import 'package:flutter_test/flutter_test.dart';
import 'package:kids_game/core/updates/update_service.dart';

void main() {
  test('compares semantic version components numerically', () {
    expect(compareVersions('0.1.2', '0.1.1'), greaterThan(0));
    expect(compareVersions('0.10.0', '0.9.9'), greaterThan(0));
    expect(compareVersions('1.0', '1.0.0'), 0);
    expect(compareVersions('1.2.2', '1.2.10'), lessThan(0));
  });
}
