// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nomo_app/AppRoutes/app-routes.dart';
import 'package:nomo_app/Services/Prefferences/prefferences.dart';
import 'package:nomo_app/res/components/buttons/elevated-button.dart';
import 'package:nomo_app/res/components/social-media-button.dart';
import 'package:nomo_app/res/components/text-field-widget.dart';
import 'package:nomo_app/res/assets/assets.dart';
import 'package:nomo_app/res/colors/appcolors.dart';
import 'package:nomo_app/screens/auth/pick-username-screen.dart';
import 'package:nomo_app/screens/constant/constant.dart';

import '../../Services/AuthServices/Authservices.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final controller = Get.put(AuthServices());
  final _forrmKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
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
              41.verticalSpace,
              const Text('Welcome to NOMO',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xff000000),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  )),
              40.verticalSpace,
              const Text('Sign Up with',
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
                        controller.googleSignInService();
                      },
                      buttonIcon: Assets.google,
                      buttonText: 'Google',
                    )),
                    20.horizontalSpace,
                    Expanded(
                        child: SocialMediaButton(
                      onTap: () {},
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
                      indent: 40,
                      endIndent: 40,
                      color: Color(0xff4D4D4D),
                      thickness: 0.8,
                    ),
                  ),
                  Text('Create an Account',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Montserrat",
                      )),
                  Expanded(
                    child: Divider(
                      indent: 40,
                      endIndent: 40,
                      color: Color(0xff4D4D4D),
                      thickness: 0.8,
                    ),
                  ),
                ],
              ),
              20.verticalSpace,
              Form(
                key: _forrmKey,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    children: [
                      CustomTextFieldWidget(
                        controller: nameController,
                        label: 'Full Name',
                        hintText: 'Please enter your full name',
                        onValidator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter name';
                          } else if (value.length < 5) {
                            return 'name length is too short';
                          }
                          return null;
                        },
                      ),
                      13.verticalSpace,
                      CustomTextFieldWidget(
                        controller: emailController,
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
                        controller: passwordController,
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
              30.verticalSpace,
              const Text(
                  'By creating an account you agree to our\n '
                  '  Terms of services and Privacy Policy',
                  maxLines: 2,
                  // textScaleFactor: 0.65,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.blackColor,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  )),
              30.verticalSpace,
              GradientElevatedButton(
                  gradient: AppColors.gradientColor,
                  width: 280.w,
                  label: 'Sign Up',
                  onPressed: () {
                    if (_forrmKey.currentState!.validate()) {
                      Get.find<PrefUtils>()
                          .setStrings(PrefferKey.name, nameController.text);
                      Get.find<PrefUtils>()
                          .setStrings(PrefferKey.email, emailController.text);
                      Get.to(
                          () => UsernamePickerScreen(
                                name: nameController.text.trim(),
                                email: emailController.text.trim(),
                                password: passwordController.text,
                              ),
                          transition: Transition.fadeIn,
                          duration: const Duration(milliseconds: 400));
                    }
                  }),
              20.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xff000000),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      )),
                  TextButton(
                      onPressed: () {
                        Get.offAllNamed(AppRoutes.login);
                      },
                      child: const Text(
                        'Sign In',
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
