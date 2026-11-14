import 'package:flutter_test/flutter_test.dart';
import 'package:found_it/features/home/data/models/home_report_model.dart';
import 'package:found_it/features/home/domain/entities/home_report_item.dart';

void main() {
  group('HomeReportModel', () {
    final tJson = {
      'id': 'rep-123',
      'ref_code': 'RPT-999',
      'title': 'Gold Ring',
      'description': 'Found in park',
      'type': 'found',
      'category_id': 'cat-1',
      'category_name_en': 'Jewelry',
      'category_name_ar': 'مجوهرات',
      'category_icon': 'diamond',
      'city_id': 'city-cairo',
      'city_name_en': 'Cairo',
      'city_name_ar': 'القاهرة',
      'area_id': 'area-nasr',
      'area_name_en': 'Nasr City',
      'area_name_ar': 'مدينة نصر',
      'item_date': '2026-11-10T12:00:00Z',
      'images': ['https://example.com/ring.jpg'],
      'status': 'active',
      'is_mine': true,
      'created_at': '2026-11-10T14:00:00Z',
    };

    test('should be a subclass of HomeReportItem', () {
      final model = HomeReportModel.fromJson(tJson);
      expect(model, isA<HomeReportItem>());
    });

    test('fromJson parses all fields correctly', () {
      final model = HomeReportModel.fromJson(tJson);

      expect(model.id, 'rep-123');
      expect(model.refCode, 'RPT-999');
      expect(model.title, 'Gold Ring');
      expect(model.description, 'Found in park');
      expect(model.type, 'found');
      expect(model.isFound, isTrue);
      expect(model.isLost, isFalse);
      expect(model.categoryNameEn, 'Jewelry');
      expect(model.categoryNameAr, 'مجوهرات');
      expect(model.categoryIcon, 'diamond');
      expect(model.cityNameEn, 'Cairo');
      expect(model.cityNameAr, 'القاهرة');
      expect(model.areaNameEn, 'Nasr City');
      expect(model.areaNameAr, 'مدينة نصر');
      expect(model.images, ['https://example.com/ring.jpg']);
      expect(model.status, 'active');
      expect(model.isMine, isTrue);
      expect(model.hasImages, isTrue);
    });

    test('localized getters return corresponding locale strings', () {
      final model = HomeReportModel.fromJson(tJson);

      expect(model.localizedCategory('ar'), 'مجوهرات');
      expect(model.localizedCategory('en'), 'Jewelry');
      expect(model.localizedCity('ar'), 'القاهرة');
      expect(model.localizedCity('en'), 'Cairo');
      expect(model.localizedArea('ar'), 'مدينة نصر');
      expect(model.localizedArea('en'), 'Nasr City');
    });

    test('toJson produces expected map', () {
      final model = HomeReportModel.fromJson(tJson);
      final json = model.toJson();

      expect(json['id'], 'rep-123');
      expect(json['ref_code'], 'RPT-999');
      expect(json['title'], 'Gold Ring');
      expect(json['type'], 'found');
      expect(json['status'], 'active');
    });
  });
}
