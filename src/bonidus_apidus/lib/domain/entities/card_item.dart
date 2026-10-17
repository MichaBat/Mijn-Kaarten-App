class CardItem {
  final int? id;
  final String title;
  final String? logoPath;
  final String domain;
  final String? codeValue;
  final String? codeFormat;
  final String? dominantColor;
  final String? accentColor;
  final bool isPinned;

  CardItem({
    this.id,
    required this.title,
    this.logoPath,
    required this.domain,
    this.codeValue,
    this.codeFormat,
    this.dominantColor,
    this.accentColor,
    this.isPinned = false,
  });

  void operator []=(String other, value) {}
}
