import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nomo_app/res/assets/assets.dart';
import 'package:nomo_app/res/colors/appcolors.dart';
import 'package:nomo_app/screens/profiles/view-profile-cover-pic.dart';
// ignore: unused_import
import 'package:nomo_app/screens/storyScreen/view-camera-image-screen.dart';
import 'package:permission_handler/permission_handler.dart';

class ChangeImageWithCamera extends StatefulWidget {
  const ChangeImageWithCamera({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChangeImageWithCameraState createState() => _ChangeImageWithCameraState();
}

class _ChangeImageWithCameraState extends State<ChangeImageWithCamera>
    with WidgetsBindingObserver {
  List<CameraDescription>? _cameras;
  CameraController? _controller;
  bool _isReady = false;
  final int _currentCameraIndex = 1;
  bool _isPermissionDialogVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final cameraPermissionStatus = await Permission.camera.status;
    if (cameraPermissionStatus.isGranted) {
      _setUpCameras();
    } else {
      setState(() => _isPermissionDialogVisible = true);
      final requestedStatus = await Permission.camera.request();
      setState(() => _isPermissionDialogVisible = false);
      if (requestedStatus.isGranted) {
        _setUpCameras();
      } else {
        // Handle permission denied
      }
    }
  }

  Future<void> _setUpCameras() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _initializeCamera(_currentCameraIndex);
    }
  }

  Future<void> _initializeCamera(int cameraIndex) async {
    _controller?.dispose(); // Dispose if _controller is already initialized
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(
        _cameras![cameraIndex], // Safe access to _cameras
        ResolutionPreset.medium,
      );

      try {
        await _controller!.initialize();
        if (mounted) {
          setState(() => _isReady = true);
        }
      } on CameraException catch (e) {
        print("Error initializing camera: $e");
      }
    }
  }
  // void _swapCamera() {
  //   if (_cameras != null && _cameras!.length > 1) {
  //     _currentCameraIndex = _currentCameraIndex == 0 ? 1 : 0;
  //     _initializeCamera(_currentCameraIndex);
  //   }
  // }

  Future<String> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      print('Error: Select a camera first.');
      return '';
    }
    final XFile file = await _controller!.takePicture();
    return file.path;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    if (_controller != null && _controller!.value.isInitialized) {
      _controller!.dispose();
    }
    _controller = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera(_currentCameraIndex);
    }
  }

// Function For Crop Image
  Future<void> _cropImage(String sourcePath) async {
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      cropStyle: CropStyle.circle,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '',
          toolbarColor: AppColors.white,
          toolbarWidgetColor: Colors.black,
          backgroundColor: AppColors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          cropFrameColor: AppColors.white,
          dimmedLayerColor: Colors.black.withOpacity(0.5),
        ),
        IOSUiSettings(
          // title: 'Crop Your Image',

          rotateButtonsHidden: false,
          aspectRatioPickerButtonHidden: false,
          resetButtonHidden: true,
          rotateClockwiseButtonHidden: false,
          aspectRatioLockEnabled: false,
          aspectRatioLockDimensionSwapEnabled: true,
          doneButtonTitle: 'Done',
          cancelButtonTitle: 'Cancel',
          resetAspectRatioEnabled: false,
          minimumAspectRatio: 1.0,
        ),
      ],
    );
    if (croppedFile != null) {
      _navigateToNextScreen(croppedFile);
    }
  }

  void _navigateToNextScreen(CroppedFile croppedFile) {
    final imageFile = File(croppedFile.path);
    Get.to(() => ViewProfileCoverPicScreen(
          isOwnProfile: true,
          imageFile: imageFile,
        ));
  }

// ***** For Image Pick From Gallery *****
  File? _image;
  final picker = ImagePicker();

