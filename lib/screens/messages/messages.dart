import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:nomo_app/Services/Prefferences/prefferences.dart';
import 'package:nomo_app/controllers/messages-tab-controller.dart';
import 'package:nomo_app/res/assets/assets.dart';
import 'package:nomo_app/res/colors/appcolors.dart';
import 'package:nomo_app/res/components/search-field.dart';
import 'package:nomo_app/screens/constant/constant.dart';
import 'package:nomo_app/screens/messages/health-and-support-screen.dart';
import '../../chat/api/apis.dart';
import '../../chat/helper/dialogs.dart';
import '../../chat/models/chat_user.dart';
import '../../chat/screens/home_screen.dart';
import '../../chat/widgets/chat_user_card.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  bool _isSearching = false;
  final MessagesTabController messagesTabController =
      Get.put(MessagesTabController());
  // for storing all users
  List<ChatUser> _list = [];

  // for storing searched items
  final List<ChatUser> _searchList = [];

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    //for updating user active status according to lifecycle events
    //resume -- active or online
    //pause  -- inactive or offline

    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APIs.user.uid != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  String shortenText(String text) {
    // Set your desired maximum length for the text
    final maxLength = 5;

    // Check if the text exceeds the maximum length
    if (text.length > maxLength) {
      // Shorten the text and add an ellipsis
      return text.substring(0, maxLength) + '...';
    } else {
      // Return the original text if it's within the limit
      return text;
    }
  }

  final CollectionReference user =
      FirebaseFirestore.instance.collection('users');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarColor: Color(0xffD9D9D9)),
        title: _isSearching
            ? SearchFieldWidget(
                hintText: 'Search',
                filledColor: AppColors.white,
                onChanged: (val) {
                  //search logic
                  _searchList.clear();
                  for (var i in _list) {
                    if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                        i.email.toLowerCase().contains(val.toLowerCase())) {
                      _searchList.add(i);
                      setState(() {
                        _searchList;
                      });
                    }
                  }
                },
                suffixIcon: IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      Assets.voiceIcon,
                      color: AppColors.blackColor,
                    )),
                preffixIcon: IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      Assets.search,
                      color: AppColors.blackColor,
                    )))
            : const Text(
                'Messages',
                style: TextStyle(
                    fontSize: 16,
                    color: AppColors.white,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600),
              ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.gradientColor),
        ),
        automaticallyImplyLeading: false,
        leading: _isSearching
            ? null
            : IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: SvgPicture.asset(Assets.arrowBack)),
        actions: <Widget>[
          if (!_isSearching)
            IconButton(
              icon: SvgPicture.asset(Assets.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                });
              },
            ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            GetBuilder<MessagesTabController>(
              init: MessagesTabController(),
              builder: (controller) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 12),
                  // height: 50,
                  constraints: const BoxConstraints(maxHeight: double.infinity),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: const Color(0xffF8F8F8),
                      borderRadius: BorderRadius.circular(50)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < 2; i++)
                        Expanded(
                          child: InkWell(
                            onTap: () => controller.setCurrentIndex = i,
                            child: Column(
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  height: 51,
                                  decoration: BoxDecoration(
                                    color: controller.currentIndex.value == i
                                        ? AppColors.blackColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    i == 0
                                        ? 'Friends & Venues'
                                        : 'Help & Support',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            controller.currentIndex.value == i
                                                ? Colors.white
                                                : AppColors.blackColor,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Montserrat'),
                                  ),
                                ),
                                5.verticalSpace,
                                Container(
                                    height: 4,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: controller.currentIndex.value == i
                                          ? AppColors.green
                                          : Colors.transparent,
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.elliptical(40, 20),
                                          topRight: Radius.elliptical(40, 20)),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(width: 12),
                    ],
                  ),
                );
              },
            ),
            _tabBarViews(_isSearching, _searchList)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.greenAccent,
          onPressed: () {
            _addChatUserDialog();
          },
          child: const Icon(
            Icons.chat,
            color: Colors.white,
          )),
    );
  }

  void _addChatUserDialog() {
    String email = '';

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
                    Icons.person_add,
                    color: AppColors.green,
                    size: 28,
                  ),
                  Text(
                    '  Add User',
                    style: TextStyle(fontWeight: FontWeight.w400),
                  )
                ],
              ),

              //content
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Email Id',
                    prefixIcon: Icon(Icons.email, color: AppColors.green),
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
                    child: Text('Cancel',
                        style: TextStyle(color: color, fontSize: 16))),

                //add button
                MaterialButton(
                    onPressed: () async {
                      //hide alert dialog

                      await APIs.addChatUser(email).then((value) {
                        if (!value) {
                          Dialogs.showSnackbar(
                              context, 'User does not Exists!');
                        }
                      });
                    },
                    child: Text(
                      'Add',
                      style: TextStyle(color: color, fontSize: 16),
                    ))
              ],
            ));
  }

  Widget _tabBarViews(bool issearch, List<ChatUser> serchinglist) {
    return GetBuilder<MessagesTabController>(
        init: MessagesTabController(),
        builder: (controller) {
          return [
            Messages(isSearching: _isSearching, serchlist: serchinglist),
            const HealthAndSupportMessages()
          ][controller.currentIndex.value];
        });
  }
}

class Messages extends StatefulWidget {
  Messages({super.key, required this.serchlist, required this.isSearching});

  bool isSearching;
  List<ChatUser> serchlist;

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  List<ChatUser> _list = [];
  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;
    return Stack(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: StreamBuilder(
              stream: APIs.getMyUsersId(),
              //get id of only known users
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  //if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Center(
                        child: LottieBuilder.asset(
                      'assets/images/empty.json',
                      width: 20,
                    ));

                  //if some or all data is loaded then show it
                  case ConnectionState.active:
                  case ConnectionState.done:
                    return StreamBuilder(
                      stream: APIs.getAllUsers(
                          snapshot.data?.docs.map((e) => e.id).toList() ?? []),

                      //get only those user, who's ids are provided
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          //if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                          // return const Center(
                          //     child: CircularProgressIndicator());

                          //if some or all data is loaded then show it
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            _list = data
                                    ?.map((e) => ChatUser.fromJson(e.data()))
                                    .toList() ??
                                [];

                            if (_list.isNotEmpty) {
                              return Column(
                                children: [
                                  ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: widget.isSearching
                                          ? widget.serchlist.length
                                          : _list.length,
                                      padding:
                                          EdgeInsets.only(top: mq.height * .01),
                                      physics: const BouncingScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return ChatUserCard(
                                            user: widget.isSearching
                                                ? widget.serchlist[index]
                                                : _list[index]);
                                      }),
                                ],
                              );
                            } else {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 200,
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Plz add email of user\n & \nChat Get Started',
                                      style: TextStyle(fontSize: 20),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              );
                            }
                        }
                      },
                    );
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
