import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:bonidus_apidus/data/datasources/local_storage.dart';
import 'package:bonidus_apidus/data/models/brandcolour.dart';
import 'package:bonidus_apidus/data/services/logo_api_service.dart';
import 'package:bonidus_apidus/domain/entities/card_item.dart';
import 'package:bonidus_apidus/core/theme/card_colour_palette.dart';
import 'package:flutter/painting.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../data/datasources/database.dart';
import '../../data/models/card.dart';
import '../../domain/repositories/card_repository.dart';
import '../models/brand.dart';

class CardRepositorySQLite implements CardRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final LogoApiService _logoApiService = LogoApiService();
  final LocalStorage _localStorage = LocalStorage();

  @override
  Future<List<CardItem>> fetchCards() async {
    final cards = await _dbHelper.getCards();
    final List<CardItem> result = [];

    for (final map in cards) {
      final card = Card.fromMap(map);
      String? dominantColor;
      String? accentColor;

      if (card.brandId != null) {
        final colours = await _dbHelper.getBrandColoursByBrandId(card.brandId!);
        for (final c in colours) {
          if (c['type'] == 'dominant') dominantColor = c['color_hex'];
          if (c['type'] == 'vibrant') accentColor = c['color_hex'];
        }
        accentColor ??= dominantColor;
      }

      result.add(CardItem(
        id: card.id,
        title: card.title,
        domain: card.domain,
        logoPath: card.logoPath,
        codeValue: card.codeValue,
        codeFormat: card.codeFormat,
        dominantColor: dominantColor,
        accentColor: accentColor,
        isPinned: card.isPinned,
      ));
    }

    return result;
  }

  @override
  Future<void> addCard(String title, String domain, String codeValue, String codeFormat) async {
    final (brandId, logoPath) = await _resolveBrand(domain);

    Card newCard = Card(
      title: title,
      domain: domain,
      logoPath: logoPath,
      codeValue: codeValue,
      codeFormat: codeFormat,
      brandId: brandId,
    );

    await _dbHelper.insertCard(newCard);
  }

  @override
  Future<int> editCard(CardItem cardItem) async {
    final (brandId, logoPath) = await _resolveBrand(cardItem.domain);

    Card card = Card(
      id: cardItem.id,
      title: cardItem.title,
      domain: cardItem.domain,
      logoPath: logoPath,
      codeValue: cardItem.codeValue,
      codeFormat: cardItem.codeFormat,
      brandId: brandId,
      isPinned: cardItem.isPinned,
    );

    return _dbHelper.updateCard(card);
  }

  @override
  Future<int> setPinned(int id, bool pinned) {
    return _dbHelper.setCardPinned(id, pinned);
  }

  // Reuses the brand for [domain] if one already exists, otherwise fetches
  // the logo and creates a new brand (used by both addCard and editCard so
  // editing a card's domain re-resolves its brand/logo the same way adding does).
  Future<(int?, String?)> _resolveBrand(String domain) async {
    List<Map<String, dynamic>> brands = await _dbHelper.getBrandByDomain(domain);

    if (brands.isNotEmpty) {
      return (brands.first['id'] as int?, brands.first['logo_path'] as String?);
    }

    int? brandId;
    String? logoPath;

    File? logoFile = await _localStorage.getLogo(domain);
    if (logoFile == null) {
      try {
        Uint8List logoBytes = await _logoApiService.getLogoFromApi(domain);
        logoFile = await _localStorage.saveLogo(logoBytes, domain);

        Brand newBrand = Brand(name: domain, domain: domain, logoPath: logoFile?.path);
        brandId = await _dbHelper.insertBrand(newBrand);

        await _generateAndStorePalette(brandId, logoBytes);
      } catch (e, stackTrace) {
        log('Logo fetch failed for $domain', error: e, stackTrace: stackTrace, name: 'CardRepository');
        Brand newBrand = Brand(name: domain, domain: domain, logoPath: null);
        brandId = await _dbHelper.insertBrand(newBrand);
      }
    } else {
      logoPath = logoFile.path;
      Brand newBrand = Brand(name: domain, domain: domain, logoPath: logoPath);
      brandId = await _dbHelper.insertBrand(newBrand);

      await _generateAndStorePalette(brandId, await logoFile.readAsBytes());
    }

    logoPath = logoFile?.path;
    return (brandId, logoPath);
  }

  @override
  Future<int> removeCard(int id) async {
    return await _dbHelper.deleteCard(id);
  }

  @override
  Future<void> removeAllCards() async {
    await _dbHelper.deleteAllCards();
  }

  Future<void> _generateAndStorePalette(int brandId, Uint8List logoBytes) async {
    final palette = await PaletteGenerator.fromImageProvider(
      MemoryImage(logoBytes),
    );

    final paletteColors = <MapEntry<String, Color?>>[
      MapEntry('dominant', palette.dominantColor?.color),
      MapEntry('vibrant', palette.vibrantColor?.color),
      MapEntry('dark_vibrant', palette.darkVibrantColor?.color),
      MapEntry('light_vibrant', palette.lightVibrantColor?.color),
      MapEntry('muted', palette.mutedColor?.color),
      MapEntry('dark_muted', palette.darkMutedColor?.color),
    ];

    for (final entry in paletteColors) {
      final extractedColor = entry.value;
      if (extractedColor == null) continue;
      final color = CardColourPalette.nearestTo(extractedColor);
      final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
      final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
      final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
      await _dbHelper.insertBrandColour(BrandColour(
        brandId: brandId,
        colorHex: '#$r$g$b',
        type: entry.key,
        brightness: color.computeLuminance() > 0.179 ? 1 : 0,
      ));
    }
  }
}
