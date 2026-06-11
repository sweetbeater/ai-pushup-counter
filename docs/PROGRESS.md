# 진행상황 문서

> 세션별 작업 기록. 최신 항목이 위에 오도록 추가한다.

---

## 2026-06-11 (2차) — 재진입 추적 버그 수정 · 포즈 추정 고도화 · 액체 유리 디자인 · 아이콘/런치 교체

### 검증 상태
- `flutter analyze`: 0건 / 테스트 7개 전부 통과
- 디자인 v2 빌드: ✅ 성공 — buildId `6a2a0f916b6a810c816fcffa`, ipa 26MB
- **이번 작업분은 아직 커밋/빌드 전**

### 1. 치명 버그 수정: 두 번째 운동부터 추적 안 됨
- 원인: `cameraInitProvider`가 영구 캐시라 재진입 시 이전 `CameraController` 재사용
  → iOS에서 같은 컨트롤러로 `stopImageStream` 후 `startImageStream` 재호출 시 프레임 미수신
- 수정: `FutureProvider.autoDispose`로 전환 — 화면 진입마다 컨트롤러 새로 생성, 이탈 시 완전 해제
- `CameraService.initialize()`에 기존 컨트롤러 해제 가드 추가, 재진입 시 잔여 랜드마크 제거

### 2. 포즈 추정 고도화
- ML Kit **accurate 모델** 전환 (BlazePose 고정밀, MoveNet Thunder급)
- **3D 관절 각도**: 랜드마크 z축 포함 — 몸이 카메라와 기울어져도 각도 안정
- 스무딩을 5프레임 이동평균 → **One Euro Filter**로 교체 (빠른 페이스 지연 제거)
- **카메라 가이드 오버레이** (`pose_guide_overlay.dart`): 시작 전 코너 브래킷 프레임 +
  전신 인식 상태 실시간 피드백 ("전신 인식 완료" / "전신이 보이게 기기를 두세요")
- FSM·visibility 게이팅·2프레임 확인은 기존 구현 유지 (중복 추가 안 함)

### 3. 액체 유리(Liquid Glass) 디자인
- `LiquidGlass` 공용 위젯: BackdropFilter 블러 + 좌상단 광원 그라데이션 엣지 + 유리 투과광 그라데이션
- `AmbientBackground`: 배경 컬러 블롭(오렌지/블루) — 유리 뒤에서 굴절될 빛
- 적용: 홈(히어로 카드, 스탯 타일) / 결과(정보 카드) / 기록(요약 카드, 레코드 카드)
- `AppTheme.cardDecoration` 제거 (전부 LiquidGlass로 대체)

### 4. 앱 아이콘 + 런치 이미지
- 진행 링 모티프 아이콘 생성 (`tool/generate_icon.ps1`, GDI+): 다크 그라데이션 배경 +
  시그널 오렌지 270° 아크 + 글로우
- `flutter_launcher_icons`로 iOS 아이콘 세트 생성 (`assets/icon/app_icon.png` 원본)
- LaunchScreen.storyboard 배경 `#0A0B0D` + LaunchImage 1x/2x/3x 링 글리프로 교체

### 다음 할 일
- [ ] 커밋 + ios-adhoc 빌드 ("빌드해")
- [ ] 실기기 검증: 재진입 추적, accurate 모델 프레임레이트, 가이드 오버레이
- [ ] 액체 유리 질감 실기기 확인 (블러 강도/블롭 밝기 조정 여지)

---

## 2026-06-11 — 인식률 개선 · 버그 수정 · 디자인 v2 · 코치형 TTS · 기능 추가

### 검증 상태
- `flutter analyze`: 0건
- 테스트: 7개 전부 통과 (카운터 단위 테스트 6 + 홈 스모크 1)
- 1차 빌드 (디자인 v1 시점): ✅ 성공 — Codemagic ios-adhoc, buildId `6a2a099d2b2e884b38bd6074`, `ai_pushup_counter.ipa` 25.9MB
- 2차 빌드 (디자인 v2): ✅ 성공 — buildId `6a2a0f916b6a810c816fcffa`, 26MB

