import 'package:bonidus_apidus/domain/entities/card_item.dart';
import 'package:bonidus_apidus/domain/repositories/card_repository.dart';

class GetCardsUseCase {
  final CardRepository _cardRepository;
  GetCardsUseCase(this._cardRepository);

  Future<List<CardItem>> getAllCards() async{
    return await _cardRepository.fetchCards();
  }
}