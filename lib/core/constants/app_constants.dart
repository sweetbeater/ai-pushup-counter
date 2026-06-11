class AppConstants {
  static const int countdownSeconds = 3;
  static const double downAngleThreshold = 100.0;
  static const double upAngleThreshold = 155.0;
  static const double visibilityThreshold = 0.5;
  // 빠른 페이스(약 1회/초)도 놓치지 않도록 500ms
  static const int minRepIntervalMs = 500;
  static const int maxMissingFrames = 3;
  // 노이즈로 인한 순간 스파이크 방지: 상태 전환에 필요한 연속 프레임 수
  static const int stateConfirmFrames = 2;
}
