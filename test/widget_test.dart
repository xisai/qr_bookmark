import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qr_bookmark/main.dart';

void main() {
  testWidgets('QR生成画面が起動時に表示される', (WidgetTester tester) async {
    await tester.pumpWidget(const QrBookmarkApp());
    await tester.pumpAndSettle();

    // 入力フィールド（コンテンツ・パスフレーズ）が描画されていることを確認
    expect(find.byType(TextField), findsWidgets);

    // QR生成ボタンが描画されていることを確認
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
