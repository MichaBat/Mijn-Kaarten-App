import 'package:bonidus_apidus/domain/entities/card_item.dart';
import 'package:bonidus_apidus/presentation/viewmodels/add_card_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AddCardViewModel viewModel;

  setUp(() {
    viewModel = AddCardViewModel(
      onAddCard: (_) async => true,
      onEditCard: (_) async => true,
    );
  });

  group('validateTitle', () {
    test('returns titleRequired for empty or whitespace-only input', () {
      expect(viewModel.validateTitle(''), AddCardFieldError.titleRequired);
      expect(viewModel.validateTitle('   '), AddCardFieldError.titleRequired);
      expect(viewModel.validateTitle(null), AddCardFieldError.titleRequired);
    });

    test('returns null for a non-empty title', () {
      expect(viewModel.validateTitle('Albert Heijn'), null);
    });
  });

  group('validateDomain', () {
    test('returns domainRequired when empty', () {
      expect(viewModel.validateDomain(''), AddCardFieldError.domainRequired);
    });

    test('returns domainInvalid for a malformed domain', () {
      expect(viewModel.validateDomain('not a domain'), AddCardFieldError.domainInvalid);
      expect(viewModel.validateDomain('ah'), AddCardFieldError.domainInvalid);
    });

    test('returns null for a valid domain', () {
      expect(viewModel.validateDomain('ah.nl'), null);
    });
  });

  group('validateBarcode', () {
    test('returns barcodeRequired when empty', () {
      expect(viewModel.validateBarcode(''), AddCardFieldError.barcodeRequired);
    });

    test('returns null when a value was scanned', () {
      expect(viewModel.validateBarcode('123456789'), null);
    });
  });

  group('setScannedCode', () {
    test('stores the value/format and updates the barcode field', () {
      viewModel.setScannedCode('123456789', 'ean13');

      expect(viewModel.codeValue, '123456789');
      expect(viewModel.codeFormat, 'ean13');
      expect(viewModel.barcodeController.text, '123456789');
    });
  });

  group('isEditing', () {
    test('is false without an existing card', () {
      expect(viewModel.isEditing, false);
    });

    test('is true and pre-fills fields with an existing card', () {
      final editViewModel = AddCardViewModel(
        onAddCard: (_) async => true,
        onEditCard: (_) async => true,
        existingCard: CardItem(
          id: 1,
          title: 'Albert Heijn',
          domain: 'ah.nl',
          codeValue: '123456789',
          codeFormat: 'ean13',
        ),
      );

      expect(editViewModel.isEditing, true);
      expect(editViewModel.titleController.text, 'Albert Heijn');
      expect(editViewModel.domainController.text, 'ah.nl');
      expect(editViewModel.barcodeController.text, '123456789');
    });
  });
}
