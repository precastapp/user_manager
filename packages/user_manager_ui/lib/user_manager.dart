/// Support for doing something awesome.
///
/// More dartdocs go here.
library user_manager;

import 'package:core_ui/core_ui.dart';
import 'package:user_manager/src/infra/repository/user_repository_auth0.dart';
import 'package:user_manager/src/pages/edit_profile_page.dart';

import 'src/infra/user_manager_service_auth0.dart';
import 'src/infra/user_manager_service_supertoken.dart';
import 'user_manager.dart';

export 'package:user_manager_domain/user_manager_domain.dart';
export 'src/services/user_manager_service.dart';

class UserManagerModule extends Module {
  UserManagerModule()
      : super(
            name: 'userManager',
            leadingActionMenu: getLeadingMenu(),
            routes: getRoutes());

  static getRoutes() => [RoutePage('/profile', (() => EditProfilePage()))];

  static getLeadingMenu() => [
        ActionData('profile', Icons.person_outlined,
            (() => AppContainer.get<PageManager>().toRoute('/profile')))
      ];

  static Future init(void Function(dynamic) openPageWeb) async {
    AppContainer.add<UserManagerService>(UserManagerServiceAuth0(openPageWeb));
    AppContainer.addLazy<UserRepository>(() => UserRepositoryAuth0(),
        fenix: true);
  }
}
