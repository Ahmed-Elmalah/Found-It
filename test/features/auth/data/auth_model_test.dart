import 'package:flutter_test/flutter_test.dart';
import 'package:found_it/features/auth/data/auth_model.dart';

void main() {
  test('fromJson reads all fields', () {
    final model = AuthModel.fromJson({
      'id': 'u1',
      'email': 'a@b.com',
      'full_name': 'Ahmed Ali',
      'phone': '+201012345678',
      'address': 'Cairo',
      'city_id': 'c1',
    });
    expect(model.id, 'u1');
    expect(model.email, 'a@b.com');
    expect(model.fullName, 'Ahmed Ali');
    expect(model.phone, '+201012345678');
    expect(model.address, 'Cairo');
    expect(model.cityId, 'c1');
    expect(model.hasCity, isTrue);
  });

  test('fromJson tolerates null city, phone and address', () {
    final model = AuthModel.fromJson({
      'id': 'u1',
      'email': 'a@b.com',
      'full_name': 'Ahmed Ali',
      'phone': null,
      'address': null,
      'city_id': null,
    });
    expect(model.phone, isNull);
    expect(model.address, isNull);
    expect(model.cityId, isNull);
    expect(model.hasCity, isFalse);
  });

  test('fromJson turns a null full_name into an empty string', () {
    final model = AuthModel.fromJson({
      'id': 'u1',
      'email': 'a@b.com',
      'full_name': null,
    });
    expect(model.fullName, '');
  });
}
