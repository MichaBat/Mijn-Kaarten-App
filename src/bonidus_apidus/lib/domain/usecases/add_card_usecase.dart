import 'package:bonidus_apidus/domain/entities/card_item.dart';
import 'package:bonidus_apidus/domain/repositories/card_repository.dart';

class AddCardUsecase {
  final CardRepository _cardRepository;
  AddCardUsecase(this._cardRepository);

  Future<void> addCard(CardItem cardItem) {
    return _cardRepository.addCard(
      cardItem.title,
      cardItem.domain,
      cardItem.codeValue ?? '',
      cardItem.codeFormat ?? 'unknown',
    );
  }
}
