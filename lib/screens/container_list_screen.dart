// lib/screens/container_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/container_provider.dart';
import '../models/container_item.dart';

class ContainerListScreen extends StatelessWidget {
  static const routeName = '/';

  const ContainerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Container Ledger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
        ],
      ),
      body: Consumer<ContainerProvider>(
        builder: (context, provider, _) {
          final items = provider.containers;
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => provider.fetchContainers(),
              child: ListView(
                children: const [
                  SizedBox(height: 240),
                  Center(child: Text('ยังไม่มีข้อมูล Container')),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => provider.fetchContainers(),
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final c = items[i];
                final owner = (c.owner == null || c.owner!.trim().isEmpty)
                    ? '-'
                    : c.owner!;
                final location =
                    (c.location == null || c.location!.trim().isEmpty)
                    ? '-'
                    : c.location!;
                final status = c.status; // สมมติเป็น non-null
                final type = c.type; // สมมติเป็น non-null

                return Dismissible(
                  key: ValueKey('container_${c.id ?? i}'),
                  direction: DismissDirection.startToEnd,
                  background: Container(
                    color: Colors.redAccent,
                    padding: const EdgeInsets.only(left: 16),
                    alignment: Alignment.centerLeft,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('ลบรายการ?'),
                            content: Text('ต้องการลบ ${c.code} จริงหรือไม่'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('ยกเลิก'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('ลบ'),
                              ),
                            ],
                          ),
                        ) ??
                        false;
                  },
                  onDismissed: (_) async {
                    // ใช้ ctx (ของ itemBuilder) เพื่อให้แน่ใจว่า scaffold ถูกต้อง
                    await ctx.read<ContainerProvider>().deleteContainer(c.id!);
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('ลบ ${c.code} แล้ว')),
                    );
                  },
                  child: ListTile(
                    leading: const Icon(Icons.inventory_2),
                    title: Text(c.code),
                    subtitle: Text(
                      '$owner • $status • $type\n$location',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'แก้ไข',
                          icon: const Icon(Icons.edit, color: Colors.blueGrey),
                          onPressed: () {
                            Navigator.pushNamed(context, '/add', arguments: c);
                          },
                        ),
                        IconButton(
                          tooltip: 'ลบ',
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.redAccent,
                          onPressed: () async {
                            final ok =
                                await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('ลบรายการ?'),
                                    content: Text(
                                      'ต้องการลบ ${c.code} จริงหรือไม่',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('ยกเลิก'),
                                      ),
                                      FilledButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('ลบ'),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;
                            if (ok) {
                              await context
                                  .read<ContainerProvider>()
                                  .deleteContainer(c.id!);
                            }
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/detail', arguments: c);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        icon: const Icon(Icons.add),
        label: const Text('เพิ่ม Container'),
      ),
    );
  }
}
