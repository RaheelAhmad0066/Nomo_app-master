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
import 'dart:io';
import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

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





// class ChatScreen extends StatefulWidget {
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   VoiceRecorder _voiceRecorder = VoiceRecorder();
//   VoicePlayer _voicePlayer = VoicePlayer();
//   TextEditingController _textEditingController = TextEditingController();
//   List<String> _messages = []; // List of messages
//   bool _isRecording = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 return _buildChatMessage(_messages[index]);
//               },
//             ),
//           ),
//           _buildChatInput(),
//         ],
//       ),
//     );
//   }

//   Widget _buildChatInput() {
//     return Container(
//       padding: EdgeInsets.all(8.0),
//       child: Row(
//         children: [
//           IconButton(
//             icon: Icon(Icons.mic),
//             onPressed: _toggleRecording,
//           ),
//           Expanded(
//             child: TextField(
//               controller: _textEditingController,
//               decoration: InputDecoration(
//                 hintText: 'Type a message...',
//               ),
//               onSubmitted: _sendMessage,
//             ),
//           ),
//           IconButton(
//             icon: Icon(Icons.send),
//             onPressed: _sendMessage,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildChatMessage(String message) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
//       padding: EdgeInsets.all(10.0),
//       decoration: BoxDecoration(
//         color: Colors.grey[300],
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       child: Row(
//         children: [
//           message.startsWith('voice_')
//               ? IconButton(
//                   icon: Icon(Icons.play_arrow),
//                   onPressed: () {
//                     _playVoiceMessage(message);
//                   },
//                 )
//               : SizedBox(),
//           SizedBox(width: 10.0),
//           Expanded(
//             child: message.startsWith('voice_')
//                 ? Text('Voice message')
//                 : Text(message),
//           ),
//         ],
//       ),
//     );
//   }

//   void _toggleRecording() {
//     setState(() {
//       _isRecording = !_isRecording;
//     });
//     if (_isRecording) {
//       _startRecording();
//     } else {
//       _stopRecording();
//     }
//   }

//   void _startRecording() async {
//     try {
//       Directory tempDir = await getTemporaryDirectory();
//       String filePath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';
//       await _voiceRecorder.startRecording(filePath);
//     } catch (e) {
//       print('Error starting recording: $e');
//     }
//   }

//   void _stopRecording() async {
//     try {
//       String path = await _voiceRecorder.stopRecording();
//       _sendMessage(path);
//     } catch (e) {
//       print('Error stopping recording: $e');
//     }
//   }

//   void _sendMessage([String message]) {
//     String text = message ?? _textEditingController.text.trim();
//     if (text.isNotEmpty) {
//       setState(() {
//         _messages.add(text);
//       });
//       _textEditingController.clear();
//     }
//   }

//   void _playVoiceMessage(String path) async {
//     try {
//       await _voicePlayer.play(path);
//     } catch (e) {
//       print('Error playing voice message: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _textEditingController.dispose();
//     super.dispose();
//   }
// }

// class VoiceRecorder {
//   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

//   Future<void> startRecording(String path) async {
//     await _recorder.openAudioSession();
//     await _recorder.startRecorder(toFile: path, codec: Codec.aacMP4);
//   }

//   Future<String> stopRecording() async {
//     await _recorder.stopRecorder();
//     await _recorder.closeAudioSession();
//     return _recorder.audioPath;
//   }
// }

// class VoicePlayer {
//   final FlutterSoundPlayer _player = FlutterSoundPlayer();

//   Future<void> play(String url) async {
//     await _player.openAudioSession();
//     await _player.startPlayer(fromURI: url);
//   }
// }
