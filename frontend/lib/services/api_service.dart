import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://localhost:8000/api';
  static const String _androidUrl = 'http://10.0.2.2:8000/api';

  static String get baseUrl {
    if (kIsWeb) return _baseUrl;
    // Android emulator için özel IP
    return _androidUrl;
  }

  static Future<List<Map<String, dynamic>>> getVehicles() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/vehicles'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Araclar yuklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Baglanti hatasi: $e');
    }
  }

  static Future<Map<String, dynamic>> getVehicle(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/vehicles/$id'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Arac bulunamadi');
      } else {
        throw Exception('Arac yuklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Baglanti hatasi: $e');
    }
  }

  static Future<Map<String, dynamic>> createVehicle(Map<String, dynamic> vehicle) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/vehicles'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(vehicle),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Arac eklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Baglanti hatasi: $e');
    }
  }

  static Future<Map<String, dynamic>> updateVehicle(String id, Map<String, dynamic> vehicle) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/vehicles/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(vehicle),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Arac bulunamadi');
      } else {
        throw Exception('Arac guncellenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Baglanti hatasi: $e');
    }
  }

  static Future<void> deleteVehicle(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/vehicles/$id'));

      if (response.statusCode != 200) {
        if (response.statusCode == 404) {
          throw Exception('Arac bulunamadi');
        }
        throw Exception('Arac silinemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Baglanti hatasi: $e');
    }
  }

  static Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl.replaceAll('/api', '')}/health'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Check endpoints
  static Future<List<Map<String, dynamic>>> getChecks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/checks'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Checkler yuklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Baglanti hatasi: $e');
    }
  }

  static Future<Map<String, dynamic>> createCheck(Map<String, dynamic> check) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/checks'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(check),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Check eklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Baglanti hatasi: $e');
    }
  }
}
