// lib/main.dart
import 'package:container_inventory/models/container_item.dart';
import 'package:container_inventory/models/maintenance_log.dart';
import 'package:container_inventory/models/movement.dart';
import 'package:container_inventory/providers/maintenance_provider.dart';
import 'package:container_inventory/providers/movement_provider.dart';
import 'package:container_inventory/screens/container_detail_screen.dart';
import 'package:container_inventory/screens/home_screen.dart';
import 'package:container_inventory/screens/maintenance_edit_screen.dart';
import 'package:container_inventory/screens/movement_edit_screen.dart';
import 'package:container_inventory/screens/movement_list_screen.dart';
import 'package:container_inventory/screens/maintenance_list_screen.dart'; // ✅ เพิ่ม
import 'package:container_inventory/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/container_provider.dart';
import 'screens/container_list_screen.dart';
import 'screens/container_edit_screen.dart';

void main() {
  runApp(const ContainerApp());
}

class ContainerApp extends StatelessWidget {
  const ContainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ContainerProvider()..initDb()),
        ChangeNotifierProvider(create: (_) => MovementProvider()..init()),
        ChangeNotifierProvider(create: (_) => MaintenanceProvider()..init()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Container Ledger',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        initialRoute: '/home',

        // ✅ เหลือเฉพาะ route ที่ "ไม่รับ arguments"
        routes: {
          '/home': (_) => const HomeScreen(),
          '/': (_) => const ContainerListScreen(),
          '/settings': (_) => const SettingsScreen(),
        },

        // ✅ ทุกหน้าที่ "รับ arguments" มาอยู่ใน onGenerateRoute
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/add': // เพิ่ม/แก้ Container (ส่ง ContainerItem? เป็น args)
              return MaterialPageRoute(
                builder: (_) => const AddEditScreen(),
                settings: settings,
              );

            case '/detail': // ✅ ต่อเข้าหน้า detail จริง
              final item = settings.arguments as ContainerItem;
              return MaterialPageRoute(
                builder: (_) => ContainerDetailScreen(item: item),
                settings: settings,
              );

            case '/movements': // (int? containerId)
              final int? containerId = settings.arguments as int?;
              return MaterialPageRoute(
                builder: (_) => MovementListScreen(containerId: containerId),
                settings: settings,
              );

            case '/movement_edit': // ({containerId:int?, movement:Movement?})
              final args = (settings.arguments as Map?) ?? {};
              return MaterialPageRoute(
                builder: (_) => MovementEditScreen(
                  containerId: args['containerId'] as int?,
                  initial: args['movement'] as Movement?,
                ),
                settings: settings,
              );

            case '/maintenances': // (int? containerId)
              final int? containerId = settings.arguments as int?;
              return MaterialPageRoute(
                builder: (_) => MaintenanceListScreen(containerId: containerId),
                settings: settings,
              );

            case '/maintenance_edit': // ({containerId:int?, maintenance:MaintenanceLog?})
              final args = (settings.arguments as Map?) ?? {};
              return MaterialPageRoute(
                builder: (_) => MaintenanceEditScreen(
                  containerId: args['containerId'] as int?,
                  initial: args['maintenance'] as MaintenanceLog?,
                ),
                settings: settings,
              );
          }
          return null;
        },
      ),
    );
  }
}
