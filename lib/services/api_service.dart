
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

// All backend calls live here.
// If empty, DEMO mode is used.
const String kBackendUrl = '';

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

    final req = http.MultipartRequest(
      'POST',
      Uri.parse('$kBackendUrl/analyze-skin'),
    )..files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'face.jpg',
        ),
      );

    final res = await http.Response.fromStream(
      await req.send().timeout(const Duration(seconds: 40)),
    );

    if (res.statusCode != 200) {
      throw Exception('Analysis failed');
    }

    final j = jsonDecode(res.body);

    return {
      'type': (j['skinType'] ?? 'Normal').toString(),
      'notes': (j['notes'] ?? '').toString(),
      'demo': 'false',
    };
  }

  /// Fetches products from Open Beauty Facts.
  Future<List<Map<String, String>>> getProducts({
    String? skinType,
    String? query,
    String? category,
  }) async {
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

    final uri = Uri.https(
      'world.openbeautyfacts.org',
      '/cgi/search.pl',
      {
        'search_terms': q,
        'search_simple': '1',
        'action': 'process',
        'json': '1',
        'page_size': '24',
        'fields': 'code,product_name,brands,image_front_small_url',
      },
    );

    try {
      final res = await http.get(uri).timeout(
        const Duration(seconds: 15),
      );

      if (res.statusCode != 200) return [];

      final list = (jsonDecode(res.body)['products'] as List?) ?? [];

      return list
          .where(
            (p) => (p['product_name'] ?? '').toString().trim().isNotEmpty,
          )
          .map<Map<String, String>>((p) => {
                'name': p['product_name'].toString(),
                'brand': (p['brands'] ?? '').toString().split(',').first,
                'image': (p['image_front_small_url'] ?? '').toString(),
                'type': skinType ?? 'All',
              })
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, String>>> getArticles() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      {'title': '5 tips for glowing skin', 'sub': 'Daily routine basics'},
      {'title': 'How to choose sunscreen', 'sub': 'SPF explained'},
      {'title': 'Dry vs dehydrated skin', 'sub': 'Know the difference'},
    ];
  }

  Future<List<Map<String, String>>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return [
      {'title': 'Scan result ready', 'time': '2m ago'},
      {'title': 'Dr. Jane Cooper replied', 'time': '1h ago'},
      {'title': 'New products for your skin', 'time': '1d ago'},
    ];
  }

  Future<Map<String, String>> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return {
      'name': 'Your Name',
      'email': 'you@example.com',
      'skin': 'Not set',
    };
  }

  /// Sends a message to Skintel AI through Supabase Edge Function.
  
Future<String> sendChatMessage(String text) async {
  try {
    final response =
        await Supabase.instance.client.functions.invoke(
      'skintel-chat',
      body: {
        'message': text,
      },
    );

    print('AI FUNCTION STATUS: ${response.status}');
    print('AI FUNCTION RESPONSE: ${response.data}');

    final data = response.data;

    if (data is Map && data['reply'] != null) {
      return data['reply'].toString();
    }

    throw Exception('AI reply missing. Response: $data');
  } on FunctionException catch (e, stackTrace) {
    print('SUPABASE FUNCTION ERROR: $e');
    print(stackTrace);
    rethrow;
  } catch (e, stackTrace) {
    print('CHATBOT ERROR: $e');
    print(stackTrace);
    rethrow;
  }
}

  /// Saves skin profile.
  Future<bool> saveSkinProfile(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }
}