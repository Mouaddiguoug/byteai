import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:byteai/constant/show_toast_dialog.dart';
import 'package:byteai/controller/profile_updation_controller.dart';
import 'package:byteai/theam/constant_colors.dart';
import 'package:byteai/theam/text_field_them.dart';
import 'package:byteai/utils/Preferences.dart';
import 'package:sizer/sizer.dart';

class ProfileUpdateScreen extends StatelessWidget {
  const ProfileUpdateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<ProfileUpdationController>(
        init: ProfileUpdationController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: ConstantColors.background,
            appBar: AppBar(title: Text('Profile'.tr), centerTitle: true),
            body: SingleChildScrollView(
              child: Form(
                key: controller.formKey.value,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.5.w),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 20.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xff42197b),
                                  Color(0xff396785),
                                ]
                            ),

                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.sp),
                        child: Container(
                          margin: EdgeInsets.only(top: 10.h),
                          decoration: BoxDecoration(
                              color: ConstantColors.background,
                              borderRadius: BorderRadius.circular(30)
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10.sp),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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

                                      style: TextStyle(
                                          color: Colors.white),
                                      decoration: InputDecoration(
                                          hintStyle: TextStyle(
                                              color: Colors.white.withOpacity(0.3)
                                          ),
                                          hintText: "Entrer votre nom",
                                        fillColor: Color(0xffFFFFFF).withOpacity(0.15),
                                        filled: true,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                          )
                                      ),
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
                                          'user_id':
                                              Preferences.getString(Preferences.userId),
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
                                                  jsonEncode(
                                                      controller.userModel.value.toJson()));
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
                                          style:
                                              const TextStyle(fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
