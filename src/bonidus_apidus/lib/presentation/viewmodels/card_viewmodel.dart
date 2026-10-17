import 'package:bonidus_apidus/domain/entities/card_item.dart';
import 'package:bonidus_apidus/domain/repositories/card_repository.dart';
import 'package:bonidus_apidus/domain/usecases/add_card_usecase.dart';
import 'package:bonidus_apidus/domain/usecases/edit_card_usecase.dart';
import 'package:bonidus_apidus/domain/usecases/get_cards_usecase.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io' show File, Platform;

class CardViewmodel extends ChangeNotifier {
  CardViewmodel({required CardRepository cardRepository})
    : _cardRepository = cardRepository {
    loadCards();
  }

  final CardRepository _cardRepository;

  late final GetCardsUseCase _getCardsUseCase = GetCardsUseCase(
    _cardRepository,
  );

  late final AddCardUsecase _addCardUsecase = AddCardUsecase(_cardRepository);

  late final EditCardUsecase _editCardUsecase = EditCardUsecase(
    _cardRepository,
  );

  List<CardItem> cardList = [];
  bool isLoading = false;
  String _searchQuery = '';

  List<CardItem> get filteredCardList {
    if (_searchQuery.isEmpty) {
      return cardList;
    }
    final query = _searchQuery.toLowerCase();
    return cardList
        .where((card) => card.title.toLowerCase().contains(query))
        .toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadCards() async {
    isLoading = true;
    notifyListeners();

    try {
      cardList = await _getCardsUseCase.getAllCards();
    } catch (e, stackTrace) {
      log(
        "Error loading cards",
        error: e,
        stackTrace: stackTrace,
        name: "CardViewmodel",
      );
    }

    isLoading = false;
    notifyListeners();

    // Fire-and-forget: the home screen widget refresh shouldn't block the
    // in-app card list from showing.
    unawaited(_syncPinnedCardsWidget());
  }

  Future<void> _syncPinnedCardsWidget() async {
    if (!Platform.isAndroid) return;

    try {
      final pinnedCards = cardList.where((card) => card.isPinned).toList();

      final pinnedData = <Map<String, dynamic>>[
        for (final card in pinnedCards)
          {
            'id': card.id,
            'logoPath': card.logoPath,
            'dominantColor': card.dominantColor,
          },
      ];

      await HomeWidget.saveWidgetData<String>(
        'pinned_cards',
        jsonEncode(pinnedData),
      );
      await HomeWidget.updateWidget(androidName: 'CardWidgetProvider');
    } catch (e, stackTrace) {
      log(
        "Error syncing pinned cards widget",
        error: e,
        stackTrace: stackTrace,
        name: "CardViewmodel",
      );
    }
  }

  Future<bool> addCard(CardItem cardItem) async {
    final trimmedCard = CardItem(
      domain: cardItem.domain.trim(),
      title: cardItem.title.trim(),
      codeValue: cardItem.codeValue,
      codeFormat: cardItem.codeFormat,
    );

    try {
      await _addCardUsecase.addCard(trimmedCard);
      await loadCards();
      return true;
    } catch (e, stackTrace) {
      log(
        "Error adding card",
        error: e,
        stackTrace: stackTrace,
        name: "CardViewmodel",
      );
      return false;
    }
  }

  Future<bool> editCard(CardItem cardItem) async {
    try {
      await _editCardUsecase.editCard(cardItem);
      await loadCards();
      return true;
    } catch (e, stackTrace) {
      log(
        "Error editing card",
        error: e,
        stackTrace: stackTrace,
        name: "CardViewmodel",
      );
      return false;
    }
  }

  Future<bool> setPinned(CardItem cardItem, bool pinned) async {
    final id = cardItem.id;

    if (id == null) {
      log(
        "Cannot pin card because id is null.",
        name: "CardViewmodel",
      );
      return false;
    }

    try {
      await _cardRepository.setPinned(id, pinned);
      await loadCards();
      return true;
    } catch (e, stackTrace) {
      log(
        "Error pinning card $id.",
        error: e,
        stackTrace: stackTrace,
        name: "CardViewmodel",
      );
      return false;
    }
  }

  Future<bool> deleteAllCards() async {
    try {
      await _cardRepository.removeAllCards();
      await loadCards();
      return true;
    } catch (e, stackTrace) {
      log(
        "Error deleting all cards",
        error: e,
        stackTrace: stackTrace,
        name: "CardViewmodel",
      );
      return false;
    }
  }

  Future<bool> exportCards() async {
    try {
      final exportData = [
        for (final card in cardList)
          {
            'title': card.title,
            'domain': card.domain,
            'codeValue': card.codeValue,
            'codeFormat': card.codeFormat,
          },
      ];

      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Kaarten exporteren',
        fileName: 'mijn_kaarten_export.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: utf8.encode(jsonEncode(exportData)),
      );

      return path != null;
    } catch (e, stackTrace) {
      log(
        "Error exporting cards",
        error: e,
        stackTrace: stackTrace,
        name: "CardViewmodel",
      );
      return false;
    }
  }

  String _cardKey(String title, String domain) =>
      '${title.trim().toLowerCase()}|${domain.trim().toLowerCase()}';

  bool cardExists(String title, String domain) {
    final key = _cardKey(title, domain);
    return cardList.any((card) => _cardKey(card.title, card.domain) == key);
  }

  /// Picks a JSON export file and returns its entries, or null if the user
  /// cancelled the picker or the file couldn't be read.
  Future<List<Map<String, dynamic>>?> pickCardsToImport() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      final path = result?.files.single.path;
      if (path == null) return null;

      final decoded = jsonDecode(await File(path).readAsString()) as List;
      return decoded.cast<Map<String, dynamic>>();
    } catch (e, stackTrace) {
      log(
        "Error reading cards to import",
        error: e,
        stackTrace: stackTrace,
        name: "CardViewmodel",
      );
      return null;
    }
  }

  Future<bool> addImportedCards(List<Map<String, dynamic>> entries) async {
    try {
      for (final map in entries) {
        await _cardRepository.addCard(
          map['title'] as String,
          map['domain'] as String,
          map['codeValue'] as String? ?? '',
          map['codeFormat'] as String? ?? 'unknown',
        );
      }

      await loadCards();
      return true;
    } catch (e, stackTrace) {
      log(
        "Error importing cards",
        error: e,
        stackTrace: stackTrace,
        name: "CardViewmodel",
      );
      return false;
    }
  }

  Future<bool> deleteCard(CardItem cardItem) async {
    final id = cardItem.id;

    if (id == null) {
      log(
        "Cannot delete card because id is null.",
        name: "CardViewmodel",
      );
      return false;
    }

    try {
      await _cardRepository.removeCard(id);
      await loadCards();
      return true;
    } catch (e, stackTrace) {
      log(
        "Error deleting card $id.",
        error: e,
        stackTrace: stackTrace,
        name: "CardViewmodel",
      );
      return false;
    }
  }
}
