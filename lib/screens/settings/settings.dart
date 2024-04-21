import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nomo_app/main.dart';
import 'package:nomo_app/res/assets/assets.dart';
import 'package:nomo_app/res/colors/appcolors.dart';
import 'package:nomo_app/res/components/common-column-widget.dart';
import 'package:nomo_app/res/components/gradient-app-bar.dart';
import 'package:nomo_app/screens/privacy-policy-screen.dart';
import 'package:nomo_app/screens/profiles/UpdatePersonalInfo/email-update.dart';
import 'package:nomo_app/screens/profiles/UpdatePersonalInfo/name-update.dart';
import 'package:nomo_app/screens/settings/contact-me-screen.dart';
import 'package:nomo_app/screens/settings/my-location-screen.dart';
import 'package:nomo_app/screens/settings/my-story.dart';
import 'package:nomo_app/screens/settings/notifications.dart';
import 'package:nomo_app/screens/terms-and-conditions-screen.dart';

class SettingScreen extends StatelessWidget {
  SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: GradientAppBar(
        title: 'Settings',
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: SvgPicture.asset(Assets.arrowBack)),
      ),
      // appBar: AppBar(
      //   backgroundColor: AppColors.white,
      //   automaticallyImplyLeading: false,
      //   centerTitle: true,
      //   elevation: 0,
      //   leading: Padding(
      //     padding: const EdgeInsets.only(left: 15),
      //     child: InkWell(
      //       onTap: () {
      //         Get.back();
      //       },
      //       child: const Icon(Icons.arrow_back,
      //           color: AppColors.black2A3, size: 24),
      //     ),
      //   ),
      //   title: Text(
      //     'Settings',
      //     textAlign: TextAlign.center,
      //     style: TextStyle(
      //         fontSize: 15.sp,
      //         fontFamily: 'Montserrat',
      //         color: AppColors.black2A3,
      //         fontWeight: FontWeight.w600),
      //   ),
      // ),
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// MyAccount Widget View
              Container(
                width: Get.width,
                color: AppColors.greyF7F,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10, left: 25),
                  child: Text(
                    'My Account',
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontFamily: 'Montserrat',
                        color: AppColors.green,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              MyAccountWidgetView(),

              /// PrivacyControl Widget View
              Container(
                width: Get.width,
                color: AppColors.greyF7F,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10, left: 25),
                  child: Text(
                    'Privacy  Control',
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontFamily: 'Montserrat',
                        color: AppColors.green,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              PrivacyControlWidgetView(),

              /// FeedBack Widget View
              Container(
                width: Get.width,
                color: AppColors.greyF7F,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10, left: 25),
                  child: Text(
                    'Feedback',
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontFamily: 'Montserrat',
                        color: AppColors.green,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FeedBackWidgetView(),

              /// MoreInformation Widget View
              Container(
                width: Get.width,
                color: AppColors.greyF7F,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10, left: 25),
                  child: Text(
                    'More Information',
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontFamily: 'Montserrat',
                        color: AppColors.green,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              MoreInformationWidgetView(),

              /// AccountAction Widget View
              Container(
                width: Get.width,
                color: AppColors.greyF7F,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10, left: 25),
                  child: Text(
                    'Account Actions',
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontFamily: 'Montserrat',
                        color: AppColors.green,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              InkWell(
                onTap: () {
                  Get.defaultDialog(
                    backgroundColor: AppColors.white,
                    contentPadding: EdgeInsets.zero,
                    title: "",
                    titlePadding: EdgeInsets.zero,
                    content: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          const Icon(Icons.logout,
                              color: AppColors.green, size: 30),
                          const SizedBox(height: 22),
                          Text(
                            'Are you sure you want to Logout.?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12.sp,
                                fontFamily: 'Montserrat',
                                color: AppColors.black2A3,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Get.back();
                                  },
                                  child: Container(
                                    height: 40,
                                    width: Get.width,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppColors.neutralGray,
                                          width: 1),
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'No',
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            fontFamily: 'Montserrat',
                                            color: AppColors.green,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Get.back();
                                  },
                                  child: Container(
                                    height: 40,
                                    width: Get.width,
                                    decoration: BoxDecoration(
                                      color: AppColors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Yes',
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            fontFamily: 'Montserrat',
                                            color: AppColors.white,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Text(
                    'Logout',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'Montserrat',
                        color: AppColors.orangeColor,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }

  /// MyAccount Widget View
  Widget MyAccountWidgetView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonColumnWidget.column(
          onTap: () {
            Get.to(() => const UpdateName());
          },
          text1: "Name",
          text2: "Devon Lane",
        ),
        const SizedBox(height: 12),
        CommonColumnWidget.column(
          onTap: () {
            // Get.to(() => DisplayUserNameScreen());
          },
          text1: "Username",
          text2: "Devon_Lane_1989",
        ),
        const SizedBox(height: 12),
        CommonColumnWidget.column(
          onTap: () {
            // Get.to(() => MobileNumberScreen());
          },
          text1: "Mobile Number",
          text2: "1234567890",
        ),
        const SizedBox(height: 12),
        CommonColumnWidget.column(
          onTap: () {
            Get.to(() => const EmailUpdate());
          },
          text1: "Email",
          text2: "devonlane@gmail.com",
        ),
        const SizedBox(height: 12),
        CommonColumnWidget.column(
          onTap: () {
            // Get.to(() => PasswordScreen());
          },
          text1: "Password",
          text2: "********",
        ),
        const SizedBox(height: 12),
        CommonColumnWidget.column(
          onTap: () {
            Get.to(() => NotificationSettings());
          },
          text1: "Notifications",
          text2: "",
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  /// PrivacyControl Widget View
  Widget PrivacyControlWidgetView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonColumnWidget.column(
          onTap: () {
            Get.to(() => ContactMeScreen());
          },
          text1: "Contact Me",
          text2: "",
        ),
        const SizedBox(height: 18),
        CommonColumnWidget.column(
          onTap: () {
            Get.to(() => MyStoryScreen());
          },
          text1: "View My Story",
          text2: "Everyone",
        ),
        const SizedBox(height: 18),
        CommonColumnWidget.column(
          onTap: () {
            Get.to(() => MyLocationScreen());
          },
          text1: "See My Location",
          text2: "",
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  /// FeedBack Widget View
  Widget FeedBackWidgetView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonColumnWidget.column(
          onTap: () {
            // Get.to(() => ISupportBugScreen());
          },
          text1: "I Spotted a Bug",
          text2: "",
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  /// MoreInformation Widget View
  Widget MoreInformationWidgetView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonColumnWidget.column(
          onTap: () {
            Get.to(() => const PrivacyPolicyScreen());
          },
          text1: "Privacy Policy",
          text2: "",
        ),
        const SizedBox(height: 18),
        CommonColumnWidget.column(
          onTap: () {
            // Get.to(() => SafetyCenterScreen());
          },
          text1: "Safety Centre",
          text2: "Everyone",
        ),
        const SizedBox(height: 18),
        CommonColumnWidget.column(
          onTap: () {
            Get.to(() => const TermsandConditionScreen());
          },
          text1: "Terms of Service",
          text2: "",
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}
