import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

class ScanService {
  // Online Render backend
  static const String baseUrl = 'https://skintel-demo.onrender.com';

  static Future<Map<String, dynamic>> scanFace(XFile photo) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/scan'),
    );

    final bytes = await photo.readAsBytes();

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: 'face.jpg',
      ),
    );

    final response = await request.send().timeout(
      const Duration(seconds: 120),
    );

    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Scan failed (${response.statusCode})');
    }

    return jsonDecode(body) as Map<String, dynamic>;
  }
}