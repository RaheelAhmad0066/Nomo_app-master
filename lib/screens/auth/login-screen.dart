import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nomo_app/res/components/buttons/elevated-button.dart';
import 'package:nomo_app/res/components/social-media-button.dart';
import 'package:nomo_app/res/components/text-field-widget.dart';
import 'package:nomo_app/res/assets/assets.dart';
import 'package:nomo_app/res/colors/appcolors.dart';
import '../../AppRoutes/app-routes.dart';
import '../../Services/AuthServices/Authservices.dart';
import '../../chat/api/apis.dart';
import '../../chat/helper/dialogs.dart';
import '../custom-navBar-screen.dart';
import '../instagram_view.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;
  final controller = Get.put(AuthServices());
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    //for auto triggering animation
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => _isAnimate = true);
    });
  }

  // handles google login button click
  _handleGoogleBtnClick() {
    //for showing progress bar
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (APIs.user.uid != null) {
        log('\nUser: ${APIs.user.uid}');
        log('\nUserAdditionalInfo: ${APIs.user}');
        if ((await APIs.userExists())) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const CustomBottomScreen()));
          // saving the values to our shared preferences
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const CustomBottomScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle: $e');
      Dialogs.showSnackbar(context, 'Something Went Wrong (Check Internet!)');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
          child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              40.verticalSpace,
              const Text('Welcome to NOMO',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xff000000),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  )),
              40.verticalSpace,
              const Text('Sign In with',
                  style: TextStyle(
                    fontSize: 25,
                    color: AppColors.blackColor,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  )),
              30.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: SocialMediaButton(
                      onTap: () {
                        _handleGoogleBtnClick();
                      },
                      buttonIcon: Assets.google,
                      buttonText: 'Google',
                    )),
                    20.horizontalSpace,
                    Expanded(
                        child: SocialMediaButton(
                      onTap: () {
                        InstagramView();
                        print('object');
                      },
                      buttonIcon: Assets.instagram,
                      buttonText: 'Instagram',
                    )),
                  ],
                ),
              ),
              30.verticalSpace,
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Divider(
                      indent: 80,
                      endIndent: 60,
                      color: Color(0xff4D4D4D),
                      thickness: 1,
                    ),
                  ),
                  Text('Or',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Montserrat",
                      )),
                  Expanded(
                    child: Divider(
                      indent: 80,
                      endIndent: 60,
                      color: Color(0xff4D4D4D),
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              20.verticalSpace,
              Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    children: [
                      CustomTextFieldWidget(
                        controller: controller.emailController,
                        label: 'Email Address',
                        hintText: 'Please enter your email address',
                        onValidator: (value) {
                          Pattern pattern =
                              r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                              r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                              r"{0,253}[a-zA-Z0-9])?)*$";
                          RegExp regex = RegExp(pattern.toString());
                          if (value == null) {
                            return 'Enter an Email Address!';
                          } else if (!regex.hasMatch(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      13.verticalSpace,
                      CustomTextFieldWidget(
                        controller: controller.passwordController,
                        obscureText: controller.isHide.value,
                        label: 'Password',
                        hintText: 'Please enter the password',
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 20.w),
                          child: Transform.scale(
                            scale: 0.6,
                            child: InkWell(
                              onTap: () {
                                controller.setIsHide = !controller.isHide.value;
                              },
                              child: SvgPicture.asset(
                                controller.isHide.value
                                    ? Assets.eyeVisibleOff
                                    : Assets.eyeVisible,
                                height: 3.h,
                                width: 3.w,
                              ),
                            ),
                          ),
                        ),
                        onValidator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          } else if (value.length < 5) {
                            return 'Password length is too short';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              5.verticalSpace,
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () {
                      Get.offAllNamed(AppRoutes.forget);
                    },
                    child: const Text('Forgot Password?',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Montserrat",
                        )),
                  ),
                ),
              ),
              30.verticalSpace,
              Obx(
                () => controller.isLoading.value
                    ? Center(child: CircularProgressIndicator())
                    : GradientElevatedButton(
                        gradient: AppColors.gradientColor,
                        width: 280.w,
                        label: 'Sign In',
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            controller.logInService();
                            print('object');
                          }
                        }),
              ),
              20.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xff000000),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      )),
                  TextButton(
                      onPressed: () {
                        Get.offAllNamed(AppRoutes.signup);
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.green),
                      ))
                ],
              ),
            ],
          ),
        ),
      )),
    );
  }
}
