# AI Push-up Counter - 개발 문서

## 현재 MVP 상태

### 완성된 기능
- 실시간 카메라 포즈 인식 (google_mlkit_pose_detection)
- 팔굽혀펴기 자동 카운팅
- 음성 카운팅 (TTS)
- 운동 기록 저장 (shared_preferences)
- 결과 화면 (횟수, 시간, 날짜)
- 기록 히스토리 화면
- **확장 가능한 운동 설정 구조**

### 알려진 이슈 / 개선 필요
- 앱 아이콘/런치 이미지 기본값 (교체 필요)
- 카메라 측면 권장 (정면 인식률 낮음)

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
│   └── utils/
│       ├── angle_calculator.dart   # 관절 각도 계산 (0~180°)
│       └── pose_smoothing.dart     # 5프레임 이동평균 스무딩
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
| 팔굽혀펴기 | 100 | 160 |
| 스쿼트 | 100 | 160 |
| 풀업 | 80 | 160 |

---

## 카운팅 알고리즘

```
카메라 프레임
    ↓
ML Kit 포즈 감지 (좌우 관절 좌표 추출)
    ↓
각도 계산: calculateAngle(shoulder, elbow, wrist)
    ↓
5프레임 이동평균 스무딩
    ↓
상태 머신
  ready/up → angle ≤ downThreshold → down 상태
  down → angle ≥ upThreshold → up 상태 + count++
    ↓
TTS 음성 출력 + UI 업데이트
```

### 오인식 방지 조건
- visibility > 0.5 (관절 신뢰도)
- 최소 반복 간격 800ms
- 3프레임 이상 랜드마크 유실 시 카운트 중단
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
