// lib/providers/maintenance_provider.dart
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/maintenance_log.dart';
import 'db_service.dart';

class MaintenanceProvider extends ChangeNotifier {
  Database? _db;
  List<MaintenanceLog> items = [];

  Future<void> init() async {
    _db = await DatabaseService.instance.database;
    await fetchAll();
  }

  Future<void> fetchAll({int? containerId}) async {
    _db ??= await DatabaseService.instance.database; // ✅ lazy-init
    final db = _db!;
    List<Map<String, dynamic>> rows;
    if (containerId == null) {
      rows = await db.query(
        'maintenances',
        orderBy: 'date DESC, id DESC', // ✅ ลบ NULLS LAST
      );
    } else {
      rows = await db.query(
        'maintenances',
        where: 'containerId = ?',
        whereArgs: [containerId],
        orderBy: 'date DESC, id DESC', // ✅ ลบ NULLS LAST
      );
    }
    items = rows.map(MaintenanceLog.fromMap).toList();
    notifyListeners();
  }

  Future<void> add(MaintenanceLog item) async {
    final db = _db!;
    await db.insert(
      'maintenances',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    await fetchAll(containerId: item.containerId);
  }

  Future<void> update(MaintenanceLog item) async {
    final db = _db!;
    await db.update(
      'maintenances',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    await fetchAll(containerId: item.containerId);
  }

  Future<void> remove(int id, {int? containerId}) async {
    final db = _db!;
    await db.delete('maintenances', where: 'id = ?', whereArgs: [id]);
    await fetchAll(containerId: containerId);
  }
}
