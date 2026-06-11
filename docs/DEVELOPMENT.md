# AI Push-up Counter - 개발 문서

## 현재 MVP 상태

### 완성된 기능
- 실시간 카메라 포즈 인식 (google_mlkit_pose_detection)
- 팔굽혀펴기 자동 카운팅 (한쪽 팔만 보여도 인식 — 측면 자세 대응)
- 코치 스타일 음성 카운팅 (고유어 숫자 "하나, 둘", 격려 멘트, 목표 안내)
- 목표 횟수 설정 (10/20/30/50/무제한) + 목표 달성 시 자동 종료
- 홈 화면 통계 (누적/이번 주/최고 기록)
- 신기록 감지 및 결과 화면 표시
- 운동 기록 저장 (shared_preferences)
- 결과 화면 (횟수, 시간, 날짜, 신기록 배지)
- 기록 히스토리 화면 (운동명 포함 카드형)
- **확장 가능한 운동 설정 구조**
- 미니멀 다크 디자인 시스템 (`core/theme/app_theme.dart`)

### 알려진 이슈 / 개선 필요
- 앱 아이콘/런치 이미지 기본값 (교체 필요)
- 카메라 측면 권장 (정면도 동작하지만 측면이 가장 정확)

---

## 기술 스택

| 항목 | 기술 |
|------|------|
| Framework | Flutter (stable) |
| 상태관리 | Riverpod |
| 포즈 인식 | google_mlkit_pose_detection |
| 음성 | flutter_tts |
| 로컬 저장 | shared_preferences |
| CI/CD | Codemagic (iOS Ad Hoc / App Store) |

---

## 아키텍처

```
Presentation (screens/)
      ↓
Providers (providers/)
      ↓
Services (services/)
      ↓
Models / Utils (models/, core/)
```

---

## 폴더 구조

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── app_constants.dart      # 각도 임계값, 타이밍 상수
│   │   └── exercises.dart          # ★ 운동 목록 (여기에 추가)
│   ├── theme/
│   │   └── app_theme.dart          # 디자인 시스템 (색상, 테마, 숫자 스타일)
│   └── utils/
│       ├── angle_calculator.dart   # 관절 각도 계산 (0~180°)
│       └── pose_smoothing.dart     # One Euro Filter 스무딩
├── models/
│   ├── exercise_config.dart        # ★ 운동 설정 모델
│   ├── exercise_record.dart        # 운동 기록 모델
│   └── pose_landmark.dart          # 랜드마크 데이터 (팔+다리)
├── services/
│   ├── camera_service.dart         # 카메라 초기화/스트림
│   ├── pose_service.dart           # ML Kit 포즈 감지
│   ├── exercise_counter_service.dart # ★ 범용 카운터 (ExerciseConfig 기반)
│   ├── tts_service.dart            # 음성 출력
│   └── storage_service.dart        # 기록 저장/조회
├── providers/
│   ├── camera_provider.dart
│   ├── pose_provider.dart
│   └── workout_provider.dart       # WorkoutStatus, WorkoutNotifier
└── screens/
    ├── home/home_screen.dart
    ├── workout/workout_screen.dart
    ├── result/result_screen.dart
    └── history/history_screen.dart
```

---

## 새 운동 추가 방법

`lib/core/constants/exercises.dart` 파일에 아래 형식으로 추가하면 끝입니다.

```dart
static const squat = ExerciseConfig(
  id: 'squat',
  name: '스쿼트',
  downThreshold: 100,   // 이 각도 이하 = 내려간 상태
  upThreshold: 160,     // 이 각도 이상 = 올라온 상태
  jointGroup: JointGroup.legs,  // 팔: arms, 다리: legs
);
```

### JointGroup 종류

| JointGroup | 사용 관절 | 적합한 동작 |
|---|---|---|
| `arms` | 어깨→팔꿈치→손목 | 팔굽혀펴기, 풀업, 덤벨컬 |
| `legs` | 엉덩이→무릎→발목 | 스쿼트, 런지 |

### 각도 임계값 가이드

| 동작 | downThreshold | upThreshold |
|---|---|---|
| 팔굽혀펴기 | 100 | 155 |
| 스쿼트 | 100 | 155 |
| 풀업 | 80 | 160 |

---

## 카운팅 알고리즘

```
카메라 프레임
    ↓
ML Kit 포즈 감지 (accurate 모델, 원본 이미지 좌표 그대로 사용 — 화면 스케일링에 의한 각도 왜곡 없음)
    ↓
좌우 각각 visibility 검사 → 신뢰도 충분한 쪽만 사용
  (양쪽 OK → 평균, 한쪽만 OK → 그쪽만, 둘 다 NG → 유실 프레임)
    ↓
각도 계산: calculateAngle(shoulder, elbow, wrist) — z축 포함 3D 각도 (기울어진 자세 대응)
    ↓
One Euro Filter 스무딩 (정지 시 떨림 억제 + 빠른 동작 즉시 추종)
    ↓
상태 머신 (전환에 2연속 프레임 확인 필요 — 노이즈 스파이크 방지)
  ready/up → angle ≤ downThreshold → down 상태
  down → angle ≥ upThreshold → up 상태 + count++
    ↓
TTS 음성 출력 + UI 업데이트
```

### 오인식 방지 조건
- visibility > 0.5 (관절 신뢰도, 좌우 개별 적용)
- 최소 반복 간격 500ms (빠른 페이스 대응)
- 상태 전환에 2연속 프레임 확인 필요
- 3프레임 이상 랜드마크 유실 시 진행 중 반복 무효화 (down → ready)
- DOWN → UP 전체 통과 필수 (중간 점프 방지)

---

## 빌드 및 배포

### 여기서 빌드 트리거
- **테스트 빌드**: "빌드해" → ios-adhoc workflow
- **앱스토어 빌드**: "앱스토어 빌드해" → ios-appstore workflow

### Codemagic 설정
- API 토큰: 환경변수 `CODEMAGIC_API_TOKEN`
- App ID: `6a26e031bd967822635efc1b`
- Bundle ID: `com.aicoach.aiPushupCounter`

### 코드사이닝
- 인증서: `AI_Pushup_Distribution` (Distribution)
- 프로파일: `AI_Pushup_Counter_AdHoc` (Ad Hoc)
- App Store Connect API Key: `Codemagic`

---

## 향후 로드맵

- [ ] 다양한 운동 지원 (스쿼트, 풀업 등)
- [ ] 운동 선택 UI
- [ ] 챌린지 시스템
- [ ] 랭킹 시스템
- [ ] 운동 통계/그래프
- [ ] 사용자 계정
- [ ] 앱 아이콘/런치 이미지 교체
