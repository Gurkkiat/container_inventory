// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode (demo)'),
            value: isDark,
            onChanged: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('เดโม—ถ้าจะทำจริงให้แยก ThemeProvider')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export (CSV/JSON)'),
            onTap: () {
              // TODO: ทำ Export ข้อมูล containers/movements/maintenances
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import (CSV/JSON)'),
            onTap: () {
              // TODO: ทำ Import
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Reset DB (ลบข้อมูลทั้งหมด)'),
            onTap: () {
              // TODO: ล้างฐานข้อมูล
            },
          ),
        ],
      ),
    );
  }
}
