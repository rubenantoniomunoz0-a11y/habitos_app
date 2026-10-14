import 'package:flutter/material.dart';
import '../models/habito.dart';
import '../services/preferencias_service.dart';

class GestionHabitosScreen extends StatefulWidget {
  const GestionHabitosScreen({super.key});

  @override
  State<GestionHabitosScreen> createState() => _GestionHabitosScreenState();
}

class _GestionHabitosScreenState extends State<GestionHabitosScreen> {
  final PreferenciasService _prefs = PreferenciasService();

  List<Habito> _habitos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final habitos = await _prefs.leerHabitos();
    if (!mounted) return;
    setState(() {
      _habitos = habitos;
      _cargando = false;
    });

    Future<void> _mostrarFormulario({int? index}) async {
      final TextEditingController nombreController = TextEditingController();

      if (index != null) {
        nombreController.text = _habitos[index].nombre;
      }

      final resultado = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(index == null ? 'Nuevo habito' : 'Editar habito'),
            content: TextField(
              controller: nombreController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nombre del habito',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final nombre = nombreController.text.trim();
                  if (nombre.isEmpty) return;
                  Navigator.pop(context, nombre);
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      );

      if (resultado == null || resultado.isEmpty) return;

      if (index == null) {
        final nuevo = Habito(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nombre: resultado,
          color: Colors.blue.value,
          fechascompletado: [],
        );
        setState(() {
          _habitos.add(nuevo);
        });
      } else {
        final original = _habitos[index];
        final editado = Habito(
          id: original.id,
          nombre: resultado,
          color: original.color,
          fechascompletado: original.fechascompletado,
        );
        setState(() {
          _habitos[index] = editado;
        });
      }

      await _prefs.guardarHabitos(_habitos);
    }

    Future<void> _borrar(int index) async {
      final confirmado = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Borrar habito'),
            content: Text('Seguro que quieres borrar "${_habitos[index].nombre}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Borrar'),
              ),
            ],
          );
        },
      );

      if (confirmado != true) return;

      setState(() {
        _habitos.removeAt(index);
      });

      await _prefs.guardarHabitos(_habitos);
    }
  }
}