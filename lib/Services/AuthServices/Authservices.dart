import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:nomo_app/Global/apis.dart';
import 'package:nomo_app/Models/user_response_model.dart';
import 'package:nomo_app/Services/Prefferences/prefferences.dart';
import 'package:nomo_app/screens/auth/login-screen.dart';
import '../../AppRoutes/app-routes.dart';
import '../../screens/auth/signup-email-verify-screen.dart';
import '../../screens/auth/update-pass-screen.dart';
import '../../screens/constant/constant.dart';
import '../../screens/custom-navBar-screen.dart';
import '../../screens/profiles/personal-information-screen.dart';
import 'social_login_services.dart';

class AuthServices extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var responseMessage = ''.obs;
  RxBool isLoading = false.obs;
  RxBool _remember = false.obs;
  RxBool _isHide = true.obs;
  RxBool _isConfirmHide = true.obs;
  RxBool _isHideConfirmPass = true.obs;
  RxBool get isHideConfirmPass => _isHideConfirmPass;
  RxBool get remember => _remember;
  RxBool get isConfirmHide => _isConfirmHide;
  RxBool get isHide => _isHide;

  set setRemember(bool val) {
    _remember.value = val;
    update();
  }

  set setIsHide(bool val) {
    _isHide.value = val;
    update();
  }

  set setIsConfirmHide(bool val) {
    _isConfirmHide.value = val;
    update();
  }

  set setIsHideConfirmPass(bool val) {
    _isHideConfirmPass.value = val;
    update();
  }

  void logInService() async {
    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse(APIEndpoints.logIn),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        UserModel responseModel = UserModel.fromMap(responseBody);
        if (responseModel.status == true) {
          Get.offAll(CustomBottomScreen());
          Get.snackbar(
            'Login Successful',
            'Welcome ${responseModel.message}', // or any message you want
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 3),
          );
          Get.find<PrefUtils>()
              .setToken(PrefferKey.token, responseModel.token.toString());
          Get.find<PrefUtils>().setUserId(
              PrefferKey.id, int.parse(responseModel.user!.id.toString()));
          log('Logintoken-----------------------${responseModel.token.toString()}');
          log('Logintoken-----------------------${responseModel.user!.id.toString()}');
        } else {
          Get.snackbar(
            'Error',
            responseModel.message.toString(),
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 3),
          );
        }
        log(response.body.toString());
      }
    } catch (e) {
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void signUpService(
      {String? fullName,
      String? email,
      String? password,
      String? username,
      String? phonenumber,
      String? gender,
      String? image}) async {
    try {
      isLoading.value = true;
      Map<String, dynamic> data = {
        'fullName': fullName,
        'email': email,
        'password': password,
        "role": "user",
        "deviceToken": "mydevicetoken",
        "username": username,
        "phoneNo": password,
        "status": 1,
        "gender": gender,
      };
      final response = await http.post(
        Uri.parse(APIEndpoints.signUP),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        UserModel responseModel = UserModel.fromMap(responseBody);
        if (responseModel.status == true) {
          Get.offAll(SignUpEmailVerifyScreen(
            email: email!,
          ));
          Get.snackbar('Success', responseModel.message.toString());
        } else {
          Get.snackbar(
            'Error',
            responseModel.message.toString(),
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      log('Error: $e');
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifySignUpOTPService({String? otp, String? email}) async {
    try {
      isLoading.value = true;
      if (email!.isEmpty) {
        throw 'Request failed';
      }
      final response = await http.post(
        Uri.parse(APIEndpoints.verifySignUpOTP),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"otp": otp, "email": email}),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        UserModel responseModel = UserModel.fromMap(responseBody);
        if (responseModel.status == true) {
          Get.snackbar('Success', responseModel.message.toString());
        } else {
          Get.snackbar(
            'Error',
            responseModel.message.toString(),
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      log('Error: $e');
      Get.snackbar('Error', e.toString());
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPasswordService(String email) async {
    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse(APIEndpoints.forgotPassbyEmail),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        UserModel responseModel = UserModel.fromMap(responseBody);
        if (responseModel.status == true) {
          Get.snackbar('Success', responseModel.message.toString());
        } else {
          Get.snackbar(
            'Error',
            responseModel.message.toString(),
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      log('Error: $e');
      Get.snackbar('Error', e.toString());

      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyUserOTPService({required String otp}) async {
    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse(APIEndpoints.verifyUserOTP),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"otp": otp.trim()}),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        UserModel responseModel = UserModel.fromMap(responseBody);
        if (responseModel.status == true) {
          Get.to(UpdatePasswordScreen());
          Get.snackbar('Success', responseModel.message.toString());
        } else {
          Get.snackbar(
            'Error',
            responseModel.message.toString(),
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      log('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePasswordService(
      {required String userID, required String password}) async {
    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse(APIEndpoints.updateuserPassword),
        headers: {'Content-Type': 'application/json'},
        body:
            jsonEncode({'userId': userID.trim(), 'password': password.trim()}),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        UserModel responseModel = UserModel.fromMap(responseBody);
        if (responseModel.status == true) {
          Get.to(LoginScreen());
          Get.snackbar('Success', responseModel.message.toString());
        } else {
          Get.snackbar(
            'Error',
            responseModel.message.toString(),
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<UserModel> googleSignInService() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: <String>['email', 'profile'],
      );
      var googleUser = await googleSignIn.signIn();
      UserModel? userModel = await socialSignUpService(
          fullName: googleUser?.displayName ?? "",
          id: googleUser?.id ?? "",
          email: googleUser?.email ?? "");
      Get.find<PrefUtils>().setStrings(PrefferKey.email, googleUser!.email);
      navigatHome();
      return userModel;
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
  }

  void navigatHome() {
    Get.to(CustomBottomScreen());
    Get.snackbar('Success', 'Login Successfull');
  }
}
