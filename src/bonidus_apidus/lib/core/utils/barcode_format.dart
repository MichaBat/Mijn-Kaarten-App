import 'package:barcode_widget/barcode_widget.dart';

Barcode resolveBarcodeFormat(String? format) {
  switch (format) {
    case 'qrCode':
      return Barcode.qrCode();
    case 'ean13':
      return Barcode.ean13();
    case 'ean8':
      return Barcode.ean8();
    case 'code128':
      return Barcode.code128();
    case 'code39':
      return Barcode.code39();
    case 'code93':
      return Barcode.code93();
    case 'upcA':
      return Barcode.upcA();
    case 'upcE':
      return Barcode.upcE();
    case 'itf':
      return Barcode.itf();
    case 'pdf417':
      return Barcode.pdf417();
    case 'dataMatrix':
      return Barcode.dataMatrix();
    case 'aztec':
      return Barcode.aztec();
    default:
      return Barcode.qrCode();
  }
}
