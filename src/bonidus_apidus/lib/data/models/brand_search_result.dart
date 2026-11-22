class BrandSearchResult {
  final String name;
  final String domain;
  final String logoUrl;

  BrandSearchResult({required this.name, required this.domain, required this.logoUrl});

  factory BrandSearchResult.fromJson(Map<String, dynamic> json) {
    return BrandSearchResult(
      name: json['name'] as String,
      domain: json['domain'] as String,
      logoUrl: json['logo_url'] as String,
    );
  }
}
