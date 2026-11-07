class Interest {
  final int id;
  final String name;
  final String? icon;

  Interest({required this.id, required this.name, this.icon});

  factory Interest.fromMap(Map<String, dynamic> map) {
    return Interest(
      id: map['id'] ?? map['interest_id'] ?? 0,
      name: map['title'] ?? map['name'] ?? '',
      icon: map['icon'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': name, 'icon': icon};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Interest && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Interest(id: $id, name: $name)';
}
