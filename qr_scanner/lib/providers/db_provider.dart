import 'package:path/path.dart';
import 'dart:io';
import 'package:qr_scanner/models/scan_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

//
class DbProvider {
  static Database? _database;
  static final DbProvider db = DbProvider._();
  DbProvider._();
  //

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }
  //

  Future<Database> initDB() async {
    // Path en donde almacenaremos la base de datos
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'ScansDB.db');
    print(path);

    //crear base de datos
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE Scans ('
          ' id INTEGER PRIMARY KEY,'
          ' tipo TEXT,'
          ' valor TEXT'
          ')');
    });
  }

  Future<int> nuevoScanRaw(ScanModel nuevoScan) async {
    //verificar la base de datos
    final db = await database;
    final res = await db.rawInsert("INSERT Into Scans (id, tipo, valor) "
        "VALUES ( ${nuevoScan.id}, '${nuevoScan.tipo}', '${nuevoScan.valor}' )");
    //
    return res;
  }

  //
  //
  Future<int> nuevoScan(ScanModel nuevoScan) async {
    final db = await database;
    final res = await db.insert('Scans', nuevoScan.toJson());
    //Es el ID del ultimo registro incertado
    //print(res);
    return res;
  }

  //
  //
  Future<ScanModel?> getScanById(int id) async {
    final db = await database;
    final res = await db.query('Scans', where: 'id = ?', whereArgs: [id]);
    //
    return res.isNotEmpty ? ScanModel.fromJson(res.first) : null;
  }

  //
  //
  Future<List<ScanModel>> getTodosLosScans() async {
    final db = await database;
    final res = await db.rawQuery('''
      select * from Scans
    ''');

    List<ScanModel> list =
        res.isNotEmpty ? res.map((c) => ScanModel.fromJson(c)).toList() : [];
    //
    return list;
  }

  //
  //
  Future<List<ScanModel>> getScansPorTipo(String tipo) async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM Scans WHERE tipo='$tipo'");

    List<ScanModel> list =
        res.isNotEmpty ? res.map((c) => ScanModel.fromJson(c)).toList() : [];
    //
    return list;
  }

  //
  //
  Future<int> updateScan(ScanModel nuevoScan) async {
    final db = await database;
    final res = await db.update('Scans', nuevoScan.toJson(),
        where: 'id=?', whereArgs: [nuevoScan.id]);
    //
    return res;
  }

  //
  //
  Future<int> deleteById(int id) async {
    final db = await database;
    final res = await db.delete('Scans', where: 'id = ?', whereArgs: [id]);
    //
    return res;
  }

  //
  //
  Future<int> deleteAllScan() async {
    final db = await database;
    final res = await db.delete('Scans');
    //
    return res;
  }

  //
  //
  Future<int> deleteAllScanRaw() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM Scans');
    //
    return res;
  }

  //END CLASS
}
