import 'package:sqflite/sqflite.dart';
import '../../models/obra.dart';

class ObraDao {
  final Database db;

  ObraDao(this.db);

  Future<int> insert(Obra obra) async {
    return await db.insert('obras', obra.toMap());
  }

  Future<int> update(Obra obra) async {
    return await db.update(
      'obras',
      obra.toMap(),
      where: 'id_obra = ?',
      whereArgs: [obra.idObra],
    );
  }

  Future<int> delete(int idObra) async {
    return await db.delete('obras', where: 'id_obra = ?', whereArgs: [idObra]);
  }

  Future<List<Obra>> getAll() async {
    final List<Map<String, dynamic>> maps = await db.query('obras');
    return List.generate(maps.length, (i) => Obra.fromMap(maps[i]));
  }

  Future<List<Obra>> getByEstado(String estado) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'obras',
      where: 'estado = ?',
      whereArgs: [estado],
    );
    return List.generate(maps.length, (i) => Obra.fromMap(maps[i]));
  }

  Future<List<Obra>> getActivas() async {
    return await getByEstado('ACTIVA');
  }

  Future<Obra?> getById(int idObra) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'obras',
      where: 'id_obra = ?',
      whereArgs: [idObra],
    );
    if (maps.isNotEmpty) {
      return Obra.fromMap(maps.first);
    }
    return null;
  }

  Future<double> calcularPorcentajeAvance(int idObra) async {
    // Calcular porcentaje promedio de las actividades de la obra
    final result = await db.rawQuery(
      '''
      SELECT AVG(a.porcentaje_ejecutado) as promedio
      FROM avances a
      INNER JOIN actividades act ON a.id_actividad = act.id_actividad
      WHERE act.id_obra = ?
    ''',
      [idObra],
    );

    if (result.isNotEmpty && result.first['promedio'] != null) {
      return (result.first['promedio'] as num).toDouble();
    }
    return 0.0;
  }

  Future<int> count() async {
    final result = await db.rawQuery('SELECT COUNT(*) FROM obras');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
