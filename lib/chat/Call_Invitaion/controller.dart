import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:nomo_app/Services/Prefferences/prefferences.dart';
import 'package:nomo_app/screens/constant/constant.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import '../api/apis.dart';
import 'Common.dart';

class CallController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    onUserLogin();
    super.onInit();
  }

  void onSendCallInvitationFinished(
    String code,
    String message,
    List<String> errorInvitees,
  ) {
    if (errorInvitees.isNotEmpty) {
      var userIDs = '';
      for (var index = 0; index < errorInvitees.length; index++) {
        if (index >= 5) {
          userIDs += '... ';
          break;
        }

        final userID = errorInvitees.elementAt(index);
        userIDs += '$userID ';
      }
      if (userIDs.isNotEmpty) {
        userIDs = userIDs.substring(0, userIDs.length - 1);
      }

      var message = "User doesn't exist or is offline: $userIDs";
      if (code.isNotEmpty) {
        message += ', code: $code, message:$message';
      }

      Fluttertoast.showToast(msg: message, gravity: ToastGravity.TOP);
    } else if (code.isNotEmpty) {
      Fluttertoast.showToast(msg: message, gravity: ToastGravity.TOP);
    }
  }

  sendCallButton(
      {required bool isVideoCall,
      required String Userid,
      required String username,
      void Function(String code, String message, List<String>)?
          onCallFinished}) {
    final invitees = getInvitesFromTextCtrl(Userid, username);

    return ZegoSendCallInvitationButton(
        isVideoCall: isVideoCall,
        invitees: invitees,
        resourceID: 'zego_data',
        iconSize: const Size(40, 40),
        buttonSize: const Size(50, 50),
        onPressed: onCallFinished);
  }

  List<ZegoUIKitUser> getInvitesFromTextCtrl(String textCtrlText, String name) {
    final invitees = <ZegoUIKitUser>[];

    final inviteeIDs = textCtrlText.replaceAll('，', '');
    inviteeIDs.split(',').forEach((inviteeUserID) {
      if (inviteeUserID.isEmpty) {
        return;
      }

      invitees.add(ZegoUIKitUser(id: inviteeUserID, name: name));
    });

    return invitees;
  }

  ZegoUIKitPrebuiltCallController? callController;

  /// on user login
  void onUserLogin() {
    callController ??= ZegoUIKitPrebuiltCallController();
    // String username = Get.find<PrefUtils>().getStrings(PrefferKey.name) ?? '';
    // int userid = Get.find<PrefUtils>().getUserId(PrefferKey.id);

    /// 4/5. initialized ZegoUIKitPrebuiltCallInvitationService when account is logged in or re-logged in
    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: Mycall.appid /*input your AppID*/,
      appSign: Mycall.appsign /*input your AppSign*/,
      userID: APIs.user.uid,
      userName: APIs.user.displayName.toString(),
      // notifyWhenAppRunningInBackgroundOrQuit: false,
      notificationConfig: ZegoCallInvitationNotificationConfig(),
      plugins: [ZegoUIKitSignalingPlugin()],
      // controller: callController,
      requireConfig: (ZegoCallInvitationData data) {
        final config = (data.invitees.length > 1)
            ? ZegoCallType.videoCall == data.type
                ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
                : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
            : ZegoCallType.videoCall == data.type
                ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
                : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

        config.avatarBuilder = customAvatarBuilder;

        /// support minimizing, show minimizing button
        config.topMenuBarConfig.isVisible = true;
        config.topMenuBarConfig.buttons
            .insert(0, ZegoMenuBarButtonName.minimizingButton);

        return config;
      },
    );
  }

  /// on user logout
  void onUserLogout() {
    callController = null;

    /// 5/5. de-initialization ZegoUIKitPrebuiltCallInvitationService when account is logged out
    ZegoUIKitPrebuiltCallInvitationService().uninit();
  }
}

class Mycall {
  static const int appid = 1350305951;
  static const String appsign =
      '85b1905e9aaf00f3f8588227be05040cc35a0dcb2724637d16289e1a834b5f19';
}
