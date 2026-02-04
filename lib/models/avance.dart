import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Avance {
  int? idAvance;
  int idActividad;
  int idUsuario;
  DateTime fecha;
  double porcentajeEjecutado;
  double? horasTrabajadas;
  String? descripcion;
  String? evidenciaFoto;
  String estado;

  Avance({
    this.idAvance,
    required this.idActividad,
    required this.idUsuario,
    required this.fecha,
    required this.porcentajeEjecutado,
    this.horasTrabajadas,
    this.descripcion,
    this.evidenciaFoto,
    this.estado = 'REGISTRADO',
  });

  // Convertir de Map a Avance
  factory Avance.fromMap(Map<String, dynamic> map) {
    return Avance(
      idAvance: map['id_avance'],
      idActividad: map['id_actividad'],
      idUsuario: map['id_usuario'],
      fecha: DateTime.fromMillisecondsSinceEpoch(map['fecha']),
      porcentajeEjecutado: (map['porcentaje_ejecutado'] as num).toDouble(),
      horasTrabajadas: map['horas_trabajadas'] != null
          ? (map['horas_trabajadas'] as num).toDouble()
          : null,
      descripcion: map['descripcion'],
      evidenciaFoto: map['evidencia_foto'],
      estado: map['estado'] ?? 'REGISTRADO',
    );
  }

  // Convertir de Avance a Map
  Map<String, dynamic> toMap() {
    return {
      'id_avance': idAvance,
      'id_actividad': idActividad,
      'id_usuario': idUsuario,
      'fecha': fecha.millisecondsSinceEpoch,
      'porcentaje_ejecutado': porcentajeEjecutado,
      'horas_trabajadas': horasTrabajadas,
      'descripcion': descripcion,
      'evidencia_foto': evidenciaFoto,
      'estado': estado,
    };
  }

  // Métodos de utilidad
  String get fechaFormateada {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  String get horaFormateada {
    return '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  String get fechaHoraCompleta {
    return '$fechaFormateada $horaFormateada';
  }

  Color get estadoColor {
    switch (estado) {
      case 'FINALIZADO':
        return Colors.green;
      case 'EN_PROCESO':
        return Colors.orange;
      case 'PENDIENTE':
        return Colors.yellow;
      case 'CANCELADO':
        return Colors.red;
      default: // REGISTRADO
        return Colors.blue;
    }
  }

  IconData get estadoIcon {
    switch (estado) {
      case 'FINALIZADO':
        return Icons.check_circle;
      case 'EN_PROCESO':
        return Icons.play_circle_fill;
      case 'PENDIENTE':
        return Icons.schedule;
      case 'CANCELADO':
        return Icons.cancel;
      default: // REGISTRADO
        return Icons.assignment;
    }
  }

  String get estadoTexto {
    switch (estado) {
      case 'FINALIZADO':
        return 'Finalizado';
      case 'EN_PROCESO':
        return 'En Proceso';
      case 'PENDIENTE':
        return 'Pendiente';
      case 'CANCELADO':
        return 'Cancelado';
      default:
        return 'Registrado';
    }
  }

  // Validaciones
  bool get tieneEvidencia => evidenciaFoto != null && evidenciaFoto!.isNotEmpty;
  bool get tieneDescripcion => descripcion != null && descripcion!.isNotEmpty;
  bool get tieneHorasTrabajadas => horasTrabajadas != null && horasTrabajadas! > 0;

  String get porcentajeTexto {
    return '${porcentajeEjecutado.toStringAsFixed(1)}%';
  }

  String? get horasTexto {
    if (horasTrabajadas == null) return null;
    return '${horasTrabajadas!.toStringAsFixed(1)} horas';
  }

  // Copiar con nuevos valores
  Avance copyWith({
    int? idAvance,
    int? idActividad,
    int? idUsuario,
    DateTime? fecha,
    double? porcentajeEjecutado,
    double? horasTrabajadas,
    String? descripcion,
    String? evidenciaFoto,
    String? estado,
  }) {
    return Avance(
      idAvance: idAvance ?? this.idAvance,
      idActividad: idActividad ?? this.idActividad,
      idUsuario: idUsuario ?? this.idUsuario,
      fecha: fecha ?? this.fecha,
      porcentajeEjecutado: porcentajeEjecutado ?? this.porcentajeEjecutado,
      horasTrabajadas: horasTrabajadas ?? this.horasTrabajadas,
      descripcion: descripcion ?? this.descripcion,
      evidenciaFoto: evidenciaFoto ?? this.evidenciaFoto,
      estado: estado ?? this.estado,
    );
  }
}