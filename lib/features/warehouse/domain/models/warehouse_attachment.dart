class WarehouseAttachment {
  final String id;
  final String fileName;

  const WarehouseAttachment({required this.id, required this.fileName});

  factory WarehouseAttachment.fromJson(Map<String, dynamic> json) {
    final idValue = (json['id'] ?? json['attachmentId'] ?? json['attachment_id'] ?? '').toString();
    final nameValue = (json['fileName'] ?? json['filename'] ?? json['name'] ?? idValue).toString();
    return WarehouseAttachment(id: idValue, fileName: nameValue);
  }
}
