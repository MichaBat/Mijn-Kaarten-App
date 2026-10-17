import 'package:bonidus_apidus/domain/entities/card_item.dart';
import 'package:bonidus_apidus/presentation/viewmodels/card_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_card_repository.dart';

void main() {
  late FakeCardRepository repository;
  late CardViewmodel viewModel;

  setUp(() {
    repository = FakeCardRepository();
    viewModel = CardViewmodel(cardRepository: repository);
  });

  group('addCard', () {
    test('trims title/domain but keeps the scanned barcode', () async {
      // Regression test: addCard used to rebuild the card with only
      // title/domain trimmed, silently dropping codeValue/codeFormat.
      await viewModel.addCard(CardItem(
        title: '  Albert Heijn  ',
        domain: '  ah.nl  ',
        codeValue: '123456789',
        codeFormat: 'ean13',
      ));

      final call = repository.addCardCalls.single;
      expect(call.title, 'Albert Heijn');
      expect(call.domain, 'ah.nl');
      expect(call.codeValue, '123456789');
      expect(call.codeFormat, 'ean13');
    });

    test('falls back to an empty code and unknown format when nothing was scanned', () async {
      await viewModel.addCard(CardItem(title: 'Jumbo', domain: 'jumbo.com'));

      final call = repository.addCardCalls.single;
      expect(call.codeValue, '');
      expect(call.codeFormat, 'unknown');
    });

    test('reloads the card list on success', () async {
      final success = await viewModel.addCard(
        CardItem(title: 'Albert Heijn', domain: 'ah.nl'),
      );

      expect(success, true);
      expect(viewModel.cardList, hasLength(1));
      expect(viewModel.cardList.single.title, 'Albert Heijn');
    });

    test('returns false and leaves the list untouched when the repository throws', () async {
      repository.throwOnAddCard = true;

      final success = await viewModel.addCard(
        CardItem(title: 'Albert Heijn', domain: 'ah.nl'),
      );

      expect(success, false);
      expect(viewModel.cardList, isEmpty);
    });
  });

  group('cardExists', () {
    test('matches case-insensitively and ignores surrounding whitespace', () async {
      await viewModel.addCard(CardItem(title: 'Albert Heijn', domain: 'ah.nl'));

      expect(viewModel.cardExists('  albert heijn ', 'AH.NL'), true);
      expect(viewModel.cardExists('Jumbo', 'jumbo.com'), false);
    });
  });

  group('addImportedCards', () {
    test('adds every entry and reloads', () async {
      final success = await viewModel.addImportedCards([
        {'title': 'Albert Heijn', 'domain': 'ah.nl'},
        {'title': 'Jumbo', 'domain': 'jumbo.com', 'codeValue': '1', 'codeFormat': 'ean13'},
      ]);

      expect(success, true);
      expect(repository.addCardCalls, hasLength(2));
      expect(viewModel.cardList, hasLength(2));
    });
  });

  group('deleteAllCards', () {
    test('clears the repository and reloads', () async {
      await viewModel.addCard(CardItem(title: 'Albert Heijn', domain: 'ah.nl'));
      expect(viewModel.cardList, hasLength(1));

      final success = await viewModel.deleteAllCards();

      expect(success, true);
      expect(viewModel.cardList, isEmpty);
    });

    test('returns false when the repository throws', () async {
      repository.throwOnRemoveAllCards = true;

      final success = await viewModel.deleteAllCards();

      expect(success, false);
    });
  });

  group('setSearchQuery', () {
    test('filters the card list by title, case-insensitively', () async {
      await viewModel.addCard(CardItem(title: 'Albert Heijn', domain: 'ah.nl'));
      await viewModel.addCard(CardItem(title: 'Jumbo', domain: 'jumbo.com'));

      viewModel.setSearchQuery('heij');

      expect(viewModel.filteredCardList, hasLength(1));
      expect(viewModel.filteredCardList.single.title, 'Albert Heijn');
    });
  });

  group('setPinned', () {
    test('returns false without touching the repository when the card has no id', () async {
      final success = await viewModel.setPinned(
        CardItem(title: 'Albert Heijn', domain: 'ah.nl'),
        true,
      );

      expect(success, false);
    });
  });
}
