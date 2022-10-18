import 'dart:convert';
import 'package:core_ui/core_ui.dart';
import 'package:user_manager/user_manager.dart';
import 'package:http/http.dart';

class UserRepositoryAuth0 extends UserRepository {
  Client client = AppContainer.get();
  final String baseUrl = String.fromEnvironment('URL_USER_MANAGER_SERVICE',
      defaultValue: 'http://localhost:8080');

  @override
  Future save(User user) async {
    var resp = await client.put(Uri.parse('${baseUrl}/api/v1/users/${user.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()));
    if (resp.statusCode != 200)
      return Future.error(resp.reasonPhrase ?? resp.body);
  }
}
