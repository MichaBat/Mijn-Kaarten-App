import 'package:barcode_widget/barcode_widget.dart';
import 'package:bonidus_apidus/core/theme/colours.dart';
import 'package:bonidus_apidus/core/utils/barcode_format.dart';
import 'package:bonidus_apidus/domain/entities/card_item.dart';
import 'package:bonidus_apidus/l10n/app_localizations.dart';
import 'package:bonidus_apidus/presentation/views/add_card_screen.dart';
import 'package:bonidus_apidus/presentation/views/scan_card_screen.dart';
import 'package:bonidus_apidus/presentation/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bonidus_apidus/core/theme/text_styles.dart' as text_styles;

import '../viewmodels/card_viewmodel.dart';
import '../viewmodels/view_card_viewmodel.dart';

class ViewCardScreen extends StatelessWidget {
  const ViewCardScreen({
    super.key,
    required this.card,
  });

  final CardItem card;

  @override
  Widget build(BuildContext context) {
    final cardViewModel = context.read<CardViewmodel>();

    return ChangeNotifierProvider(
      create: (_) => ViewCardViewmodel(
        card: card,
        onDeleteCard: cardViewModel.deleteCard,
        onSetPinned: cardViewModel.setPinned,
      ),
      child: const _ViewCardView(),
    );
  }
}

class _ViewCardView extends StatelessWidget {
  const _ViewCardView();

  void _openScan(BuildContext context, CardItem card) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ScanCardScreen(card: card)),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final viewModel = context.read<ViewCardViewmodel>();

    final success = await viewModel.deleteCard();

    if (success && context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _edit(BuildContext context) async {
    final viewModel = context.read<ViewCardViewmodel>();
    final cardViewModel = context.read<CardViewmodel>();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddCardScreen(existingCard: viewModel.card),
      ),
    );

    if (!context.mounted) return;

    final id = viewModel.card.id;
    final updated = cardViewModel.cardList.where((c) => c.id == id);
    if (updated.isNotEmpty) {
      viewModel.updateCard(updated.first);
    }
  }

  Future<void> _togglePinned(BuildContext context) async {
    final viewModel = context.read<ViewCardViewmodel>();
    await viewModel.togglePinned();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ViewCardViewmodel>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: NewAppBar(
        actions: [
          IconButton(
            icon: Icon(
              viewModel.card.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            ),
            onPressed: viewModel.isPinning ? null : () => _togglePinned(context),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _edit(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                viewModel.card.title,
                style: text_styles.TextStyles.h1Style.copyWith(
                  color: AppColours.primary,
                ),
              ),
        
              const SizedBox(height: 20),
        
              Text(
                viewModel.card.domain,
                style: text_styles.TextStyles.h2Style,
              ),
        
              const SizedBox(height: 30),
        
              if (viewModel.card.codeValue != null)
                GestureDetector(
                  onTap: () => _openScan(context, viewModel.card),
                  child: SizedBox(
                    height: 220,
                    child: BarcodeWidget(
                      barcode: resolveBarcodeFormat(viewModel.card.codeFormat),
                      data: viewModel.card.codeValue!,
                      drawText: false,
                      color: Colors.black,
                    ),
                  ),
                )
              else
                Center(
                  child: Text(l10n.noBarcodeAvailable),
                ),
        
              const SizedBox(height: 20),
        
              if (viewModel.card.codeValue != null)
                Text(
                  viewModel.card.codeValue!,
                  textAlign: TextAlign.center,
                ),
        
              TextButton(
                onPressed: viewModel.isDeleting
                    ? null
                    : () => _delete(context),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: viewModel.isDeleting
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : Text(l10n.delete),
              ),
            ],
          ),
        ),
      ),
    );
  }
}