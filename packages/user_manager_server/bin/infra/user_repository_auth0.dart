import 'dart:convert';
import 'dart:io';

import 'package:user_manager_domain/user_manager_domain.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

class UserRepositoryAuth0 extends UserRepository {
  oauth2.Client? _client;
  final auth0Url = 'https://rtabet.us.auth0.com';

  Future<oauth2.Client> getClient() async {
    if (_client != null && !_client!.credentials.isExpired) return _client!;

    _client = await oauth2.clientCredentialsGrant(
        Uri.parse('$auth0Url/oauth/token'),
        Platform.environment['AUTH0_ID'],
        Platform.environment['AUTH0_SECRET'],
        body: {'audience': 'https://rtabet.us.auth0.com/api/v2/'},
        scopes: ['update:users', 'update:users_app_metadata']);
    return _client!;
  }

  @override
  Future<User> getUserByEmail(String email) async {
    return User(name: 'name', username: 'username', email: 'email');
  }

  @override
  Future save(User user) async {
    var client = await getClient();
    Map<String, dynamic> json = {'name': user.name, 'picture': user.image};
    json['user_metadata'] = {'phone': user.phone};
    var resp = await client.patch(
        Uri.parse('$auth0Url/api/v2/users/${user.id}'),
        body: jsonEncode(json),
        headers: {'Content-Type': 'application/json'});
    if (resp.statusCode != 200) return Future.error(resp.body);
  }

  @override
  Future<User> getUserByToken(String token) async {
    return User(name: 'name', username: 'username', email: 'email');
  }
}
