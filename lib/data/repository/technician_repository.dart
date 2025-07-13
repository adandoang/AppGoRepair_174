import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/response/login_response_model.dart'; // Menggunakan kembali model User
import '../services/service_http_client.dart';

class TechnicianRepository {
  final ServiceHttpClient _service = ServiceHttpClient();

  Future<List<User>> getAllTechnicians() async {
    try {
      final http.Response response = await _service.get('admin/technicians');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        List<dynamic> technicianListJson = responseBody['data'];

        List<User> technicians = technicianListJson
            .map((json) => User.fromJson(json))
            .toList();

        return technicians;
      } else {
        final errorBody = json.decode(response.body);
        throw Exception('Gagal mengambil data teknisi: ${errorBody['message']}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}