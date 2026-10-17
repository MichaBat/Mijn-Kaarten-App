import 'dart:io';
import 'dart:developer';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class LocalStorage {
  Future<String> getDocumentPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> getLogoPath() async {
    final path = "${await getDocumentPath()}/images/logos";

    final folder = Directory(path);
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    return folder.path;
  }

  Future<File?> getLogo(String domain) async {
    var path = await getLogoPath();

    final safeName = _safeName(domain);
    final file = File("$path/$safeName.png");

    if (await file.exists()) {
      return file;
    }

    return null;
  }

  Future<File?> saveLogo(Uint8List fileBytes, String domain) async {
    try {
      String path = await getLogoPath();

      final safeName= _safeName(domain);
      final newFile = await File("$path/$safeName.png").writeAsBytes(fileBytes);

      return newFile;
    } catch (e, stacktrace) {
      log('Failed to save logo of $domain', error: e, stackTrace: stacktrace, name: 'LocalStorage');
      return null;
    }
  }

  String _safeName(String domain){
    return domain.replaceAll('.', '_');
  }
}
