import 'package:sqflite/sqflite.dart';
import '../../models/actividad.dart';

class ActividadDao {
  final Database db;

  ActividadDao(this.db);

  // INSERTAR una nueva actividad
  Future<int> insert(Actividad actividad) async {
    return await db.insert('actividades', actividad.toMap());
  }

  // ACTUALIZAR una actividad existente
  Future<int> update(Actividad actividad) async {
    return await db.update(
      'actividades',
      actividad.toMap(),
      where: 'id_actividad = ?',
      whereArgs: [actividad.idActividad],
    );
  }

  // ELIMINAR una actividad por ID
  Future<int> delete(int idActividad) async {
    return await db.delete(
      'actividades',
      where: 'id_actividad = ?',
      whereArgs: [idActividad],
    );
  }

  // OBTENER todas las actividades
  Future<List<Actividad>> getAll() async {
    final List<Map<String, dynamic>> maps = await db.query('actividades');
    return List.generate(maps.length, (i) => Actividad.fromMap(maps[i]));
  }

  // OBTENER actividad por ID
  Future<Actividad?> getById(int idActividad) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'actividades',
      where: 'id_actividad = ?',
      whereArgs: [idActividad],
    );
    if (maps.isNotEmpty) {
      return Actividad.fromMap(maps.first);
    }
    return null;
  }

  // OBTENER actividades por obra
  Future<List<Actividad>> getByObra(int idObra) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'actividades',
      where: 'id_obra = ?',
      whereArgs: [idObra],
      orderBy: 'peso_porcentual DESC',
    );
    return List.generate(maps.length, (i) => Actividad.fromMap(maps[i]));
  }

  // OBTENER actividades por estado
  Future<List<Actividad>> getByEstado(String estado) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'actividades',
      where: 'estado = ?',
      whereArgs: [estado],
      orderBy: 'id_obra, peso_porcentual DESC',
    );
    return List.generate(maps.length, (i) => Actividad.fromMap(maps[i]));
  }

  // OBTENER actividades por obra y estado
  Future<List<Actividad>> getByObraAndEstado(int idObra, String estado) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'actividades',
      where: 'id_obra = ? AND estado = ?',
      whereArgs: [idObra, estado],
      orderBy: 'peso_porcentual DESC',
    );
    return List.generate(maps.length, (i) => Actividad.fromMap(maps[i]));
  }

  // CONTAR actividades por obra
  Future<int> countByObra(int idObra) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM actividades WHERE id_obra = ?',
      [idObra],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // CONTAR actividades por estado
  Future<int> countByEstado(String estado) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM actividades WHERE estado = ?',
      [estado],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // CALCULAR suma de pesos porcentuales por obra
  Future<double> sumPesosByObra(int idObra) async {
    final result = await db.rawQuery('''
      SELECT SUM(peso_porcentual) as total_peso
      FROM actividades
      WHERE id_obra = ?
    ''', [idObra]);

    if (result.isNotEmpty && result.first['total_peso'] != null) {
      return (result.first['total_peso'] as num).toDouble();
    }
    return 0.0;
  }

  // CALCULAR porcentaje de avance de obra basado en actividades
  Future<double> calcularPorcentajeAvanceObra(int idObra) async {
    // Obtener todas las actividades de la obra con sus pesos
    final actividades = await getByObra(idObra);

    if (actividades.isEmpty) return 0.0;

    double porcentajeTotal = 0.0;

    for (var actividad in actividades) {
      // Calcular porcentaje completado de cada actividad
      final porcentajeActividad = await _calcularPorcentajeActividad(actividad.idActividad!);
      final contribucion = (actividad.pesoPorcentual * porcentajeActividad) / 100;
      porcentajeTotal += contribucion;
    }

    return porcentajeTotal;
  }

  // Método privado para calcular porcentaje de actividad
  Future<double> _calcularPorcentajeActividad(int idActividad) async {
    final result = await db.rawQuery('''
      SELECT AVG(porcentaje_ejecutado) as promedio
      FROM avances
      WHERE id_actividad = ?
    ''', [idActividad]);

    if (result.isNotEmpty && result.first['promedio'] != null) {
      return (result.first['promedio'] as num).toDouble();
    }
    return 0.0;
  }

  // ACTUALIZAR estado de una actividad
  Future<int> updateEstado(int idActividad, String estado) async {
    return await db.update(
      'actividades',
      {'estado': estado},
      where: 'id_actividad = ?',
      whereArgs: [idActividad],
    );
  }

  // ACTUALIZAR peso porcentual de una actividad
  Future<int> updatePeso(int idActividad, double nuevoPeso) async {
    return await db.update(
      'actividades',
      {'peso_porcentual': nuevoPeso},
      where: 'id_actividad = ?',
      whereArgs: [idActividad],
    );
  }

  // BUSCAR actividades por nombre o descripción
  Future<List<Actividad>> search(String query) async {
    final searchTerm = '%$query%';
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM actividades 
      WHERE nombre LIKE ? 
      OR descripcion LIKE ?
      ORDER BY id_obra, peso_porcentual DESC
    ''', [searchTerm, searchTerm]);

    return List.generate(maps.length, (i) => Actividad.fromMap(maps[i]));
  }

  // BUSCAR actividades por obra y texto
  Future<List<Actividad>> searchByObra(int idObra, String query) async {
    final searchTerm = '%$query%';
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM actividades 
      WHERE id_obra = ? 
      AND (nombre LIKE ? OR descripcion LIKE ?)
      ORDER BY peso_porcentual DESC
    ''', [idObra, searchTerm, searchTerm]);

    return List.generate(maps.length, (i) => Actividad.fromMap(maps[i]));
  }

  // OBTENER actividades próximas a vencer (con fecha estimada)
  Future<List<Actividad>> getProximasAVencer({int dias = 7}) async {
    // Esto es un ejemplo. Podrías tener un campo fecha_estimada en la tabla
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM actividades 
      WHERE estado = 'PENDIENTE' OR estado = 'EN_PROGRESO'
      ORDER BY id_obra
      LIMIT 20
    ''');

    return List.generate(maps.length, (i) => Actividad.fromMap(maps[i]));
  }

  // OBTENER estadísticas de actividades
  Future<Map<String, dynamic>> getEstadisticasByObra(int idObra) async {
    final total = await db.rawQuery(
      'SELECT COUNT(*) FROM actividades WHERE id_obra = ?',
      [idObra],
    );
    final completadas = await db.rawQuery(
      'SELECT COUNT(*) FROM actividades WHERE id_obra = ? AND estado = ?',
      [idObra, 'COMPLETADA'],
    );
    final enProgreso = await db.rawQuery(
      'SELECT COUNT(*) FROM actividades WHERE id_obra = ? AND estado = ?',
      [idObra, 'EN_PROGRESO'],
    );
    final pendientes = await db.rawQuery(
      'SELECT COUNT(*) FROM actividades WHERE id_obra = ? AND estado = ?',
      [idObra, 'PENDIENTE'],
    );

    return {
      'total': Sqflite.firstIntValue(total) ?? 0,
      'completadas': Sqflite.firstIntValue(completadas) ?? 0,
      'en_progreso': Sqflite.firstIntValue(enProgreso) ?? 0,
      'pendientes': Sqflite.firstIntValue(pendientes) ?? 0,
    };
  }

  // VERIFICAR si el peso total de actividades de una obra excede 100%
  Future<bool> validarPesosObra(int idObra, double nuevoPeso) async {
    final currentPeso = await sumPesosByObra(idObra);
    return (currentPeso + nuevoPeso) <= 100.0;
  }
}