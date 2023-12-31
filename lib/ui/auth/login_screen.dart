import 'dart:convert';
import 'dart:developer';
import 'dart:ffi' as io;
import 'dart:io';

import 'package:byteai/res/assets_res.dart';
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
                    Image.asset(AssetsRes.COLOR_SHARP),
                    Form(
                      key: controller.formKey.value,
                      child: Container(
                        child: SingleChildScrollView(
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20.h),

                              Center(
                                  child: Image.asset(
                                AssetsRes.LOGIN_LOGO_NEW_V2,
                                height: 15.h,
                              )),
                              // Component : Email + mot de passe + connexion button + login with google
                              Padding(
                                padding: const EdgeInsets.all(35.0),
                                child: Column(children: [
                                  Center(
                                      child: Text(
                                    "Connexion".tr,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15.sp),
                                  )),
                                  SizedBox(
                                    height: 3.h,
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
                                    height: 3.h,
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          top: 1.h, bottom: 0.4.h),
                                      child: TextFieldThem.boxBuildTextField(
                                        suffixData: IconButton(
                                          onPressed: () {
                                            controller.passwordVisible.value =
                                                !controller
                                                    .passwordVisible.value;
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
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 3.h,
                                  ),

                                  // vanilla Login Connexion Button

                                  Container(
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
                                    child: ClipRRect(
                                      child: Column(
                                        children: [
                                          ButtonThem.buildBorderButton(
                                            context,
                                            title: 'Login'.tr,
                                            btnColor: Color(0xff060A33),

                                            txtColor: Colors.white,
                                            iconVisibility: false,
                                            onPress: () async {
                                              FocusScope.of(context).unfocus();
                                              if (controller
                                                  .formKey.value.currentState!
                                                  .validate()) {
                                                Map<String, String> bodyParams =
                                                    {
                                                  'email': controller
                                                      .emailController
                                                      .value
                                                      .text,
                                                  'password': controller
                                                      .passwordController
                                                      .value
                                                      .text,
                                                  'fcmtoken': controller
                                                      .notificationToken.value
                                                };
                                                await controller
                                                    .loginAPI(bodyParams)
                                                    .then((value) {
                                                  if (value != null) {
                                                    if (value.success ==
                                                        "Success") {
                                                      Preferences.setBoolean(
                                                          Preferences
                                                              .isFinishOnBoardingKey,
                                                          true);
                                                      Preferences.setString(
                                                          Preferences.user,
                                                          jsonEncode(value));
                                                      Preferences.setString(
                                                          Preferences
                                                              .accessToken,
                                                          value
                                                              .data!.accesstoken
                                                              .toString());
                                                      Preferences.setString(
                                                          Preferences
                                                              .customerId,
                                                          value.data!.customerId
                                                              .toString());
                                                      Preferences.setString(
                                                          Preferences.userId,
                                                          value.data!.id
                                                              .toString());
                                                      Preferences.setBoolean(
                                                          Preferences.isLogin,
                                                          true);
                                                      ApiServices.header[
                                                              'accesstoken'] =
                                                          value
                                                              .data!.accesstoken
                                                              .toString();

                                                      if (redirectType ==
                                                          "subscription") {
                                                        Get.off(
                                                            const SubscriptionScreen());
                                                      } else {
                                                        Get.offAll(
                                                            const DashBoard());
                                                      }
                                                    } else {
                                                      ShowToastDialog.showToast(
                                                          value.error);
                                                    }
                                                  }
                                                });
                                              }
                                            },
                                            btnBorderColor: Colors.transparent,

                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // space between the two login buttons
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 2.h),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Image.asset(AssetsRes.LOGIN_SHAPE_LEFT, width: 30.w,),
                                        FittedBox(
                                          child: Text(
                                              "Où".tr,
                                            style: TextStyle(
                                              color: Colors.white
                                            ),
                                          ),
                                        ),
                                        Image.asset(AssetsRes.LOGIN_SHAPE_RIGHT, width: 30.w,),
                                      ],
                                    ),
                                  ),
                                  // Google Login Button

                                  Container(
                                    // linear gradient effect 1 :
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        // Add a border with a LinearGradient
                                        // border color
                                        color: Color.fromRGBO(
                                            117, 7, 133, 1.0), // Border color
                                        width: 2.0, // Border width
                                        style: BorderStyle
                                            .solid, // Border style (you can use BorderStyle.solid, BorderStyle.none, etc.)
                                      ),
                                    ),

                                    child: Visibility(
                                      visible: Platform.isAndroid,
                                      child: ButtonThem.buildBorderButton(
                                        context,
                                        title: "   Login with google",
                                        btnColor: Color(0xffD1E8EF),
                                        txtColor: Colors.black,
                                        iconVisibility: true,
                                        iconAssetImage:
                                            'assets/icons/ic_google.png',
                                        onPress: () async {
                                          ShowToastDialog.showLoader(
                                              "Please wait");
                                          await controller
                                              .signInWithGoogle()
                                              .then((value) async {
                                            ShowToastDialog.closeLoader();
                                            if (value != null) {
                                              Map<String, String> bodyParams = {
                                                'name': value.user!.displayName
                                                    .toString(),
                                                'email': value.user!.email
                                                    .toString(),
                                                'photo': value.user!.photoURL
                                                    .toString(),
                                                'fcmtoken': controller
                                                    .notificationToken.value
                                              };
                                              await controller
                                                  .socialLoginAPI(bodyParams)
                                                  .then((value) {
                                                if (value != null) {
                                                  if (value.success ==
                                                      "Success") {
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
                                                        value.data!.id
                                                            .toString());
                                                    Preferences.setBoolean(
                                                        Preferences.isLogin,
                                                        true);
                                                    ApiServices.header[
                                                            'accesstoken'] =
                                                        value.data!.accesstoken
                                                            .toString();

                                                    if (redirectType ==
                                                        "subscription") {
                                                      Get.off(
                                                          const SubscriptionScreen());
                                                    } else {
                                                      Get.offAll(
                                                          const DashBoard());
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
                                        btnBorderColor: Colors.transparent,
                                      ),
                                    ),
                                  ),

                                  Visibility(
                                      visible: Platform.isIOS,
                                      child: ButtonThem.buildBorderButton(
                                        context,
                                        title: "Login with apple",
                                        btnColor: Colors.black,
                                        txtColor: Colors.white,
                                        iconVisibility: true,
                                        iconAssetImage:
                                            'assets/icons/ic_apple.png',
                                        onPress: () async {
                                          ShowToastDialog.showLoader(
                                              "Please wait");
                                          await controller
                                              .signInWithApple()
                                              .then((value) async {
                                            ShowToastDialog.closeLoader();
                                            // ignore: unnecessary_null_comparison
                                            if (value != null) {
                                              Map<String, String> bodyParams = {
                                                'name': value.user!.displayName
                                                    .toString(),
                                                'email': value.user!.email
                                                    .toString(),
                                                'photo': value.user!.photoURL
                                                    .toString(),
                                                'fcmtoken': controller
                                                    .notificationToken.value
                                              };
                                              await controller
                                                  .socialLoginAPI(bodyParams)
                                                  .then((value) {
                                                if (value != null) {
                                                  if (value.success ==
                                                      "Success") {
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
                                                        value.data!.id
                                                            .toString());
                                                    Preferences.setBoolean(
                                                        Preferences.isLogin,
                                                        true);
                                                    ApiServices.header[
                                                            'accesstoken'] =
                                                        value.data!.accesstoken
                                                            .toString();

                                                    if (redirectType ==
                                                        "subscription") {
                                                      Get.off(
                                                          const SubscriptionScreen());
                                                    } else {
                                                      Get.offAll(
                                                          const DashBoard());
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
                                      )),
                                  Container(
                                    padding: EdgeInsets.all(2.w),
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        text: "${"Don't have an account?".tr} ",
                                        style: const TextStyle(
                                            color: Colors.white),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: " ${'Register now!'.tr}",
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    15, 32, 182, 1),
                                                fontFamily: 'Roboto',
                                                fontWeight: FontWeight.w800,
                                                fontSize: 10.sp),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () =>
                                                  Get.to(SignupScreen(
                                                    redirectType: redirectType,
                                                    token: controller
                                                        .notificationToken
                                                        .toString(),
                                                  )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ]),
                              ),
                              // space  between the sign in text and the text Field "Email"
                            ],
                          ),
                        ),
                      ),
                    ),

                    //Style for skip button
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.h, right: 1.h),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border:
                                  Border.all(width: 0.6, color: Colors.white)),
                          child: ElevatedButton(
                            onPressed: () async {
                              FocusScope.of(context).unfocus();

                              await Constant()
                                  .getDeviceId()
                                  .then((value) async {
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
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.transparent),
                            ),
                            child: SizedBox(
                              width: 18.w,
                              child: Row(
                                children: [
                                  Text('Skip'.tr,
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w600)),
                                  SizedBox(
                                    width: 2.w,
                                  ),
                                  Image.asset(
                                    AssetsRes.ARROW_RIGHT,
                                    width: 2.w,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          );
        });
  }
}
