import 'dart:convert';

import 'package:bonidus_apidus/data/models/brand_search_result.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class BrandSearchService {
  Future<List<BrandSearchResult>> search(String query) async {
    final baseUrl = dotenv.env['BRAND_SEARCH_BASE_URL'];
    final appKey = dotenv.env['BRAND_SEARCH_APP_KEY'];
    if (baseUrl == null || appKey == null) {
      throw Exception('BRAND_SEARCH_BASE_URL/BRAND_SEARCH_APP_KEY missing in .env');
    }

    final uri = Uri.parse('$baseUrl/search').replace(
      queryParameters: {'q': query},
    );

    final response = await http.get(uri, headers: {'x-app-key': appKey});

    if (response.statusCode != 200) {
      throw Exception('brand search failed with status ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (body['data'] as List<dynamic>? ?? []);
    return data
        .map((item) => BrandSearchResult.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
