import 'package:equatable/equatable.dart';

class Hymn extends Equatable {
  final int number;
  final String title;
  final String content;

  const Hymn({
    required this.number,
    required this.title,
    required this.content,
  });

  factory Hymn.fromJson(Map<String, dynamic> json) {
    return Hymn(
      number: json['number'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'title': title,
      'content': content,
    };
  }

  @override
  List<Object?> get props => [number, title, content];
}
