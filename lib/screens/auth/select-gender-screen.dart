import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nomo_app/Services/AuthServices/Authservices.dart';
import 'package:nomo_app/controllers/gender-controller.dart';
import 'package:nomo_app/res/assets/assets.dart';
import 'package:nomo_app/res/colors/appcolors.dart';
import 'package:image/image.dart' as imgLib;
import 'package:nomo_app/screens/auth/signup-email-verify-screen.dart';

class SelectGenderScreen extends StatefulWidget {
  final File imageFile;
  String name;
  String email;
  String password;
  String fullname;

  SelectGenderScreen(
      {super.key,
      required this.imageFile,
      required this.name,
      required this.email,
      required this.password,
      required this.fullname});

  @override
  State<SelectGenderScreen> createState() => _SelectGenderScreenState();
}

class _SelectGenderScreenState extends State<SelectGenderScreen> {
  imgLib.Image? _image;
  String? selectedGender;
  final authcontroller = Get.put(AuthServices());
  String image = '';
  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final imageBytes = await widget.imageFile.readAsBytes();
    String images = base64Encode(imageBytes);
    setState(() {
      _image = imgLib.decodeImage(imageBytes);
      image = images;
    });
  }

  final GenderSelectionController controller =
      Get.put(GenderSelectionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarColor: Color(0xffD9D9D9)),
        backgroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          InkWell(
            onTap: () {
              authcontroller.signUpService(
                  fullName: widget.fullname,
                  email: widget.email,
                  password: widget.password,
                  image: image,
                  gender: controller.selectedGender.toString(),
                  username: widget.name);
            },
            child: const Padding(
              padding: EdgeInsets.only(top: 10, right: 25),
              child: Text(
                'Skip',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          20.verticalSpace,
          if (_image != null)
            Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: FileImage(widget.imageFile),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
              child: const Icon(Icons.person, size: 120, color: Colors.grey),
            ),
          70.verticalSpace,
          const Text(
            'Select your Gender',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
          ),
          20.verticalSpace,
          Obx(() {
            return authcontroller.isLoading.value
                ? Center(child: CircularProgressIndicator())
                : Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            controller.selectGender('male');
                            authcontroller.signUpService(
                                fullName: widget.fullname,
                                email: widget.email,
                                password: widget.password,
                                image: image,
                                gender: controller.selectedGender.toString(),
                                username: widget.name);
                            print(widget.email);
                            print(widget.fullname);
                            print(widget.password);
                            print(controller.selectedGender);
                            print(widget.name);
                            print(widget.email);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(1.5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      controller.selectedGender.value == 'male'
                                          ? Border.all(
                                              color: AppColors.green, width: 4)
                                          : null,
                                ),
                                child: Image.asset(Assets.maleAvatar,
                                    height: 125, width: 125),
                              ),
                              10.verticalSpace,
                              const Text(
                                'Male',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 30),
                        GestureDetector(
                          onTap: () {
                            authcontroller.signUpService(
                                fullName: widget.fullname,
                                email: widget.email,
                                password: widget.password,
                                image: image,
                                gender: controller.selectedGender.toString(),
                                username: widget.name);
                            controller.selectGender('female');
                            Get.to(() => SignUpEmailVerifyScreen(
                                  email: widget.email,
                                ));
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(1.5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: controller.selectedGender.value ==
                                          'female'
                                      ? Border.all(
                                          color: AppColors.green, width: 4)
                                      : null,
                                ),
                                child: Image.asset(Assets.femaleAvatar,
                                    height: 125, width: 125),
                              ),
                              10.verticalSpace,
                              const Text(
                                'Female',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
          })
        ],
      ),
    );
  }
}
