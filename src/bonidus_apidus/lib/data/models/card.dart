class Card {
  final int? id;
  final String title;
  final String? logoPath;
  final String domain;
  final String? codeValue;
  final String? codeFormat;
  final int? brandId;
  final bool isPinned;

  Card({
    this.id,
    required this.title,
    required this.domain,
    this.logoPath,
    this.codeValue,
    this.codeFormat,
    this.brandId,
    this.isPinned = false,
  });

  Map<String, Object?> toMap() {
    return {
      'id':id,
      'title': title,
      'domain': domain,
      'logo_path': logoPath,
      'code_value': codeValue,
      'code_format': codeFormat,
      'brand_id': brandId,
      'is_pinned': isPinned ? 1 : 0,
    };
  }

  factory Card.fromMap(Map<String, dynamic> map) {
    return Card(
      id: map['id'],
      title: map['title'],
      domain: map['domain'],
      logoPath: map['logo_path'],
      codeValue: map['code_value'],
      codeFormat: map['code_format'],
      brandId: map['brand_id'],
      isPinned: (map['is_pinned'] as int?) == 1,
    );
  }
}
