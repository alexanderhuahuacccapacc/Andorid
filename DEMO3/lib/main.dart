import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

void main() => runApp(const MiApp());

class ContadorViewModel extends ChangeNotifier { // ★
  int _valor = 0; // ★
  String _historial = ''; // ★
  int get valor => _valor; // ★
  String get historial => _historial; // ★
  void incrementar() { // ★
    _valor++;
    _historial += 'Incrementado a $_valor\n';
    notifyListeners(); // dispara rebuild // ★
  }
  void resetear() { // ★
    _valor = 0;
    _historial = 'Reseteado.\n';
    notifyListeners(); // ★
  }
}
final contadorVM = ContadorViewModel();

// Widget sin estado — inmutable, no cambia por sí solo
class MiApp extends StatefulWidget {
  const MiApp({super.key});

  @override
  State<MiApp> createState() => _MiAppState();
}



class _MiAppState extends State<MiApp> {
  int _contador = 0; // ★
  String _mensaje = 'Presiona el botón';
  int _segundos = 0;
  late Timer _timer;

  @override
  void initState() { // ★
    super.initState(); // ★ SIEMPRE primero
    print('Widget creado por el super.');
    _timer = Timer.periodic( // ★
      const Duration(seconds: 1),
          (_) => setState(() => _segundos++),
    );
  }

  @override
  void dispose() { // ★
    _timer.cancel(); // ★ liberar el timer
    print('Widget eliminado......');
    super.dispose(); // ★ SIEMPRE al final
  }

  Future<void> _irASegundaPantalla(BuildContext context) async { // ★
    final resultado = await Navigator.push<String>( // ★
      context,
      MaterialPageRoute(
        builder: (_) =>
            SegundaPantalla(valorRecibido: _contador),
      ),
    );
    if (!mounted) return; // SIEMPRE verificar mounted // ★
    setState(() { // ★
      _mensaje = resultado != null
          ? 'Recibido: "$resultado"'
          : 'El usuario canceló sin enviar';
    });
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title:  Text('Tiempo: $_segundos')),
            body: Center( // ★
              child: Column( // ★
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$_contador', // ★
                      style: const TextStyle(
                          fontSize: 64,
                      fontWeight: FontWeight.bold)),
                  Text(_mensaje), // ★
                  const SizedBox(height: 24),
                  ListenableBuilder(
                    listenable: contadorVM,
                    builder: (context, _) => Text(
                      'ViewModel: ${contadorVM.valor}',
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                  const SizedBox(height: 10),


                  Text(
                    contadorVM.historial,
                    style: const TextStyle(fontSize: 14),
                  ),
                  ElevatedButton(
                    onPressed: () => contadorVM.incrementar(),
                    child: const Text('Incrementar'),
                  ),

                  ElevatedButton( // ★
                    onPressed: () {
                      setState(() { // ★
                        _contador++;
                        _mensaje = _contador == 1
                            ? '¡Primer toque!'

                            : 'Has tocado $_contador veces';

                      });
                    },
                    child: const Text('Tocar_boton'),

                  ),
                  ElevatedButton( // ★
                    onPressed: () {
                      Navigator.push( // ★
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          SegundaPantalla(valorRecibido: _contador,), // ★
                        ),
                      );
                    },
                    child: const Text('Ir a Segunda Pantalla'),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}

// Nueva clase al final del archivo: // ★
class SegundaPantalla extends StatefulWidget {
  final int valorRecibido; // ★
  const SegundaPantalla( // ★
          {super.key, required this.valorRecibido});

  @override
  State<SegundaPantalla> createState() => _SegundaPantallaState();
}

class _SegundaPantallaState extends State<SegundaPantalla> {
  final _formKey = GlobalKey<FormState>(); // ★
  final _ctrl = TextEditingController(); // ★
  String? _resultado;

  @override
  void dispose() {
    _ctrl.dispose(); // ★ SIEMPRE liberar
    super.dispose();
  }
  void _enviar() { // ★
    if (!_formKey.currentState!.validate()) return; // ★
    setState(() => _resultado = _ctrl.text.trim()); // ★
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Valor: ${widget.valorRecibido}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ListenableBuilder(
                listenable: contadorVM,
                builder: (context, _) => Text(
                  'ViewModel: ${contadorVM.valor}',
                  style: const TextStyle(fontSize: 48),
                ),
              ),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () => contadorVM.incrementar(),
                child: const Text('Incrementar desde P2'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => contadorVM.resetear(),
                child: const Text('Resetear'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver'),
              ),

              TextFormField(
                controller: _ctrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Escribe algo (min. 5 chars)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Campo requerido';
                  }
                  if (v.trim().length < 5) {
                    return 'Mínimo 5 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _enviar,
                child: const Text('Enviar'),
              ),

              if (_resultado != null)
                Text(
                  'Ingresaste: $_resultado',
                  style: const TextStyle(color: Colors.green),
                ),
            ],
          ),
        ),
      ),
    );
  }
}