// lib/screens/container_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/container_item.dart';
import '../providers/container_provider.dart';

class AddEditScreen extends StatefulWidget {
  const AddEditScreen({super.key});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeCtl;
  late TextEditingController _typeCtl;
  late TextEditingController _statusCtl;
  late TextEditingController _locationCtl;
  late TextEditingController _ownerCtl;
  int? _id;
  ContainerItem? _initial;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ContainerItem? editItem =
        ModalRoute.of(context)!.settings.arguments as ContainerItem?;
    _codeCtl = TextEditingController(text: editItem?.code ?? '');
    _typeCtl = TextEditingController(text: editItem?.type ?? '');
    _statusCtl = TextEditingController(text: editItem?.status ?? '');
    _locationCtl = TextEditingController(text: editItem?.location ?? '');
    _ownerCtl = TextEditingController(text: editItem?.owner ?? '');
    _id = editItem?.id;
    _initial ??= ModalRoute.of(context)?.settings.arguments as ContainerItem?;
    
    final newItem = ContainerItem(
      id: _id,
      code: _codeCtl.text,
      type: _typeCtl.text,
      status: _statusCtl.text,
      location: _locationCtl.text.trim().isEmpty
          ? null
          : _locationCtl.text.trim(),
      owner: _ownerCtl.text.trim().isEmpty ? null : _ownerCtl.text.trim(),
    );
  }

  @override
  void dispose() {
    _codeCtl.dispose();
    _typeCtl.dispose();
    _statusCtl.dispose();
    _locationCtl.dispose();
    _ownerCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _id != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'แก้ไขข้อมูล Container' : 'เพิ่ม Container'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_codeCtl, 'รหัส Container'),
              _buildTextField(_typeCtl, 'ประเภท'),
              _buildTextField(_statusCtl, 'สถานะ'),
              _buildTextField(_locationCtl, 'สถานที่'),
              _buildTextField(_ownerCtl, 'เจ้าของ'),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('บันทึก'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final newItem = ContainerItem(
                      id: _id,
                      code: _codeCtl.text,
                      type: _typeCtl.text,
                      status: _statusCtl.text,
                      location: _locationCtl.text,
                      owner: _ownerCtl.text,
                    );
                    final provider = context.read<ContainerProvider>();
                    if (isEdit) {
                      await provider.updateContainer(newItem);
                    } else {
                      await provider.addContainer(newItem);
                    }
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list), label: 'รายการ'),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: 'เพิ่มข้อมูล',
          ),
        ],
        onDestinationSelected: (int index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/add');
          } else {
            Navigator.pushNamed(context, '/');
          }
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctl, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: ctl,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'กรุณากรอก $label';
          }
          return null;
        },
      ),
    );
  }
}
