import 'dart:developer';

import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../res/colors/appcolors.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../helper/my_date_util.dart';

import '../models/message.dart';
import '../screens/home_screen.dart';

// for showing single message details
class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
        onLongPress: () {
          _showBottomSheet(isMe);
        },
        child: isMe ? _greenMessage() : _blueMessage());
  }

  // sender or another user message
  Widget _blueMessage() {
    //update last read message if sender and receiver are different
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }
    Size mq = MediaQuery.of(context).size;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                gradient: AppColors.deafaultTextColor,
                border:
                    Border.all(color: AppColors.neutralGray.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(12)),
            child: widget.message.type == Type.text
                ?
                //show text
                Text(
                    widget.message.msg,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  )
                : widget.message.type == Type.image
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: CachedNetworkImage(
                          imageUrl: widget.message.msg,
                          placeholder: (context, url) => const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.image, size: 70),
                        ),
                      )
                    : widget.message.type == Type.video
                        ? VideoPlayerWidget(videoUrl: widget.message.msg)
                        : Container(
                            child: Text('data'),
                          ),
          ),
        ),
      ],
    );
  }

  // our or user message
  Widget _greenMessage() {
    Size mq = MediaQuery.of(context).size;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //message time
        Row(
          children: [
            //for adding some space
            SizedBox(width: mq.width * .04),

            //double tick blue icon for message read
            if (widget.message.read.isNotEmpty)
              Icon(Icons.done_all_rounded, color: AppColors.green00D, size: 20),

            //for adding some space
            const SizedBox(width: 2),

            //sent time
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),

        //message content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                gradient: AppColors.myMsgTextColor,
                border:
                    Border.all(color: AppColors.neutralGray.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                widget.message.type == Type.text
                    ? Text(
                        widget.message.msg,
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.blackColor,
                            fontWeight: FontWeight.bold),
                      )
                    : widget.message.type == Type.image
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              imageUrl: widget.message.msg,
                              placeholder: (context, url) => const Padding(
                                padding: EdgeInsets.all(8.0),
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.image, size: 70),
                            ),
                          )
                        : widget.message.type == Type.video
                            ? VideoPlayerWidget(videoUrl: widget.message.msg)
                            : Container(
                                child: Text('data'),
                              ),
              ],
            ), // Placeholder for other types or handle as needed
          ),
        ),
      ],
    );
  }

  // bottom sheet for modifying message details
  void _showBottomSheet(bool isMe) {
    Size mq = MediaQuery.of(context).size;

    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              //black divider
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),

              widget.message.type == Type.text
                  ?
                  //copy option
                  _OptionItem(
                      icon:
                          Icon(Icons.copy_all_rounded, color: color, size: 26),
                      name: 'Copy Text',
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          //for hiding bottom sheet
                          Navigator.pop(context);

                          Dialogs.showSnackbar(context, 'Text Copied!');
                        });
                      })
                  :
                  //save option
                  _OptionItem(
                      icon:
                          Icon(Icons.download_rounded, color: color, size: 26),
                      name: 'Save Image',
                      onTap: () async {
                        try {
                          log('Image Url: ${widget.message.msg}');

                          // await ImageGallerySaver.saveImage()
                          // await Image.saveImage(widget.message.msg,
                          //         albumName: 'We Chat')
                          //     .then((success) {
                          //   //for hiding bottom sheet
                          //   Navigator.pop(context);
                          //   if (success != null && success) {
                          //     Dialogs.showSnackbar(
                          //         context, 'Image Successfully Saved!');
                          //   }
                          // });
                        } catch (e) {
                          log('ErrorWhileSavingImg: $e');
                        }
                      }),

              //separator or divider
              if (isMe)
                Divider(
                  color: Colors.black54,
                  endIndent: mq.width * .04,
                  indent: mq.width * .04,
                ),

              //edit option
              if (widget.message.type == Type.text && isMe)
                _OptionItem(
                    icon: Icon(Icons.edit, color: color, size: 26),
                    name: 'Edit Message',
                    onTap: () {
                      //for hiding bottom sheet
                      Navigator.pop(context);

                      _showMessageUpdateDialog();
                    }),

              //delete option
              if (isMe)
                _OptionItem(
                    icon: const Icon(Icons.delete_forever,
                        color: Colors.red, size: 26),
                    name: 'Delete Message',
                    onTap: () {
                      //for hiding bottom sheet
                      Navigator.pop(context);
                      deletedialog();
                    }),

              //separator or divider
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),

              //sent time
              _OptionItem(
                  icon: Icon(Icons.remove_red_eye, color: color),
                  name:
                      'Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                  onTap: () {}),

              //read time
              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.green),
                  name: widget.message.read.isEmpty
                      ? 'Read At: Not seen yet'
                      : 'Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
                  onTap: () {}),
            ],
          );
        });
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  //dialog for updating message content
  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: Row(
                children: [
                  Icon(
                    Icons.message,
                    color: color,
                    size: 28,
                  ),
                  Text(' Update Message')
                ],
              ),

              //content
              content: TextFormField(
                initialValue: updatedMsg,
                maxLines: null,
                onChanged: (value) => updatedMsg = value,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: color, fontSize: 16),
                    )),

                //update button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                      APIs.updateMessage(widget.message, updatedMsg);
                      showToast('Message is Edit');
                    },
                    child: Text(
                      'Update',
                      style: TextStyle(color: color, fontSize: 16),
                    ))
              ],
            ));
  }

  void deletedialog() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              //actions
              title: Row(
                children: [
                  Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  Text('Delete')
                ],
              ),
              content: Text('delete message for everyone'),
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: color, fontSize: 16),
                    )),

                //update button
                MaterialButton(
                    onPressed: () async {
                      //hide alert dialog
                      Navigator.pop(context);
                      showToast('Message is Delete');
                      await APIs.deleteMessage(widget.message);
                    },
                    child: Text(
                      'Update',
                      style: TextStyle(color: color, fontSize: 16),
                    ))
              ],
            ));
  }
}

