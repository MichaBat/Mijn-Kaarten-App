class BrandColour {
  final int? id;
  final int brandId;
  final String colorHex;
  final String type;
  final int brightness;

  BrandColour({
    this.id,
    required this.brandId,
    required this.colorHex,
    required this.type,
    required this.brightness,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'brand_id': brandId,
      'color_hex': colorHex,
      'type': type,
      'brightness': brightness,
    };
  }

  factory BrandColour.fromMap(Map<String, dynamic> map) {
    return BrandColour(
      id: map['id'],
      brandId: map['brand_id'],
      colorHex: map['color_hex'],
      type: map['type'],
      brightness: map['brightness'],
    );
  }
}
