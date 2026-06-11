import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';

/// 실제 코치처럼 말하는 TTS.
/// - 고유어 숫자로 카운팅 (하나, 둘, 셋...)
/// - 구간별 격려 멘트
/// - 목표 임박/달성 안내
class TtsService {
  final FlutterTts _tts = FlutterTts();
  final Random _random = Random();

  static const _ones = [
    '', '하나', '둘', '셋', '넷', '다섯', '여섯', '일곱', '여덟', '아홉',
  ];
  static const _tens = [
    '', '열', '스물', '서른', '마흔', '쉰', '예순', '일흔', '여든', '아흔',
  ];

  static const _cheers = [
    '좋아요!',
    '잘하고 있어요!',
    '아주 좋습니다!',
    '자세 좋아요!',
    '그 페이스 유지하세요!',
  ];

  Future<void> initialize() async {
    await _tts.setLanguage('ko-KR');
    // iOS에서 0.5가 자연스러운 기본 속도. 0.9는 알아듣기 힘들 정도로 빠름.
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.05);
  }

  /// 1~99는 고유어 숫자(하나, 둘...), 그 이상은 숫자 그대로
  String _koreanCount(int n) {
    if (n < 1 || n > 99) return '$n';
    return '${_tens[n ~/ 10]}${_ones[n % 10]}';
  }

  Future<void> speakCount(int count, {int? goal}) async {
    var phrase = _koreanCount(count);

    if (goal != null && goal - count == 3 && count > 0) {
      phrase += ', 세 개 남았어요!';
    } else if (goal != null && goal - count == 1) {
      phrase += ', 마지막 하나!';
    } else if (count % 10 == 0 && count > 0) {
      phrase += ', ${_cheers[_random.nextInt(_cheers.length)]}';
    }

    await _tts.stop();
    await _tts.speak(phrase);
  }

  Future<void> speakCountdown(int second) async {
    await _tts.stop();
    await _tts.speak('$second');
  }

  Future<void> speakStart() async {
    await _tts.stop();
    await _tts.speak('시작! 화이팅!');
  }

  Future<void> speakGoalReached(int goal) async {
    await _tts.stop();
    await _tts.speak('목표 달성! ${_koreanCount(goal)} 개 완료! 정말 수고했어요!');
  }

  Future<void> speakFinish(int count, {bool isNewRecord = false}) async {
    await _tts.stop();
    if (count == 0) return;
    final record = isNewRecord ? ' 신기록입니다!' : '';
    await _tts.speak('수고하셨습니다! 총 ${_koreanCount(count)} 개 완료!$record');
  }

  Future<void> dispose() async {
    await _tts.stop();
  }
}
