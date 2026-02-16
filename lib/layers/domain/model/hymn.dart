import 'package:equatable/equatable.dart';
import 'package:hymnal_app/core/utils/string_utils.dart';

class Hymn extends Equatable {
  final int number;
  final String title;
  final String content;
  final String normalizedTitle;
  final String normalizedContent;

  const Hymn({
    required this.number,
    required this.title,
    required this.content,
    required this.normalizedTitle,
    required this.normalizedContent,
  });

  factory Hymn.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String;
    final content = json['content'] as String;
    return Hymn(
      number: json['number'] as int,
      title: title,
      content: content,
      normalizedTitle: StringUtils.normalize(title),
      normalizedContent: StringUtils.normalize(content),
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
  List<Object?> get props => [
        number,
        title,
        content,
        normalizedTitle,
        normalizedContent,
      ];
}
