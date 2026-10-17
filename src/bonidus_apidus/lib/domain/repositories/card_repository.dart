import '../entities/card_item.dart';

abstract class CardRepository {
  Future<List<CardItem>> fetchCards();
  Future<void> addCard(String title, String domain, String codeValue, String codeFormat);
  Future<int> editCard(CardItem card);
  Future<int> removeCard(int id);
  Future<void> removeAllCards();
  Future<int> setPinned(int id, bool pinned);
}