### 1. 인식률 개선 (목표 95%+)
- **각도 왜곡 제거 (핵심)**: 랜드마크를 화면 비율로 비균등 스케일링한 뒤 각도를 계산하던 문제 수정 → 원본 이미지 좌표로 각도 계산 (`pose_service.dart`)
- **한쪽 팔만 보여도 인식**: 좌우 각각 visibility ≥ 0.5 검사, 신뢰도 충분한 쪽만 사용 (측면 자세 대응, `exercise_counter_service.dart`)
- visibility 검사 실제 적용 (문서에만 있고 코드에 없었음)
- 상태 전환에 2연속 프레임 확인 (노이즈 스파이크 방지)
- 최소 반복 간격 800ms → 500ms (빠른 페이스 대응)
- upThreshold 160° → 155° (팔을 완전히 안 펴도 인식)
- 추적 끊기면 진행 중 반복 무효화 (down → ready)
- 카운터 단위 테스트 6종 추가 (`test/exercise_counter_test.dart`)

### 2. 버그 수정
- `currentCamera`가 선택된 전면 카메라가 아닌 첫 번째 카메라 반환 → 수정
- 운동 완료 후 `finished` 상태 잔존 → 재진입 시 시작 버튼 안 나오던 버그 수정 (결과 화면 이동 후 `resetWorkout`)
- 카운트다운 중 종료 시 0개짜리 결과 화면으로 가던 것 → 취소하면 idle 복귀
- 비동기 스트림 콜백 안 `MediaQuery.of(context)` 사용 제거
- 스트리밍 중 아닐 때 `stopImageStream` 예외 방지
- 기본 템플릿이라 실패하던 `widget_test.dart` 수정
- 전면 카메라 프리뷰 늘어남(왜곡) → cover fit으로 수정

### 3. 디자인 시스템 v2 "FORGE" (승인 완료)
- **컨셉**: "어두운 체육관, 한 줄기 조명" — 사용자 승인: **시그널 오렌지 `#FF5C38`**
- 컬러 레이어: `#0A0B0D` 배경 → `#13151A` 카드 → `#1A1D24` 상승 표면 + 흰색 8% 헤어라인
- 악센트는 화면당 1곳 원칙 (핵심 숫자 + CTA), CTA에만 오렌지 글로우
- 타이포 스케일 8단계 (Display 104 ~ Overline 11), 숫자는 tabular figures
- 공용 위젯: `FadeSlideIn` (staggered 진입 모션), `ProgressRing` (목표 진행 링)
- 모션: 카운트 pop + 미디엄 햅틱, 카운트다운 scale-fade, 결과 count-up(800ms)
- 화면: 홈(인사말 + 주간 바 차트 히어로 카드 + 스탯 타일), 운동(글래스 상태 필 + 진행 링), 결과(링 안 count-up 히어로), 기록(요약 카드 + 주 단위 그룹핑)

### 4. 코치형 TTS (`tts_service.dart`)
- 고유어 숫자 카운팅: "하나, 둘, 셋... 열, 스물" (1~99)
- 10개 단위 랜덤 격려 멘트 ("좋아요!", "그 페이스 유지하세요!" 등)
- 목표 임박 안내: "세 개 남았어요!", "마지막 하나!"
- 시작 "시작! 화이팅!" / 종료 "수고하셨습니다! 총 N개 완료!" (+ "신기록입니다!")
- iOS 속도 0.9 → 0.5 정상화

### 5. 추가 기능
- **목표 횟수**: 홈에서 10/20/30/50/무제한 선택 → 달성 시 TTS 축하 + 자동 종료
- **홈 통계**: 누적 / 이번 주(요일별 바 차트) / 최고 기록, 운동 후 자동 갱신
- **신기록 감지**: 경신 시 결과 화면 🏆 배지 + 오렌지 숫자 + TTS 안내

### 다음 할 일
- [ ] 디자인 v2 커밋 + ios-adhoc 빌드 ("빌드해")
- [ ] 실기기에서 인식률 검증 (측면/정면, 빠른 페이스)
- [ ] TTS 자연스러움 확인 (속도, 고유어 카운팅)
- [ ] 앱 아이콘/런치 이미지 교체 (기존 이슈)
