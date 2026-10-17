import 'package:bonidus_apidus/domain/entities/card_item.dart';
import 'package:flutter/material.dart';

enum AddCardFieldError { titleRequired, domainRequired, domainInvalid, barcodeRequired }

class AddCardViewModel extends ChangeNotifier {
  AddCardViewModel({
    required Future<bool> Function(CardItem) onAddCard,
    required Future<bool> Function(CardItem) onEditCard,
    this.existingCard,
  })  : _onAddCard = onAddCard,
        _onEditCard = onEditCard {
    final card = existingCard;
    if (card != null) {
      titleController.text = card.title;
      domainController.text = card.domain;
      if (card.codeValue != null) {
        barcodeController.text = card.codeValue!;
        codeValue = card.codeValue;
        codeFormat = card.codeFormat;
      }
    }
  }

  final CardItem? existingCard;
  bool get isEditing => existingCard != null;

  final Future<bool> Function(CardItem) _onAddCard;
  final Future<bool> Function(CardItem) _onEditCard;

  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final domainController = TextEditingController();
  final barcodeController = TextEditingController();

  static final _domainPattern = RegExp(
    r'^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)+$',
  );

  AddCardFieldError? validateTitle(String? value) {
    return (value == null || value.trim().isEmpty)
        ? AddCardFieldError.titleRequired
        : null;
  }

  AddCardFieldError? validateDomain(String? value) {
    final domain = value?.trim() ?? '';
    if (domain.isEmpty) return AddCardFieldError.domainRequired;
    if (!_domainPattern.hasMatch(domain)) {
      return AddCardFieldError.domainInvalid;
    }
    return null;
  }

  AddCardFieldError? validateBarcode(String? value) {
    return (value == null || value.trim().isEmpty)
        ? AddCardFieldError.barcodeRequired
        : null;
  }

  String? codeValue;
  String? codeFormat;
  bool isSaving = false;

  void setScannedCode(String value, String format) {
    codeValue = value;
    codeFormat = format;
    barcodeController.text = value;
    notifyListeners();
  }

  Future<bool> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return false;
    }

    isSaving = true;
    notifyListeners();

    bool success = false;
    try {
      final card = CardItem(
        id: existingCard?.id,
        title: titleController.text,
        domain: domainController.text,
        codeValue: codeValue,
        codeFormat: codeFormat,
        isPinned: existingCard?.isPinned ?? false,
      );

      success = isEditing ? await _onEditCard(card) : await _onAddCard(card);
    } finally {
      isSaving = false;
      notifyListeners();
    }

    return success;
  }

  @override
  void dispose() {
    titleController.dispose();
    domainController.dispose();
    barcodeController.dispose();
    super.dispose();
  }
}