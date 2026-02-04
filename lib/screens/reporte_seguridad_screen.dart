import 'package:flutter/material.dart';

class ReporteSeguridadScreen extends StatelessWidget {
  const ReporteSeguridadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10121D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181B35),
        title: const Text(
          'Reporte de Seguridad',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Text(
          'Pantalla de Reporte de Seguridad - En desarrollo',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
      ),
    );
  }
}
