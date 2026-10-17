import 'package:bonidus_apidus/domain/entities/card_item.dart';
import 'package:flutter/material.dart';

class ViewCardViewmodel extends ChangeNotifier {
  ViewCardViewmodel({
    required Future<bool> Function(CardItem) onDeleteCard,
    required Future<bool> Function(CardItem, bool) onSetPinned,
    required CardItem card,
  })  : _card = card,
        _onDeleteCard = onDeleteCard,
        _onSetPinned = onSetPinned;

  CardItem _card;
  CardItem get card => _card;

  final Future<bool> Function(CardItem) _onDeleteCard;
  final Future<bool> Function(CardItem, bool) _onSetPinned;

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  bool _isPinning = false;
  bool get isPinning => _isPinning;

  void updateCard(CardItem card) {
    _card = card;
    notifyListeners();
  }

  Future<bool> deleteCard() async {
    _isDeleting = true;
    notifyListeners();

    final success = await _onDeleteCard(_card);

    _isDeleting = false;
    notifyListeners();

    return success;
  }

  Future<bool> togglePinned() async {
    final newPinned = !_card.isPinned;

    _isPinning = true;
    notifyListeners();

    final success = await _onSetPinned(_card, newPinned);

    if (success) {
      _card = CardItem(
        id: _card.id,
        title: _card.title,
        domain: _card.domain,
        logoPath: _card.logoPath,
        codeValue: _card.codeValue,
        codeFormat: _card.codeFormat,
        dominantColor: _card.dominantColor,
        accentColor: _card.accentColor,
        isPinned: newPinned,
      );
    }

    _isPinning = false;
    notifyListeners();

    return success;
  }
}