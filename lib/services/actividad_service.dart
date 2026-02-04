import '../db/app_db.dart';
import '../db/daos/actividad_dao.dart';
import '../db/daos/avance_dao.dart';
import '../db/daos/obra_dao.dart';
import '../models/actividad.dart';
import '../models/avance.dart';
import '../models/obra.dart';

class ActividadService {
  late ActividadDao _actividadDao;
  late AvanceDao _avanceDao;
  late ObraDao _obraDao;
  bool _inicializado = false;

  Future<void> _initialize() async {
    if (!_inicializado) {
      final db = await AppDatabase().database;
      _actividadDao = ActividadDao(db);
      _avanceDao = AvanceDao(db);
      _obraDao = ObraDao(db);
      _inicializado = true;
    }
  }

  // CREAR una nueva actividad
  Future<Actividad> crearActividad({
    required int idObra,
    required String nombre,
    String? descripcion,
    required double pesoPorcentual,
  }) async {
    await _initialize();

    // Validar que la obra exista
    final obra = await _obraDao.getById(idObra);
    if (obra == null) {
      throw Exception('La obra no existe');
    }

    // Validar peso porcentual
    if (pesoPorcentual < 0 || pesoPorcentual > 100) {
      throw Exception('El peso porcentual debe estar entre 0 y 100');
    }

    // Verificar que no se exceda el 100% de peso en la obra
    final pesoValido = await _actividadDao.validarPesosObra(idObra, pesoPorcentual);
    if (!pesoValido) {
      throw Exception('El peso total de las actividades excede el 100%');
    }

    final nuevaActividad = Actividad(
      idObra: idObra,
      nombre: nombre,
      descripcion: descripcion,
      pesoPorcentual: pesoPorcentual,
      estado: 'PENDIENTE',
    );

    final id = await _actividadDao.insert(nuevaActividad);
    nuevaActividad.idActividad = id;

    return nuevaActividad;
  }

  // ACTUALIZAR una actividad existente
  Future<Actividad> actualizarActividad(Actividad actividad) async {
    await _initialize();

    if (actividad.idActividad == null) {
      throw Exception('La actividad no tiene ID');
    }

    // Validaciones
    final errores = actividad.validar();
    if (errores.isNotEmpty) {
      throw Exception(errores.join(', '));
    }

    // Si cambia el peso, validar que no exceda el 100%
    final actividadExistente = await _actividadDao.getById(actividad.idActividad!);
    if (actividadExistente != null &&
        actividadExistente.pesoPorcentual != actividad.pesoPorcentual) {

      final pesoActualSinEsta = await _actividadDao.sumPesosByObra(actividad.idObra);
      final pesoActualSinEstaAjustado = pesoActualSinEsta - actividadExistente.pesoPorcentual;

      if ((pesoActualSinEstaAjustado + actividad.pesoPorcentual) > 100) {
        throw Exception('El peso total de las actividades excedería el 100%');
      }
    }

    await _actividadDao.update(actividad);
    return actividad;
  }

  // ELIMINAR una actividad
  Future<void> eliminarActividad(int idActividad) async {
    await _initialize();

    final actividad = await _actividadDao.getById(idActividad);
    if (actividad == null) {
      throw Exception('La actividad no existe');
    }

    // Primero eliminar todos los avances de la actividad
    await _avanceDao.deleteByActividad(idActividad);

    // Luego eliminar la actividad
    await _actividadDao.delete(idActividad);
  }

  // OBTENER actividades por obra
  Future<List<Actividad>> obtenerActividadesPorObra(int idObra) async {
    await _initialize();

    final actividades = await _actividadDao.getByObra(idObra);

    // Calcular porcentaje completado para cada actividad
    for (var actividad in actividades) {
      if (actividad.idActividad != null) {
        final promedio = await _avanceDao.calcularPromedioPorActividad(actividad.idActividad!);
        actividad.porcentajeCompletado = promedio;
      }
    }

    return actividades;
  }

  // OBTENER actividad por ID con detalles
  Future<Actividad?> obtenerActividadConDetalles(int idActividad) async {
    await _initialize();

    final actividad = await _actividadDao.getById(idActividad);
    if (actividad == null) return null;

    // Calcular porcentaje completado
    final promedio = await _avanceDao.calcularPromedioPorActividad(idActividad);
    actividad.porcentajeCompletado = promedio;

    // Obtener avances recientes
    final avances = await _avanceDao.getByActividad(idActividad);

    return actividad;
  }

  // BUSCAR actividades
  Future<List<Actividad>> buscarActividades(String query) async {
    await _initialize();
    return await _actividadDao.search(query);
  }

