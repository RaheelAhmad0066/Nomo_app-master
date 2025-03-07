import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

import '../api/apis.dart';
import '../models/text_info.dart';
import '../screens/home_screen.dart';
import '../service/database_service.dart';

class EditImagePage extends StatefulWidget {
  const EditImagePage(
      {super.key,
      required this.imagePath,
      required this.groupId,
      required this.username});

  final String imagePath;
  final String groupId;
  final String username;

  @override
  State<EditImagePage> createState() => _EditImagePageState();
}

class DrawingArea {
  Offset point;
  Paint areaPaint;
  DrawingArea({
    required this.point,
    required this.areaPaint,
  });
}

class _EditImagePageState extends State<EditImagePage> {
  TextEditingController messageController = TextEditingController();
  TextEditingController textController = TextEditingController();

  ui.Image? backgroundImage;
  bool isImageloaded = false;
  bool isEditButtonClicked = false;
  bool isSending = false;

  List<DrawingArea?> points = [];
  Color selectedColor = Colors.black;
  Color textColor = Colors.red;
  double strokeWidth = 2.0;
  File? loadedImage;
  CroppedFile? croppedImage;
  String text = "";
  Offset offset = Offset.zero;
  List<TextInfo> texts = [];

  static GlobalKey ssKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    getImage();
  }

  getImage() {
    loadedImage = File(widget.imagePath);
    setState(() {
      isImageloaded = true;
    });
  }

  addNewText(BuildContext context) {
    setState(() {
      texts.add(TextInfo(
          text: textController.text,
          left: 0,
          top: 0,
          color: Colors.red,
          fontWeight: FontWeight.normal,
          fontStyle: FontStyle.normal,
          fontSize: 20,
          textAlign: TextAlign.center));

      Navigator.of(context).pop();
    });
  }

  Future takeScreenShort() async {
    RenderRepaintBoundary boundary =
        ssKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    ui.Image image = await boundary.toImage(pixelRatio: 3.0);

    ByteData? bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    Uint8List memoryImageData = bytes!.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();
    loadedImage = await File('${tempDir.path}/image.png').create();
    loadedImage!.writeAsBytesSync(memoryImageData);
  }

  void selectColour() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Pick a color!'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: selectedColor,
                onColorChanged: (color) {
                  setState(() {
                    selectedColor = color;
                  });
                },
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: color,
        actions: [
          IconButton(
              onPressed: () {
                _cropImage();
              },
              icon: Icon(Icons.crop)),
          IconButton(
              onPressed: () {
                textDialog(context);
              },
              icon: Text(
                "T",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
              )),
          IconButton(
              onPressed: () {
                setState(() {
                  isEditButtonClicked = !isEditButtonClicked;
                });
              },
              icon: Icon(Icons.edit)),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          (isEditButtonClicked)
              ? editLayout(context)
              : Container(
                  height: 150,
                ),

          Expanded(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: 60,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: (isImageloaded)
                        ? RepaintBoundary(
                            key: ssKey,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: color, width: 2)),
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: (croppedImage != null)
                                      ? Image.file(
                                          File(croppedImage!.path),
                                          fit: BoxFit.fill,
                                          width:
                                              MediaQuery.of(context).size.width,
                                        )
                                      : Image.file(
                                          File(loadedImage!.path),
                                          fit: BoxFit.cover,
                                          width:
                                              MediaQuery.of(context).size.width,
                                        ),
                                ),
                                Positioned(
                                  left: 0.0,
                                  right: 0.0,
                                  bottom: 0.0,
                                  top: 0.0,
                                  child: GestureDetector(
                                    onPanDown: (details) {
                                      setState(() {
                                        if (isEditButtonClicked) {
                                          points.add(
                                            DrawingArea(
                                              point: details.localPosition,
                                              areaPaint: Paint()
                                                ..color = selectedColor
                                                ..isAntiAlias = true
                                                ..strokeWidth = strokeWidth
                                                ..strokeCap = StrokeCap.round,
                                            ),
                                          );
                                        }
                                      });
                                    },
                                    onPanUpdate: (details) {
                                      setState(() {
                                        if (isEditButtonClicked) {
                                          points.add(
                                            DrawingArea(
                                              point: details.localPosition,
                                              areaPaint: Paint()
                                                ..color = selectedColor
                                                ..isAntiAlias = true
                                                ..strokeWidth = strokeWidth
                                                ..strokeCap = StrokeCap.round,
                                            ),
                                          );
                                        }
                                      });
                                    },
                                    onPanEnd: (details) {
                                      setState(() {
                                        if (isEditButtonClicked) {
                                          points.add(null);
                                        }
                                      });
                                    },
                                    child: ClipRRect(
                                      child: CustomPaint(
                                        painter: MyCustomPainter(points),
                                      ),
                                    ),
                                  ),
                                ),
                                for (int i = 0; i < texts.length; i++)
                                  _textWidget(context, texts[i]),
                                (isSending)
                                    ? Center(
                                        child: CircularProgressIndicator(
                                        color: Theme.of(context).primaryColor,
                                      ))
                                    : SizedBox.shrink(),
                              ],
                            ),
                          )
                        : Center(
                            child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          )),
                  ),
                ),
                Positioned(bottom: 10.0, child: _buildMessageComposer()),
              ],
            ),
          ),

          //SizedBox(height: 0)
        ],
      ),
    );
  }

  Widget _textWidget(BuildContext context, TextInfo textInfo) {
    return Positioned(
      left: textInfo.left,
      top: textInfo.top,
      child: GestureDetector(
        onLongPress: () {
          selectColour();
          textInfo.color = selectedColor;
        },
        onPanUpdate: ((details) {
          setState(() {
            textInfo.top = textInfo.top + details.delta.dy;
            textInfo.left = textInfo.left + details.delta.dx;
          });
        }),
        child: SizedBox(
          width: 150,
          height: 150,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Center(
              child: Text(textInfo.text,
                  textAlign: textInfo.textAlign,
                  style: TextStyle(
                      fontWeight: textInfo.fontWeight,
                      fontSize: textInfo.fontSize,
                      fontStyle: textInfo.fontStyle,
                      color: textInfo.color)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(40)),
        child: Row(children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: TextField(
              controller: messageController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration.collapsed(
                hintText: "Enter a caption",
                hintStyle: TextStyle(color: Colors.white),
              ),
            ),
          )),
          ButtonBar(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                ),
                onPressed: () {
                  sendMessage();
                  setState(() {
                    isSending = true;
                  });
                },
              ),
            ],
          )
        ]),
      ),
    );
  }

  textDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Enter Text"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: textController,
                  decoration: InputDecoration(
                      hintText: "Add your text here",
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffb9f85ff)),
                          borderRadius: BorderRadius.circular(20)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xffb9f85ff), width: 3),
                          borderRadius: BorderRadius.circular(20))),
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    addNewText(context);
                  },
                  child: Text("Add"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor),
                )
              ],
            ),
          );
        });
  }

  Widget editLayout(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 110),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30), color: Colors.white),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.color_lens),
              onPressed: () {
                selectColour();
              },
              color: selectedColor,
            ),
            Expanded(
                child: Slider(
              min: 1.0,
              max: 7.0,
              activeColor: selectedColor,
              value: strokeWidth,
              onChanged: (value) {
                setState(() {
                  strokeWidth = value;
                });
              },
            )),
            IconButton(
              icon: Icon(
                Icons.layers_clear,
                color: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  points.clear();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  _cropImage() async {
    await takeScreenShort();
    croppedImage = await ImageCropper().cropImage(
      sourcePath:
          (croppedImage == null) ? widget.imagePath : croppedImage!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );

    setState(() {});
  }

  sendMessage() async {
    await takeScreenShort();
    await DatabaseService(uid: APIs.user.uid)
        .sendImage(loadedImage!.path, widget.groupId)
        .then((value) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "imgUrl": value,
        "sender": widget.username,
        "time": DateTime.now().microsecondsSinceEpoch
      };

      DatabaseService(uid: APIs.user.uid)
          .sendMessage(widget.groupId, chatMessageMap);

      DatabaseService(uid: APIs.user.uid)
          .toggleRecentMessageSeen(widget.groupId);

      setState(() {
        messageController.clear();
        isSending = false;
      });

      Navigator.pop(context);
    });
  }
}

class MyCustomPainter extends CustomPainter {
  List<DrawingArea?> points;

  MyCustomPainter(
    this.points,
  );

  @override
  void paint(Canvas canvas, Size size) {
    //canvas.drawImage(myBackground, Offset.zero, Paint());

    Paint background = Paint()..color = Colors.transparent;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);

    for (var i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        Paint paint = points[i]!.areaPaint;
        canvas.drawLine(points[i]!.point, points[i + 1]!.point, paint);
      } else if (points[i] != null && points[i + 1] != null) {
        Paint paint = points[i]!.areaPaint;

        canvas.drawPoints(PointMode.points, [points[i]!.point], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
