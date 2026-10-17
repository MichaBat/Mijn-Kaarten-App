import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../viewmodels/card_scanner_viewmodel.dart';

class CardScanner extends StatefulWidget {
  const CardScanner({super.key});

  @override
  State<CardScanner> createState() => _CardScannerState();
}

class _CardScannerState extends State<CardScanner> {
  late final CardScannerViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CardScannerViewModel()..addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (_viewModel.detected) {
      Navigator.of(context).pop({
        'value': _viewModel.scannedValue!,
        'format': _viewModel.scannedFormat!,
      });
    } else if (_viewModel.error != null) {
      final l10n = AppLocalizations.of(context)!;
      final message = switch (_viewModel.error!) {
        CardScannerError.noCodeFoundInImage => l10n.noCodeFoundInImage,
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanCardAppBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            tooltip: l10n.pickFromGalleryTooltip,
            onPressed: _viewModel.pickImage,
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _viewModel.controller,
            onDetect: _viewModel.onDetect,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: AppConstants.borderWidth),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}