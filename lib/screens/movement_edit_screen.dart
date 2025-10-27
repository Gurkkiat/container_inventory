// lib/screens/movement_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movement_provider.dart';
import '../models/movement.dart';

class MovementEditScreen extends StatefulWidget {
  final int? containerId;      // บังคับให้เลือกหรือระบุ ถ้าทำจากหน้าตู้
  final Movement? initial;     // ถ้าแก้ไขจะไม่ null
  const MovementEditScreen({super.key, this.containerId, this.initial});

  @override
  State<MovementEditScreen> createState() => _MovementEditScreenState();
}

class _MovementEditScreenState extends State<MovementEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fromCtl;
  late TextEditingController _toCtl;
  late TextEditingController _byCtl;
  DateTime? _movedAt;
  int? _containerId;

  @override
  void initState() {
    super.initState();
    final it = widget.initial;
    _containerId = widget.containerId ?? it?.containerId;
    _fromCtl = TextEditingController(text: it?.fromLocation ?? '');
    _toCtl   = TextEditingController(text: it?.toLocation ?? '');
    _byCtl   = TextEditingController(text: it?.byPerson ?? '');
    _movedAt = it?.movedAt ?? DateTime.now();
  }

  @override
  void dispose() {
    _fromCtl.dispose();
    _toCtl.dispose();
    _byCtl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
      initialDate: _movedAt ?? now,
    );
    if (picked != null) setState(() => _movedAt = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'แก้ไข Movement' : 'เพิ่ม Movement')),
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
                  onChanged: (v) =>
                      _containerId = int.tryParse(v),
                  validator: (v) {
                    final id = int.tryParse(v ?? '');
                    if (id == null) return 'ระบุ Container ID เป็นตัวเลข';
                    return null;
                  },
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
              _tf(_fromCtl, 'จาก (fromLocation)'),
              const SizedBox(height: 12),
              _tf(_toCtl, 'ไป (toLocation)'),
              const SizedBox(height: 12),
              _tf(_byCtl, 'ผู้ดำเนินการ (by)'),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(_movedAt == null
                    ? 'เลือกวันที่ย้าย'
                    : 'ย้ายเมื่อ: ${_movedAt!.toLocal().toString().split(' ').first}'),
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
                  final prov = context.read<MovementProvider>();
                  final item = Movement(
                    id: widget.initial?.id,
                    containerId: _containerId!,
                    fromLocation: _fromCtl.text.trim().isEmpty ? null : _fromCtl.text.trim(),
                    toLocation: _toCtl.text.trim().isEmpty ? null : _toCtl.text.trim(),
                    movedAt: _movedAt,
                    byPerson: _byCtl.text.trim().isEmpty ? null : _byCtl.text.trim(),
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
