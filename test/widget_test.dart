import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rihabiri_run/main.dart';

void main() {
  testWidgets('アプリが起動してタイトルが表示される', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: RihabiriRunApp()),
    );
    expect(find.text('リハビリラン'), findsOneWidget);
  });
}
