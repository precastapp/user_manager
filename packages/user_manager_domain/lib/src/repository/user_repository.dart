import '../entity/user.dart';

abstract class UserRepository {
  Future save(User user);
}
