import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();

  Future<void> initialize() async {
    await _tts.setLanguage('ko-KR');
    await _tts.setSpeechRate(0.9);
    await _tts.setVolume(1.0);
  }

  Future<void> speakCount(int count) async {
    await _tts.stop();
    await _tts.speak('$count');
  }

  Future<void> speakCountdown(int second) async {
    await _tts.stop();
    await _tts.speak('$second');
  }

  Future<void> speakStart() async {
    await _tts.stop();
    await _tts.speak('운동 시작');
  }

  Future<void> dispose() async {
    await _tts.stop();
  }
}
