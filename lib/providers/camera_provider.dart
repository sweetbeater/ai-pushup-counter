import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/camera_service.dart';

final cameraServiceProvider = Provider<CameraService>((ref) {
  final service = CameraService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// 운동 화면 진입마다 컨트롤러를 새로 만들고, 나가면 완전히 해제한다.
/// iOS에서 같은 컨트롤러로 이미지 스트림을 재시작하면 프레임이 오지 않아
/// 두 번째 운동부터 추적이 안 되던 버그의 원인이었음.
final cameraInitProvider = FutureProvider.autoDispose<void>((ref) async {
  final service = ref.watch(cameraServiceProvider);
  await service.initialize();
  ref.onDispose(() => service.dispose());
});
