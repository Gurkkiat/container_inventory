// lib/providers/movement_provider.dart
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/movement.dart';
import 'db_service.dart';

class MovementProvider extends ChangeNotifier {
  Database? _db;
  List<Movement> items = [];

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
        'movements',
        orderBy: 'movedAt DESC, id DESC', // ✅ ลบ NULLS LAST
      );
    } else {
      rows = await db.query(
        'movements',
        where: 'containerId = ?',
        whereArgs: [containerId],
        orderBy: 'movedAt DESC, id DESC', // ✅ ลบ NULLS LAST
      );
    }
    items = rows.map(Movement.fromMap).toList();
    notifyListeners();
  }

  Future<void> add(Movement item) async {
    final db = _db!;
    await db.insert(
      'movements',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    await fetchAll(containerId: item.containerId);
  }

  Future<void> update(Movement item) async {
    final db = _db!;
    await db.update(
      'movements',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    await fetchAll(containerId: item.containerId);
  }

  Future<void> remove(int id, {int? containerId}) async {
    final db = _db!;
    await db.delete('movements', where: 'id = ?', whereArgs: [id]);
    await fetchAll(containerId: containerId);
  }
}
