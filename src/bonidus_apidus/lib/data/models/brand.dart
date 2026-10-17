class Brand {
  final int? id;
  final String name;
  final String domain;
  final String? logoPath;

  Brand({ this.id, required this.name, required this.domain, this.logoPath});

  Map<String, Object?> toMap() {
    return {'name': name, 'domain': domain, 'logo_path' : logoPath};
  }

  factory Brand.fromMap(Map<String, dynamic> map) {
    return Brand(id: map['id'], name: map['name'], domain: map['domain'], logoPath: map['logo_path']);
  }
}