//Image Picker function to get image from gallery
  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isPermissionDialogVisible
        ? const Center(child: CircularProgressIndicator())
        : _isReady
            ? Scaffold(
                backgroundColor: AppColors.blackColor,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  centerTitle: true,
                  elevation: 0,
                  systemOverlayStyle: const SystemUiOverlayStyle(
                      statusBarColor: Color(0xffD9D9D9)),
                  flexibleSpace: Container(
                    decoration:
                        const BoxDecoration(gradient: AppColors.gradientColor),
                  ),
                  leadingWidth: 70,
                  leading: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Transform.scale(
                        scale: 0.3,
                        child: SvgPicture.asset(
                          Assets.cancel,
                          color: AppColors.white,
                          height: 30,
                        ),
                      )),
                  title: InkWell(
                    onTap: () {},
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage(Assets.follower7),
                    ),
                  ),
                ),
                body: Stack(
                  children: [
                    getBody(),

                    // getBody(),
                    getFooter(
                      onTap: () async {
                        final imagePath = await takePicture();
                        // if (imagePath.isNotEmpty) {
                        //   final imageFile = File(imagePath);

                        //   Get.to(() => SelectGenderScreen(imageFile: imageFile));
                        // }
                        _cropImage(imagePath);
                      },
                    ),
                  ],
                ))
            : getPermissionRequestUI();
  }

  Widget cameraPreview() {
    return AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: CameraPreview(_controller!));
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    if (_isReady == false ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return Container(
        decoration: const BoxDecoration(color: Colors.white),
        width: size.width,
        height: size.height,
        child: const Center(
            child: SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                ))),
      );
    }

    return SizedBox(
      width: size.width,
      height: size.height,
      child: ClipRRect(
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10)),
          child: cameraPreview()),
    );
  }

  Widget getBodyBK() {
    var size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20)),
          color: Colors.white),
      child: const Image(
        image: NetworkImage(
          "https://images.unsplash.com/photo-1582152629442-4a864303fb96?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MXx8c2VsZmllfGVufDB8fDB8&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
        ),
        fit: BoxFit.cover,
      ),
    );
  }

  Widget getPermissionRequestUI() {
    return Scaffold(backgroundColor: Colors.white, body: Container());
  }

  Widget getFooter({required VoidCallback onTap}) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 50,
            margin: const EdgeInsets.only(top: 20, right: 20),
            decoration: BoxDecoration(
                color: AppColors.blackColor,
                borderRadius: BorderRadius.circular(30)),
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 10, bottom: 20, top: 20, right: 13),
              child: Column(
                children: [
                  GestureDetector(
                      onTap: () {}, child: SvgPicture.asset(Assets.swapImage)),
                  const SizedBox(height: 25),
                  SvgPicture.asset(Assets.flashLightImage),
                  const SizedBox(height: 25),
                  SvgPicture.asset(Assets.timeLineImage),
                  const SizedBox(height: 25),
                  InkWell(
                    onTap: () {},
                    child: SvgPicture.asset(Assets.soundImage),
                  ),
                  const SizedBox(height: 25),
                  SvgPicture.asset(Assets.multiFabisImage),
                  const SizedBox(height: 25),
                  SvgPicture.asset(Assets.timerImage),
                  const SizedBox(height: 25),
                  SvgPicture.asset(Assets.focusImage),
                  const SizedBox(height: 25),
                  SvgPicture.asset(Assets.gridImage),
                  // const SizedBox(height: 25),
                  // const Align(
                  //   alignment: Alignment.centerRight,
                  //   child: Icon(Icons.keyboard_arrow_up,
                  //       color: AppColors.white, size: 18),
                  // ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      getImageFromGallery();
                    },
                    child: Container(
                      height: 35,
                      width: 35,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xff171700).withOpacity(0.8)),
                      child: SvgPicture.asset(
                        Assets.storyGallery,
                        height: 30,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  InkWell(
                      onTap: onTap,
                      child: IconButton(
                          onPressed: null,
                          icon: SvgPicture.asset(
                            Assets.storyCapture,
                          ))),
                  const SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 35,
                      width: 35,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xff171700).withOpacity(0.8)),
                      child: SvgPicture.asset(
                        Assets.storyEmojy,
                        height: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
