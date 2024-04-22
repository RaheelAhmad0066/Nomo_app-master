import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nomo_app/Services/Prefferences/prefferences.dart';
import 'package:nomo_app/controllers/splash-controller.dart';
import 'package:nomo_app/screens/auth/login-screen.dart';
import 'package:video_player/video_player.dart';
import '../AppRoutes/app-routes.dart';
import 'constant/constant.dart';

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
      var id = Get.find<PrefUtils>().getUserId(PrefferKey.id);
      if (id != null) {
        log('userid: $id');
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
