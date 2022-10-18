import 'dart:convert';
import 'package:async/async.dart';
import 'package:core_ui/core_ui.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:user_manager_domain/user_manager_domain.dart';
import '../services/user_manager_service.dart';
import 'package:http/http.dart' as http;

class UserManagerServiceAuth0 implements UserManagerService {
  @override
  User? current;
  void Function(dynamic) openPageWeb;
  oauth2.Client? _client;
  final baseUrl = 'https://rtabet.us.auth0.com';

  oauth2.Client? get client {
    if (_client == null) return null;
    if (!_client!.credentials.isExpired) return _client;

    _client!.credentials.refresh();
    return _client;
  }

  UserManagerServiceAuth0(this.openPageWeb);

  Future<oauth2.Client?> createClient({bool byStorageOnly = false}) async {
    final authorizationEndpoint = Uri.parse('${baseUrl}/authorize');
    final tokenEndpoint = Uri.parse('${baseUrl}/oauth/token');
    final identifier = 'sD3FxjTurJ4C7hvwxdP6bekTQdx2EqDY';
    final redirectUrl =
        Uri.parse('https://www.businessaccounting.com/oauth2-redirect');
    final storage = getStorageCredential();

    var user = storage.read('user');
    if (user != null) {
      var credentials = oauth2.Credentials.fromJson(user);
      if (!credentials.isExpired)
        _client = oauth2.Client(credentials, identifier: identifier);
    }
    if (!byStorageOnly && _client == null) {
      var grant = oauth2.AuthorizationCodeGrant(
          identifier, authorizationEndpoint, tokenEndpoint);

      var authorizationUrl = grant.getAuthorizationUrl(redirectUrl,
          scopes: ['openid', 'profile', 'email', 'address', 'phone']);
      authorizationUrl = authorizationUrl.replace(
          queryParameters: Map.from(authorizationUrl.queryParameters)
            ..addAll({'audience': 'https://rtabet.us.auth0.com/api/v2/'}));

      var responseUrl =
          await redirect(authorizationUrl, redirectUrl.toString());
      var parametres = <String, String>{};
      parametres.addAll(responseUrl.queryParameters);
      parametres['client_id'] = identifier;
      _client = await grant.handleAuthorizationResponse(parametres);
      await storage.write('user', _client!.credentials.toJson());
    }
    if (_client != null) {
      AppContainer.add<http.Client>(_client!);
    }
    return _client;
  }

  Future<Uri> redirect(Uri url, String redirectUrl) async {
    var responseUrl = Uri().obs;

    if (GetPlatform.isWindows && !GetPlatform.isWeb) {
      final _controller = WebviewController();
      await _controller.initialize();
      _controller.url.listen((url) {
        if (url.startsWith(redirectUrl, 0)) responseUrl.value = Uri.parse(url);
      });
      await _controller.loadUrl(url.toString());
      openPageWeb(Webview(
        _controller,
      ));
    } else {
      openPageWeb(WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: url.toString(),
        navigationDelegate: (navReq) {
          if (navReq.url.startsWith(redirectUrl))
            responseUrl.value = Uri.parse(navReq.url);
          return NavigationDecision.navigate;
        },
      ));
    }

    return responseUrl.stream.first;
  }

  Future<User?> loadUser() async {
    _client = await createClient(byStorageOnly: true);
    if (_client == null) return null;
    current = tokenToUser(_client?.credentials.idToken ?? '');
    return current;
  }

  @override
  Future<void> loggout() async {
    current = null;
    _client = null;
    AppContainer.delete<http.Client>(force: true);
    var storage = getStorageCredential();
    await storage.erase();
    final _controller = WebviewController();
    await _controller.initialize();
    await _controller.clearCache();
    await _controller.clearCookies();
  }

  User tokenToUser(String token) {
    try {
      var data = JwtDecoder.decode(token);
      return User(
          id: data['sub'],
          name: data['name'],
          username: data['nickname'],
          email: data['email'],
          phone: data['user_metadata']?['phone'],
          image: data['picture']);
    } catch (ex, st) {
      snakeErro(ex.toString(), st);
      loggout();
      rethrow;
    }
  }

  @override
  Future<Result<bool>> signIn() async {
    var client = _client ?? await createClient();
    if (client == null) return Result.value(false);
    current = tokenToUser(client.credentials.idToken ?? '');
    return Result.value(true);
  }

  @override
  Future<Result<bool>> signUp(User user, String password) {
    // TODO: implement signUp
    throw UnimplementedError();
  }

  GetStorage getStorageCredential() {
    final storage = GetStorage('credentials');
    return storage;
  }

  @override
  Future saveUser(User user) async {
    var resp = await client!.put(
        Uri.parse('${baseUrl}/api/v2/users/${user.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()));
    if (resp.statusCode != 200)
      return Future.error(resp.reasonPhrase ?? resp.body);
  }
}
