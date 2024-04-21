import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nomo_app/res/assets/assets.dart';
import 'package:nomo_app/res/colors/appcolors.dart';
import 'package:nomo_app/res/components/gradient-app-bar.dart';

class GalleryScreen extends StatefulWidget {
  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final List<String> images = [
    // Add image URLs or local assets paths
    Assets.greenVila,
    Assets.royalVila,
    Assets.royalVila,
    Assets.greenVila,
    // 'image1.jpg',
    // 'image2.jpg',
    // 'image3.jpg',
    // More images...
  ];

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    var screenWidth = MediaQuery.of(context).size.width;

    // Set the crossAxisCount to a value that creates a nice layout for different screen sizes
    int crossAxisCount = screenWidth < 600 ? 2 : 3;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: GridView.builder(
        padding: EdgeInsets.all(10.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.asset(
              images[index],
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
