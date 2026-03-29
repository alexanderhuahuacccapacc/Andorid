import 'package:flutter/material.dart';
import 'screens/perfil_screen.dart';
void main() {
  runApp(const TarjetaApp());
}
class TarjetaApp extends StatelessWidget {
  const TarjetaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarjeta de Presentacion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true, // default desde Flutter 3.16
      ),
      home: const PerfilScreen(),
    );
  }
}