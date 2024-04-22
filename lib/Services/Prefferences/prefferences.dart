import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../screens/auth/login-screen.dart';

class PrefUtils {
  late SharedPreferences _prefsInstance;
  Future<PrefUtils> initial() async {
    _prefsInstance = await SharedPreferences.getInstance();
    return this;
  }

//isfirst

  bool isFirstSignin() {
    return _prefsInstance.getBool('isfirst') ?? true;
  }

  Future setIsFirstsignin(bool value) async {
    return await _prefsInstance.setBool('isfirst', value);
  }

// user token
  Future setToken(String key, String value) async {
    try {
      await _prefsInstance.setString(key, value);
    } catch (e) {
      print(e);
    }
  }

  String? getToken(String key) {
    return _prefsInstance.getString(key);
  }

//userid
  Future setUserId(String key, int value) async {
    try {
      await _prefsInstance.setInt(key, value);
    } catch (e) {
      print(e);
    }
  }

  getUserId(String key) {
    return _prefsInstance.getInt(key);
  }
// strings

  Future setStrings(String key, String value) async {
    try {
      await _prefsInstance.setString(key, value);
    } catch (e) {
      print(e);
    }
  }

  getStrings(String key) {
    return _prefsInstance.getString(key);
  }

  Future<void> logOut() async {
    try {
      await _prefsInstance.clear();
      Get.offAll(LoginScreen());
      Get.snackbar('Logout', 'user Logout successfully');
    } catch (e) {
      print(e);
    }
  }
}

class Services {
  static final Services _instance = Services._();
  Services._();
  factory Services() => _instance;
  Future<void> initServices() async {
    await Get.putAsync<PrefUtils>(() => PrefUtils().initial());
  }
}
