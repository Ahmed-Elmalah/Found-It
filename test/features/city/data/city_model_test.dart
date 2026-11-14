import 'package:flutter_test/flutter_test.dart';
import 'package:found_it/features/city/data/city_model.dart';
import 'package:found_it/features/city/domain/city_entity.dart';

void main() {
  group('CityModel', () {
    const json = {
      'id': 'c1',
      'name_en': 'Cairo',
      'name_ar': 'القاهرة',
      'sort_order': 1,
    };

    test('fromJson creates a valid CityModel', () {
      final model = CityModel.fromJson(json);

      expect(model, isA<CityEntity>());
      expect(model.id, 'c1');
      expect(model.nameEn, 'Cairo');
      expect(model.nameAr, 'القاهرة');
      expect(model.sortOrder, 1);
    });

    test('toJson produces expected map', () {
      final model = CityModel.fromJson(json);
      final mapped = model.toJson();

      expect(mapped, json);
    });

    test('handles missing or null sort_order gracefully', () {
      final model = CityModel.fromJson({
        'id': 'c2',
        'name_en': 'Giza',
        'name_ar': 'الجيزة',
      });

      expect(model.sortOrder, 0);
    });
  });
}
