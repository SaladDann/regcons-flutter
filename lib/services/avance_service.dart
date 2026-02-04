import '../db/app_db.dart';
import '../db/daos/avance_dao.dart';
import '../db/daos/actividad_dao.dart';
import '../models/avance.dart';
import '../models/actividad.dart';

class AvanceService {
  late AvanceDao _avanceDao;
  late ActividadDao _actividadDao;
  bool _inicializado = false;

  Future<void> _initialize() async {
    if (!_inicializado) {
      final db = await AppDatabase().database;
      _avanceDao = AvanceDao(db);
      _actividadDao = ActividadDao(db);
      _inicializado = true;
    }
  }

  // REGISTRAR un nuevo avance
  Future<Avance> registrarAvance({
    required int idActividad,
    required int idUsuario,
    required double porcentajeEjecutado,
    String? descripcion,
    double? horasTrabajadas,
    String? evidenciaFoto,
  }) async {
    await _initialize();

    // Validar porcentaje
    if (porcentajeEjecutado < 0 || porcentajeEjecutado > 100) {
      throw Exception('El porcentaje debe estar entre 0 y 100');
    }

    // Verificar que la actividad exista
    final actividad = await _actividadDao.getById(idActividad);
    if (actividad == null) {
      throw Exception('La actividad no existe');
    }

    final nuevoAvance = Avance(
      idActividad: idActividad,
      idUsuario: idUsuario,
      fecha: DateTime.now(),
      porcentajeEjecutado: porcentajeEjecutado,
      horasTrabajadas: horasTrabajadas,
      descripcion: descripcion,
      evidenciaFoto: evidenciaFoto,
      estado: 'REGISTRADO',
    );

    final id = await _avanceDao.insert(nuevoAvance);
    nuevoAvance.idAvance = id;

    // Actualizar estado de la actividad si corresponde
    await _actualizarEstadoActividad(idActividad);

    return nuevoAvance;
  }

  // ACTUALIZAR un avance existente
  Future<Avance> actualizarAvance(Avance avance) async {
    await _initialize();

    if (avance.idAvance == null) {
      throw Exception('El avance no tiene ID');
    }

    // Validar porcentaje
    if (avance.porcentajeEjecutado < 0 || avance.porcentajeEjecutado > 100) {
      throw Exception('El porcentaje debe estar entre 0 y 100');
    }

    await _avanceDao.update(avance);

    // Actualizar estado de la actividad
    await _actualizarEstadoActividad(avance.idActividad);

    return avance;
  }

  // ELIMINAR un avance
  Future<void> eliminarAvance(int idAvance) async {
    await _initialize();

    final avance = await _avanceDao.getById(idAvance);
    if (avance == null) {
      throw Exception('El avance no existe');
    }

    await _avanceDao.delete(idAvance);

    // Actualizar estado de la actividad
    await _actualizarEstadoActividad(avance.idActividad);
  }

  // OBTENER avances por actividad
  Future<List<Avance>> obtenerAvancesPorActividad(int idActividad) async {
    await _initialize();
    return await _avanceDao.getByActividad(idActividad);
  }

  // OBTENER avances por obra
  Future<List<Avance>> obtenerAvancesPorObra(int idObra) async {
    await _initialize();
    return await _avanceDao.getByObra(idObra);
  }

  // OBTENER avances por usuario
  Future<List<Avance>> obtenerAvancesPorUsuario(int idUsuario) async {
    await _initialize();
    return await _avanceDao.getByUsuario(idUsuario);
  }

