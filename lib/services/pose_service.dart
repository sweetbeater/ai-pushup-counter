import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/widgets.dart';
import '../models/pose_landmark.dart';

class PoseService {
  final PoseDetector _detector = PoseDetector(
    options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
  );

  Future<PoseLandmarks?> processImage(
    CameraImage image,
    CameraDescription camera,
    Size screenSize,
  ) async {
    final inputImage = _buildInputImage(image, camera);
    if (inputImage == null) return null;

    final poses = await _detector.processImage(inputImage);
    if (poses.isEmpty) return null;

    final pose = poses.first;
    return _extractLandmarks(pose, image, screenSize);
  }

  InputImage? _buildInputImage(CameraImage image, CameraDescription camera) {
    final rotation = InputImageRotationValue.fromRawValue(
      camera.sensorOrientation,
    );
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  PoseLandmarks _extractLandmarks(
    Pose pose,
    CameraImage image,
    Size screenSize,
  ) {
    PoseLandmarkData? toLandmark(PoseLandmarkType type) {
      final lm = pose.landmarks[type];
      if (lm == null) return null;
      return PoseLandmarkData(
        position: Offset(
          lm.x / image.width * screenSize.width,
          lm.y / image.height * screenSize.height,
        ),
        visibility: lm.likelihood,
      );
    }

    return PoseLandmarks(
      leftShoulder: toLandmark(PoseLandmarkType.leftShoulder),
      leftElbow: toLandmark(PoseLandmarkType.leftElbow),
      leftWrist: toLandmark(PoseLandmarkType.leftWrist),
      rightShoulder: toLandmark(PoseLandmarkType.rightShoulder),
      rightElbow: toLandmark(PoseLandmarkType.rightElbow),
      rightWrist: toLandmark(PoseLandmarkType.rightWrist),
    );
  }

  Future<void> dispose() async {
    await _detector.close();
  }
}
