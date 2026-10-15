import 'package:flutter/material.dart';

// Widget sencillo que muestra un indicador de carga centrado.
// Se usa mientras se leen los datos de SharedPreferences, que son
// operaciones asíncronas y tardan un poco.
//
// Es StatelessWidget porque no guarda estado propio: siempre pinta
// lo mismo hasta que el padre lo sustituye por otra pantalla.
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}