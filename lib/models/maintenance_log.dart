// lib/models/maintenance_log.dart
class MaintenanceLog {
  final int? id;
  final int containerId;
  final DateTime? date; // epoch millis ใน DB
  final String? remark;
  final double? cost;

  MaintenanceLog({
    this.id,
    required this.containerId,
    this.date,
    this.remark,
    this.cost,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'containerId': containerId,
        'date': date?.millisecondsSinceEpoch,
        'remark': remark,
        'cost': cost,
      };

  factory MaintenanceLog.fromMap(Map<String, dynamic> map) => MaintenanceLog(
        id: map['id'] as int?,
        containerId: map['containerId'] as int,
        date: map['date'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
        remark: map['remark'] as String?,
        cost: (map['cost'] as num?)?.toDouble(),
      );

  MaintenanceLog copyWith({
    int? id,
    int? containerId,
    DateTime? date,
    String? remark,
    double? cost,
  }) {
    return MaintenanceLog(
      id: id ?? this.id,
      containerId: containerId ?? this.containerId,
      date: date ?? this.date,
      remark: remark ?? this.remark,
      cost: cost ?? this.cost,
    );
  }
}
