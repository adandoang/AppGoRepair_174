class CreateOrderRequestModel {
  final int categoryId;
  final String description;
  final String address;
  final double latitude;
  final double longitude;

  CreateOrderRequestModel({
    required this.categoryId,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}