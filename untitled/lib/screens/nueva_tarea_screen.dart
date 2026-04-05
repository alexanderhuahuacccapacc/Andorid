import 'package:flutter/material.dart';
import '../viewmodels/tarea_viewmodel.dart';
class NuevaTareaScreen extends StatefulWidget {
  const NuevaTareaScreen({super.key});
  @override
  State<NuevaTareaScreen> createState() =>
      _NuevaTareaScreenState();
}
class _NuevaTareaScreenState extends State<NuevaTareaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  bool _guardando = false;
  @override
  void dispose() {
    _tituloCtrl.dispose(); // SIEMPRE liberar el controller
    super.dispose();
  }
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_guardando) return;
    setState(() => _guardando = true);
// Simula latencia (en S07: escritura real en BD)
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return; // guard: widget puede haber muerto
    tareasVM.agregar(_tituloCtrl.text);
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Tarea')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tituloCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la tarea',
                  border: OutlineInputBorder(),
                ),
                onSaved: (_) => _guardar(),
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'El nombre no puede estar vacío';
                  if (v.trim().length < 3)
                    return 'Mínimo 3 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _guardando
                  ? const Center(
                  child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _guardar,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}