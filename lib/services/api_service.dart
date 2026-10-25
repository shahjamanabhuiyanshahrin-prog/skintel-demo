import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

// All backend calls live here. Some are dummy data for now.
// Your backend URL (e.g. https://api.yoursite.com). If empty, DEMO mode is used.
const String kBackendUrl = '';

// Address of your own backend (the Python server). Right for Chrome on this computer.
const String kApiBase = 'http://127.0.0.1:5000';

class ApiService {
  /// Sends the face photo and returns the skin type.
  /// Backend response: {"skinType": "Oily", "notes": "..."}
  Future<Map<String, String>> analyzeSkin(Uint8List imageBytes) async {
    if (kBackendUrl.isEmpty) {
      // DEMO: fake result when no backend is set.
      await Future.delayed(const Duration(seconds: 2));
      return {
        'type': 'Oily',
        'notes': 'Demo result. Connect a backend for real analysis.',
        'demo': 'true',
      };
    }
    final req = http.MultipartRequest('POST', Uri.parse('$kBackendUrl/analyze-skin'))
      ..files.add(http.MultipartFile.fromBytes('image', imageBytes,
          filename: 'face.jpg'));
    final res = await http.Response.fromStream(
        await req.send().timeout(const Duration(seconds: 40)));
    if (res.statusCode != 200) throw Exception('Analysis failed');
    final j = jsonDecode(res.body);
    return {
      'type': (j['skinType'] ?? 'Normal').toString(),
      'notes': (j['notes'] ?? '').toString(),
      'demo': 'false',
    };
  }

  /// Products with prices from the backend (Google Shopping), cheapest first
  /// by default. If the price search is not available, it falls back to the
  /// free Open Beauty Facts search (no prices).
  /// [sort] is 'asc' (low to high) or 'desc' (high to low).
  Future<List<Map<String, String>>> getProducts({
    String? skinType,
    String? query,
    String? category,
    String sort = 'asc',
  }) async {
    try {
      final uri = Uri.parse('$kApiBase/products').replace(queryParameters: {
        if (skinType != null) 'skin_type': skinType,
        if (category != null) 'category': category,
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        'sort': sort,
      });
      final res = await http.get(uri).timeout(const Duration(seconds: 25));
      if (res.statusCode == 200) {
        final list = (jsonDecode(res.body)['products'] as List?) ?? [];
        final items = list
            .map<Map<String, String>>((p) => {
                  'name': (p['name'] ?? '').toString(),
                  'brand': (p['store'] ?? '').toString(),
                  'image': (p['image'] ?? '').toString(),
                  'price': (p['price_text'] ?? '').toString(),
                  'link': (p['link'] ?? '').toString(),
                  'type': skinType ?? 'All',
                })
            .where((p) => p['name']!.isNotEmpty)
            .toList();
        if (items.isNotEmpty) return items;
      }
    } catch (_) {
      // fall through to the free search below
    }
    return _getProductsFree(
        skinType: skinType, query: query, category: category);
  }

  /// Free fallback: Open Beauty Facts (any brand, no prices).
  Future<List<Map<String, String>>> _getProductsFree(
      {String? skinType, String? query, String? category}) async {
    String base;
    switch (category != null ? '_cat' : skinType) {
      case '_cat':
        base = category!;
        break;
      case 'Dry':
        base = 'moisturizer dry skin';
        break;
      case 'Oily':
        base = 'oil control oily skin';
        break;
      case null:
        base = 'skin care';
        break;
      default:
        base = '$skinType skin care';
    }
    final q = (query != null && query.trim().isNotEmpty)
        ? '${query.trim()} $base'
        : base;

    final uri = Uri.https('world.openbeautyfacts.org', '/cgi/search.pl', {
      'search_terms': q,
      'search_simple': '1',
      'action': 'process',
      'json': '1',
      'page_size': '24',
      'fields': 'code,product_name,brands,image_front_small_url',
    });

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return [];
      final list = (jsonDecode(res.body)['products'] as List?) ?? [];
      return list
          .where((p) => (p['product_name'] ?? '').toString().trim().isNotEmpty)
          .map<Map<String, String>>((p) => {
                'name': p['product_name'].toString(),
                'brand': (p['brands'] ?? '').toString().split(',').first,
                'image': (p['image_front_small_url'] ?? '').toString(),
                'link': (p['code'] ?? '').toString().isEmpty
                    ? ''
                    : 'https://world.openbeautyfacts.org/product/${p['code']}',
                'type': skinType ?? 'All',
              })
          .toList();
    } catch (_) {
      return []; // network error
    }
  }

  Future<List<Map<String, String>>> getArticles() async {
    // TODO: GET /articles
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {'title': '5 tips for glowing skin', 'sub': 'Daily routine basics'},
      {'title': 'How to choose sunscreen', 'sub': 'SPF explained'},
      {'title': 'Dry vs dehydrated skin', 'sub': 'Know the difference'},
    ];
  }

  Future<List<Map<String, String>>> getNotifications() async {
    // TODO: GET /notifications
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      {'title': 'Scan result ready', 'time': '2m ago'},
      {'title': 'Dr. Jane Cooper replied', 'time': '1h ago'},
      {'title': 'New products for your skin', 'time': '1d ago'},
    ];
  }

  Future<Map<String, String>> getProfile() async {
    // TODO: GET /me
    await Future.delayed(const Duration(milliseconds: 400));
    return {'name': 'Your Name', 'email': 'you@example.com', 'skin': 'Not set'};
  }

  Future<String> sendChatMessage(String text) async {
    // TODO: POST /chat  { message: text }
    await Future.delayed(const Duration(milliseconds: 800));
    return 'Thanks for your message! (Chatbot reply will come from the backend)';
  }

  Future<bool> saveSkinProfile(Map<String, dynamic> data) async {
    // TODO: POST /skin-profile
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }
}