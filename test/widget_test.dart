import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_pushup_counter/main.dart';

void main() {
  testWidgets('홈 화면 스모크 테스트', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    expect(find.text('PUSH UP'), findsOneWidget);
    expect(find.text('운동 시작'), findsOneWidget);
    expect(find.text('목표 횟수'), findsOneWidget);
  });
}
