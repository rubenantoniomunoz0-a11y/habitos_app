import 'package:flutter/material.dart';
import '../models/habito.dart';

// Fila de un hábito en la lista. Muestra el nombre, un círculo con su
// color y una casilla para marcarlo como hecho hoy.
//
// Es StatelessWidget porque no guarda estado propio: solo pinta lo que
// le pasa el padre y avisa cuando cambia la casilla.
class HabitoTile extends StatelessWidget {
  final Habito habito;
  final bool completadoHoy;

  // Función que se ejecuta al pulsar la casilla. La pantalla principal
  // es la que decide qué hacer con el cambio.
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
      // El círculo de la izquierda lleva el color del hábito.
      secondary: CircleAvatar(
        backgroundColor: Color(habito.color),
        radius: 14,
      ),
      title: Text(habito.nombre),
    );
  }
}