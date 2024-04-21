import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nomo_app/res/assets/assets.dart';
import 'package:nomo_app/res/colors/appcolors.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../chat/api/apis.dart';
import '../../chat/screens/home_screen.dart';
import '../../chat/service/database_service.dart';
import '../../chat/widgets/group_tile.dart';
import '../../chat/widgets/widgets.dart';
import '../contact-screen.dart';

class HealthAndSupportMessages extends StatefulWidget {
  const HealthAndSupportMessages({super.key});

  @override
  State<HealthAndSupportMessages> createState() =>
      _HealthAndSupportMessagesState();
}

class _HealthAndSupportMessagesState extends State<HealthAndSupportMessages> {
  String username = APIs.user.displayName.toString();
  String email = APIs.user.email.toString();
  String userDp = APIs.user.photoURL.toString();
  Stream<QuerySnapshot>? groups;
  bool _isLoading = false;
  String groupName = "";
  DocumentSnapshot? groupData;
  List<String> groupIds = List.empty(growable: true);

  // string manipulation
  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gettingUserData();
  }

  gettingUserData() async {
    await DatabaseService(uid: "${APIs.user.uid}_$username")
        .getUserGroupsv1()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: StreamBuilder(
                  stream: groups,
                  builder: (context, AsyncSnapshot snapshot) {
                    //make checks
                    if (snapshot.hasData) {
                      if (snapshot.data.docs.length != 0) {
                        return ListView.builder(
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              var reverseIndex =
                                  snapshot.data.docs.length - index - 1;

                              return GroupTile(
                                groupId: snapshot.data.docs[reverseIndex]
                                    ["groupId"],
                                groupName: snapshot.data.docs[reverseIndex]
                                    ["groupName"],
                                userName: username,
                                groupIcon: snapshot.data.docs[reverseIndex]
                                    ["groupIcon"],
                                recentMessage: snapshot.data.docs[reverseIndex]
                                    ["recentMessage"],
                                recentMessageSender: snapshot.data
                                    .docs[reverseIndex]["recentMessageSender"],
                                recentMessageTime: snapshot.data
                                    .docs[reverseIndex]["recentMessageTime"],
                                isRecentMessageSeen: (snapshot
                                        .data
                                        .docs[reverseIndex]
                                            ["recentMessageSeenBy"]
                                        .contains(APIs.user.uid))
                                    ? true
                                    : false,
                              );
                            });
                      } else {
                        return noGroupWidget();
                      }
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor),
                      );
                    }
                  }),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.3),
              child: _createTicketButton(
                  label: 'Create New Ticket',
                  onPressed: () {
                    Get.to(ContactUsScreen(
                      groupname: groupName,
                      username: username,
                      isloading: _isLoading,
                    ));
                  },
                  width: double.infinity),
            )
          ],
        ),
      ),
    );
  }

  Widget _createTicketButton(
      {required final String label,
      var width = 100,
      required VoidCallback onPressed}) {
    return Container(
      height: 45,
      width: width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          gradient: AppColors.gradientColor),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.white),
            10.horizontalSpace,
            Text(
              label,
              style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat'),
            ),
          ],
        ),
      ),
    );
  }

  popUpDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Create a group"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _isLoading == true
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : TextField(
                        onChanged: (value) {
                          setState(() {
                            groupName = value;
                          });
                        },
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.email,
                              color: color,
                            ),
                            hintText: 'Email Id',
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                                borderRadius: BorderRadius.circular(20)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                                borderRadius: BorderRadius.circular(20)),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                                borderRadius: BorderRadius.circular(20))),
                      ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (groupName != "") {
                    setState(() {
                      _isLoading = true;
                    });

                    DatabaseService(uid: APIs.user.uid)
                        .createGroup(username, APIs.user.uid, groupName)
                        .whenComplete(() => _isLoading = false);
                    Navigator.of(context).pop();
                    showSnackbar(
                        context, Colors.green, "Group created successfully");
                  }
                },
                child: Text("Create"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor),
              )
            ],
          );
        });
  }

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              popUpDialog(context);
            },
            child: Image.asset(
              'images/chat.png',
              width: 100,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "You've not joined any chatsupport help, tap on the add icon to create a group or also search from top search button.",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}

class HealthAndSupportMessageTile extends StatelessWidget {
  final String title;
  final String message;
  final String date;
  final bool isActive;
  final VoidCallback onTap;

  const HealthAndSupportMessageTile({
    super.key,
    required this.title,
    required this.message,
    required this.date,
    this.isActive = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.fromLTRB(16, 0, 0, 10),
        height: 106,
        decoration: BoxDecoration(
          color: !isActive ? Colors.white : const Color(0xffF8F9FA),
          border: Border.all(
              color: !isActive ? Colors.transparent : const Color(0xffDDE2E5)),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            !isActive
                ? BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  )
                : const BoxShadow(
                    color: Colors.transparent,
                  ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage(Assets.appLogo),
                        ),
                        10.horizontalSpace,
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                                10.horizontalSpace,
                                !isActive
                                    ? Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        height: 20,
                                        width: 80,
                                        decoration: BoxDecoration(
                                            color: const Color(0xffDEFFDD),
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        child: const Text('Active',
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600)),
                                      )
                                    : Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        height: 20,
                                        width: 80,
                                        decoration: BoxDecoration(
                                            color: AppColors.neutralGray
                                                .withOpacity(0.29),
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        child: const Text('Closed',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: AppColors.white,
                                                fontWeight: FontWeight.w600)),
                                      )
                              ],
                            ),
                            5.verticalSpace,
                            Text(message,
                                style: const TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w600)),
                          ],
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20, bottom: 10),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          date,
                          style: TextStyle(
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff878F96)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!isActive)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  height: 25,
                  width: 25,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: const Text(
                    '2',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
