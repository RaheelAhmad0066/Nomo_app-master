import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../res/assets/assets.dart';
import '../../res/colors/appcolors.dart';
import '../../res/components/buttons/post-button.dart';
import '../../res/components/messages/message-field.dart';
import '../api/apis.dart';
import '../service/database_service.dart';
import '../widgets/message_tile.dart';
import '../widgets/widgets.dart';
import 'edit_image_page.dart';
import 'group_info.dart';

class ChatSupportHelp extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  final String groupIcon;
  const ChatSupportHelp(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.userName,
      required this.groupIcon});

  @override
  State<ChatSupportHelp> createState() => _ChatSupportHelpState();
}

class _ChatSupportHelpState extends State<ChatSupportHelp> {
  String admin = "";
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  ScrollController listScrollController = ScrollController();
  bool _isFirstScrolled = false;

  FilePickerResult? result;

  String imagePath = "";
  String groupDp = "";
  String username = "";

  selectImages() async {
    result = await FilePicker.platform.pickFiles();

    if (result != null) {
      imagePath = result!.files.single.path!;

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => EditImagePage(
                    imagePath: imagePath,
                    groupId: widget.groupId,
                    username: widget.userName,
                  )));

      setState(() {});
    } else {
      // User canceled the picker
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getChatAndAdmin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName),
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(
                    context,
                    GroupInfo(
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                      adminName: admin,
                      groupIcon: widget.groupIcon,
                    ));
              },
              icon: Icon(Icons.info))
        ],
      ),
      body: Column(
        children: [
          chatMessages(),
          SizedBox(
            height: 10,
          ),
          chatInput(),
          SizedBox(
            height: 50,
          )
        ],
      ),
    );
  }

  getChatAndAdmin() async {
    DatabaseService(uid: APIs.user.uid).getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });

    DatabaseService(uid: APIs.user.uid)
        .getGroupAdmins(widget.groupId)
        .then((value) {
      setState(() {
        admin = value;
      });
    });

    DatabaseService(uid: APIs.user.uid).toggleRecentMessageSeen(widget.groupId);

    chats!.listen((event) {
      DatabaseService(uid: APIs.user.uid)
          .toggleRecentMessageSeen(widget.groupId);
    });
  }

  chatMessages() {
    return StreamBuilder(
        stream: chats,
        builder: (context, AsyncSnapshot snapshot) {
          DatabaseService(uid: APIs.user.uid)
              .toggleRecentMessageSeen(widget.groupId);

          return snapshot.hasData
              ? Expanded(
                  child: ListView.builder(
                      controller: listScrollController,
                      itemCount: snapshot.data.docs.length,
                      reverse: true,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return MessageTile(
                          message: snapshot.data.docs[index]["message"],
                          sender: snapshot.data.docs[index]['sender'],
                          isMe: widget.userName ==
                              snapshot.data.docs[index]['sender'],
                          image: snapshot.data.docs[index]['imgUrl'],
                          messageTimeStamp: snapshot.data.docs[index]['time'],
                        );
                      }),
                )
              : Expanded(child: Container());
        });
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "imgUrl": "",
        "sender": widget.userName,
        "time": DateTime.now().microsecondsSinceEpoch
      };

      DatabaseService(uid: APIs.user.uid)
          .sendMessage(widget.groupId, chatMessageMap);

      DatabaseService(uid: APIs.user.uid)
          .toggleRecentMessageSeen(widget.groupId);

      setState(() {
        messageController.clear();
      });
    }
  }

  scrollToBottom() {
    if (listScrollController.hasClients) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        listScrollController.animateTo(
          listScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Widget chatInput() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 8, bottom: 8, top: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              top: BorderSide(color: AppColors.neutralGray.withOpacity(0.5)))),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: "Type your message...",
                hintStyle: TextStyle(
                    fontSize: 10.sp,
                    color: const Color(0xff878F96),
                    fontWeight: FontWeight.w600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                prefixIcon: GestureDetector(
                  onTap: () {
                    showAttachmentBottomSheet(context);
                  },
                  child: Transform.scale(
                    scale: 0.5,
                    child: SvgPicture.asset(
                      Assets.documentAdd,
                      height: 10.h,
                    ),
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              ),
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          const SizedBox(width: 8),
          PostButton(
              width: 70.w,
              text: 'Send',
              onTap: () {
                sendMessage();
              })
        ],
      ),
    );
  }

  void showAttachmentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
              // color: AppColors.white,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30), topLeft: Radius.circular(30))),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Attachment File',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          CircularGradientButton(
                              gradient: AppColors.gradientColor,
                              onPressed: () {},
                              child: SvgPicture.asset(Assets.documentText)),
                          const SizedBox(height: 8),
                          Text(
                            'Document',
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          CircularGradientButton(
                              gradient: AppColors.gradientColor,
                              onPressed: () async {},
                              child: SvgPicture.asset(Assets.camera)),
                          const SizedBox(height: 8),
                          Text(
                            'Camera',
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          CircularGradientButton(
                              gradient: AppColors.gradientColor,
                              onPressed: () async {},
                              child: SvgPicture.asset(Assets.gallery)),
                          const SizedBox(height: 8),
                          Text(
                            'Gallery',
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          CircularGradientButton(
                              gradient: AppColors.gradientColor,
                              onPressed: () {},
                              child: SvgPicture.asset(Assets.documentText)),
                          const SizedBox(height: 8),
                          Text(
                            'Audio',
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          CircularGradientButton(
                              gradient: AppColors.gradientColor,
                              onPressed: () {},
                              child: SvgPicture.asset(Assets.camera)),
                          const SizedBox(height: 8),
                          Text(
                            'Location',
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          CircularGradientButton(
                              gradient: AppColors.gradientColor,
                              onPressed: () {},
                              child: SvgPicture.asset(Assets.gallery)),
                          const SizedBox(height: 8),
                          Text(
                            'Contact',
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              )),
            ],
          ),
        );
      },
    );
  }
}
