import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ServiceHttpClient {
  // final String baseUrl = 'http://10.0.2.2:8000/api/';
  final String baseUrl = 'http://192.168.0.148:8000/api/';
  final secureStorage = const FlutterSecureStorage();

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );
      return response;
    } catch (e) {
      throw Exception('Post request failed: $e');
    }
  }

  Future<http.Response> postWithToken(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final token = await secureStorage.read(key: 'authToken');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );
      return response;
    } catch (e) {
      throw Exception('Post with token request failed: $e');
    }
  }

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final token = await secureStorage.read(key: 'authToken');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      return response;
    } catch (e) {
      throw Exception('Get request failed: $e');
    }
  }

  Future<http.Response> putWithToken(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final token = await secureStorage.read(key: 'authToken');

    // Ini adalah cara yang benar untuk method spoofing di Laravel
    final Map<String, String> stringBody = body.map((key, value) => MapEntry(key, value.toString()));
    stringBody['_method'] = 'PUT';

    try {
        final response = await http.post(
            url,
            headers: {
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
            },
            body: stringBody, // Kirim sebagai form data biasa, bukan JSON
        );
        return response;
    } catch (e) {
        throw Exception('Put with token request failed: $e');
    }
}

  Future<http.Response> postMultipart(
    String endpoint, Map<String, String> body, File file, String fieldName,) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final token = await secureStorage.read(key: 'authToken');

    var request = http.MultipartRequest('POST', url);

    // Tambahkan headers
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // Tambahkan body (data teks)
    request.fields.addAll(body);

    // Tambahkan file
    request.files.add(
      await http.MultipartFile.fromPath(
        fieldName, // nama field ini harus cocok dengan di backend Laravel
        file.path,
      ),
    );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return response;
    } catch (e) {
      throw Exception('Multipart request failed: $e');
    }
  }

  Future<http.Response> deleteWithToken(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final token = await secureStorage.read(key: 'authToken');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      return response;
    } catch (e) {
      throw Exception('Delete request failed: $e');
    }
  }
}


