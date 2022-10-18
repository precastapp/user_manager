import 'package:user_manager_domain/user_manager_domain.dart';

extension UserJson on User {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      if (phone != null) 'phone': phone,
      if (image != null) 'image': image,
    };
  }

  static User fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        name: json['name'],
        username: json['username'],
        email: json['email'],
        phone: json['phone']);
  }
}
