import 'package:flutter/material.dart';

class Actividad {
  int? idActividad;
  int idObra;
  String nombre;
  String? descripcion;
  double pesoPorcentual;
  String estado;
  double? porcentajeCompletado; // Calculado

  Actividad({
    this.idActividad,
    required this.idObra,
    required this.nombre,
    this.descripcion,
    required this.pesoPorcentual,
    this.estado = 'PENDIENTE',
    this.porcentajeCompletado = 0,
  });

  // Convertir de Map a Actividad
  factory Actividad.fromMap(Map<String, dynamic> map) {
    return Actividad(
      idActividad: map['id_actividad'],
      idObra: map['id_obra'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      pesoPorcentual: (map['peso_porcentual'] as num).toDouble(),
      estado: map['estado'] ?? 'PENDIENTE',
    );
  }

  // Convertir de Actividad a Map
  Map<String, dynamic> toMap() {
    return {
      'id_actividad': idActividad,
      'id_obra': idObra,
      'nombre': nombre,
      'descripcion': descripcion,
      'peso_porcentual': pesoPorcentual,
      'estado': estado,
    };
  }

  // Métodos de utilidad
  Color get estadoColor {
    switch (estado) {
      case 'COMPLETADA':
        return Colors.green;
      case 'EN_PROGRESO':
        return Colors.orange;
      case 'PENDIENTE':
        return Colors.yellow;
      case 'ATRASADA':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData get estadoIcon {
    switch (estado) {
      case 'COMPLETADA':
        return Icons.check_circle;
      case 'EN_PROGRESO':
        return Icons.play_circle_fill;
      case 'PENDIENTE':
        return Icons.schedule;
      case 'ATRASADA':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  String get estadoTexto {
    switch (estado) {
      case 'COMPLETADA':
        return 'Completada';
      case 'EN_PROGRESO':
        return 'En Progreso';
      case 'PENDIENTE':
        return 'Pendiente';
      case 'ATRASADA':
        return 'Atrasada';
      default:
        return estado;
    }
  }

  // Validaciones
  bool get esCompletada => estado == 'COMPLETADA';
  bool get tieneDescripcion => descripcion != null && descripcion!.isNotEmpty;
  bool get pesoValido => pesoPorcentual >= 0 && pesoPorcentual <= 100;

  // Para mostrar en UI
  String get pesoTexto {
    return '${pesoPorcentual.toStringAsFixed(1)}%';
  }

  String? get porcentajeCompletadoTexto {
    if (porcentajeCompletado == null) return null;
    return '${porcentajeCompletado!.toStringAsFixed(1)}% completado';
  }

  // Calcular contribución al avance total
  double get contribucionAvance {
    final porcentaje = porcentajeCompletado ?? 0;
    return (pesoPorcentual * porcentaje) / 100;
  }

  // Copiar con nuevos valores
  Actividad copyWith({
    int? idActividad,
    int? idObra,
    String? nombre,
    String? descripcion,
    double? pesoPorcentual,
    String? estado,
    double? porcentajeCompletado,
  }) {
    return Actividad(
      idActividad: idActividad ?? this.idActividad,
      idObra: idObra ?? this.idObra,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      pesoPorcentual: pesoPorcentual ?? this.pesoPorcentual,
      estado: estado ?? this.estado,
      porcentajeCompletado: porcentajeCompletado ?? this.porcentajeCompletado,
    );
  }

  // Validar antes de guardar
  List<String> validar() {
    final errores = <String>[];

    if (nombre.isEmpty) {
      errores.add('El nombre de la actividad es requerido');
    }

    if (!pesoValido) {
      errores.add('El peso porcentual debe estar entre 0 y 100');
    }

    if (idObra <= 0) {
      errores.add('Debe seleccionar una obra válida');
    }

    return errores;
  }
}