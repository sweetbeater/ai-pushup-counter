import 'dart:math' as math;
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_pushup_counter/core/constants/exercises.dart';
import 'package:ai_pushup_counter/models/pose_landmark.dart';
import 'package:ai_pushup_counter/services/exercise_counter_service.dart';

/// 팔꿈치 각도가 [angleDeg]인 포즈 생성
PoseLandmarks poseWithElbowAngle(
  double angleDeg, {
  double leftVisibility = 0.9,
  double rightVisibility = 0.9,
}) {
  const elbow = Offset(200, 200);
  const shoulder = Offset(200, 100); // 팔꿈치 기준 위쪽
  final rad = angleDeg * math.pi / 180;
  // 어깨 벡터(0, -100)를 angleDeg만큼 회전시킨 위치에 손목 배치
  final wrist = Offset(
    elbow.dx - 100 * math.sin(rad),
    elbow.dy - 100 * math.cos(rad),
  );

  PoseLandmarkData lm(Offset p, double v) =>
      PoseLandmarkData(position: p, visibility: v);

  return PoseLandmarks(
    imageSize: const Size(720, 1280),
    leftShoulder: lm(shoulder, leftVisibility),
    leftElbow: lm(elbow, leftVisibility),
    leftWrist: lm(wrist, leftVisibility),
    rightShoulder: lm(shoulder, rightVisibility),
    rightElbow: lm(elbow, rightVisibility),
    rightWrist: lm(wrist, rightVisibility),
  );
}

void main() {
  late ExerciseCounterService counter;

  setUp(() {
    counter = ExerciseCounterService(Exercises.pushup);
  });

  void feed(double angle, int frames) {
    for (var i = 0; i < frames; i++) {
      counter.processPose(poseWithElbowAngle(angle));
    }
  }

  test('내려갔다 올라오면 1회 카운트', () {
    feed(60, 8); // down
    feed(175, 8); // up
    expect(counter.count, 1);
  });

  test('연속 반복 카운트 (최소 간격 경과 후)', () {
    feed(60, 8);
    feed(175, 8);
    expect(counter.count, 1);

    // 최소 반복 간격을 통과시키기 위해 마지막 카운트 시각을 과거로 이동
    counter.lastRepTime =
        DateTime.now().subtract(const Duration(seconds: 2));

    feed(60, 8);
    feed(175, 8);
    expect(counter.count, 2);
  });

  test('내려가지 않고 위에서만 머물면 카운트 없음', () {
    feed(175, 20);
    expect(counter.count, 0);
  });

  test('visibility 낮은 프레임은 무시', () {
    for (var i = 0; i < 8; i++) {
      counter.processPose(
        poseWithElbowAngle(60, leftVisibility: 0.2, rightVisibility: 0.2),
      );
    }
    feed(175, 8);
    expect(counter.count, 0);
  });

  test('한쪽 팔만 보여도 카운트 (측면 자세)', () {
    for (var i = 0; i < 8; i++) {
      counter.processPose(poseWithElbowAngle(60, rightVisibility: 0.1));
    }
    for (var i = 0; i < 8; i++) {
      counter.processPose(poseWithElbowAngle(175, rightVisibility: 0.1));
    }
    expect(counter.count, 1);
  });

  test('추적이 끊기면 진행 중 반복 무효화', () {
    feed(60, 8); // down 상태 진입
    // 랜드마크 유실 프레임
    for (var i = 0; i < 5; i++) {
      counter.processPose(
        poseWithElbowAngle(60, leftVisibility: 0.1, rightVisibility: 0.1),
      );
    }
    expect(counter.state, PushupState.ready);
  });
}
