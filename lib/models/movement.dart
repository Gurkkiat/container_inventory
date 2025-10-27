// lib/models/movement.dart
class Movement {
  final int? id;
  final int containerId;
  final String? fromLocation;
  final String? toLocation;
  final DateTime? movedAt; // epoch millis ใน DB
  final String? byPerson;

  Movement({
    this.id,
    required this.containerId,
    this.fromLocation,
    this.toLocation,
    this.movedAt,
    this.byPerson,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'containerId': containerId,
        'fromLocation': fromLocation,
        'toLocation': toLocation,
        'movedAt': movedAt?.millisecondsSinceEpoch,
        'by': byPerson,
      };

  factory Movement.fromMap(Map<String, dynamic> map) => Movement(
        id: map['id'] as int?,
        containerId: map['containerId'] as int,
        fromLocation: map['fromLocation'] as String?,
        toLocation: map['toLocation'] as String?,
        movedAt: map['movedAt'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(map['movedAt'] as int),
        byPerson: map['by'] as String?,
      );

  Movement copyWith({
    int? id,
    int? containerId,
    String? fromLocation,
    String? toLocation,
    DateTime? movedAt,
    String? byPerson,
  }) {
    return Movement(
      id: id ?? this.id,
      containerId: containerId ?? this.containerId,
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      movedAt: movedAt ?? this.movedAt,
      byPerson: byPerson ?? this.byPerson,
    );
    }
}
