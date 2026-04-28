import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_tr/shared/widgets/degisim_badge.dart';

void main() {
  group('DegisimBadge', () {
    testWidgets('null değişim — boş widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DegisimBadge(degisimYuzdesi: null)),
      );
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('pozitif değişim — zam göstergesi', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DegisimBadge(degisimYuzdesi: 2.5)),
        ),
      );
      // Format: "+%2.5"
      expect(find.textContaining('%2.5'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('negatif değişim — indirim göstergesi', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DegisimBadge(degisimYuzdesi: -1.3)),
        ),
      );
      expect(find.textContaining('%'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('sıfır değişim — sabit göstergesi', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DegisimBadge(degisimYuzdesi: 0.001)),
        ),
      );
      expect(find.text('— Sabit'), findsOneWidget);
    });
  });
}
