// ignore_for_file: must_be_immutable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nomo_app/res/colors/appcolors.dart';

class SocialMediaButton extends StatelessWidget {
  VoidCallback onTap;
  String? buttonText;
  String? buttonIcon;

  SocialMediaButton({
    super.key,
    required this.buttonIcon,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      splashColor: Colors.grey.shade100,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.white,
          border: Border.all(color: AppColors.neutralGray),
        ),
        height: 48,
        width: 160.w,
        child: Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                buttonIcon!,
                height: 15.h,
              ),
              5.horizontalSpace,
              Text(
                buttonText!,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  fontFamily: 'Montserrat',
                ),
                textScaleFactor: 0.9,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
