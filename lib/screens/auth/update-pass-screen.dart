import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nomo_app/Services/AuthServices/Authservices.dart';
import 'package:nomo_app/Services/Prefferences/prefferences.dart';
import 'package:nomo_app/res/components/text-field-widget.dart';
import 'package:nomo_app/res/assets/assets.dart';
import 'package:nomo_app/res/colors/appcolors.dart';
import 'package:nomo_app/screens/constant/constant.dart';

enum ButtonState { Default, Loading, Success }

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key, required});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  ButtonState _buttonState = ButtonState.Default;
  final controler = Get.put(AuthServices());
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _keyForm = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
            child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 45, vertical: 8.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                30.verticalSpace,
                const Text('Update Password',
                    style: TextStyle(
                      fontSize: 25,
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    )),
                10.verticalSpace,
                const Text('Please enter a new password for your\naccount',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xff768089),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    )),
                10.verticalSpace,
                Form(
                  key: _keyForm,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomTextFieldWidget(
                        controller: passwordController,
                        obscureText: controler.isHide.value,
                        label: '',
                        hintText: 'Password',
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 20.w),
                          child: Transform.scale(
                            scale: 0.6,
                            child: InkWell(
                              onTap: () {
                                controler.setIsHide = !controler.isHide.value;
                              },
                              child: SvgPicture.asset(
                                controler.isHide.value
                                    ? Assets.eyeVisibleOff
                                    : Assets.eyeVisible,
                                height: 3.h,
                                width: 3.w,
                              ),
                            ),
                          ),
                        ),
                        // onValidator: Utils.passValidator,
                      ),
                      5.verticalSpace,
                      CustomTextFieldWidget(
                        controller: confirmPasswordController,
                        obscureText: controler.isHideConfirmPass.value,
                        label: '',
                        hintText: 'Confirm Password',
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 20.w),
                          child: Transform.scale(
                            scale: 0.6,
                            child: InkWell(
                              onTap: () {
                                controler.setIsHideConfirmPass =
                                    !controler.isHideConfirmPass.value;
                              },
                              child: SvgPicture.asset(
                                controler.isHideConfirmPass.value
                                    ? Assets.eyeVisibleOff
                                    : Assets.eyeVisible,
                                height: 5.h,
                                width: 5.w,
                              ),
                            ),
                          ),
                        ),
                        // onValidator: Utils.passValidator,
                      ),
                    ],
                  ),
                ),
                75.verticalSpace,
                Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 41.h,
                      width: 300,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          gradient: AppColors.gradientColor),
                      child: Obx(
                        () => controler.isLoading.value
                            ? Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                onPressed: () async {
                                  final userId = Get.find<PrefUtils>()
                                      .getUserId(PrefferKey.id);
                                  controler.updatePasswordService(
                                      userID: userId,
                                      password: passwordController.text);
                                },
                                child: _buttonContent()),
                      ),
                    )),
              ],
            ),
          ),
        )));
  }

  Widget _buttonContent() {
    switch (_buttonState) {
      case ButtonState.Loading:
        return const CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        );
      case ButtonState.Success:
        return const Icon(
          Icons.check,
          color: Colors.black,
          size: 30,
        );
      default:
        return const Text(
          'Change Password',
          style: TextStyle(
              fontSize: 16,
              color: AppColors.white,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat'),
        );
    }
  }
}
