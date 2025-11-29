import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neumatik_frontend/main.dart';

void main() {
  // Test para verificar que la app inicia y navega a la pantalla de Login.
  testWidgets('La app inicia y muestra la pantalla de Login si no hay sesión', (
    WidgetTester tester,
  ) async {
    // 1. Construir nuestra aplicación.
    await tester.pumpWidget(const MyApp());

    // 2. La app primero muestra un CircularProgressIndicator en CheckAuthStateScreen.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 3. Esperamos a que todos los frames y la navegación se completen.
    // Esto simula la finalización del FutureBuilder y la redirección.
    await tester.pumpAndSettle();

    // 4. Verificar que, al no haber sesión, se muestra la pantalla de Login.
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
