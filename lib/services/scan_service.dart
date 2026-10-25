import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

class ScanService {
  // This address is correct when the app runs in Chrome (web)
  static const String baseUrl = 'http://127.0.0.1:5000';

  static Future<Map<String, dynamic>> scanFace(XFile photo) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/scan'));
    final bytes = await photo.readAsBytes();
    request.files.add(
      http.MultipartFile.fromBytes('image', bytes, filename: 'face.jpg'),
    );

    final response = await request.send().timeout(const Duration(seconds: 30));
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Scan failed (${response.statusCode})');
    }
    return jsonDecode(body) as Map<String, dynamic>;
  }
}