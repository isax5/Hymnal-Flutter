import 'package:equatable/equatable.dart';

class MusicSettings extends Equatable {
  final String id;
  final String isoLanguage;
  final String? instrumentalMusicUrl;
  final String? sungMusicUrl;

  const MusicSettings({
    required this.id,
    required this.isoLanguage,
    this.instrumentalMusicUrl,
    this.sungMusicUrl,
  });

  factory MusicSettings.fromJson(Map<String, dynamic> json) {
    return MusicSettings(
      id: (json['id'] ?? json['Id']) as String,
      isoLanguage: json['ISOLanguage'] as String,
      instrumentalMusicUrl:
          (json['instrumentalMusicUrl'] ?? json['InstrumentalMusicUrl']) as String?,
      sungMusicUrl: (json['sungMusicUrl'] ?? json['SungMusicUrl']) as String?,
    );
  }

  String? getInstrumentalUrl(int hymnNumber) {
    if (instrumentalMusicUrl == null) return null;
    return instrumentalMusicUrl!.replaceAll(
      '###',
      hymnNumber.toString().padLeft(3, '0'),
    );
  }

  String? getSungUrl(int hymnNumber) {
    if (sungMusicUrl == null) return null;
    return sungMusicUrl!.replaceAll(
      '###',
      hymnNumber.toString().padLeft(3, '0'),
    );
  }

  @override
  List<Object?> get props => [id, isoLanguage, instrumentalMusicUrl, sungMusicUrl];
}
