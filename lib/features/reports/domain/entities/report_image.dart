import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class ReportImage extends Equatable {
  final String name;
  final Uint8List bytes;

  const ReportImage({
    required this.name,
    required this.bytes,
  });

  @override
  List<Object?> get props => [name, bytes];
}
