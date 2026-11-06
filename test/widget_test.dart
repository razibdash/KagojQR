import 'package:flutter_test/flutter_test.dart';
import 'package:kagojqr/core/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('light theme uses Material 3 and brand primary', () {
    final theme = buildLightTheme();
    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, AppColors.primary);
  });
}
