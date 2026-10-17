import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'package:bonidus_apidus/core/theme/colours.dart' as colours;
import 'package:bonidus_apidus/core/theme/text_styles.dart' as text_styles;
import 'package:bonidus_apidus/l10n/app_localizations.dart';

import '../viewmodels/card_viewmodel.dart';
import '../widgets/appbar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _deleteAll(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteAllDialogTitle),
        content: Text(l10n.deleteAllDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: colours.AppColours.alert,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = await context.read<CardViewmodel>().deleteAllCards();
    if (!context.mounted) return;
    _showSnackbar(
      context,
      success ? l10n.deleteAllSuccess : l10n.deleteAllFailure,
    );
  }

  Future<void> _export(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final success = await context.read<CardViewmodel>().exportCards();
    if (!context.mounted) return;
    _showSnackbar(
      context,
      success ? l10n.exportSuccess : l10n.exportFailure,
    );
  }

  Future<void> _import(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.read<CardViewmodel>();

    final entries = await viewModel.pickCardsToImport();
    if (entries == null) return;
    if (!context.mounted) return;

    final hasDuplicates = entries.any(
      (entry) => viewModel.cardExists(
        entry['title'] as String,
        entry['domain'] as String,
      ),
    );

    var toImport = entries;
    if (hasDuplicates) {
      final onlyNew = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(l10n.importDuplicatesDialogTitle),
          content: Text(l10n.importDuplicatesDialogContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.importOnlyNew),
            ),
          ],
        ),
      );

      if (onlyNew == null || !context.mounted) return;
      toImport = entries
          .where(
            (entry) => !viewModel.cardExists(
              entry['title'] as String,
              entry['domain'] as String,
            ),
          )
          .toList();
    }

    final success = await viewModel.addImportedCards(toImport);
    if (!context.mounted) return;
    _showSnackbar(
      context,
      success ? l10n.importSuccess : l10n.importFailure,
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: NewAppBar(title: l10n.settingsTitle),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(l10n.aboutSectionTitle, style: text_styles.TextStyles.h3Style),
          const SizedBox(height: 8),
          Text(l10n.appTitle, style: text_styles.TextStyles.textStyle),
          Text(l10n.appDescription, style: text_styles.TextStyles.textSmallStyle),
          const SizedBox(height: 4),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '';
              return Text(
                l10n.appVersionLabel(version),
                style: text_styles.TextStyles.textSmallStyle,
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            l10n.cardManagementSectionTitle,
            style: text_styles.TextStyles.h3Style,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _export(context),
            icon: const Icon(Icons.upload_file),
            label: Text(l10n.exportCardsButton),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _import(context),
            icon: const Icon(Icons.download),
            label: Text(l10n.importCardsButton),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _deleteAll(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: colours.AppColours.alert,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete_forever),
            label: Text(l10n.deleteAllButton),
          ),
        ],
      ),
    );
  }
}
