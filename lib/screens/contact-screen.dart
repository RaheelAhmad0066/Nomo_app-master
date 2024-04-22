import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nomo_app/controllers/dropdown-controller.dart';
import 'package:nomo_app/res/assets/assets.dart';
import 'package:nomo_app/res/colors/appcolors.dart';
import 'package:nomo_app/res/components/ProfileWidgets/buttons/send-button.dart';
import 'package:nomo_app/res/components/contact-fields.dart';
import 'package:nomo_app/res/components/dialogs/dialogs.dart';
import 'package:nomo_app/res/components/gradient-app-bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/Prefferences/prefferences.dart';
import '../chat/api/apis.dart';
import '../chat/service/database_service.dart';
import '../chat/widgets/widgets.dart';
import 'constant/constant.dart';

class ContactUsScreen extends StatefulWidget {
  String username;
  String groupname;
  bool isloading;
  ContactUsScreen(
      {super.key,
      required this.isloading,
      required this.groupname,
      required this.username});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

String messageToken = '';

class _ContactUsScreenState extends State<ContactUsScreen> {
  final DropdownController dropdownController = Get.put(DropdownController());
  final TextEditingController nameController = TextEditingController();
  final TextEditingController msgController = TextEditingController();
  final TextEditingController token = TextEditingController();
  @override
  void initState() {
    getdata();
    super.initState();
  }

  List<String> genderOptions = ['Male', 'Female', 'Other'];
  List<String> prefereceOptions = ['Option 1', 'Option 2', 'Option 2'];

  saveddata() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    _pref.setString('messagetoken', token.text);
  }

  getdata() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    setState(() {
      messageToken = _pref.getString('messagetoken') ?? '';
    });
    return messageToken;
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: GradientAppBar(
        title: 'Contact Us',
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: SvgPicture.asset(Assets.arrowBack)),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              8.verticalSpace,
              ContactFielsdWidget(
                controller: token,
                hintText: '',
                label: 'Ticket',
                keyboardType: TextInputType.number,
              ),
              8.verticalSpace,
              ContactFielsdWidget(
                controller: nameController,
                hintText: '',
                label: 'Full Name',
                onChanged: (value) {
                  setState(() {
                    widget.groupname = value;
                  });
                },
              ),
              20.verticalSpace,
              ContactFielsdWidget(
                maxLines: 8,
                controller: msgController,
                hintText: '',
                label: 'Message',
              ),
              2.verticalSpace,
              Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Max 250 words',
                    style:
                        TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w600),
                  )),
              20.verticalSpace,
              fileAttachmentWidget(),
              70.verticalSpace,
              Align(
                alignment: Alignment.center,
                child: SendButton(
                    gradient: AppColors.gradientColor,
                    label: 'Send Message',
                    onPressed: () {
                      if (widget.groupname != "") {
                        setState(() {
                          widget.isloading = true;
                        });
                        saveddata();
                        DatabaseService(uid: APIs.user.uid)
                            .createGroup(widget.username, APIs.user.uid,
                                widget.groupname)
                            .whenComplete(() => widget.isloading = false);
                        Navigator.of(context).pop();
                        showSnackbar(context, Colors.green,
                            "Group created successfully");
                      }
                      showDialog(
                          context: context,
                          builder: (_) {
                            return ticketDialog();
                          });
                    },
                    width: 280.w),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget fileAttachmentWidget() {
    return Column(
      children: [
        InkWell(
          onTap: () {},
          splashColor: Colors.grey.shade100,
          child: Ink(
            height: 60,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xffF1F0F0),
              borderRadius: BorderRadius.circular(5.r),
              border: Border.all(color: const Color(0xffF1F0F0), width: 0.5),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  Assets.upload,
                  height: 50,
                  width: 50,
                ),
                5.horizontalSpace,
                const Text(
                  'Add Attachment',
                  style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
