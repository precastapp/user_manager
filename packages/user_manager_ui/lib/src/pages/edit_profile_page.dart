import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:core_ui/core_ui.dart';
import 'package:user_manager_domain/user_manager_domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/user_manager_service.dart';

class EditProfilePage extends StatelessWidget {
  PageManager pageManager = AppContainer.get();
  UserManagerService userManagerService = AppContainer.get();
  UserRepository userRepository = AppContainer.get();
  User user = AppContainer.get<UserManagerService>().current!;
  var formKey = GlobalKey<FormState>();
  var nameControl = TextEditingController();
  var usernameControl = TextEditingController();
  var phoneControl = TextEditingController();
  var emailControl = TextEditingController();
  Timer? timer;

  EditProfilePage() {
    nameControl.text = user.name;
    usernameControl.text = user.username;
    phoneControl.text = user.phone ?? '';
    emailControl.text = user.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'.trs),
        actions: [
          TextButton.icon(
              icon: Icon(Icons.logout, color: Get.theme.bottomAppBarColor),
              label: Text('Logout'.trs,
                  style: TextStyle(color: Get.theme.bottomAppBarColor)),
              onPressed: loggout)
        ],
      ),
      body: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.all(kPadding),
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                    clipBehavior: Clip.none,
                    fit: StackFit.expand,
                    children: [
                      CircleAvatar(
                          backgroundColor: Colors.amber,
                          backgroundImage: user.image != null
                              ? CachedNetworkImageProvider(user.image!)
                              : null),
                      Positioned(
                          bottom: 0,
                          right: 25,
                          child: ElevatedButton(
                            child: Icon(Icons.photo_camera),
                            onPressed: changePhoto,
                          )),
                    ]),
              ),
              TextFormField(
                controller: nameControl,
                decoration: InputDecoration(
                    labelText: 'Name:'.trs, hintText: 'Full name'.trs),
                onChanged: save,
              ),
              TextFormField(
                controller: phoneControl,
                decoration: InputDecoration(
                    labelText: 'Phone:'.trs, hintText: '+DDI (DDD) XXXX-XXXX'),
                onChanged: save,
              ),
            ],
          )),
    );
  }

  void save(String _) {
    timer?.cancel();
    timer = Timer(Duration(seconds: 2), () async {
      user.name = nameControl.text;
      user.phone = phoneControl.text;
      try {
        await userRepository.save(user);
        userManagerService.current = user;
      } catch (ex, st) {
        snakeErro('Unable to save data: %s'.trsArgs([ex.toString()]), st);
      }
    });
  }

  void loggout() {
    pageManager.dialog(() => AlertDialog(
          title: Text('Confirm?'.trs),
          content: Text('Are you sure you want to quit'.trs),
          actions: [
            TextButton(
              child: Text('Yes'.trs),
              onPressed: () async {
                await userManagerService.loggout();
                pageManager.toRoute('/', clearStack: true);
              },
            ),
            ElevatedButton(
              child: Text('No'.trs),
              onPressed: pageManager.back,
            ),
          ],
        ));
  }

  void changePhoto() {
    launchUrl(Uri.parse('https://gravatar.com/emails/'));
  }
}
