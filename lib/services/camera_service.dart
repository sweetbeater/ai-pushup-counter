import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];

  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  Future<void> initialize() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;

    final camera = _cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras.first,
    );

    _controller = CameraController(
      camera,
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
    await _controller!.stopImageStream();
  }

  CameraDescription? get currentCamera =>
      _cameras.isNotEmpty ? _cameras.first : null;

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}
