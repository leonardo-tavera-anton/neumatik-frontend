// Este es el archivo de prueba por defecto que necesita ser actualizado
// para reflejar el nombre de la clase principal de la app (NeumatikApp).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Importamos la clase principal de nuestra aplicación (NeumatikApp)
import 'package:neumatik_frontend/main.dart';

void main() {
  // Test para verificar que la aplicación inicia correctamente y muestra el título.
  testWidgets('Verifica que la aplicación inicia y muestra el título principal', (
    WidgetTester tester,
  ) async {
    // 1. Construir nuestra aplicación (usando NeumatikApp, no MyApp)
    await tester.pumpWidget(const NeumatikApp());

    // 2. Disparar un frame para que se complete la carga asíncrona (como FutureBuilder)
    // Esto es importante si la pantalla inicial ListadoAutopartesScreen usa FutureBuilder.
    await tester.pumpAndSettle();

    // 3. Verificar que el título principal de la AppBar esté presente.
    // El título definido en ListadoAutopartesScreen es 'Neumatik: Autopartes en Venta'
    expect(find.text('Neumatik: Autopartes en Venta'), findsOneWidget);

    // Se eliminó la lógica del contador ya que la aplicación no lo utiliza.
  });
}
