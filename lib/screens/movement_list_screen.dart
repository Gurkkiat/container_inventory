// lib/screens/movement_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movement_provider.dart';

class MovementListScreen extends StatefulWidget {
  /// ถ้าส่ง containerId มาจะลิสต์เฉพาะของตู้นั้น
  final int? containerId;
  const MovementListScreen({super.key, this.containerId});

  @override
  State<MovementListScreen> createState() => _MovementListScreenState();
}

class _MovementListScreenState extends State<MovementListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<MovementProvider>().fetchAll(containerId: widget.containerId));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovementProvider>(
      builder: (context, prov, _) {
        final items = prov.items;
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.containerId == null
                ? 'Movements (ทั้งหมด)'
                : 'Movements ของ Container #${widget.containerId}'),
          ),
          body: items.isEmpty
              ? const Center(child: Text('ยังไม่มี Movement'))
              : RefreshIndicator(
                  onRefresh: () => prov.fetchAll(containerId: widget.containerId),
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final m = items[i];
                      final dateStr = m.movedAt == null
                          ? '-'
                          : m.movedAt!.toLocal().toString().split(' ').first;
                      return ListTile(
                        leading: const Icon(Icons.sync_alt),
                        title: Text('${m.fromLocation ?? "-"}  →  ${m.toLocation ?? "-"}'),
                        subtitle: Text('เมื่อ: $dateStr   •   โดย: ${m.byPerson ?? "-"}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueGrey),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/movement_edit',
                                  arguments: {'containerId': m.containerId, 'movement': m},
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                              onPressed: () async {
                                await prov.remove(m.id!, containerId: widget.containerId);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('ลบ Movement แล้ว')),
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
              Navigator.pushNamed(context, '/movement_edit', arguments: {
                'containerId': widget.containerId, // อาจเป็น null ถ้าเข้าเมนูรวม
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('เพิ่ม Movement'),
          ),
        );
      },
    );
  }
}
