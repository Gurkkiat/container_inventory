// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/container_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ContainerProvider>();
    final list = prov.containers;
    final int total = list.length;
    final int active = list.where((e) => e.status == 'Active').length;
    final int inTransit = list.where((e) => e.status == 'InTransit').length;
    final int repair = list.where((e) => e.status == 'Repair').length;
    final int retired = list.where((e) => e.status == 'Retired').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_alt),
            tooltip: 'Movements',
            onPressed: () => Navigator.pushNamed(context, '/movements'),
          ),
          IconButton(
            icon: const Icon(Icons.build),
            tooltip: 'Maintenances',
            onPressed: () => Navigator.pushNamed(context, '/maintenances'),
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () => Navigator.pushNamed(context, '/'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        children: const [
          _StatCard(title: 'ทั้งหมด', statKey: _StatKey.total),
          _StatCard(title: 'Active', statKey: _StatKey.active),
          _StatCard(title: 'InTransit', statKey: _StatKey.inTransit),
          _StatCard(title: 'Repair', statKey: _StatKey.repair),
          _StatCard(title: 'Retired', statKey: _StatKey.retired),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        icon: const Icon(Icons.add),
        label: const Text('เพิ่ม Container'),
      ),
    );
  }
}

enum _StatKey { total, active, inTransit, repair, retired }

class _StatCard extends StatelessWidget {
  final String title;
  final _StatKey statKey;
  const _StatCard({required this.title, required this.statKey, super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ContainerProvider>();
    final list = prov.containers;

    int value = 0;
    switch (statKey) {
      case _StatKey.total:
        value = list.length;
        break;
      case _StatKey.active:
        value = list.where((e) => e.status == 'Active').length;
        break;
      case _StatKey.inTransit:
        value = list.where((e) => e.status == 'InTransit').length;
        break;
      case _StatKey.repair:
        value = list.where((e) => e.status == 'Repair').length;
        break;
      case _StatKey.retired:
        value = list.where((e) => e.status == 'Retired').length;
        break;
    }

    return Card(
      child: Center(
        child: ListTile(
          title: Text(title, textAlign: TextAlign.center),
          subtitle: Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
