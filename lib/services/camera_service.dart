import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;
  CameraDescription? _camera;

  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  /// 실제 선택된(스트림 중인) 카메라
  CameraDescription? get currentCamera => _camera;

  bool get isFrontCamera =>
      _camera?.lensDirection == CameraLensDirection.front;

  Future<void> initialize() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      _camera!,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();
  }

  Future<void> startStream(Function(CameraImage) onImage) async {
    if (_controller == null || !isInitialized) return;
    await _controller!.startImageStream(onImage);
  }

  Future<void> stopStream() async {
    if (_controller == null || !isInitialized) return;
    if (!_controller!.value.isStreamingImages) return;
    await _controller!.stopImageStream();
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}
