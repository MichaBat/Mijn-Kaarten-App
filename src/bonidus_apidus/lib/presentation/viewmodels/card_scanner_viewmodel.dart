import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

enum CardScannerError { noCodeFoundInImage }

class CardScannerViewModel extends ChangeNotifier {
  final MobileScannerController controller = MobileScannerController();

  bool detected = false;
  String? scannedValue;
  String? scannedFormat;
  CardScannerError? error;

  void onDetect(BarcodeCapture capture) {
    if (detected) return;
    final code = capture.barcodes.firstOrNull;
    if (code?.rawValue == null) return;

    detected = true;
    scannedValue = code!.rawValue;
    scannedFormat = code.format.name;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = result?.files.firstOrNull?.path;
    if (path == null) return;

    await controller.stop();
    final capture = await controller.analyzeImage(path);
    if (capture != null) {
      onDetect(capture);
    } else {
      error = CardScannerError.noCodeFoundInImage;
      notifyListeners();
      await controller.start();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}