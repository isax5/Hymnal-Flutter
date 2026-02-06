import 'package:equatable/equatable.dart';

class HymnHistoryEntry extends Equatable {
  final String hymnalId;
  final int hymnNumber;
  final String title;
  final DateTime openedAt;

  const HymnHistoryEntry({
    required this.hymnalId,
    required this.hymnNumber,
    required this.title,
    required this.openedAt,
  });

  factory HymnHistoryEntry.fromJson(Map<String, dynamic> json) {
    return HymnHistoryEntry(
      hymnalId: json['hymnalId'] as String,
      hymnNumber: json['hymnNumber'] as int,
      title: json['title'] as String,
      openedAt: DateTime.parse(json['openedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hymnalId': hymnalId,
      'hymnNumber': hymnNumber,
      'title': title,
      'openedAt': openedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [hymnalId, hymnNumber, title, openedAt];
}
