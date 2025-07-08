import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';
import '../services/service_http_client.dart';

class OrderRepository {
  final ServiceHttpClient _service = ServiceHttpClient();

  // Mengambil daftar order untuk pelanggan yang sedang login
  Future<List<OrderModel>> getCustomerOrders() async {
    try {
      // Gunakan method get() dari service, endpointnya 'orders'
      final http.Response response = await _service.get('orders');

      if (response.statusCode == 200) {
        // Decode response body
        final responseBody = json.decode(response.body);

        // Ambil list 'data' dari response
        List<dynamic> orderListJson = responseBody['data'];

        // Ubah setiap item di list menjadi OrderModel
        List<OrderModel> orders = orderListJson
            .map((json) => OrderModel.fromJson(json))
            .toList();

        return orders;
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message']);
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengambil data order: $e');
    }
  }
}