import 'package:flutter/material.dart';
class AvatarWidget extends StatelessWidget {
  final String nombre;
  final String rol;
  const AvatarWidget({
    super.key,
    required this.nombre,
    required this.rol,
  });
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
      CircleAvatar(
      radius: 60,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        nombre[0], // primera letra del nombre
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
      ),
        const SizedBox(height: 16),
        Text(
          nombre,
          style: Theme.of(context)
              .textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          rol,
          style: Theme.of(context)
              .textTheme.bodyLarge
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}