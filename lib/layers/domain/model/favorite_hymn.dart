import 'package:equatable/equatable.dart';

class FavoriteHymn extends Equatable {
  final String hymnalId;
  final int hymnNumber;
  final String title;
  final DateTime addedAt;
  final int? orderIndex;

  const FavoriteHymn({
    required this.hymnalId,
    required this.hymnNumber,
    required this.title,
    required this.addedAt,
    this.orderIndex,
  });

  factory FavoriteHymn.fromJson(Map<String, dynamic> json) {
    return FavoriteHymn(
      hymnalId: json['hymnalId'] as String,
      hymnNumber: json['hymnNumber'] as int,
      title: json['title'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
      orderIndex: json['orderIndex'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hymnalId': hymnalId,
      'hymnNumber': hymnNumber,
      'title': title,
      'addedAt': addedAt.toIso8601String(),
      'orderIndex': orderIndex,
    };
  }

  @override
  List<Object?> get props => [hymnalId, hymnNumber, title, addedAt, orderIndex];
}
