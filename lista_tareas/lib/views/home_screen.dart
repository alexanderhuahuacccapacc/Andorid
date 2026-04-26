import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/tareas_viewmodel.dart';
import '../models/tarea.dart';
import 'nueva_tarea_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // context.watch se suscribe: cada vez que el ViewModel
    // llama notifyListeners(), este build() se ejecuta de nuevo.
    final vm = context.watch<TareasViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        backgroundColor: const Color(0xFF23373B),
        foregroundColor: Colors.white,
        // El resumen en el AppBar se actualiza automáticamente
        // porque vm viene de context.watch
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '${vm.tareasCompletadas} de ${vm.totalTareas} completadas',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Filtros ──────────────────────────────────────────
          _FiltroBar(),

          // ── Lista de tareas ──────────────────────────────────
          Expanded(
            child: vm.cargando
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : vm.tareas.isEmpty
                ? const Center(
              child: Text(
                'No hay tareas. ¡Agrega una!',
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: vm.tareas.length,
              itemBuilder: (context, index) {
                return _TareaCard(tarea: vm.tareas[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        // context.read aquí porque no necesitamos rebuild
        // al pulsar el botón — solo navegamos.
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const NuevaTareaScreen(),
          ),
        ),
        backgroundColor: const Color(0xFFEB811B),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nueva tarea',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

// ── Widget interno: barra de filtros ────────────────────────────
// Es un StatelessWidget separado para mantener HomeScreen limpia.
class _FiltroBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // watch aquí para que la barra se actualice cuando cambia el filtro
    final vm = context.watch<TareasViewModel>();

    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: FiltroTareas.values.map((filtro) {
          final etiqueta = switch (filtro) {
            FiltroTareas.todas => 'Todas',
            FiltroTareas.pendientes => 'Pendientes',
            FiltroTareas.completadas => 'Completadas',
          };

          final seleccionado = vm.filtroActivo == filtro;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(etiqueta),
              selected: seleccionado,
              selectedColor: const Color(0xFFEB811B).withOpacity(0.2),
              onSelected: (_) {
                // read aquí: cambiar filtro no requiere que este
                // widget se reconstruya (watch ya lo hace en build)
                context.read<TareasViewModel>().cambiarFiltro(filtro);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Widget interno: tarjeta de tarea ────────────────────────────
class _TareaCard extends StatelessWidget {
  final Tarea tarea;

  const _TareaCard({required this.tarea});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(tarea.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade400,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        // read en callbacks: no necesitamos que la tarjeta
        // se reconstruya, solo ejecutamos la acción.
        context.read<TareasViewModel>().eliminarTarea(tarea.id);
      },
      child: ListTile(
        leading: Checkbox(
          value: tarea.completada,
          activeColor: const Color(0xFF23373B),
          onChanged: (_) {
            context.read<TareasViewModel>().toggleCompletada(tarea.id);
          },
        ),
        title: Text(
          tarea.titulo,
          style: TextStyle(
            decoration: tarea.completada
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: tarea.completada ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: tarea.descripcion.isNotEmpty
            ? Text(
          tarea.descripcion,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        )
            : null,
      ),
    );
  }
}