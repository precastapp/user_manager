import 'package:async/async.dart';
import 'package:core_ui/core_ui.dart';
import 'package:user_manager_domain/user_manager_domain.dart';

abstract class UserManagerService {
  User? current;
  Future<User?> loadUser();
  Future<Result<bool>> signIn();
  Future<Result<bool>> signUp(User user, String password);
  Future<void> loggout();
}
