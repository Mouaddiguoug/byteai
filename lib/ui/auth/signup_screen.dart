import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:byteai/constant/constant.dart';
import 'package:byteai/constant/show_toast_dialog.dart';
import 'package:byteai/controller/signup_controller.dart';
import 'package:byteai/theam/constant_colors.dart';
import 'package:byteai/theam/text_field_them.dart';
import 'package:byteai/ui/auth/otp_screen.dart';
import 'package:sizer/sizer.dart';

class SignupScreen extends StatelessWidget {
  final String? redirectType;
  final String token;

  const SignupScreen({Key? key, required this.token, required this.redirectType}) : super(key: key);

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
                return Stack(
                    children: [
                      Form(
                        key: controller.formKey.value,
                        child: SingleChildScrollView(
                          child: Container(

                            child: Column(

                              // mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                 SizedBox(height: 100),
                                Center(child: Text('Create account'.tr,
                                    style: const TextStyle(color: Colors.white,
                                        fontFamily: 'Akshar',
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600))),
                                SizedBox(
                                  height: 50,
                                ),
                                // component 2 : TextField + Register Button
                                Container(
                                  height: 100.h,
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(30.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        Text(
                                          'Full Name'.tr,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5, bottom: 10),
                                            child: TextFieldThem
                                                .boxBuildTextField(
                                              hintText: ''.tr,
                                              controller: controller
                                                  .fullNameController.value,
                                              validators: (String? value) {
                                                if (value!.isNotEmpty) {
                                                  return null;
                                                } else {
                                                  return '*required'.tr;
                                                }
                                              },
                                            )),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Email'.tr,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5, bottom: 10),
                                            child: TextFieldThem
                                                .boxBuildTextField(
                                              hintText: ''.tr,
                                              controller: controller
                                                  .emailController.value,
                                              validators: (p0) =>
                                                  Constant().validateEmail(p0),
                                            )),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'password'.tr,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5, bottom: 10),
                                            child: TextFieldThem
                                                .boxBuildTextField(
                                              suffixData: IconButton(
                                                onPressed: () {
                                                  controller.passwordVisible
                                                      .value =
                                                  !controller.passwordVisible
                                                      .value;
                                                  // ignore: invalid_use_of_protected_member
                                                  controller.refresh();
                                                },
                                                icon: Icon(
                                                  controller.passwordVisible
                                                      .value
                                                      ? Icons
                                                      .visibility_outlined
                                                      : Icons.visibility_off,
                                                  size: 20,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              hintText: ''.tr,
                                              obscureText: controller
                                                  .passwordVisible.value,
                                              controller: controller
                                                  .passwordController.value,
                                              validators: (String? value) {
                                                if (value!.isNotEmpty) {
                                                  return null;
                                                } else {
                                                  return '*required'.tr;
                                                }
                                              },
                                            )),
                                         SizedBox(
                                          height: 8.h,
                                        ),
                                        Center(
                                          child: Container(
                                            decoration: BoxDecoration(

                                              borderRadius: BorderRadius
                                                  .circular(30),
                                              gradient: LinearGradient(
                                                begin: FractionalOffset
                                                    .centerLeft,
                                                end: FractionalOffset
                                                    .centerRight,
                                                colors: [
                                                  Color(0xFF601A81),
                                                  Color.fromRGBO(
                                                      14, 111, 117, 0.479167),
                                                  Color.fromRGBO(
                                                      49, 26, 189, 0),
                                                ],
                                              ),
                                            ),
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                FocusScope.of(context)
                                                    .unfocus();

                                                if (controller.formKey.value
                                                    .currentState!.validate()) {
                                                  Map<String,
                                                      String> bodyParams = {
                                                    'email': controller
                                                        .emailController.value
                                                        .text,
                                                  };

                                                  await controller.sendOtp(
                                                      bodyParams).then((value) {
                                                    if (value != null) {
                                                      if (value == true) {
                                                        Map<String,
                                                            String> redirectBodyParams = {
                                                          'name': controller
                                                              .fullNameController
                                                              .value.text,
                                                          'email': controller
                                                              .emailController
                                                              .value.text,
                                                          'password': controller
                                                              .passwordController
                                                              .value.text,
                                                          'fcmtoken': token
                                                        };
                                                        Get.to(OTPScreen(
                                                          bodyParams: redirectBodyParams,
                                                        ));
                                                      } else {
                                                        ShowToastDialog
                                                            .showToast(
                                                            "Something want wrong"
                                                                .tr);
                                                      }
                                                    }
                                                  });
                                                }
                                              },
                                              style: ButtonStyle(
                                                shape: MaterialStateProperty
                                                    .all<OutlinedBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius: BorderRadius
                                                        .circular(8.0),
                                                    // Adjust the border radius as desired
                                                    // Set the border color and width
                                                  ),
                                                ),
                                                foregroundColor: MaterialStateProperty
                                                    .all<Color>(
                                                    Colors.white),
                                                backgroundColor: MaterialStateProperty
                                                    .all<Color>(
                                                    Colors.transparent),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(horizontal: 15.0,
                                                    vertical: 12),
                                                child: Text('Register now'.tr,
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight
                                                            .w600)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),


                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(left: 15, top: 40),
                          child: Icon(Icons.arrow_back_ios,
                              color: Colors.white),
                        ),
                      ),
                    ]
                );
              }
              ),
            ),
          );
        });
  }
}
