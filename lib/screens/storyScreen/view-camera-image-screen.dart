// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nomo_app/res/assets/assets.dart';
import 'package:nomo_app/res/colors/appcolors.dart';
import 'package:nomo_app/res/components/dialogs/dialogs.dart';
import 'package:image/image.dart' as imgLib;
import 'dart:io';
import 'dart:math' as math;

class ViewCameraImageScreen extends StatefulWidget {
  final File imageFile;
  const ViewCameraImageScreen({super.key, required this.imageFile});

  @override
  State<ViewCameraImageScreen> createState() => _ViewCameraImageScreenState();
}

class _ViewCameraImageScreenState extends State<ViewCameraImageScreen> {
  late imgLib.Image _image;
  late File _imageFile;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    _imageFile = widget.imageFile;
    final imageBytes = await _imageFile.readAsBytes();
    _image = imgLib.decodeImage(imageBytes)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarColor: Color(0xffD9D9D9)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.gradientColor),
        ),
        leadingWidth: 70,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Transform.scale(
              scale: 0.5,
              child: SvgPicture.asset(
                Assets.cancel,
                color: AppColors.white,
                height: 30,
              ),
            )),
        title: InkWell(
          onTap: () {
            // Get.to(() => ProfileScreen());
          },
          child: const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(Assets.follower7),
          ),
        ),
      ),

      /// Top Widget View
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: FileImage(_imageFile), fit: BoxFit.cover)),
          ),
          topWidgetView(),
        ],
      ),
    );
  }

  /// Top Widget View
  Widget topWidgetView() {
    return Padding(
        padding:
            const EdgeInsets.only(top: 32, bottom: 50, left: 25, right: 27),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: AppColors.blackColor),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  children: [
                    SvgPicture.asset(Assets.textImage),
                    const SizedBox(height: 25),
                    SvgPicture.asset(Assets.pencilIcon),
                    const SizedBox(height: 25),
                    SvgPicture.asset(Assets.stickerIcon),
                    const SizedBox(height: 25),
                    SvgPicture.asset(Assets.scissorIcon),
                    const SizedBox(height: 25),
                    SvgPicture.asset(Assets.soundImage),
                    const SizedBox(height: 25),
                    SvgPicture.asset(Assets.magnifyingGlass),
                    const SizedBox(height: 25),
                    SvgPicture.asset(Assets.paperclip),
                    const SizedBox(height: 25),
                    SvgPicture.asset(Assets.crop),
                    const SizedBox(height: 25),
                    SvgPicture.asset(Assets.timerImage),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: addStoryButton(onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return storyDialog();
                    });
              }),
            ),
          ],
        ));
  }

// Add Story Button
  Widget addStoryButton({required VoidCallback onTap}) {
    return Container(
      height: 40,
      width: 134,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          gradient: AppColors.gradientColor),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.only(left: 18, right: 12),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              flex: 3,
              child: Text(
                'Add Story',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat'),
              ),
            ),
            Expanded(
              child: Transform.rotate(
                angle: -35 * math.pi / 180,
                child: SvgPicture.asset(
                  Assets.send,
                  color: AppColors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