//custom options card (for copy, edit, delete, etc.)
class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;

    return InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.only(
              left: mq.width * .05,
              top: mq.height * .015,
              bottom: mq.height * .015),
          child: Row(children: [
            icon,
            Flexible(
                child: Text('    $name',
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        letterSpacing: 0.5)))
          ]),
        ));
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller
        .setLooping(true); // Set this to true if you want the video to loop
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_controller.value.isPlaying) {
          _controller.pause();
        } else {
          _controller.play();
        }
      },
      child: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}






// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:nomo_app/res/assets/assets.dart';
// import 'package:nomo_app/res/colors/appcolors.dart';
// import 'package:nomo_app/res/components/booking-widgets/booking-message-card.dart';
// import 'package:nomo_app/res/components/gradient-app-bar.dart';
// import 'package:nomo_app/res/components/messages/message-field.dart';

// enum BookingState {
//   confirmed,
//   rejected,
// }

// class ChatScreens extends StatefulWidget {
//   const ChatScreens({
//     super.key,
//   });

//   @override
//   State<ChatScreens> createState() => _ChatScreensState();
// }

// class _ChatScreensState extends State<ChatScreens> {
//   @override
//   Widget build(BuildContext context) {
//     BookingState _bookingState = BookingState.confirmed;
//     return Scaffold(
//       appBar: GradientAppBar(
//         title: 'Joe Doodle',
//         leading: IconButton(
//             onPressed: () {
//               Get.back();
//             },
//             icon: SvgPicture.asset(Assets.arrowBack)),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             flex: 4,
//             child: ListView(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
//               children: [
//                 const ChatBubble(
//                   text: "Nice to hear that 🙂",
//                   isSentByMe: false,
//                   time: "14:29",
//                 ),
//                 const ChatBubble(
//                   text: "Hi, can I get your best offers?",
//                   isSentByMe: true,
//                   time: "14:25",
//                 ),
//                 const ChatBubble(
//                   text:
//                       "👋 Hi Waldo! Thank you for reaching us out, let me walk you through our offers. Mind if I reaching you out via email?",
//                   isSentByMe: false,
//                   time: "14:32",
//                 ),
//                 const ChatBubble(
//                   text: "Nice to hear that 😊",
//                   isSentByMe: true,
//                   time: "14:36",
//                 ),
//                 const BookingMessageCard(
//                   isSentByMe: true,
//                 ),
//                 if (_bookingState == BookingState.confirmed ||
//                     _bookingState == BookingState.rejected)
//                   BookingAlertMessage(
//                     isSentByMe: false,
//                     text: _bookingState == BookingState.confirmed
//                         ? 'Booking Confirm'
//                         : 'Booking Reject',
//                     time: '14:36',
//                     asset: _bookingState == BookingState.confirmed
//                         ? Assets.confirm
//                         : Assets.reject,
//                   ),
//                 const CallEndedMessage(
//                   message: 'Voice Call Ended at 4:51 pm',
//                   asset: Assets.call,
//                 ),
//                 const CallEndedMessage(
//                   message: 'Video Call Ended at 4:51 pm',
//                   asset: Assets.videoCall,
//                 ),
//               ],
//             ),
//           ),
//           const SafeArea(child: MessageField()),
//         ],
//       ),
//     );
//   }
// }

// class BookingAlertMessage extends StatelessWidget {
//   final String text;
//   final bool isSentByMe;
//   final String time;
//   final String asset;
//   const BookingAlertMessage(
//       {required this.text,
//       required this.isSentByMe,
//       required this.time,
//       super.key,
//       required this.asset});

//   @override
//   Widget build(BuildContext context) {
//     final borderRadius = BorderRadius.circular(8.r);

