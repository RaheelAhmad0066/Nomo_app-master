import 'dart:developer';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../res/assets/assets.dart';
import '../../res/colors/appcolors.dart';
import '../../res/components/buttons/post-button.dart';
import '../../res/components/messages/message-field.dart';
import '../Call_Invitaion/controller.dart';
import '../api/apis.dart';
import '../helper/my_date_util.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../widgets/message_card.dart';
import 'home_screen.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];
  final controller = Get.put(CallController());

  @override
  void initState() {
    // // TODO: implement initState
    // onUserLogin();
    super.initState();
  }

  //for handling message text changes
  final _textController = TextEditingController();

  //showEmoji -- for storing value of showing or hiding emoji
  //isUploading -- for checking if image is uploading or not?
  bool _showEmoji = false, _isUploading = false;
  final TextEditingController singleInviteeUserIDTextCtrl =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          //if emojis are shown & back button is pressed then hide emojis
          //or else simple close current screen on back button click
          onWillPop: () {
            if (_showEmoji) {
              setState(() => _showEmoji = !_showEmoji);
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            //app bar
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
              actions: [
                controller.sendCallButton(
                  username: widget.user.name,
                  isVideoCall: false,
                  Userid: widget.user.id,
                  onCallFinished: (code, message, p2) {
                    controller.onSendCallInvitationFinished;
                    controller.onUserLogin();
                  },
                ),
                controller.sendCallButton(
                  username: widget.user.name,
                  isVideoCall: true,
                  Userid: widget.user.id,
                  onCallFinished: (code, message, p2) {
                    controller.onSendCallInvitationFinished;
                    controller.onUserLogin();
                  },
                ),
              ],
            ),

            backgroundColor: Colors.white,

            //body
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();

                        //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                reverse: true,
                                itemCount: _list.length,
                                padding: EdgeInsets.only(top: mq.height * .01),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return MessageCard(message: _list[index]);
                                });
                          } else {
                            return const Center(
                              child: Text('Say Hii! 👋',
                                  style: TextStyle(fontSize: 20)),
                            );
                          }
                      }
                    },
                  ),
                ),

                chatInput(),

                //show emojis on keyboard emoji button click & vice versa
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // app bar widget
  Widget _appBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green,
            Colors.greenAccent
          ], // Your desired gradient colors
        ),
      ),
      child: InkWell(
          onTap: () {},
          child: StreamBuilder(
              stream: APIs.getUserInfo(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list =
                    data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                        [];
                Size mq = MediaQuery.of(context).size;

                return Row(
                  children: [
                    //back button
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.black54)),

                    //user profile picture
                    // ClipRRect(
                    //   borderRadius: BorderRadius.circular(mq.height * .03),
                    //   child: CachedNetworkImage(
                    //     width: mq.height * .05,
                    //     height: mq.height * .05,
                    //     imageUrl:
                    //         list.isNotEmpty ? list[0].image : widget.user.image,
                    //     errorWidget: (context, url, error) =>
                    //         const CircleAvatar(
                    //             child: Icon(CupertinoIcons.person)),
                    //   ),
                    // ),

                    //for adding some space
                    const SizedBox(width: 10),

                    //user name & last seen time
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //user name
                        Text(list.isNotEmpty ? list[0].name : widget.user.name,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.fade,
                            )),

                        //for adding some space
                        const SizedBox(height: 2),

                        //last seen time of user
                        Text(
                            list.isNotEmpty
                                ? list[0].isOnline
                                    ? 'Online'
                                    : MyDateUtil.getLastActiveTime(
                                        context: context,
                                        lastActive: list[0].lastActive)
                                : MyDateUtil.getLastActiveTime(
                                    context: context,
                                    lastActive: widget.user.lastActive),
                            style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                );
              })),
    );
  }

  Future<void> playSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource('audios/happy-pop.mp3'));
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
          IconButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                setState(() => _showEmoji = !_showEmoji);
              },
              icon: Icon(Icons.emoji_emotions, color: color, size: 25)),
          Expanded(
            child: TextField(
              controller: _textController,
              onTap: () {
                if (_showEmoji) setState(() => _showEmoji = !_showEmoji);
              },
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
                if (_textController.text.isNotEmpty) {
                  if (_list.isEmpty) {
                    //on first message (add user to my_user collection of chat user)
                    APIs.sendFirstMessage(
                        widget.user, _textController.text, Type.text);
                  } else {
                    //simply send message
                    APIs.sendMessage(
                        widget.user, _textController.text, Type.text);
                  }
                  _textController.text = '';
                }
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
                              onPressed: () async {
                                final ImagePicker picker = ImagePicker();
                                // Pick an image
                                final XFile? image = await picker.pickImage(
                                    source: ImageSource.camera,
                                    imageQuality: 70);
                                if (image != null) {
                                  log('Image Path: ${image.path}');
                                  setState(() => _isUploading = true);

                                  await APIs.sendChatImage(
                                      widget.user, File(image.path));
                                  setState(() => _isUploading = false);
                                }
                              },
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
                              onPressed: () async {
                                final ImagePicker picker = ImagePicker();
                                // Picking multiple images
                                final List<XFile> images = await picker
                                    .pickMultiImage(imageQuality: 70);
                                // uploading & sending image one by one
                                for (var i in images) {
                                  log('Image Path: ${i.path}');
                                  setState(() => _isUploading = true);
                                  await APIs.sendChatImage(
                                      widget.user, File(i.path));
                                  setState(() => _isUploading = false);
                                }
                              },
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
