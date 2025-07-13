import 'response/login_response_model.dart';

// --- ORDER PHOTO MODEL ---
class OrderPhotoModel {
  final int id;
  final String? photoUrl;

  OrderPhotoModel({required this.id, this.photoUrl});

  factory OrderPhotoModel.fromJson(Map<String, dynamic> json) {
    return OrderPhotoModel(
      id: json['id'],
      photoUrl: json['photo_url']?.toString(),
    );
  }
}

// --- SERVICE RATING MODEL ---
class ServiceRatingModel {
  final int id;
  final int orderId;
  final int customerId;
  final int technicianId;
  final int rating;
  final String? comment;
  final String? createdAt;
  final String? updatedAt;

  ServiceRatingModel({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.technicianId,
    required this.rating,
    this.comment,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceRatingModel.fromJson(Map<String, dynamic> json) {
    return ServiceRatingModel(
      id: json['id'],
      orderId: json['order_id'],
      customerId: json['customer_id'],
      technicianId: json['technician_id'],
      rating: json['rating'],
      comment: json['comment']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

// --- ORDER MODEL ---
class OrderModel {
  final int id;
  final String? description;
  final String? address;
  final String? status;
  final String? createdAt;
  final Category category;
  final User customer;
  final User? technician;
  final String? paymentProofUrl;
  final bool isPaymentValidated;
  final List<OrderPhotoModel> photos;
  final double? invoiceAmount;
  final String? technicianNotes;
  final ServiceRatingModel? rating;

  OrderModel({
    required this.id,
    this.description,
    this.address,
    this.status,
    this.createdAt,
    required this.category,
    required this.customer,
    this.technician,
    this.paymentProofUrl,
    this.invoiceAmount,
    required this.isPaymentValidated,
    required this.photos,
    this.technicianNotes,
    this.rating,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse photos
      List<OrderPhotoModel> parsedPhotos = [];
      if (json['photos'] != null && json['photos'] is List) {
        parsedPhotos = (json['photos'] as List)
            .map((p) => OrderPhotoModel.fromJson(p))
            .toList();
      }

      // Parse rating
      ServiceRatingModel? parsedRating;
      try {
        if (json['rating'] != null && json['rating'] is Map<String, dynamic>) {
          parsedRating = ServiceRatingModel.fromJson(json['rating']);
        }
      } catch (e) {
        print('Error parsing rating: $e');
        parsedRating = null;
      }

      return OrderModel(
        id: json['id'],
        description: json['description']?.toString(),
        address: json['address']?.toString(),
        status: json['status']?.toString(),
        createdAt: json['created_at']?.toString(),
        category: Category.fromJson(json['category']),
        customer: User.fromJson(json['customer']),
        technician: json['technician'] != null
            ? User.fromJson(json['technician'])
            : null,
        paymentProofUrl: json['payment_proof_url']?.toString(),
        isPaymentValidated: json['is_payment_validated'] == 1 || json['is_payment_validated'] == true,
        photos: parsedPhotos,
        invoiceAmount: json['invoice_amount'] != null
            ? double.tryParse(json['invoice_amount'].toString())
            : null,
        technicianNotes: json['technician_notes']?.toString(),
        rating: parsedRating,
      );
    } catch (e) {
      print('Error parsing OrderModel: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'invoice_amount': invoiceAmount,
    };
  }
}

// --- CATEGORY MODEL ---
class Category {
  final int id;
  final String? name;

  Category({
    required this.id,
    this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name']?.toString(),
    );
  }
}
