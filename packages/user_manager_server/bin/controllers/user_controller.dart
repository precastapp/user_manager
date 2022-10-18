import 'dart:convert';

import 'package:user_manager_domain/user_manager_domain.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../infra/user_repository_auth0.dart';

class UserController {
  final router = Router();
  UserRepository userRepository;

  UserController(this.userRepository) {
    router.put('/<id>', putUser);
  }

  Future<Response> call(Request request) => router.call(request);

  Future<Response> putUser(Request request, String id) async {
    //final id = request.params['id'];
    User user = UserJson.fromJson(jsonDecode(await request.readAsString()));
    if (user.id != request.context['user_id'])
      return Response(401, body: 'not authorized');
    await userRepository.save(user);
    return Response(200);
  }
}
