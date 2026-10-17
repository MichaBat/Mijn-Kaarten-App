
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class LogoApiService {
  Future<Uint8List> getLogoFromApi(String domain) async {
    final uri = Uri.https(
      "img.logo.dev",
      "/$domain",
      {"token": dotenv.env["LOGO_DEV_TOKEN"]},
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception("logo.dev returned ${response.statusCode} for $domain");
    }

    return response.bodyBytes;
  }
}