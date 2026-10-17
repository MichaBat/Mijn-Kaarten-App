import 'package:bonidus_apidus/domain/entities/card_item.dart';
import 'package:bonidus_apidus/domain/repositories/card_repository.dart';

class EditCardUsecase {
  final CardRepository _cardRepository;
  EditCardUsecase(this._cardRepository);

  Future<void> editCard(CardItem cardItem) {
    return _cardRepository.editCard(cardItem);
  }
}
