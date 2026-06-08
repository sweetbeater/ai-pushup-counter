import '../../models/exercise_config.dart';

// 새 동작 추가 시 여기에만 추가하면 됩니다.
class Exercises {
  static const pushup = ExerciseConfig(
    id: 'pushup',
    name: '팔굽혀펴기',
    downThreshold: 100,
    upThreshold: 160,
    jointGroup: JointGroup.arms,
  );

  static const squat = ExerciseConfig(
    id: 'squat',
    name: '스쿼트',
    downThreshold: 100,
    upThreshold: 160,
    jointGroup: JointGroup.legs,
  );

  static const pullup = ExerciseConfig(
    id: 'pullup',
    name: '풀업',
    downThreshold: 80,
    upThreshold: 160,
    jointGroup: JointGroup.arms,
  );

  static const all = [pushup, squat, pullup];
}
