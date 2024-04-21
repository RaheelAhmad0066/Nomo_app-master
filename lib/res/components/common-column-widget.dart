import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nomo_app/res/colors/appcolors.dart';

class CommonColumnWidget {
  static column({text1, text2, onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 30.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    text1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'Montserrat',
                        color: AppColors.black2A3,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    text2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11.sp,
                        fontFamily: 'Montserrat',
                        color: AppColors.grey818,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          // SizedBox(height: 18),
          const Divider(color: AppColors.neutralGray, thickness: 1),
        ],
      ),
    );
  }
}
