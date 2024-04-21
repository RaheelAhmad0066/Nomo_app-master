import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nomo_app/controllers/shared-index-controller.dart';
import 'package:nomo_app/firebase_option.dart';
import 'package:nomo_app/res/colors/appcolors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nomo_app/screens/splash-screen.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'AppRoutes/app-routes.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
  ZegoUIKit().initLog().then((value) {
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
      [ZegoUIKitSignalingPlugin()],
    );
  });

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Color(0xffD9D9D9)),
  );
  //for setting orientation to portrait only
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    _initializeFirebase();
    runApp(MyApp(
      navigatorKey: navigatorKey,
    ));
  });
}

String dummyImg =
    'https://www.afristay.com/media/thumbnails/pictures/places/7032/royalvillas_1-x_large.jpg.1366x768_q85_crop_upscale.jpg';
String dummyImg1 =
    'https://images.unsplash.com/photo-1531971589569-0d9370cbe1e5?q=80&w=2081&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
String dummyImg2 =
    'https://images.unsplash.com/photo-1561026554-29d9815d4f3d?q=80&w=1935&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
String dummyImg3 =
    'https://images.unsplash.com/photo-1568605114967-8130f3a36994?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
String dummyImg4 =
    'https://cf.bstatic.com/xdata/images/hotel/max1024x768/15285563.jpg?k=5dabb705c470e0daa5bd45db238fa88ef16906db948e180e2137e976f5786c9a&o=&hp=1';

class MyApp extends StatelessWidget {
  MyApp({Key? key, required this.navigatorKey}) : super(key: key);

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    Get.put(SharedController());
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return Listener(
            onPointerDown: (_) {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.focusedChild?.unfocus();
              }
            },
            child: GetMaterialApp(
              getPages: AppRoutes.routes,
              defaultTransition: Transition.fadeIn,
              initialRoute: AppRoutes.splash,
              debugShowCheckedModeBanner: false,
              title: 'NOMO App',
              theme: ThemeData(
                fontFamily: 'Montserrat',
                colorScheme: ColorScheme.fromSeed(seedColor: AppColors.white),
              ),
              home: child,
              navigatorKey: navigatorKey,
              builder: (BuildContext context, Widget? child) {
                return Stack(
                  children: [
                    child!,
                    ZegoUIKitPrebuiltCallMiniOverlayPage(
                      contextQuery: () {
                        return navigatorKey.currentState!.context;
                      },
                    ),
                  ],
                );
              },
            ),
          );
        },
        child: SplashScreen());
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

Future<void> _initializeFirebase() async {
  // Initialize Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Handle FCM message when the app is in foreground
    showLocalNotification(message.data['title'], message.data['body']);
  });

  // Request permission for receiving notifications
  await FirebaseMessaging.instance.requestPermission();

  // Set up local notifications
  await _setupLocalNotifications();
}

Future<void> _setupLocalNotifications() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  final initializationSettingsIOS = DarwinInitializationSettings();
  final initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> showLocalNotification(String title, String body) async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'channel_id',
    'Channel Name',
    importance: Importance.max,
    priority: Priority.high,
  );
  final platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: DarwinNotificationDetails(),
  );
  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: 'item x',
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  showLocalNotification(message.data['title'], message.data['body']);
}
