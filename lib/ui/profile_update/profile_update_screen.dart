import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:byteai/constant/show_toast_dialog.dart';
import 'package:byteai/controller/profile_updation_controller.dart';
import 'package:byteai/theam/constant_colors.dart';
import 'package:byteai/theam/text_field_them.dart';
import 'package:byteai/utils/Preferences.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../controller/setting_controller.dart';
import '../../res/assets_res.dart';
import '../auth/login_screen.dart';

class ProfileUpdateScreen extends StatelessWidget {
  const ProfileUpdateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var settingsController = Get.put(SettingController());
    return GetX<ProfileUpdationController>(
        init: ProfileUpdationController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: ConstantColors.background,
            appBar: AppBar(
                title: Text('Profile'.tr),
                centerTitle: true,
                backgroundColor: Colors.black.withOpacity(0.3)),
            body: SingleChildScrollView(
              child: Form(
                key: controller.formKey.value,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Padding(
                  padding: EdgeInsets.all(8.sp),
                  child: Container(
                    decoration: BoxDecoration(
                        color: ConstantColors.background,
                        borderRadius: BorderRadius.circular(30)),
                    child: Padding(
                      padding: EdgeInsets.all(10.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Positioned(top: 0, bottom: 20.h, left: 0, right: 50.w,child: Image.asset(AssetsRes.PLACEHOLDER_COLOR)),
                              Image.asset(AssetsRes.PLACEHOLDER_COLOR),
                              Stack(
                                children: [
                                  BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 5.0,
                                      sigmaY: 5.0,
                                    ),
                                    child: Container(
                                      width: 100.w,
                                      height: 35.h,
                                      decoration: BoxDecoration(
                                        color: Color(0xff585B73).withOpacity(0.15),
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(60.sp), bottomRight: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(20)),
                                      ),
                                      child: Preferences.getBoolean(Preferences.isLogin)
                                          ? Padding(
                                        padding: EdgeInsets.only(top: 23.h, left: 6.w),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                controller.userModel.value.data!.name
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.white, fontSize: 15.sp)),
                                            Text(
                                                controller.userModel.value.data!.email
                                                    .toString(),
                                                style: TextStyle(
                                                    color: ConstantColors.hintTextColor,
                                                    fontSize: 16)),
                                          ],
                                        ),
                                      )
                                          : Padding(
                                        padding: EdgeInsets.only( top:20.h, bottom: 5.h, left: 2.w, right: 2.w),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            FocusScope.of(context).unfocus();
                                            Get.off(const LoginScreen(
                                              redirectType: "",
                                            ));
                                          },
                                          style: ElevatedButton.styleFrom(

                                              foregroundColor: Colors.white,
                                              backgroundColor: ConstantColors.primary,
                                              shape: const StadiumBorder()),
                                          child: Text('Login'.tr,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top :20.sp, left: settingsController.profileImage.isEmpty ? 100.sp : 10.sp, right: 10.sp),
                                    child: Row(
                                      children: [
                                        Stack(
                                          alignment: Alignment.bottomCenter,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(100),
                                              child: settingsController.profileImage.isEmpty
                                                  ? Image.asset(
                                                AssetsRes.PROFILE_PLACEHOLDER,
                                                height: 90,
                                                width: 90,
                                              )
                                                  : CachedNetworkImage(
                                                imageUrl:
                                                settingsController.profileImage.toString(),
                                                height: 90.sp,
                                                width: 90.sp,
                                                fit: BoxFit.cover,
                                                progressIndicatorBuilder:
                                                    (context, url, downloadProgress) =>
                                                    Center(
                                                      child: CircularProgressIndicator(
                                                          value: downloadProgress.progress),
                                                    ),
                                                errorWidget: (context, url, error) =>
                                                const Icon(Icons.error),
                                              ),
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            Preferences.clearSharPreference();
                                            Purchases.logOut();
                                            await FirebaseAuth.instance.signOut();
                                            Get.off(const LoginScreen(
                                              redirectType: "",
                                            ));
                                          },
                                          child: Preferences.getBoolean(Preferences.isLogin)
                                              ? Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                width: 10.w,
                                              ),
                                              Icon(Icons.logout_rounded, color: Colors.white),
                                              SizedBox(
                                                width: 2.w,
                                              ),
                                              Text("Logout".tr, style: TextStyle(
                                                  color: Colors.white
                                              ))
                                            ],
                                          ) : Container(),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Text(
                            'Full name'.tr,
                            style: const TextStyle(color: Colors.white),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            child: TextField(
                              onChanged: (value) {
                                controller.name.value = value;
                              },
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.3)),
                                  hintText: "Entrer votre nom",
                                  fillColor:
                                      Color(0xffFFFFFF).withOpacity(0.15),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                  )),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          SizedBox(
                            width: 100.w,
                            child: ElevatedButton(
                              onPressed: () async {
                                FocusScope.of(context).unfocus();
                                if (controller.formKey.value.currentState!
                                    .validate()) {
                                  Map<String, String> bodyParams = {
                                    'name': controller.name.value,
                                    'email': controller.email.value,
                                    'user_id': Preferences.getString(
                                        Preferences.userId),
                                  };
                                  await controller
                                      .updateProfile(bodyParams)
                                      .then((value) {
                                    if (value != null) {
                                      if (value == true) {
                                        controller.userModel.value.data!.name =
                                            controller.name.value;
                                        Preferences.setString(
                                            Preferences.user,
                                            jsonEncode(controller
                                                .userModel.value
                                                .toJson()));
                                        Get.back();
                                      } else {
                                        ShowToastDialog.showToast(
                                            "Something want wrong...".tr);
                                      }
                                    }
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: ConstantColors.primary,
                                  shape: const StadiumBorder()),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 12),
                                child: Text('Update Profile'.tr,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
