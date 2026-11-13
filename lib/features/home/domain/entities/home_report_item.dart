import 'package:equatable/equatable.dart';

enum HomeFilterType {
  all,
  lost,
  found,
}

/// A lightweight domain entity representing a report card in the Home feed.
class HomeReportItem extends Equatable {
  const HomeReportItem({
    required this.id,
    required this.refCode,
    required this.title,
    this.description,
    required this.type,
    required this.categoryName,
    required this.categoryIcon,
    required this.areaName,
    required this.cityName,
    required this.itemDate,
    required this.images,
    required this.status,
    required this.isMine,
    required this.createdAt,
  });

  final String id;
  final String refCode;
  final String title;
  final String? description;
  final String type; // 'lost' or 'found'
  final String categoryName;
  final String categoryIcon;
  final String areaName;
  final String cityName;
  final DateTime itemDate;
  final List<String> images;
  final String status;
  final bool isMine;
  final DateTime createdAt;

  bool get isLost => type.toLowerCase() == 'lost';
  bool get isFound => type.toLowerCase() == 'found';
  bool get hasImages => images.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        refCode,
        title,
        description,
        type,
        categoryName,
        categoryIcon,
        areaName,
        cityName,
        itemDate,
        images,
        status,
        isMine,
        createdAt,
      ];
}
