import 'dart:developer';
import 'package:bonidus_apidus/domain/repositories/card_repository.dart';

class RemoveCardUsecase {
  final CardRepository _cardRepository;

  RemoveCardUsecase(this._cardRepository);

  Future<bool> removeCard(int id) async {
    try {
      _cardRepository.removeCard(id);
      return true;
    } catch (e, stackTrace) {
      log(
        "Error removing card",
        error: e,
        stackTrace: stackTrace,
        name: "GetCardsUsecase",
      );
      return false;
    }
  }
}