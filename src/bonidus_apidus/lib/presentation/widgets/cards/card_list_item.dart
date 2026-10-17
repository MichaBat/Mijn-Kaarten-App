  import 'dart:io';
  import 'dart:math';

  import 'package:barcode_widget/barcode_widget.dart';
  import 'package:flutter/material.dart';

  import 'package:bonidus_apidus/core/constants/app_constants.dart';
  import 'package:bonidus_apidus/core/utils/barcode_format.dart';

  import '../../../core/theme/colours.dart' as colours;
  import '../../../domain/entities/card_item.dart';
  import '../../views/view_card_screen.dart';

  class CardListItem extends StatefulWidget {
    final CardItem item;

    const CardListItem({super.key, required this.item});

    @override
    State<CardListItem> createState() => _CardListItemState();
  }

  class _CardListItemState extends State<CardListItem>
      with SingleTickerProviderStateMixin {
    late final AnimationController _shakeController;

    CardItem get item => widget.item;

    @override
    void initState() {
      super.initState();
      _shakeController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      )..forward();
    }

    @override
    void dispose() {
      _shakeController.dispose();
      super.dispose();
    }

    Color _hexToColor(String hex) {
      final buffer = StringBuffer()
        ..write('ff')
        ..write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    }

    @override
    Widget build(BuildContext context) {
      final cardColor = item.dominantColor != null
          ? _hexToColor(item.dominantColor!)
          : colours.AppColours.accentDark;
      final borderColor = item.accentColor != null
          ? _hexToColor(item.accentColor!)
          : Colors.purple;
      // Only genuinely light card colours (pastels, bright yellows, ...) flip
      // the label to primary blue — everything else keeps the white label.
      final titleColor = cardColor.computeLuminance() > 0.5
          ? colours.AppColours.primary
          : colours.AppColours.textPrimary;

      return AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          final t = _shakeController.value;
          final dx = sin(t * pi * 6) * (1 - t) * 8;
          return Transform.translate(offset: Offset(dx, 0), child: child);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ViewCardScreen(card: item)),
                  );
                },
                child: Container(
                  height: AppConstants.cardHeight,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(AppConstants.cardBorderRadius),
                      bottomLeft: Radius.circular(AppConstants.cardBorderRadius),
                      bottomRight: Radius.circular(AppConstants.cardBorderRadius),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Stack(
                                children: [
                                  Positioned(
                                    left: 37,
                                    width: constraints.maxWidth - 47,
                                    child: Container(
                                      height: AppConstants.cardContentHeight,
                                      decoration: BoxDecoration(
                                        color: colours.AppColours.textPrimary,
                                        borderRadius: const BorderRadius.only(
                                          bottomRight: Radius.circular(AppConstants.cardBorderRadius),
                                          topRight: Radius.circular(AppConstants.cardBorderRadius),
                                        ),
                                        border: Border.all(
                                          color: borderColor,
                                          width: AppConstants.borderWidth,
                                          strokeAlign:
                                              BorderSide.strokeAlignInside,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 8.0,
                                          left: item.codeFormat!.toLowerCase().contains('qr')
                                              ? 0.0
                                              : 40.0,
                                          right: 15
                                        ),
                                        child: Center(
                                          child: item.codeValue != null
                                              ? BarcodeWidget(
                                                  barcode: resolveBarcodeFormat(
                                                    item.codeFormat,
                                                  ),
                                                  data: item.codeValue!,
                                                  drawText: false,
                                                  color: Colors.black,
                                                )
                                              : const Icon(
                                                  Icons.qr_code,
                                                  size: 40,
                                                  color: Colors.grey,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 74,
                                    height: 75,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: colours.AppColours.textPrimary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: borderColor,
                                          width: AppConstants.borderWidth,
                                          strokeAlign:
                                              BorderSide.strokeAlignInside,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: Transform.scale(
                                          scale: 0.95,
                                          child: item.logoPath != null
                                              ? Image.file(
                                                  File(item.logoPath!),
                                                  fit: BoxFit.contain,
                                                )
                                              : const SizedBox(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -20,
                child: Container(
                  padding: const EdgeInsets.only(top: 2, left: 7, right: 7),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(7),
                      topRight: Radius.circular(7),
                    ),
                  ),
                  child: Text(
                    item.title,
                    style: TextStyle(
                      color: titleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
