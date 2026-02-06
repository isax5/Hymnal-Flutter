import 'package:equatable/equatable.dart';

class Ambit extends Equatable {
  final String name;
  final int start;
  final int end;
  final String? backImage;

  const Ambit({
    required this.name,
    required this.start,
    required this.end,
    this.backImage,
  });

  factory Ambit.fromJson(Map<String, dynamic> json) {
    return Ambit(
      name: json['ambit'] as String,
      start: (json['star'] ?? json['start']) as int,
      end: json['end'] as int,
      backImage: json['backimage'] as String? ?? json['fondo'] as String?,
    );
  }

  @override
  List<Object?> get props => [name, start, end, backImage];
}

class ThematicCategory extends Equatable {
  final String thematic;
  final List<Ambit> ambits;

  const ThematicCategory({
    required this.thematic,
    required this.ambits,
  });

  factory ThematicCategory.fromJson(Map<String, dynamic> json) {
    return ThematicCategory(
      thematic: json['thematic'] as String,
      ambits: (json['ambits'] as List)
          .map((e) => Ambit.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [thematic, ambits];
}
