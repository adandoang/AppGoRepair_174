import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/request/login_request_model.dart';
import '../models/response/login_response_model.dart';
import '../services/service_http_client.dart';
import '../models/request/register_request_model.dart';
import '../models/request/update_profile_request_model.dart';

class AuthRepository {
  // Variabel _service didefinisikan di sini, di dalam class
  final ServiceHttpClient _service = ServiceHttpClient();

  // Method login yang sudah ada
  Future<LoginResponseModel> login(LoginRequestModel requestModel) async {
    try {
      final http.Response response = await _service.post(
        'login',
        requestModel.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        final loginResponse = LoginResponseModel.fromJson(responseBody);

        await _service.secureStorage.write(
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

  // Method logout yang baru
  Future<void> logout() async {
    try {
      // Panggil endpoint logout di server
      await _service.postWithToken('logout', {});
    } catch (e) {
      print('Gagal logout di server, tapi data lokal tetap dihapus: $e');
    } finally {
      // Selalu hapus data lokal, baik logout di server berhasil maupun gagal
      await _service.secureStorage.delete(key: 'authToken');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
    }
  }

  Future<void> register(RegisterRequestModel requestModel) async {
    try {
      // Panggil endpoint 'register' dengan method post biasa (tanpa token)
      final response = await _service.post(
        'register',
        requestModel.toJson(),
      );

      if (response.statusCode != 201) {
        // Jika gagal, lempar error dengan pesan dari server
        final errorBody = json.decode(response.body);
        // Error validasi dari laravel biasanya ada di 'errors'
        final errorMessage = errorBody['errors']?.toString() ?? errorBody['message'] ?? 'Registrasi gagal';
        throw Exception(errorMessage);
      }
      // Jika berhasil, tidak perlu melakukan apa-apa lagi di sini
      // Pengguna akan diarahkan ke halaman login untuk login pertama kali

    } catch (e) {
      throw Exception('Terjadi kesalahan saat registrasi: $e');
    }
  }

  Future<User> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString != null) {
      return User.fromJson(json.decode(userString));
    } else {
      throw Exception('User tidak ditemukan.');
    }
  }

  // Mengupdate profil
  Future<User> updateProfile(UpdateProfileRequestModel requestModel) async {
    try {
      // Gunakan metode putWithToken yang sudah kita buat
      final response = await _service.putWithToken(
        'user/update',
        requestModel.toJson(),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final updatedUser = User.fromJson(responseBody['data']);

        // Perbarui juga data user di local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', json.encode(updatedUser.toJson()));

        return updatedUser;
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Gagal update profil');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

}