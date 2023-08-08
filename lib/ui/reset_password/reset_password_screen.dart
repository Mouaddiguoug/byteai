import 'package:byteai/constant/show_toast_dialog.dart';
import 'package:byteai/controller/reset_password_controller.dart';
import 'package:byteai/res/assets_res.dart';
import 'package:byteai/theam/constant_colors.dart';
import 'package:byteai/theam/text_field_them.dart';
import 'package:byteai/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class ResetPasswordScreen extends StatelessWidget {
   ResetPasswordScreen({Key? key}) : super(key: key);
  final ResetPasswordController controller = ResetPasswordController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ResetPasswordController>(
      init: controller,
      builder: (_) {
        return Scaffold(

          backgroundColor: ConstantColors.background,
          body: SingleChildScrollView(
            child: Form(
              key: controller.formKey.value,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Container(
                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [

                      ],
                    ),
                    SizedBox(height:20),

                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/icons/arrow.svg'),
                            fit: BoxFit.cover,
                          ),

                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 14.0, 8.0, 8.0), // Add padding to the top
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SvgPicture.asset(
                              'assets/icons/arrow.svg',
                              semanticsLabel: 'Acme Logo',
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Logo - Image
                    Center(child: Image.asset(AssetsRes.GALAXY)),

                    // Sized Box to add space between the logo and the form
                    // form

                    SizedBox(
                      height: 800,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/bg.png'),
                              fit: BoxFit.cover,

                            ),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(100.0),
                              topLeft: Radius.zero,
                              bottomRight: Radius.circular(30.0),
                              bottomLeft: Radius.circular(30.0),
                            ),
                          ),

                          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 20),
                                // text changer le mot de passe
                                Center(
                                  child: Text(
                                    'Changer le mot de passe',
                                    style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Akshar', fontWeight: FontWeight.w400),

                                  ),
                                ),
                                SizedBox(height: 30),
                                Text(
                                  'New Password'.tr,
                                  style:  TextStyle(color: Colors.white, fontFamily: 'Roboto', fontWeight: FontWeight.w300, fontSize: 16, height: 1.5),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5, bottom: 10),
                                  child: TextFieldThem.boxBuildTextField(
                                    hintText: ''.tr,
                                    controller: controller.passwordController.value,
                                    obscureText: false,
                                    validators: (String? value) {
                                      if (value!.isNotEmpty) {
                                        return null;
                                      } else {
                                        return '*required'.tr;
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(height: 15),
                                Text(
                                  'Confirm new password'.tr,
                                  style:  TextStyle(color: Colors.white, fontFamily: 'Roboto', fontWeight: FontWeight.w300, fontSize: 16, height: 1.5),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5, bottom: 10),
                                  child: TextFieldThem.boxBuildTextField(
                                    hintText: ''.tr,
                                    controller: controller.conformPasswordController.value,
                                    obscureText: false,
                                    validators: (String? value) {
                                      if (value!.isNotEmpty) {
                                        return null;
                                      } else {
                                        return '*required'.tr;
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(height: 40),
                                // confirm Button
                                Container(
                                  child: Center(
                                    child: SizedBox(
                                      child: Container(
                                        width: 100.w,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          gradient: LinearGradient(
                                            begin: FractionalOffset.centerLeft,
                                            end: FractionalOffset.centerRight,
                                            colors: [
                                              Color(0xFF601A81),
                                              Color.fromRGBO(14, 111, 117, 0.479167),
                                              Color.fromRGBO(49, 26, 189, 0),
                                            ],
                                          ),
                                        ),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            if (controller.formKey.value.currentState!.validate()) {
                                              if (controller.passwordController.value.text ==
                                                  controller.conformPasswordController.value.text) {
                                                Map<String, String> bodyParams = {
                                                  'user_id': Preferences.getString(Preferences.userId),
                                                  'password': controller.passwordController.value.text,
                                                };
                                                await controller.resetPassword(bodyParams).then((value) {
                                                  if (value != null) {
                                                    if (value == true) {
                                                      Get.back(result: true);
                                                    } else {
                                                      ShowToastDialog.showToast('Something went wrong...'.tr);
                                                    }
                                                  }
                                                });
                                              } else {
                                                ShowToastDialog.showToast("Password doesn't match".tr);
                                              }
                                            }
                                          },
                                          // Button style
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            shadowColor: Colors.transparent,
                                            backgroundColor: Colors.transparent,
                                            minimumSize: Size(244, 50),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8), // Adjust the value as needed
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
                                            child: Text(
                                              'Login'.tr,
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
      },
    );
  }
}
