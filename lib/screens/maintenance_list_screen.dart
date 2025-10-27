// lib/screens/maintenance_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/maintenance_provider.dart';
import '../models/maintenance_log.dart';

class MaintenanceListScreen extends StatefulWidget {
  final int? containerId;
  const MaintenanceListScreen({super.key, this.containerId});

  @override
  State<MaintenanceListScreen> createState() => _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends State<MaintenanceListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<MaintenanceProvider>().fetchAll(containerId: widget.containerId));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MaintenanceProvider>(
      builder: (context, prov, _) {
        final items = prov.items;
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.containerId == null
                ? 'Maintenances (ทั้งหมด)'
                : 'Maintenances ของ Container #${widget.containerId}'),
          ),
          body: items.isEmpty
              ? const Center(child: Text('ยังไม่มี Maintenance'))
              : RefreshIndicator(
                  onRefresh: () => prov.fetchAll(containerId: widget.containerId),
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final m = items[i];
                      final dateStr = m.date == null
                          ? '-'
                          : m.date!.toLocal().toString().split(' ').first;
                      final costStr = m.cost == null ? '-' : m.cost!.toStringAsFixed(2);
                      return ListTile(
                        leading: const Icon(Icons.build),
                        title: Text('ตรวจ: $dateStr   •   ค่าใช้จ่าย: $costStr'),
                        subtitle: Text(m.remark ?? '-'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueGrey),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/maintenance_edit',
                                  arguments: {'containerId': m.containerId, 'maintenance': m},
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                              onPressed: () async {
                                await prov.remove(m.id!, containerId: widget.containerId);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('ลบ Maintenance แล้ว')),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(context, '/maintenance_edit', arguments: {
                'containerId': widget.containerId,
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('เพิ่ม Maintenance'),
          ),
        );
      },
    );
  }
}
