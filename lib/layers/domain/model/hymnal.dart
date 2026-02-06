import 'package:equatable/equatable.dart';

class Hymnal extends Equatable {
  final String id;
  final String name;
  final String detail;
  final int year;
  final String twoLetterIsoLanguageName;
  final String hymnsFileName;
  final String thematicHymnsFileName;
  final String? hymnsSheetsFileName;

  const Hymnal({
    required this.id,
    required this.name,
    required this.detail,
    required this.year,
    required this.twoLetterIsoLanguageName,
    required this.hymnsFileName,
    required this.thematicHymnsFileName,
    this.hymnsSheetsFileName,
  });

  factory Hymnal.fromJson(Map<String, dynamic> json) {
    return Hymnal(
      id: json['Id'] as String,
      name: json['name'] as String,
      detail: json['Detail'] as String,
      year: json['year'] as int,
      twoLetterIsoLanguageName: json['twoLetterIsoLanguageName'] as String,
      hymnsFileName: json['hymnsFileName'] as String,
      thematicHymnsFileName: json['thematicHymnsFileName'] as String,
      hymnsSheetsFileName: json['hymnsSheetsFileName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'name': name,
      'Detail': detail,
      'year': year,
      'twoLetterIsoLanguageName': twoLetterIsoLanguageName,
      'hymnsFileName': hymnsFileName,
      'thematicHymnsFileName': thematicHymnsFileName,
      'hymnsSheetsFileName': hymnsSheetsFileName,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        detail,
        year,
        twoLetterIsoLanguageName,
        hymnsFileName,
        thematicHymnsFileName,
        hymnsSheetsFileName,
      ];
}