  // CAMBIAR estado de una actividad
  Future<void> cambiarEstadoActividad(int idActividad, String nuevoEstado) async {
    await _initialize();

    final estadosValidos = ['PENDIENTE', 'EN_PROGRESO', 'COMPLETADA', 'ATRASADA'];
    if (!estadosValidos.contains(nuevoEstado)) {
      throw Exception('Estado no válido: $nuevoEstado');
    }

    await _actividadDao.updateEstado(idActividad, nuevoEstado);
  }

  // ACTUALIZAR peso porcentual de una actividad
  Future<void> actualizarPesoActividad(int idActividad, double nuevoPeso) async {
    await _initialize();

    if (nuevoPeso < 0 || nuevoPeso > 100) {
      throw Exception('El peso debe estar entre 0 y 100');
    }

    final actividad = await _actividadDao.getById(idActividad);
    if (actividad == null) {
      throw Exception('La actividad no existe');
    }

    // Validar que no exceda el 100%
    final pesoValido = await _actividadDao.validarPesosObra(actividad.idObra, nuevoPeso - actividad.pesoPorcentual);
    if (!pesoValido) {
      throw Exception('El peso total de las actividades excedería el 100%');
    }

    await _actividadDao.updatePeso(idActividad, nuevoPeso);
  }

  // CALCULAR porcentaje de avance de obra
  Future<double> calcularPorcentajeAvanceObra(int idObra) async {
    await _initialize();
    return await _actividadDao.calcularPorcentajeAvanceObra(idObra);
  }

  // OBTENER estadísticas de actividades por obra
  Future<Map<String, dynamic>> obtenerEstadisticasPorObra(int idObra) async {
    await _initialize();
    return await _actividadDao.getEstadisticasByObra(idObra);
  }

  // OBTENER actividades próximas a vencer
  Future<List<Actividad>> obtenerActividadesProximasAVencer({int dias = 7}) async {
    await _initialize();
    return await _actividadDao.getProximasAVencer(dias: dias);
  }

  // GENERAR reporte de actividades
  Future<Map<String, dynamic>> generarReporteActividades({
    int? idObra,
    String? estado,
  }) async {
    await _initialize();

    List<Actividad> actividades;

    if (idObra != null && estado != null) {
      actividades = await _actividadDao.getByObraAndEstado(idObra, estado);
    } else if (idObra != null) {
      actividades = await _actividadDao.getByObra(idObra);
    } else if (estado != null) {
      actividades = await _actividadDao.getByEstado(estado);
    } else {
      actividades = await _actividadDao.getAll();
    }

    // Calcular estadísticas
    int totalActividades = actividades.length;
    double totalPeso = 0;
    int completadas = 0;
    int enProgreso = 0;
    int pendientes = 0;

    for (var actividad in actividades) {
      totalPeso += actividad.pesoPorcentual;

      if (actividad.estado == 'COMPLETADA') completadas++;
      else if (actividad.estado == 'EN_PROGRESO') enProgreso++;
      else if (actividad.estado == 'PENDIENTE') pendientes++;
    }

    return {
      'total_actividades': totalActividades,
      'total_peso': totalPeso,
      'completadas': completadas,
      'en_progreso': enProgreso,
      'pendientes': pendientes,
      'actividades': actividades,
    };
  }

  // OBTENER resumen completo de obra (actividades + avances)
  Future<Map<String, dynamic>> obtenerResumenObra(int idObra) async {
    await _initialize();

    final actividades = await obtenerActividadesPorObra(idObra);
    final porcentajeAvance = await calcularPorcentajeAvanceObra(idObra);
    final estadisticas = await obtenerEstadisticasPorObra(idObra);

    // Obtener avances recientes
    final avancesRecientes = await _avanceDao.getByObra(idObra);
    avancesRecientes.sort((a, b) => b.fecha.compareTo(a.fecha));
    final ultimosAvances = avancesRecientes.take(5).toList();

    return {
      'actividades': actividades,
      'porcentaje_avance': porcentajeAvance,
      'estadisticas': estadisticas,
      'ultimos_avances': ultimosAvances,
      'total_actividades': actividades.length,
    };
  }

  // VALIDAR que se pueda crear una actividad en una obra
  Future<List<String>> validarCreacionActividad({
    required int idObra,
    required double pesoPorcentual,
  }) async {
    await _initialize();

    final errores = <String>[];

    // Verificar que la obra exista
    final obra = await _obraDao.getById(idObra);
    if (obra == null) {
      errores.add('La obra no existe');
      return errores;
    }

    // Validar peso porcentual
    if (pesoPorcentual <= 0 || pesoPorcentual > 100) {
      errores.add('El peso porcentual debe estar entre 0.1 y 100');
    }

    // Verificar que no se exceda el 100%
    final pesoValido = await _actividadDao.validarPesosObra(idObra, pesoPorcentual);
    if (!pesoValido) {
      errores.add('El peso total de las actividades excede el 100%');
    }

    return errores;
  }
}