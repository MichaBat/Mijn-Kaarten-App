import 'package:flutter/material.dart';
import 'package:bonidus_apidus/core/theme/colours.dart' as colours;
import 'package:bonidus_apidus/core/theme/text_styles.dart' as text_styles;
import 'package:bonidus_apidus/l10n/app_localizations.dart';

class NewAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;

  const NewAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title ?? AppLocalizations.of(context)!.appTitle),
      backgroundColor: colours.AppColours.primary,
      foregroundColor: colours.AppColours.textPrimary,
      centerTitle: true,
      titleTextStyle: text_styles.TextStyles.h1Style,
      leading: leading,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}