//     Widget avatar = Stack(
//       children: <Widget>[
//         const CircleAvatar(
//           backgroundImage: AssetImage(Assets.follower3),
//           radius: 20,
//         ),
//         Positioned(
//           right: 0,
//           bottom: 0,
//           child: Container(
//             width: 14,
//             height: 14,
//             decoration: BoxDecoration(
//               color: AppColors.green,
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: Theme.of(context).scaffoldBackgroundColor,
//                 width: 2,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//     return Row(
//       mainAxisAlignment:
//           isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//       children: [
//         if (!isSentByMe) ...[avatar, const SizedBox(width: 8)],
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           margin: const EdgeInsets.symmetric(vertical: 10.0),
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.6,
//           ),
//           decoration: BoxDecoration(
//               gradient: isSentByMe
//                   ? AppColors.myMsgTextColor
//                   : AppColors.deafaultTextColor,
//               border: Border.all(
//                   color: isSentByMe
//                       ? Colors.transparent
//                       : AppColors.neutralGray.withOpacity(0.5)),
//               borderRadius: borderRadius),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     text,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.blackColor,
//                     ),
//                   ),
//                   const SizedBox(height: 5),
//                   isSentByMe
//                       ? Align(
//                           alignment: Alignment.bottomRight,
//                           child: Text(
//                             time,
//                             style: const TextStyle(
//                               color: AppColors.blackColor,
//                               fontSize: 12,
//                             ),
//                           ),
//                         )
//                       : Align(
//                           alignment: Alignment.bottomLeft,
//                           child: Text(
//                             time,
//                             style: TextStyle(
//                               color: isSentByMe
//                                   ? Colors.white70
//                                   : AppColors.blackColor,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                 ],
//               ),
//               Image.asset(
//                 asset,
//                 height: 30,
//               )
//             ],
//           ),
//         ),
//         if (isSentByMe) const SizedBox(width: 8),
//       ],
//     );
//   }
// }

// class ChatBubble extends StatelessWidget {
//   final String text;
//   final bool isSentByMe;
//   final String time;

//   const ChatBubble({
//     Key? key,
//     required this.text,
//     required this.isSentByMe,
//     required this.time,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final borderRadius = BorderRadius.circular(8.r);

//     Widget avatar = Stack(
//       children: <Widget>[
//         const CircleAvatar(
//           backgroundImage: AssetImage(Assets.follower3),
//           radius: 20,
//         ),
//         Positioned(
//           right: 0,
//           bottom: 0,
//           child: Container(
//             width: 14,
//             height: 14,
//             decoration: BoxDecoration(
//               color: AppColors.green,
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: Theme.of(context).scaffoldBackgroundColor,
//                 width: 2,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );

//     return Row(
//       mainAxisAlignment:
//           isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//       children: [
//         if (!isSentByMe) ...[avatar, const SizedBox(width: 8)],
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           margin: const EdgeInsets.symmetric(vertical: 10.0),
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.6,
//           ),
//           decoration: BoxDecoration(
//               gradient: isSentByMe
//                   ? AppColors.myMsgTextColor
//                   : AppColors.deafaultTextColor,
//               border: Border.all(
//                   color: isSentByMe
//                       ? Colors.transparent
//                       : AppColors.neutralGray.withOpacity(0.5)),
//               borderRadius: borderRadius),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 text,
//                 style: const TextStyle(
//                     color: AppColors.blackColor,
//                     fontSize: 12,
//                     fontFamily: 'Montserrat',
//                     fontWeight: FontWeight.w600),
//               ),
//               const SizedBox(height: 5),
//               Align(
//                 alignment:
//                     isSentByMe ? Alignment.bottomRight : Alignment.bottomLeft,
//                 child: Text(
//                   time,
//                   style: TextStyle(
//                       color: isSentByMe
//                           ? AppColors.blackColor
//                           : AppColors.neutralGray,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600),
//                 ),
//               )
//               // : Align(
//               //     alignment: Alignment.bottomLeft,
//               //     child: Text(
//               //       time,
//               //       style: TextStyle(
//               //           color: isSentByMe
//               //               ? AppColors.neutralGray
//               //               : AppColors.blackColor,
//               //           fontSize: 12,
//               //           fontWeight: FontWeight.w600),
//               //     ),
//               //   ),
//             ],
//           ),
//         ),
//         if (isSentByMe) const SizedBox(width: 8),
//       ],
//     );
//   }
// }

// class CallEndedMessage extends StatelessWidget {
//   final String message;
//   final String asset;

//   const CallEndedMessage({
//     super.key,
//     required this.message,
//     required this.asset,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
//         decoration: BoxDecoration(
//           color: Colors.transparent,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SvgPicture.asset(asset, color: AppColors.green),
//             SizedBox(width: 12.w),
//             Text(
//               message,
//               style: const TextStyle(
//                   color: Colors.black54,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
