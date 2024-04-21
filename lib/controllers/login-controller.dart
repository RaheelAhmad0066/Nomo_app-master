import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  GlobalKey<FormState>? signinFormKey;
  TextEditingController? emailController;
  TextEditingController? passController;

  RxBool _remember = false.obs;
  RxBool _isHide = true.obs;

  RxBool get remember => _remember;

  set setRemember(bool val) {
    _remember.value = val;
    update();
  }

  RxBool get isHide => _isHide;

  set setIsHide(bool val) {
    _isHide.value = val;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    signinFormKey = GlobalKey<FormState>();
    emailController = TextEditingController();
    passController = TextEditingController();
  }
}
