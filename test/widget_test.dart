// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hymnal_app/main.dart';
import 'package:hymnal_app/services/locator_service.dart';
import 'package:hymnal_app/services/audio_service.dart' as app_audio;
import 'package:audio_service/audio_service.dart';
import 'package:hymnal_app/services/audio_handler.dart';

class MockAudioService extends app_audio.AudioService {
  MockAudioService() : super.test();

  @override
  bool get hasAudio => false;
}

void main() {
  setUp(() {
    getIt.reset();
    setupLocator();
    // Register mock services for widget testing
    getIt.registerSingleton<AudioHandler>(MyAudioHandler());
    getIt.unregister<app_audio.AudioService>();
    getIt.registerSingleton<app_audio.AudioService>(MockAudioService());
  });

  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const HymnalApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
