class ContainerItem {
  final int? id;
  final String code;
  final String type;
  final String status;
  final String? location; // ✅ nullable
  final String? owner;    // ✅ nullable

  ContainerItem({
    this.id,
    required this.code,
    required this.type,
    required this.status,
    this.location, // ✅
    this.owner,    // ✅
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'type': type,
      'status': status,
      'location': location,
      'owner': owner,
    };
  }

  factory ContainerItem.fromMap(Map<String, dynamic> map) {
    return ContainerItem(
      id: map['id'] as int?,
      code: map['code'] as String,
      type: map['type'] as String,
      status: map['status'] as String,
      location: map['location'] as String?, // ✅ รับ null ได้
      owner: map['owner'] as String?,       // ✅ รับ null ได้
    );
  }
}
