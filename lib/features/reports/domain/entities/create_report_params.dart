import 'package:image_picker/image_picker.dart';
import 'package:equatable/equatable.dart';

class CreateReportParams extends Equatable {
  final String type; // 'lost' or 'found'
  final String title;
  final String categoryId;
  final String cityId;
  final String areaId;
  final List<XFile> images;
  final DateTime itemDate;
  final String? description;

  const CreateReportParams({
    required this.type,
    required this.title,
    required this.categoryId,
    required this.cityId,
    required this.areaId,
    required this.images,
    required this.itemDate,
    this.description,
  });

  @override
  List<Object?> get props => [
        type,
        title,
        categoryId,
        cityId,
        areaId,
        images,
        itemDate,
        description,
      ];
}
