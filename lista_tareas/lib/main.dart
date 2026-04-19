import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repositories/tarea_repo_shared_prefs.dart';
import 'viewmodels/tareas_viewmodel.dart';
import 'views/home_screen.dart';
// main() debe ser async para poder usar await.
Future<void> main() async {
// Obligatorio cuando usas await antes de runApp().
// Inicializa el binding de Flutter con el motor nativo.
  WidgetsFlutterBinding.ensureInitialized();
// Inicializar el Repository ANTES de arrancar la UI.
// Esto carga los datos del disco al caché en memoria.
  final repo = await TareaRepoSharedPrefs.create();
  runApp(
    ChangeNotifierProvider(
// La única línea que cambia respecto a S04:
// TareaRepoMemory() → repo (TareaRepoSharedPrefs)
      create: (_) => TareasViewModel(repo),
      child: const MiApp(),
    ),
  );
}
class MiApp extends StatelessWidget {
  const MiApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tareas S05',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF23373B),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}