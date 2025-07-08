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

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
    );
  }
  
  Map<String, dynamic> toJson() {
        return {
            'id': id,
            'name': name,
            'email': email,
            'role': role,
        };
    }
}