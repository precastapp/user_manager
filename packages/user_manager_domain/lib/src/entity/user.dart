import 'package:user_manager_domain/user_manager_domain.dart';

class User extends Entity {
  String name;
  String username;
  String email;
  String? phone;
  String? image;

  User(
      {String? id,
      required this.name,
      required this.username,
      required this.email,
      this.phone,
      this.image})
      : super(id: id);
}
