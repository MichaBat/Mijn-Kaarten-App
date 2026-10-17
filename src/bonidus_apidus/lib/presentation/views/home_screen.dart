import 'package:bonidus_apidus/presentation/viewmodels/card_viewmodel.dart';
import 'package:bonidus_apidus/presentation/widgets/list_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bonidus_apidus/core/theme/colours.dart' as colours;
import 'package:bonidus_apidus/core/theme/text_styles.dart' as text_styles;
import 'package:bonidus_apidus/l10n/app_localizations.dart';

import 'package:bonidus_apidus/presentation/widgets/input_field.dart';

import '../widgets/appbar.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: NewAppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Text(
                  l10n.homeHeader,
                  style: text_styles.TextStyles.h2Style.copyWith(
                    color: colours.AppColours.textDark,
                  ),
                ),
                InputField(
                  onChanged: (String value) =>
                      context.read<CardViewmodel>().setSearchQuery(value),
                  title: '',
                  placeholder: l10n.searchPlaceholder,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: (colours.AppColours.accent.withValues(alpha: 0.3)),
                  border: Border(
                    top: BorderSide(
                      color: colours.AppColours.accent,
                      width: 5.0,
                    ),
                  ),
                ),
                child: Column(
                    children: [Expanded(child: ListViewWidget())]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
