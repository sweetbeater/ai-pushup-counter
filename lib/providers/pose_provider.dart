import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pose_landmark.dart';
import '../services/pose_service.dart';

final poseServiceProvider = Provider<PoseService>((ref) {
  final service = PoseService();
  ref.onDispose(() => service.dispose());
  return service;
});

final poseLandmarksProvider =
    StateProvider<PoseLandmarks?>((ref) => null);
