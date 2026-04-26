import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/gastos_viewmodel.dart';
import 'repositories/gastos_repository.dart';
import 'screens/home_screen.dart';
void main() {
  runApp(const MiApp());
}
class MiApp extends StatelessWidget {
  const MiApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
// Creamos el Repository y lo pasamos al ViewModel.
// El ViewModel no sabe como funciona el Repository — solo
// sabe que puede llamar cargarGastos() y guardarGastos().
        final repository = GastosRepository();
        final viewModel = GastosViewModel(repository);
// Cargamos los gastos guardados al iniciar la app.
// No usamos await aqui porque build() no puede ser async.
// cargarGastos() es async pero la llamamos sin await —
// se ejecuta en segundo plano y cuando termina llama
// notifyListeners() para actualizar la UI.
        viewModel.cargarGastos();
        return viewModel;
      },
      child: MaterialApp(
        title: 'Control de Gastos',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}