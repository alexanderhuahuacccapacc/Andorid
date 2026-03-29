import 'package:flutter/material.dart';

class LikeButton extends StatefulWidget {
  const LikeButton({super.key});

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  int _likes = 0;
  bool _presionado = false;

  void _toggleLike() {
    setState(() {
      if (_presionado) {
        _likes--;
      } else {
        _likes++;
      }
      _presionado = !_presionado;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$_likes Me gusta',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _toggleLike,
          icon: Icon(
            _presionado ? Icons.favorite : Icons.favorite_border,
          ),
          label: Text(
            _presionado ? 'Te gustó!' : 'Me gusta',
          ),
          style: FilledButton.styleFrom(
            backgroundColor: _presionado ? Colors.red : Colors.deepPurple,
          ),
        ),
      ],
    );
  }
}