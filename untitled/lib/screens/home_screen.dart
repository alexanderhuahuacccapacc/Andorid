import 'package:flutter/material.dart';
import '../viewmodels/tarea_viewmodel.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: ListenableBuilder(
            listenable: tareasVM,
            builder: (_, __) => Text(
                '${tareasVM.pendientes} tarea(s) pendiente(s)'),
          ),
        ),
        body: Column(children: [
// Filtros con ChoiceChip
          ListenableBuilder(
          listenable: tareasVM,
          builder: (_, __) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: FiltroTarea.values.map((f) {
              final etiqueta = {
                FiltroTarea.todas: 'Todas',
                FiltroTarea.pendientes: 'Pendientes',
                FiltroTarea.completadas: 'Completadas',
              }[f]!;
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 8),
                child: ChoiceChip(
                  label: Text(etiqueta),
                  selected: tareasVM.filtro == f,
                  onSelected: (_) => tareasVM.cambiarFiltro(f),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
            child: ListenableBuilder(
                listenable: tareasVM,
                builder: (_, __) {
                  final tareas = tareasVM.tareas;
                  if (tareas.isEmpty)
                    return const Center(
                        child: Text('Sin tareas en esta categoría.'));
                  return ListView.builder(
                    itemCount: tareas.length,
                    itemBuilder: (ctx, i) {
                      final t = tareas[i];
                      return Dismissible(
                        key: Key(t.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete,
                              color: Colors.white),
                        ),
                        onDismissed: (_) => tareasVM.eliminar(t.id),
                        child: CheckboxListTile(
                          title: Text(t.titulo,
                              style: TextStyle(
                                  decoration: t.completada
                                      ? TextDecoration.lineThrough
                                      : null)),
                          value: t.completada,
                          onChanged: (_) =>
                              tareasVM.toggleCompletada(t.id),
                        ),
                      );
                    },
                  );
                },
            ),
        ),
        ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/nueva'),
        child: const Icon(Icons.add),
      ),
    );
  }
}