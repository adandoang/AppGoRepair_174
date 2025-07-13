import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../services/service_http_client.dart';

class CategoryRepository {
  final ServiceHttpClient _service = ServiceHttpClient();

  // READ: Mengambil semua kategori
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final http.Response response = await _service.get('categories');
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        List<dynamic> categoryListJson = responseBody['data'];
        return categoryListJson
            .map((json) => CategoryModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Gagal mengambil kategori');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // CREATE: Membuat kategori baru
  Future<CategoryModel> createCategory(String name, String? description) async {
    final body = {
      'name': name,
      'description': description ?? '',
    };
    try {
      final response = await _service.postWithToken('admin/categories', body);
      if (response.statusCode == 201) {
        return CategoryModel.fromJson(json.decode(response.body)['data']);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['errors']?.toString() ?? 'Gagal membuat kategori');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // UPDATE: Memperbarui kategori
  Future<CategoryModel> updateCategory(int categoryId, String name, String? description) async {
    final body = {
      'name': name,
      'description': description ?? '',
    };
    try {
      final response = await _service.putWithToken('admin/categories/$categoryId', body);
       if (response.statusCode == 200) {
        return CategoryModel.fromJson(json.decode(response.body)['data']);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['errors']?.toString() ?? 'Gagal memperbarui kategori');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // DELETE: Menghapus kategori
  Future<void> deleteCategory(int categoryId) async {
    try {
      final response = await _service.deleteWithToken('admin/categories/$categoryId');
      if (response.statusCode != 200) {
         final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Gagal menghapus kategori');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
