import 'package:bonidus_apidus/domain/entities/card_item.dart';
import 'package:bonidus_apidus/domain/repositories/card_repository.dart';

class AddCardCall {
  AddCardCall(this.title, this.domain, this.codeValue, this.codeFormat);

  final String title;
  final String domain;
  final String codeValue;
  final String codeFormat;
}

/// In-memory [CardRepository] for ViewModel unit tests — no database, no
/// platform channels.
class FakeCardRepository implements CardRepository {
  final List<CardItem> cards = [];
  final List<AddCardCall> addCardCalls = [];

  bool throwOnAddCard = false;
  bool throwOnRemoveAllCards = false;

  int _nextId = 1;

  @override
  Future<List<CardItem>> fetchCards() async => List.unmodifiable(cards);

  @override
  Future<void> addCard(
    String title,
    String domain,
    String codeValue,
    String codeFormat,
  ) async {
    addCardCalls.add(AddCardCall(title, domain, codeValue, codeFormat));
    if (throwOnAddCard) throw Exception('addCard failed');

    cards.add(CardItem(
      id: _nextId++,
      title: title,
      domain: domain,
      codeValue: codeValue.isEmpty ? null : codeValue,
      codeFormat: codeFormat == 'unknown' ? null : codeFormat,
    ));
  }

  @override
  Future<int> editCard(CardItem card) async {
    final index = cards.indexWhere((c) => c.id == card.id);
    if (index == -1) return 0;
    cards[index] = card;
    return 1;
  }

  @override
  Future<int> removeCard(int id) async {
    final before = cards.length;
    cards.removeWhere((c) => c.id == id);
    return before - cards.length;
  }

  @override
  Future<void> removeAllCards() async {
    if (throwOnRemoveAllCards) throw Exception('removeAllCards failed');
    cards.clear();
  }

  @override
  Future<int> setPinned(int id, bool pinned) async {
    final index = cards.indexWhere((c) => c.id == id);
    if (index == -1) return 0;

    final c = cards[index];
    cards[index] = CardItem(
      id: c.id,
      title: c.title,
      domain: c.domain,
      logoPath: c.logoPath,
      codeValue: c.codeValue,
      codeFormat: c.codeFormat,
      dominantColor: c.dominantColor,
      accentColor: c.accentColor,
      isPinned: pinned,
    );
    return 1;
  }
}
