// lib/data/models/order_model.dart

// Menggunakan kembali class User dari login response
import 'response/login_response_model.dart';

class OrderModel {
  final int id;
  final String description;
  final String address;
  final String status;
  final String createdAt;
  final Category category;
  // User bisa null jika teknisi belum ditugaskan
  final User? technician; 

  OrderModel({
    required this.id,
    required this.description,
    required this.address,
    required this.status,
    required this.createdAt,
    required this.category,
    this.technician,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      description: json['description'],
      address: json['address'],
      status: json['status'],
      createdAt: json['created_at'],
      category: Category.fromJson(json['category']),
      // Cek jika data teknisi ada sebelum di-parse
      technician: json['technician'] != null
          ? User.fromJson(json['technician'])
          : null,
    );
  }
}

class Category {
  final int id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }
}