  // OBTENER avances por fecha
  Future<List<Avance>> obtenerAvancesPorFecha(DateTime fecha) async {
    await _initialize();

    final startOfDay = DateTime(fecha.year, fecha.month, fecha.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await _avanceDao.getByFechaRange(startOfDay, endOfDay);
  }

  // OBTENER avances por rango de fechas
  Future<List<Avance>> obtenerAvancesPorRangoFechas(
      DateTime fechaInicio,
      DateTime fechaFin,
      ) async {
    await _initialize();
    return await _avanceDao.getByFechaRange(fechaInicio, fechaFin);
  }

  // BUSCAR avances
  Future<List<Avance>> buscarAvances(String query) async {
    await _initialize();
    return await _avanceDao.search(query);
  }

  // CALCULAR estadísticas de avances
  Future<Map<String, dynamic>> obtenerEstadisticasAvances() async {
    await _initialize();
    return await _avanceDao.getEstadisticas();
  }

  // CAMBIAR estado de un avance
  Future<void> cambiarEstadoAvance(int idAvance, String nuevoEstado) async {
    await _initialize();

    final estadosValidos = ['REGISTRADO', 'EN_PROCESO', 'FINALIZADO', 'CANCELADO'];
    if (!estadosValidos.contains(nuevoEstado)) {
      throw Exception('Estado no válido: $nuevoEstado');
    }

    await _avanceDao.updateEstado(idAvance, nuevoEstado);

    // Obtener el avance para actualizar la actividad
    final avance = await _avanceDao.getById(idAvance);
    if (avance != null) {
      await _actualizarEstadoActividad(avance.idActividad);
    }
  }

  // OBTENER resumen de avances por actividad
  Future<Map<String, dynamic>> obtenerResumenPorActividad(int idActividad) async {
    await _initialize();

    final avances = await _avanceDao.getByActividad(idActividad);
    final promedio = await _avanceDao.calcularPromedioPorActividad(idActividad);
    final totalHoras = await _avanceDao.sumHorasByActividad(idActividad);
    final ultimoAvance = await _avanceDao.getUltimoByActividad(idActividad);

    return {
      'total_avances': avances.length,
      'porcentaje_promedio': promedio,
      'total_horas': totalHoras,
      'ultimo_avance': ultimoAvance,
      'avances': avances,
    };
  }

  // OBTENER resumen de avances por obra
  Future<Map<String, dynamic>> obtenerResumenPorObra(int idObra) async {
    await _initialize();

    final avances = await _avanceDao.getByObra(idObra);

    // Agrupar por actividad
    final avancesPorActividad = <int, List<Avance>>{};
    for (var avance in avances) {
      avancesPorActividad.putIfAbsent(avance.idActividad, () => []);
      avancesPorActividad[avance.idActividad]!.add(avance);
    }

    // Calcular estadísticas
    int totalAvances = avances.length;
    double totalHoras = 0;
    for (var avance in avances) {
      if (avance.horasTrabajadas != null) {
        totalHoras += avance.horasTrabajadas!;
      }
    }

    return {
      'total_avances': totalAvances,
      'total_horas': totalHoras,
      'avances_por_actividad': avancesPorActividad.length,
      'avances': avances,
    };
  }

  // Método privado para actualizar estado de actividad
  Future<void> _actualizarEstadoActividad(int idActividad) async {
    final promedio = await _avanceDao.calcularPromedioPorActividad(idActividad);

    String nuevoEstado;
    if (promedio >= 100) {
      nuevoEstado = 'COMPLETADA';
    } else if (promedio > 0) {
      nuevoEstado = 'EN_PROGRESO';
    } else {
      nuevoEstado = 'PENDIENTE';
    }

    await _actividadDao.updateEstado(idActividad, nuevoEstado);
  }

  // OBTENER avances con fotos
  Future<List<Avance>> obtenerAvancesConFotos() async {
    await _initialize();

    final todosAvances = await _avanceDao.getAll();
    return todosAvances.where((avance) => avance.tieneEvidencia).toList();
  }

  // GENERAR reporte de avances
  Future<Map<String, dynamic>> generarReporteAvances({
    int? idObra,
    int? idUsuario,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    await _initialize();

    List<Avance> avances;

    if (idObra != null) {
      avances = await _avanceDao.getByObra(idObra);
    } else if (idUsuario != null) {
      avances = await _avanceDao.getByUsuario(idUsuario);
    } else if (fechaInicio != null && fechaFin != null) {
      avances = await _avanceDao.getByFechaRange(fechaInicio, fechaFin);
    } else {
      avances = await _avanceDao.getAll();
    }

    // Filtrar por fechas si se especificaron
    if (fechaInicio != null && fechaFin != null) {
      avances = avances.where((avance) {
        return avance.fecha.isAfter(fechaInicio) &&
            avance.fecha.isBefore(fechaFin);
      }).toList();
    }

    // Calcular estadísticas del reporte
    double totalHoras = 0;
    double porcentajePromedio = 0;

    for (var avance in avances) {
      if (avance.horasTrabajadas != null) {
        totalHoras += avance.horasTrabajadas!;
      }
      porcentajePromedio += avance.porcentajeEjecutado;
    }

    if (avances.isNotEmpty) {
      porcentajePromedio /= avances.length;
    }

    return {
      'total_avances': avances.length,
      'total_horas': totalHoras,
      'porcentaje_promedio': porcentajePromedio,
      'periodo': fechaInicio != null && fechaFin != null
          ? '${fechaInicio.toIso8601String()} - ${fechaFin.toIso8601String()}'
          : 'Todos',
      'avances': avances,
    };
  }
}