import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nomo_app/controllers/splash-controller.dart';
import 'package:nomo_app/screens/auth/login-screen.dart';
import 'package:video_player/video_player.dart';

import '../AppRoutes/app-routes.dart';
import '../chat/api/apis.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      // //exit full-screen
      // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      //     systemNavigationBarColor: Colors.white,
      //     statusBarColor: Colors.white));

      if (APIs.auth.currentUser != null) {
        log('userid: ${APIs.auth.currentUser}');
        //navigate to home screen
        Get.offAllNamed(AppRoutes.customerBottomNav);
      } else {
        //navigate to login screen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('buildScreen');
    return Scaffold(
        body: SizedBox.expand(
            child: GetBuilder(
                init: VideoController(),
                builder: (videoController) {
                  var controller = videoController.controller;
                  return controller == null || !controller.value.isInitialized
                      ? Container()
                      : FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: controller.value.size.width,
                            height: controller.value.size.height,
                            child: VideoPlayer(controller),
                          ));
                })));
  }
}
