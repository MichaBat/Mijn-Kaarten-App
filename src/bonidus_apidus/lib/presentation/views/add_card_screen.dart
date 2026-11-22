import 'package:bonidus_apidus/domain/entities/card_item.dart';
import 'package:bonidus_apidus/presentation/viewmodels/add_card_viewmodel.dart';
import 'package:bonidus_apidus/presentation/viewmodels/card_viewmodel.dart';
import 'package:bonidus_apidus/presentation/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/colours.dart' as colours;
import '../../core/theme/text_styles.dart' as text_styles;
import '../../l10n/app_localizations.dart';
import '../widgets/appbar.dart';
import '../widgets/card_scanner.dart';

class AddCardScreen extends StatelessWidget {
  const AddCardScreen({super.key, this.existingCard});

  final CardItem? existingCard;

  @override
  Widget build(BuildContext context) {
    final cardViewmodel = context.read<CardViewmodel>();

    return ChangeNotifierProvider(
      create: (_) => AddCardViewModel(
        onAddCard: cardViewmodel.addCard,
        onEditCard: cardViewmodel.editCard,
        existingCard: existingCard,
      ),
      child: const _AddCardView(),
    );
  }
}

class _AddCardView extends StatelessWidget {
  const _AddCardView();

  Future<void> _scanCard(BuildContext context) async {
    final viewModel = context.read<AddCardViewModel>();
    final result = await Navigator.of(context).push<Map<String, String>>(
      MaterialPageRoute(builder: (_) => const CardScanner()),
    );
    if (result != null) {
      viewModel.setScannedCode(result['value']!, result['format']!);
    }
  }

  Future<void> _submit(BuildContext context) async {
    final viewModel = context.read<AddCardViewModel>();
    final success = await viewModel.submit();
    if (success && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  String? _fieldError(AppLocalizations l10n, AddCardFieldError? error) {
    switch (error) {
      case null:
        return null;
      case AddCardFieldError.titleRequired:
        return l10n.titleRequired;
      case AddCardFieldError.domainRequired:
        return l10n.domainRequired;
      case AddCardFieldError.domainInvalid:
        return l10n.domainInvalid;
      case AddCardFieldError.barcodeRequired:
        return l10n.barcodeRequired;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddCardViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: NewAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Form(
          key: viewModel.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              Text(
                viewModel.isEditing ? l10n.editCardTitle : l10n.addCardTitle,
                style: text_styles.TextStyles.h2Style.copyWith(
                  color: colours.AppColours.primary,
                ),
              ),
              InputField(
                title: l10n.titleFieldLabel,
                controller: viewModel.titleController,
                placeholder: '',
                onChanged: (String value) {},
                validator: (value) => _fieldError(l10n, viewModel.validateTitle(value)),
              ),
              InputField(
                title: l10n.domainFieldLabel,
                controller: viewModel.domainController,
                placeholder: l10n.domainFieldPlaceholder,
                onChanged: viewModel.onDomainQueryChanged,
                validator: (value) => _fieldError(l10n, viewModel.validateDomain(value)),
              ),
              if (viewModel.isSearchingBrands)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              if (viewModel.brandSuggestions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colours.AppColours.searchInputBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: viewModel.brandSuggestions.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final brand = viewModel.brandSuggestions[index];
                        return ListTile(
                          leading: Image.network(
                            brand.logoUrl,
                            width: 32,
                            height: 32,
                            errorBuilder: (_, _, _) => const Icon(Icons.business),
                          ),
                          title: Text(brand.name),
                          subtitle: Text(brand.domain),
                          onTap: () => viewModel.selectBrandSuggestion(brand),
                        );
                      },
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () => _scanCard(context),
                child: InputField(
                  title: l10n.scanFieldLabel,
                  controller: viewModel.barcodeController,
                  placeholder: '',
                  readOnly: true,
                  validator: (value) => _fieldError(l10n, viewModel.validateBarcode(value)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _scanCard(context),
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(l10n.scanCardButton),
              ),
              SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: TextButton(
                    onPressed:
                        viewModel.isSaving ? null : () => _submit(context),
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        colours.AppColours.primary,
                      ),
                      foregroundColor: WidgetStatePropertyAll(
                        colours.AppColours.textPrimary,
                      ),
                    ),
                    child: Text(
                      viewModel.isEditing ? l10n.updateButton : l10n.addButton,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}