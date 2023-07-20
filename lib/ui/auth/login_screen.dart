import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:byteai/constant/constant.dart';
import 'package:byteai/constant/show_toast_dialog.dart';
import 'package:byteai/controller/login_controller.dart';
import 'package:byteai/service/api_services.dart';
import 'package:byteai/theam/button_them.dart';
import 'package:byteai/theam/constant_colors.dart';
import 'package:byteai/theam/text_field_them.dart';
import 'package:byteai/ui/auth/signup_screen.dart';
import 'package:byteai/ui/dashboard.dart';
import 'package:byteai/ui/forgot_password/forgot_password_screen.dart';
import 'package:byteai/ui/subscription/subscription_screen.dart';
import 'package:byteai/utils/Preferences.dart';
import 'package:sizer/sizer.dart';

class LoginScreen extends StatelessWidget {
  final String redirectType;

  const LoginScreen({Key? key, required this.redirectType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(
        init: LoginController(),
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

                    Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 2.h, vertical: 8.h),
                      child: Form(
                        key: controller.formKey.value,
                        child: Container(


                          child: SingleChildScrollView(
                            child: Column(

                              // mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(child: Image.asset('assets/images/login_logo_new_v2.png')),

                                Container(
                                  child: Column( children : [
                                  Center(child: Text('Sign in', style: TextStyle(color: Colors.white, fontSize: 15.sp),)),
                                  SizedBox(
                                    height: 4.h,
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(top: 1.h),
                                      child: TextFieldThem.boxBuildTextField(
                                        hintText: 'Email'.tr,
                                        controller:
                                        controller.emailController.value,
                                        validators: (p0) =>
                                            Constant().validateEmail(p0),
                                      )),
                                  SizedBox(
                                    height: 5.h,
                                  ),
                                  Padding(
                                      padding:
                                      EdgeInsets.only(top: 1.h, bottom: 2.h),
                                      child: TextFieldThem.boxBuildTextField(
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
                                        hintText: 'password'.tr,
                                        controller:
                                        controller.passwordController.value,
                                        obscureText:
                                        controller.passwordVisible.value,
                                        validators: (String? value) {
                                          if (value!.isNotEmpty) {
                                            return null;
                                          } else {
                                            return '*required'.tr;
                                          }
                                        },
                                      )),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Get.to(const ForgotPasswordScreen());
                                        },
                                        child: Text(
                                          'Forgot Password?'.tr,
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5.h,
                                  ),
                                  // vanilla Login Button
                                  Container( child :
                                  ButtonThem.buildBorderButton(
                                    context,
                                    title: 'Login'.tr,
                                    btnColor: Colors.transparent,
                                    txtColor: Colors.white,
                                    iconVisibility: false,
                                    onPress: () async {
                                      FocusScope.of(context).unfocus();
                                      if (controller.formKey.value.currentState!
                                          .validate()) {
                                        Map<String, String> bodyParams = {
                                          'email':
                                          controller.emailController.value.text,
                                          'password': controller
                                              .passwordController.value.text,
                                          'fcmtoken':
                                          controller.notificationToken.value
                                        };
                                        await controller
                                            .loginAPI(bodyParams)
                                            .then((value) {
                                          if (value != null) {
                                            if (value.success == "Success") {
                                              Preferences.setBoolean(
                                                  Preferences.isFinishOnBoardingKey,
                                                  true);
                                              Preferences.setString(
                                                  Preferences.user,
                                                  jsonEncode(value));
                                              Preferences.setString(
                                                  Preferences.accessToken,
                                                  value.data!.accesstoken
                                                      .toString());
                                              Preferences.setString(
                                                  Preferences.customerId,
                                                  value.data!.customerId
                                                      .toString());
                                              Preferences.setString(
                                                  Preferences.userId,
                                                  value.data!.id.toString());
                                              Preferences.setBoolean(
                                                  Preferences.isLogin, true);
                                              ApiServices.header['accesstoken'] =
                                                  value.data!.accesstoken
                                                      .toString();

                                              if (redirectType == "subscription") {
                                                Get.off(const SubscriptionScreen());
                                              } else {
                                                Get.offAll(const DashBoard());
                                              }
                                            } else {
                                              ShowToastDialog.showToast(
                                                  value.error);
                                            }
                                          }
                                        });
                                      }
                                    },
                                    btnBorderColor: ConstantColors.primary,

                                  ),

                                  ),

                                  // space between the two login buttons
                                  SizedBox(
                                    height: 5.h,
                                  ),
                                  // Google Login Button
                                  Visibility(
                                    visible: Platform.isAndroid,
                                    child: ButtonThem.buildBorderButton(
                                      context,
                                      title: "Login with google",
                                      btnColor: Colors.transparent,
                                      txtColor: Colors.white,
                                      iconVisibility: true,
                                      iconAssetImage: 'assets/icons/ic_google.png',
                                      onPress: () async {
                                        ShowToastDialog.showLoader("Please wait");
                                        await controller
                                            .signInWithGoogle()
                                            .then((value) async {
                                          ShowToastDialog.closeLoader();
                                          if (value != null) {
                                            Map<String, String> bodyParams = {
                                              'name': value.user!.displayName
                                                  .toString(),
                                              'email': value.user!.email.toString(),
                                              'photo':
                                              value.user!.photoURL.toString(),
                                              'fcmtoken':
                                              controller.notificationToken.value
                                            };
                                            await controller
                                                .socialLoginAPI(bodyParams)
                                                .then((value) {
                                              if (value != null) {
                                                if (value.success == "Success") {
                                                  Preferences.setBoolean(
                                                      Preferences
                                                          .isFinishOnBoardingKey,
                                                      true);
                                                  Preferences.setString(
                                                      Preferences.user,
                                                      jsonEncode(value));
                                                  Preferences.setString(
                                                      Preferences.accessToken,
                                                      value.data!.accesstoken
                                                          .toString());
                                                  Preferences.setString(
                                                      Preferences.customerId,
                                                      value.data!.customerId
                                                          .toString());
                                                  Preferences.setString(
                                                      Preferences.userId,
                                                      value.data!.id.toString());
                                                  Preferences.setBoolean(
                                                      Preferences.isLogin, true);
                                                  ApiServices
                                                      .header['accesstoken'] =
                                                      value.data!.accesstoken
                                                          .toString();

                                                  if (redirectType ==
                                                      "subscription") {
                                                    Get.off(
                                                        const SubscriptionScreen());
                                                  } else {
                                                    Get.offAll(const DashBoard());
                                                  }
                                                } else {
                                                  ShowToastDialog.showToast(
                                                      value.error);
                                                }
                                              }
                                            });
                                          }
                                        });
                                      },
                                      btnBorderColor: Colors.white,
                                    ),

                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                    Visibility(
                                        visible: Platform.isIOS,
                                        child: ButtonThem.buildBorderButton(
                                          context,
                                          title: "Login with apple",
                                          btnColor: Colors.black,
                                          txtColor: Colors.white,
                                          iconVisibility: true,
                                          iconAssetImage: 'assets/icons/ic_apple.png',
                                          onPress: () async {
                                            ShowToastDialog.showLoader("Please wait");
                                            await controller
                                                .signInWithApple()
                                                .then((value) async {
                                              ShowToastDialog.closeLoader();
                                              // ignore: unnecessary_null_comparison
                                              if (value != null) {
                                                Map<String, String> bodyParams = {
                                                  'name': value.user!.displayName
                                                      .toString(),
                                                  'email':
                                                  value.user!.email.toString(),
                                                  'photo':
                                                  value.user!.photoURL.toString(),
                                                  'fcmtoken': controller
                                                      .notificationToken.value
                                                };
                                                await controller
                                                    .socialLoginAPI(bodyParams)
                                                    .then((value) {
                                                  if (value != null) {
                                                    if (value.success == "Success") {
                                                      Preferences.setBoolean(
                                                          Preferences
                                                              .isFinishOnBoardingKey,
                                                          true);
                                                      Preferences.setString(
                                                          Preferences.user,
                                                          jsonEncode(value));
                                                      Preferences.setString(
                                                          Preferences.accessToken,
                                                          value.data!.accesstoken
                                                              .toString());
                                                      Preferences.setString(
                                                          Preferences.customerId,
                                                          value.data!.customerId
                                                              .toString());
                                                      Preferences.setString(
                                                          Preferences.userId,
                                                          value.data!.id.toString());
                                                      Preferences.setBoolean(
                                                          Preferences.isLogin, true);
                                                      ApiServices
                                                          .header['accesstoken'] =
                                                          value.data!.accesstoken
                                                              .toString();

                                                      if (redirectType ==
                                                          "subscription") {
                                                        Get.off(
                                                            const SubscriptionScreen());
                                                      } else {
                                                        Get.offAll(const DashBoard());
                                                      }
                                                    } else {
                                                      ShowToastDialog.showToast(
                                                          value.error);
                                                    }
                                                  }
                                                });
                                              }
                                            });
                                          },
                                          btnBorderColor: Colors.white,
                                        ))
                                ]
                                ),

                                ),
                                // space  between the sign in text and the text Field "Email"









                              ],
                            ),
                          ),
                        ),
                      ),

                    ),

