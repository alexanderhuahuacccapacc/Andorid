import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/nueva_tarea_screen.dart';
void main() => runApp(const MiApp());
class MiApp extends StatelessWidget {
  const MiApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tareas',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/nueva': (_) => const NuevaTareaScreen(),
      },
    );
  }
}