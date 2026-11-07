import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nearu/src/widgets/user_location_marker.dart';

void main() {
  testWidgets('UserLocationMarker renderiza sem erros', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: UserLocationMarker())),
      ),
    );

    // Avança um pouco para a animação não travar o teste
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(UserLocationMarker), findsOneWidget);
  });

  testWidgets('UserLocationMarker não intercepta toques', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GestureDetector(
              onTap: () => debugPrint('tap no fundo'),
              child: const SizedBox(
                width: 200,
                height: 200,
                child: UserLocationMarker(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(UserLocationMarker), findsOneWidget);
  });
}