                    //Style for skip button

                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.only(top: 10.h, right: 1.h),
                        child: Container(
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
                              FocusScope.of(context).unfocus();

                              await Constant().getDeviceId().then((value) async {
                                log("------>$value");
                                Map<String, String> bodyParams = {
                                  'device_id': value.toString(),
                                  'fcmtoken': controller.notificationToken.value
                                };
                                await controller
                                    .guestAPI(bodyParams)
                                    .then((value) {
                                  Preferences.setBoolean(
                                      Preferences.isFinishOnBoardingKey, true);
                                  Preferences.setString(
                                      Preferences.gustUser, jsonEncode(value));
                                  Preferences.setString(Preferences.deviceId,
                                      value!.data!.deviceId.toString());
                                  Preferences.setBoolean(
                                      Preferences.isLogin, false);
                                  Get.off(const DashBoard());
                                });
                              });
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<OutlinedBorder>(

                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0), // Adjust the border radius as desired
                                  side: BorderSide(color: Colors.purple, width: 2.0), // Set the border color and width
                                ),

                              ),
                              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  // layout of the buttons
                                  horizontal: 8.0, vertical: 10),
                              child: Text('Skip'.tr,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              bottomNavigationBar: Padding(
                padding: EdgeInsets.all(2.w),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "${"Don't have an account?".tr} ",
                    style: const TextStyle(color: Colors.white),
                    children: <TextSpan>[
                      TextSpan(
                        text: " ${'Register now!'.tr}",
                        style: TextStyle(color: Color(0xFF0F20B6)),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () =>
                              Get.to(SignupScreen(
                                redirectType: redirectType,
                                token: controller.notificationToken.toString(),
                              )),
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
