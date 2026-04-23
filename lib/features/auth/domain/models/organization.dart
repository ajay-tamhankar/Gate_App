class Organization {
  final String id;
  final String code;
  final String name;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Organization({
    required this.id,
    required this.code,
    required this.name,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });
}
