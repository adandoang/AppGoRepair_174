import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../services/service_http_client.dart';

class CategoryRepository {
  final ServiceHttpClient _service = ServiceHttpClient();

  Future<List<CategoryModel>> getAllCategories() async {
    try {
      // Endpoint untuk mengambil kategori ada di rute admin
      final http.Response response = await _service.get('categories');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        List<dynamic> categoryListJson = responseBody['data'];

        // Ubah setiap item di list menjadi CategoryModel
        List<CategoryModel> categories = categoryListJson
            .map((json) => CategoryModel.fromJson(json))
            .toList();

        return categories;
      } else {
        final errorBody = json.decode(response.body);
        throw Exception('Gagal mengambil kategori: ${errorBody['message']}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}