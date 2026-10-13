import 'package:flutter/material.dart';
import '../models/habito.dart';

class HabitoTile extends StatelessWidget {
  final Habito habito;
  final bool completadoHoy;
  final ValueChanged<bool?> onCambio;

  const HabitoTile({
    super.key,
    required this.habito,
    required this.completadoHoy,
    required this.onCambio,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: completadoHoy,
      onChanged: onCambio,
      secondary: CircleAvatar(
        backgroundColor: Color(habito.color),
        radius: 14,
      ),
      title: Text(habito.nombre),
    );
  }
}