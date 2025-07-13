import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';
import '../models/request/create_order_request_model.dart';
import '../services/service_http_client.dart';

class OrderRepository {
  final ServiceHttpClient _service = ServiceHttpClient();

  // Ambil daftar order milik PELANGGAN
  Future<List<OrderModel>> getCustomerOrders() async {
    try {
      final http.Response response = await _service.get('customer/orders');
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        List<dynamic> orderListJson = responseBody['data'];
        return orderListJson.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil daftar order');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Ambil detail order milik PELANGGAN
  Future<OrderModel> getOrderDetail(int orderId) async {
    try {
      final response = await _service.get('customer/orders/$orderId');
      if (response.statusCode == 200) {
        return OrderModel.fromJson(json.decode(response.body)['data']);
      } else {
        throw Exception('Gagal mengambil detail order');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // PELANGGAN membuat order baru
  Future<OrderModel> createOrder(CreateOrderRequestModel requestModel, File imageFile) async {
    try {
      final createOrderResponse = await _service.postWithToken(
        'customer/orders', // Tambahkan prefix 'customer/'
        requestModel.toJson(),
      );

      if (createOrderResponse.statusCode != 201) {
        throw Exception('Gagal membuat order. Status: ${createOrderResponse.statusCode}');
      }
      
      final newOrder = OrderModel.fromJson(json.decode(createOrderResponse.body)['data']);
      
      final uploadResponse = await _service.postMultipart(
        'customer/orders/${newOrder.id}/upload-photo', // Tambahkan prefix 'customer/'
        {},
        imageFile,
        'photo',
      );

      if (uploadResponse.statusCode != 201) {
        print('Order dibuat, tapi gagal mengunggah foto.');
      }
      return newOrder;
    } catch (e) {
      throw Exception('Gagal memproses pesanan: $e');
    }
  }

  // PELANGGAN upload bukti bayar
  Future<void> uploadPaymentProof({required int orderId, required File imageFile}) async {
    try {
      final response = await _service.postMultipart(
        'customer/orders/$orderId/upload-payment', // Pastikan prefix 'customer/' ada
        {},
        imageFile,
        'payment_proof',
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Gagal mengunggah bukti pembayaran');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Ambil semua order untuk ADMIN
  Future<List<OrderModel>> getAdminOrders({int? categoryId, String? searchQuery}) async {
    try {
      // Bangun endpoint dasar
      String endpoint = 'admin/orders';
      
      // Siapkan parameter query
      Map<String, String> queryParams = {};
      if (categoryId != null) {
        queryParams['category_id'] = categoryId.toString();
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }

      // Gabungkan endpoint dengan query parameters jika ada
      if (queryParams.isNotEmpty) {
        String queryString = Uri(queryParameters: queryParams).query;
        endpoint += '?$queryString';
      }
      
      final http.Response response = await _service.get(endpoint);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        List<dynamic> orderListJson = responseBody['data'];
        return orderListJson.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        final errorBody = json.decode(response.body);
        throw Exception('Gagal mengambil order admin: ${errorBody['message']}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Ambil detail order untuk ADMIN
  Future<OrderModel> adminGetOrderDetail(int orderId) async {
    try {
      final response = await _service.get('admin/orders/$orderId');
      if (response.statusCode == 200) {
        return OrderModel.fromJson(json.decode(response.body)['data']);
      } else {
        throw Exception('Gagal mengambil detail order (admin)');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ADMIN update order
  Future<OrderModel> adminUpdateOrder({required int orderId, required String status, int? technicianId}) async {
    try {
      final body = {
        'status': status,
        if (technicianId != null) 'technician_id': technicianId,
      };
      final response = await _service.postWithToken(
        'admin/orders/$orderId', // Rute update admin
        body,
      );
      if (response.statusCode == 200) {
        return OrderModel.fromJson(json.decode(response.body)['data']);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Gagal update order');
      }
    } catch (e) {
      throw Exception('Error di repository: $e');
    }
  }

  // Ambil daftar pekerjaan TEKNISI
  Future<List<OrderModel>> getTechnicianJobs() async {
    try {
      final http.Response response = await _service.get('technician/jobs');
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        List<dynamic> jobListJson = responseBody['data'];
        return jobListJson.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil pekerjaan');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Ambil detail pekerjaan TEKNISI
  Future<OrderModel> technicianGetJobDetail(int orderId) async {
    try {
      final response = await _service.get('technician/jobs/$orderId');
      if (response.statusCode == 200) {
        return OrderModel.fromJson(json.decode(response.body)['data']);
      } else {
        throw Exception('Gagal mengambil detail pekerjaan');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  // TEKNISI update status pekerjaan
  Future<OrderModel> technicianUpdateStatus({required int orderId, required String status}) async {
    try {
      final body = {'status': status};
      final response = await _service.putWithToken(
        'technician/jobs/$orderId/status',
        body,
      );
      if (response.statusCode == 200) {
        return OrderModel.fromJson(json.decode(response.body)['data']);
      } else {
        throw Exception('Gagal update status pekerjaan');
      }
    } catch (e) {
      throw Exception('Error di repository: $e');
    }
  }

  Future<OrderModel> validatePayment(int orderId) async {
    try {
      // Panggil endpoint validasi dengan POST, body bisa kosong
      final response = await _service.postWithToken(
        'admin/orders/$orderId/validate-payment',
        {},
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(json.decode(response.body)['data']);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Gagal memvalidasi pembayaran');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> cancelOrder(int orderId) async {
    try {
      final response = await _service.deleteWithToken('customer/orders/$orderId');
      if (response.statusCode != 200) {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Gagal membatalkan pesanan');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> setInvoiceAmount({required int orderId, required double invoiceAmount}) async {
    final response = await _service.postWithToken(
      'admin/orders/$orderId/set-invoice',
      {'invoice_amount': invoiceAmount},
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal menyimpan harga invoice');
    }
  }

  // Dapatkan URL PDF transaksi order untuk admin
  String getOrderPdfUrl(int orderId) {
    final baseUrl = _service.baseUrl; // Sudah ada /api/
    final url = '${baseUrl}admin/orders/$orderId/download-invoice';
    print('PDF URL: $url');
    return url;
  }

  String getCustomerOrderPdfUrl(int orderId) {
    final baseUrl = _service.baseUrl; // Sudah ada /api/
    return '${baseUrl}customer/orders/$orderId/download-invoice';
  }

  // TEKNISI tambah catatan untuk pelanggan
  Future<OrderModel> addTechnicianNotes({required int orderId, required String notes}) async {
    try {
      final body = {'notes': notes};
      final response = await _service.postWithToken(
        'technician/jobs/$orderId/notes',
        body,
      );
      if (response.statusCode == 200) {
        return OrderModel.fromJson(json.decode(response.body)['data']);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Gagal menambahkan catatan');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // CUSTOMER tambah rating untuk teknisi
  Future<OrderModel> addRating({required int orderId, required int rating, String? comment}) async {
    try {
      final body = {
        'rating': rating,
        if (comment != null) 'comment': comment,
      };
      final response = await _service.postWithToken(
        'customer/orders/$orderId/rate',
        body,
      );
      if (response.statusCode == 200) {
        return OrderModel.fromJson(json.decode(response.body)['data']);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Gagal menambahkan rating');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // TEKNISI ambil rating mereka
  Future<Map<String, dynamic>> getTechnicianRatings() async {
    try {
      final response = await _service.get('technician/ratings');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal mengambil rating');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}