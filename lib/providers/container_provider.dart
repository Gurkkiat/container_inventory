// lib/providers/container_provider.dart
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/container_item.dart';
import 'db_service.dart';

class ContainerProvider extends ChangeNotifier {
  Database? _db;
  List<ContainerItem> containers = [];
  String _query = '';
  String _status = '';

  Future<void> initDb() async {
    _db = await DatabaseService.instance.database;
    await fetchContainers();
  }

  Future<void> fetchContainers() async {
    final db = _db!;
    final where = <String>[];
    final args = <Object?>[];

    if (_query.isNotEmpty) {
      final q = '%$_query%';
      where.add('(code LIKE ? OR location LIKE ? OR owner LIKE ?)');
      args..add(q)..add(q)..add(q);
    }
    if (_status.isNotEmpty) {
      where.add('status = ?');
      args.add(_status);
    }

    final rows = await db.query(
      'containers',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'id DESC',
    );
    containers = rows.map(ContainerItem.fromMap).toList();
    notifyListeners();
  }

  void setQuery(String q) {
    _query = q.trim();
    fetchContainers();
  }

  void setStatusFilter(String status) {
    _status = status;
    fetchContainers();
  }

  Future<void> addContainer(ContainerItem item) async {
    final db = _db!;
    await db.insert('containers', item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort);
    await fetchContainers();
  }

  Future<void> updateContainer(ContainerItem item) async {
    final db = _db!;
    await db.update('containers', item.toMap(),
        where: 'id = ?', whereArgs: [item.id], conflictAlgorithm: ConflictAlgorithm.abort);
    await fetchContainers();
  }

  Future<void> deleteContainer(int id) async {
    final db = _db!;
    await db.delete('containers', where: 'id = ?', whereArgs: [id]);
    await fetchContainers();
  }
}
