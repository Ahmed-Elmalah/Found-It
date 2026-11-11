import 'package:flutter_test/flutter_test.dart';
import 'package:found_it/core/constants/storage_keys.dart';
import 'package:found_it/features/onboarding/data/onboarding_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<OnboardingLocalDataSourceImpl> _build(
  Map<String, Object> initial,
) async {
  SharedPreferences.setMockInitialValues(initial);
  return OnboardingLocalDataSourceImpl(await SharedPreferences.getInstance());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('first launch is true when nothing stored', () async {
    final ds = await _build({});
    expect(ds.isFirstLaunch(), isTrue);
  });

  test('setOnboardingCompleted makes first launch false', () async {
    final ds = await _build({});
    await ds.setOnboardingCompleted();
    expect(ds.isFirstLaunch(), isFalse);
  });

  test('first launch is false when stored value is false', () async {
    final ds = await _build({StorageKeys.isFirstLaunch: false});
    expect(ds.isFirstLaunch(), isFalse);
  });
}
