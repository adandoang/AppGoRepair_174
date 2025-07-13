class LoginResponseModel {
  final String accessToken;
  final String tokenType;
  final User user;

  LoginResponseModel({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  // Factory constructor untuk membuat objek dari data JSON
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      user: User.fromJson(json['user']),
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? emailVerifiedAt;
  final String? phoneNumber;
  final String? address;
  final String? createdAt;
  final String? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.emailVerifiedAt,
    this.phoneNumber,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      emailVerifiedAt: json['email_verified_at']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      address: json['address']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'email_verified_at': emailVerifiedAt,
      'phone_number': phoneNumber,
      'address': address,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}