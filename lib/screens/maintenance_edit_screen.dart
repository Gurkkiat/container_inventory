// lib/screens/maintenance_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/maintenance_provider.dart';
import '../models/maintenance_log.dart';

class MaintenanceEditScreen extends StatefulWidget {
  final int? containerId;
  final MaintenanceLog? initial;
  const MaintenanceEditScreen({super.key, this.containerId, this.initial});

  @override
  State<MaintenanceEditScreen> createState() => _MaintenanceEditScreenState();
}

class _MaintenanceEditScreenState extends State<MaintenanceEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _remarkCtl;
  late TextEditingController _costCtl;
  DateTime? _date;
  int? _containerId;

  @override
  void initState() {
    super.initState();
    final it = widget.initial;
    _containerId = widget.containerId ?? it?.containerId;
    _remarkCtl = TextEditingController(text: it?.remark ?? '');
    _costCtl = TextEditingController(text: it?.cost?.toString() ?? '');
    _date = it?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _remarkCtl.dispose();
    _costCtl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
      initialDate: _date ?? now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'แก้ไข Maintenance' : 'เพิ่ม Maintenance')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_containerId == null)
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Container ID',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _containerId = int.tryParse(v),
                  validator: (v) =>
                      int.tryParse(v ?? '') == null ? 'ระบุ Container ID เป็นตัวเลข' : null,
                ),
              if (_containerId != null)
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Container ID',
                    border: OutlineInputBorder(),
                  ),
                  child: Text('$_containerId'),
                ),
              const SizedBox(height: 12),
              _tf(_remarkCtl, 'หมายเหตุ/รายละเอียด'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _costCtl,
                decoration: const InputDecoration(
                  labelText: 'ค่าใช้จ่าย (บาท)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null; // optional
                  return double.tryParse(v) == null ? 'กรอกตัวเลขให้ถูกต้อง' : null;
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(_date == null
                    ? 'เลือกวันที่ตรวจ/ซ่อม'
                    : 'วันที่: ${_date!.toLocal().toString().split(' ').first}'),
                onPressed: _pickDate,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('บันทึก'),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  if (_containerId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('กรุณาระบุ Container ID')),
                    );
                    return;
                  }
                  final prov = context.read<MaintenanceProvider>();
                  final item = MaintenanceLog(
                    id: widget.initial?.id,
                    containerId: _containerId!,
                    date: _date,
                    remark: _remarkCtl.text.trim().isEmpty ? null : _remarkCtl.text.trim(),
                    cost: _costCtl.text.trim().isEmpty
                        ? null
                        : double.tryParse(_costCtl.text.trim()),
                  );
                  if (isEdit) {
                    await prov.update(item);
                  } else {
                    await prov.add(item);
                  }
                  if (mounted) Navigator.pop(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _tf(TextEditingController c, String label) {
    return TextFormField(
      controller: c,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }
}
