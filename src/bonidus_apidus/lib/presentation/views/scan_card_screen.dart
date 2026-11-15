import 'dart:developer';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../../core/utils/barcode_format.dart';
import '../../domain/entities/card_item.dart';
import '../../l10n/app_localizations.dart';

const _exitChannel = MethodChannel('com.michabat.mycards/exit');

class ScanCardScreen extends StatefulWidget {
  const ScanCardScreen({super.key, required this.card, this.dismissOnTap = true});

  final CardItem card;

  /// Whether tapping the screen pops it. Disabled when this screen is the
  /// app's root route (opened directly from the home screen widget), since
  /// there's no previous screen underneath to pop back to.
  final bool dismissOnTap;

  @override
  State<ScanCardScreen> createState() => _ScanCardScreenState();
}

class _ScanCardScreenState extends State<ScanCardScreen> {
  @override
  void initState() {
    super.initState();
    _maximizeBrightness();
  }

  Future<void> _maximizeBrightness() async {
    try {
      await ScreenBrightness().setApplicationScreenBrightness(1.0);
    } catch (e, stackTrace) {
      log(
        "Error setting screen brightness",
        error: e,
        stackTrace: stackTrace,
        name: "ScanCardScreen",
      );
    }
  }

  @override
  void dispose() {
    ScreenBrightness().resetApplicationScreenBrightness();
    super.dispose();
  }

  Future<void> _exitApp() async {
    try {
      await _exitChannel.invokeMethod('finishAndRemoveTask');
    } catch (e, stackTrace) {
      log(
        "Error finishing widget-launched task",
        error: e,
        stackTrace: stackTrace,
        name: "ScanCardScreen",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;

    return PopScope(
      // When this screen was opened directly from the home screen widget
      // (dismissOnTap == false) it's the app's root route: there's no
      // in-app screen to pop back to, so back should finish the task
      // outright instead of leaving an empty task behind in Recents.
      canPop: widget.dismissOnTap,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !widget.dismissOnTap) {
          _exitApp();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: GestureDetector(
            onTap: widget.dismissOnTap ? () => Navigator.of(context).pop() : null,
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: card.codeValue != null
                  ? Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: BarcodeWidget(
                        barcode: resolveBarcodeFormat(card.codeFormat),
                        data: card.codeValue!,
                        drawText: false,
                        color: Colors.black,
                      ),
                    )
                  : Text(AppLocalizations.of(context)!.noBarcodeAvailable),
            ),
          ),
        ),
      ),
    );
  }
}
