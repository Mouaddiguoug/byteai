import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
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
                    Form(
                      key: controller.formKey.value,
                      child: Container(

                        child: SingleChildScrollView(
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  height: 5.h
                              ),

                              Center(
                                  child: Image.asset(
                                      AssetsRes.LOGIN_LOGO_NEW_V2, height: 20.h,)),
                              // Component : Email + mot de passe + connexion button + login with google
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

                                  padding: const EdgeInsets.all(35.0),
                                  child: Column(children: [
                                    Center(
                                        child: Text(
                                          'Sign in',
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 15.sp),
                                        )),
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
                                        padding: EdgeInsets.only(
                                            top: 1.h, bottom: 2.h),
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
                                          controller: controller
                                              .passwordController.value,
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
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Get.to(
                                                const ForgotPasswordScreen());
                                          },
                                          child: Text(
                                            'Forgot Password?'.tr,
                                            textAlign: TextAlign.end,
                                            style:
                                            TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    // vanilla Login Connexion Button
                                    Container(
                                      decoration: BoxDecoration(

                                        gradient: LinearGradient(
                                          begin: FractionalOffset.bottomLeft,
                                          end: FractionalOffset.topRight,
                                          colors: [
                                            Color.fromRGBO(92, 142, 196, 1),
                                            Color.fromRGBO(76, 21, 101, 0.5),
                                            Color.fromRGBO(76, 21, 101, 0.5),
                                            Color.fromRGBO(76, 21, 101, 0.5),
                                            Color.fromRGBO(76, 21, 101, 0.6),
                                            Color.fromRGBO(76, 21, 101, 0.7),
                                          ],
                                        ),
                                      ),
                                      child: ButtonThem.buildBorderButton(
                                        context,
                                        title: 'Login'.tr,
                                        btnColor: Colors.transparent,
                                        txtColor: Colors.white,
                                        iconVisibility: false,
                                        onPress: () async {
                                          FocusScope.of(context).unfocus();
                                          if (controller
                                              .formKey.value.currentState!
                                              .validate()) {
                                            Map<String, String> bodyParams = {
                                              'email': controller
                                                  .emailController.value.text,
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
                                        },
                                        btnBorderColor: Colors.transparent,
                                      ),
                                    ),
                                    // space between the two login buttons
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    // Google Login Button
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: FractionalOffset.bottomLeft,
                                          end: FractionalOffset.topRight,
                                          colors: [
                                            Color.fromRGBO(92, 142, 196, 1),
                                            Color.fromRGBO(76, 21, 101, 0.5),
                                            Color.fromRGBO(76, 21, 101, 0.5),
                                            Color.fromRGBO(76, 21, 101, 0.5),
                                            Color.fromRGBO(76, 21, 101, 0.6),
                                            Color.fromRGBO(76, 21, 101, 0.7),
                                          ],
                                        ),
                                      ),
                                      child: Visibility(
                                        visible: Platform.isAndroid,
                                        child: ButtonThem.buildBorderButton(
                                          context,
                                          title: "Login with google",
                                          btnColor: Colors.transparent,
                                          txtColor: Colors.white,
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
                                                Map<String, String> bodyParams =
                                                {
                                                  'name': value
                                                      .user!.displayName
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
                                          style: const TextStyle(color: Colors.white),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: " ${'Register now!'.tr}",
                                              style: TextStyle(color: Color(0xFF0F20B6)),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () => Get.to(SignupScreen(
                                                  redirectType: redirectType,
                                                  token: controller.notificationToken.toString(),
                                                )),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),

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
                          width: 24.w,
                          height: 6.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              begin: FractionalOffset.topCenter,
                              end: FractionalOffset.bottomCenter,
                              colors: [
                                Color.fromRGBO(255, 94, 249, 0.47),

                                Color.fromRGBO(107, 127, 255, 0.490625),

                                Color.fromRGBO(80, 254, 254, 0.51),
                              ],
                            ),
                          ),
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
                              shape: MaterialStateProperty.all<OutlinedBorder>(

                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  // Adjust the border radius as desired


                                  /*
                                  side: BorderSide(
                                      color: Colors.purple,
                                      width:
                                      2.0), // Set the border color and width


                                   */
                                ),

                              ),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.transparent),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                // layout of the buttons
                                  horizontal: 8.0,
                                  vertical: 10),
                              child: Text('Skip'.tr,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
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
