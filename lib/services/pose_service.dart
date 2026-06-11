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
  ) async {
    final inputImage = _buildInputImage(image, camera);
    if (inputImage == null) return null;

    final poses = await _detector.processImage(inputImage);
    if (poses.isEmpty) return null;

    return _extractLandmarks(poses.first, image);
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

  /// 랜드마크를 원본 이미지 좌표 그대로 반환.
  /// 화면 비율로 늘리지 않아 관절 각도가 왜곡되지 않는다.
  PoseLandmarks _extractLandmarks(Pose pose, CameraImage image) {
    PoseLandmarkData? toLandmark(PoseLandmarkType type) {
      final lm = pose.landmarks[type];
      if (lm == null) return null;
      return PoseLandmarkData(
        position: Offset(lm.x, lm.y),
        visibility: lm.likelihood,
      );
    }

    return PoseLandmarks(
      imageSize: Size(image.width.toDouble(), image.height.toDouble()),
      leftShoulder: toLandmark(PoseLandmarkType.leftShoulder),
      leftElbow: toLandmark(PoseLandmarkType.leftElbow),
      leftWrist: toLandmark(PoseLandmarkType.leftWrist),
      rightShoulder: toLandmark(PoseLandmarkType.rightShoulder),
      rightElbow: toLandmark(PoseLandmarkType.rightElbow),
      rightWrist: toLandmark(PoseLandmarkType.rightWrist),
      leftHip: toLandmark(PoseLandmarkType.leftHip),
      leftKnee: toLandmark(PoseLandmarkType.leftKnee),
      leftAnkle: toLandmark(PoseLandmarkType.leftAnkle),
      rightHip: toLandmark(PoseLandmarkType.rightHip),
      rightKnee: toLandmark(PoseLandmarkType.rightKnee),
      rightAnkle: toLandmark(PoseLandmarkType.rightAnkle),
    );
  }

  Future<void> dispose() async {
    await _detector.close();
  }
}
