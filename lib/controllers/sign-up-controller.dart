import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  GlobalKey<FormState>? signupFormKey;
  TextEditingController? emailController;
  TextEditingController? passController;
  TextEditingController? nameController;
  RxBool _remember = false.obs;
  RxBool _isHide = true.obs;
  RxBool _isConfirmHide = true.obs;

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

  RxBool get isConfirmHide => _isConfirmHide;

  set setIsConfirmHide(bool val) {
    _isConfirmHide.value = val;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    signupFormKey = GlobalKey<FormState>();
    emailController = TextEditingController();
    passController = TextEditingController();
    nameController = TextEditingController();
  }
}
