import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:byteai/constant/constant.dart';
import 'package:byteai/constant/show_toast_dialog.dart';
import 'package:byteai/controller/signup_controller.dart';
import 'package:byteai/theam/constant_colors.dart';
import 'package:byteai/theam/text_field_them.dart';
import 'package:byteai/ui/auth/otp_screen.dart';
import 'package:sizer/sizer.dart';

import '../../res/assets_res.dart';

class SignupScreen extends StatelessWidget {
  final String? redirectType;
  final String token;

  const SignupScreen(
      {Key? key, required this.token, required this.redirectType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignupController>(
        init: SignupController(),
        builder: (controller) {
          return InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              backgroundColor: ConstantColors.background,
              body: Sizer(builder: (context, orientation, deviceType) {
                return Form(
                  key: controller.formKey.value,
                  child: SingleChildScrollView(
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        SizedBox(
                          height: 20.h,
                        ),
                        Center(
                            child: Image.asset(
                          AssetsRes.LOGIN_LOGO_NEW_V2,
                          height: 15.h,
                        )),
                        SizedBox(height: 5.h),
                        Center(
                            child: Text('Create account'.tr,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Akshar',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600))),
                        SizedBox(
                          height: 5.h,
                        ),
                        // component 2 : TextField + Register Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFieldThem.boxBuildTextField(
                                hintText: 'Full Name'.tr,
                                controller:
                                    controller.fullNameController.value,
                                validators: (String? value) {
                                  if (value!.isNotEmpty) {
                                    return null;
                                  } else {
                                    return '*required'.tr;
                                  }
                                },
                              ),
                              SizedBox(
                                height: 4.h,
                              ),
                              TextFieldThem.boxBuildTextField(
                                hintText: 'Email'.tr,
                                controller:
                                    controller.emailController.value,
                                validators: (p0) =>
                                    Constant().validateEmail(p0),
                              ),
                              SizedBox(
                                height: 4.h,
                              ),
                              TextFieldThem.boxBuildTextField(
                                suffixData: IconButton(
                                  onPressed: () {
                                    controller.passwordVisible.value =
                                        !controller.passwordVisible.value;
                                    // ignore: invalid_use_of_protected_member
                                    controller.refresh();
                                  },
                                  icon: Icon(
                                    controller.passwordVisible.value
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                hintText: 'Password'.tr,
                                obscureText:
                                    controller.passwordVisible.value,
                                controller:
                                    controller.passwordController.value,
                                validators: (String? value) {
                                  if (value!.isNotEmpty) {
                                    return null;
                                  } else {
                                    return '*required'.tr;
                                  }
                                },
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              SizedBox(
                                width: 100.w,
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF060C18),
                                        blurRadius: 4,
                                        offset: Offset(4, 4),
                                        spreadRadius: 0,
                                      ),
                                      BoxShadow(
                                        color: Color(0x7F3A445D),
                                        blurRadius: 4,
                                        offset: Offset(-4, -4),
                                        spreadRadius: 0,
                                      )
                                    ],
                                  ),
                                  child: ElevatedButton(

                                    onPressed: () async {
                                      FocusScope.of(context).unfocus();
                                      if (controller
                                          .formKey.value.currentState!
                                          .validate()) {
                                        Map<String, String> bodyParams = {
                                          'email': controller
                                              .emailController.value.text,
                                        };

                                        await controller
                                            .sendOtp(bodyParams)
                                            .then((value) {
                                          if (value != null) {
                                            if (value == true) {
                                              Map<String, String>
                                                  redirectBodyParams = {
                                                'name': controller
                                                    .fullNameController
                                                    .value
                                                    .text,
                                                'email': controller
                                                    .emailController
                                                    .value
                                                    .text,
                                                'password': controller
                                                    .passwordController
                                                    .value
                                                    .text,
                                                'fcmtoken': token
                                              };
                                              Get.to(OTPScreen(
                                                bodyParams:
                                                    redirectBodyParams,
                                              ));
                                            } else {
                                              ShowToastDialog.showToast(
                                                  "Something want wrong".tr);
                                            }
                                          }
                                        });
                                      }
                                    },
                                    style: ButtonStyle(

                                      shape: MaterialStateProperty.all<
                                          OutlinedBorder>(
                                        RoundedRectangleBorder(

                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          // Adjust the border radius as desired
                                          // Set the border color and width
                                        ),
                                      ),
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Color(0xff060A33)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15.0, vertical: 12),
                                      child: Text('Register now'.tr,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 15, top: 40),
                    child: Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                );
              }),
            ),
          );
        });
  }
}
