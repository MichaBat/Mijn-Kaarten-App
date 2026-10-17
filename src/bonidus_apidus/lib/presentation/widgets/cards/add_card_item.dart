import 'package:flutter/material.dart';
import 'package:bonidus_apidus/core/constants/app_constants.dart';
import 'package:bonidus_apidus/l10n/app_localizations.dart';
import '../../../core/theme/colours.dart' as colours;
import '../../../core/theme/text_styles.dart';
import '../../views/add_card_screen.dart';

class AddCardItem extends StatelessWidget {
  const AddCardItem({super.key});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddCardScreen(),
            ),
          );
        },
        child: Container(
          height: AppConstants.cardHeight,
          decoration: BoxDecoration(
            color: colours.AppColours.accent,
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 50,
                right: 10,
                top: 10,
                child: Container(
                  height: AppConstants.cardContentHeight,
                  decoration: BoxDecoration(
                    color: colours.AppColours.textPrimary,
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(AppConstants.cardBorderRadius),
                      topRight: Radius.circular(AppConstants.cardBorderRadius),
                    ),
                    border: Border.all(
                      color: colours.AppColours.primary,
                      width: AppConstants.borderWidth,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.addButton,
                        style: TextStyles.h2Style.copyWith(
                          color: colours.AppColours.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Circular container with add icon
              Positioned(
                left: 8,
                top: 10,
                child: SizedBox(
                  width: 75,
                  height: 75,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: colours.AppColours.primary,
                        width: 3,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                    ),
                    child: Icon(
                      Icons.add,
                      color: colours.AppColours.primary,
                      size: 50,
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
