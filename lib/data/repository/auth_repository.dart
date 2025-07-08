import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/request/login_request_model.dart';
import '../models/response/login_response_model.dart';
import '../services/service_http_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final ServiceHttpClient service = ServiceHttpClient();

  Future<LoginResponseModel> login(LoginRequestModel requestModel) async {
    try {
      final http.Response response = await service.post(
        'login', 
        requestModel.toJson(), 
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body);

        final loginResponse = LoginResponseModel.fromJson(responseBody);

        await service.secureStorage.write(
          key: 'authToken',
          value: loginResponse.accessToken,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', json.encode(loginResponse.user.toJson()));

        return loginResponse;
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message']);
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Nanti fungsi register, logout, dll bisa ditambahkan di sini
}
