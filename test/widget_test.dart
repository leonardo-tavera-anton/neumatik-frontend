import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neumatik_frontend/main.dart';

void main() {
  //test para verificar la navegacion inicial segun el estado de autenticacion
  testWidgets('La app inicia y muestra la pantalla de Login si no hay sesión', (
    WidgetTester tester,
  ) async {
    // 1. Construir nuestra aplicacion
    await tester.pumpWidget(const MyApp());

    // 2. La app primero muestra un CircularProgressIndicator en CheckAuthStateScreen.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 3. Esperamos a que la navegación se complete
    await tester.pumpAndSettle();

    // 4. Verificamos que la pantalla de Login se muestra
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
