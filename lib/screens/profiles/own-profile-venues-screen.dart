import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nomo_app/res/assets/assets.dart';
import 'package:nomo_app/res/colors/appcolors.dart';
import 'package:nomo_app/screens/profiles/user-public-view-profile-screen.dart';
import 'package:nomo_app/screens/venues/myVenues/my-venues-screen.dart';
import 'package:nomo_app/screens/venues/venue-detail-screen.dart';

class OwnProfileVenuesScreen extends StatefulWidget {
  const OwnProfileVenuesScreen({super.key});

  @override
  State<OwnProfileVenuesScreen> createState() => _OwnProfileVenuesScreenState();
}

class _OwnProfileVenuesScreenState extends State<OwnProfileVenuesScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding:
            const EdgeInsets.only(top: 10, bottom: 60, right: 20, left: 20),
        itemCount: 10,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          if (index == 0) {
            return buildCreatesVenueButton();
          }
          return buildVenueCard();
        });
  }

  Widget buildCreatesVenueButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 0,
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => const UserPublicViewProfileScreen());
                  },
                  child: const CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage(
                      Assets.userProfile,
                    ),
                  ),
                ),
              ),
              8.horizontalSpace,
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: () {
                    Get.to(() => const MyVenuesScreen());
                  },
                  splashColor: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  child: Ink(
                    height: 43,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(width: 1, color: AppColors.neutralGray)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add,
                          color: Color(0xff50555C),
                        ),
                        10.horizontalSpace,
                        const Text(
                          'Create Venues',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                              fontFamily: "Montserrat"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              8.horizontalSpace,
              Expanded(
                  flex: 0,
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => const VenueDetailScreen());
                    },
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          Assets.locationPin,
                          height: 22,
                        ),
                        4.horizontalSpace,
                        const Text(
                          'Venues Detail',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                              color: AppColors.blackColor,
                              fontFamily: "Montserrat"),
                        ),
                      ],
                    ),
                  ))
            ],
          ),
          8.verticalSpace,
          const Divider(),
        ],
      ),
    );
  }

  Widget buildVenueCard() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        // height: 90.h,
        constraints: const BoxConstraints(maxHeight: double.infinity),
        margin: const EdgeInsets.only(bottom: 10),
        width: double.infinity,
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                  offset: const Offset(0, 3),
                  color: AppColors.neutralGray.withOpacity(0.2),
                  blurRadius: 3,
                  spreadRadius: 0)
            ]),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 75.h,
                width: 110.w,
                margin: const EdgeInsets.only(left: 6, top: 3, bottom: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  image: const DecorationImage(
                    image: AssetImage(Assets.resortImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 0.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Nature Pure, Hotel',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            fontFamily: "Montserrat"),
                      ),
                      8.verticalSpace,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(Assets.locationBlack),
                          5.horizontalSpace,
                          const Expanded(
                            child: Text(
                              'Lorem ipsum dolor sit amet consectetur adipiscing elit.',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                  color: Color(0xff6F6E6E),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Montserrat"),
                            ),
                          ),
                        ],
                      ),
                      10.verticalSpace,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.star_rate_rounded,
                            color: Color(0xffFFC107),
                            size: 20,
                          ),
                          3.horizontalSpace,
                          const Text(
                            '4.7',
                            style: TextStyle(
                                color: Color(0xff6F6E6E),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Montserrat"),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
