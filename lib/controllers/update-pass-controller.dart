import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdatePassController extends GetxController {
  GlobalKey<FormState>? updatePassFormKey;
  TextEditingController? confirmPassController;
  TextEditingController? passController;

  RxBool _isHide = true.obs;
  RxBool _isHideConfirmPass = true.obs;

  RxBool get isHide => _isHide;
  RxBool get isHideConfirmPass => _isHideConfirmPass;

  set setIsHide(bool val) {
    _isHide.value = val;
    update();
  }

  set setIsHideConfirmPass(bool val) {
    _isHideConfirmPass.value = val;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    updatePassFormKey = GlobalKey<FormState>();
    confirmPassController = TextEditingController();
    passController = TextEditingController();
  }
}
