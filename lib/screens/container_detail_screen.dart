// lib/screens/container_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/container_item.dart';

class ContainerDetailScreen extends StatelessWidget {
  final ContainerItem item;
  const ContainerDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('รายละเอียด: ${item.code}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _kv('Code', item.code),
          _kv('Type', item.type),
          _kv('Status', item.status),
          _kv('Location', item.location ?? ''),
          _kv('Owner', item.owner ?? ''),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.sync_alt),
            label: const Text('Movement ของตู้นี้'),
            onPressed: () =>
                Navigator.pushNamed(context, '/movements', arguments: item.id),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.build),
            label: const Text('Maintenance ของตู้นี้'),
            onPressed: () =>
                Navigator.pushNamed(context, '/maintenances', arguments: item.id),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('แก้ไขข้อมูล'),
            onPressed: () => Navigator.pushNamed(context, '/add', arguments: item),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Card(
        child: ListTile(
          title: Text(k),
          subtitle: Text(v.isEmpty ? '-' : v),
        ),
      );
}
