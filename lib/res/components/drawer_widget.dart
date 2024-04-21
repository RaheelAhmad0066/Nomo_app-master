// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nomo_app/res/assets/assets.dart';
import 'package:nomo_app/res/colors/appcolors.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      clipBehavior: Clip.none,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: Get.height * .34,
            width: Get.width,
            margin: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
                color: Color(0xff141C53),
                borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(40))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(Assets.ddmLogo),
                10.verticalSpace,
                Text(
                  'Trusted Partner for',
                  style: TextStyle(
                      fontSize: 14,
                      color: AppColors.white,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600),
                ),
                10.verticalSpace,
                Text(
                  'Development, Designing,\nManagement & Marketing',
                  style: TextStyle(
                      fontSize: 14,
                      color: AppColors.white,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
