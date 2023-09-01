import 'dart:async';
import 'dart:developer';
import 'package:byteai/res/assets_res.dart';
import 'package:byteai/theam/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:byteai/controller/main_setting_controller.dart';
import 'package:byteai/service/notification_service.dart';
import 'package:byteai/ui/auth/login_screen.dart';
import 'package:byteai/ui/dashboard.dart';
import 'package:byteai/ui/on_boarding_screen.dart';
import 'package:byteai/utils/Preferences.dart';
import 'package:sizer/sizer.dart';

import 'service/localization_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String token = '';
  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      notificationService.initInfo().then((value) async {
        token = await NotificationService.getToken();
        log(":::::::TOKEN:::::: $token");
        getLanguage();
        Timer(const Duration(seconds: 3), () => redirect());
      });
    });
    super.initState();
  }

  getLanguage() async {
    if (Preferences.getString(Preferences.lngCode).toString().isNotEmpty) {
      LocalizationService()
          .changeLocale(Preferences.getString(Preferences.lngCode).toString());
    }
  }

  redirect() {
    if (Preferences.getBoolean(Preferences.isFinishOnBoardingKey) == false) {
      Get.offAll(const OnBoardingScreen());
    } else if (Preferences.getBoolean(Preferences.isLogin) == false) {
      Get.offAll(const LoginScreen(
        redirectType: "",
      ));
    } else {
      Get.offAll(const DashBoard());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainSettingController>(
        init: MainSettingController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: ConstantColors.background,
            body: Stack(
              children: [
                Positioned(bottom: 50.h,
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Image.asset(AssetsRes.PLACEHOLDER_COLOR, width: 50.sp, height: 50.sp,)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 10.h),
                    Image.asset(AssetsRes.LOGIN_LOGO_NEW_V2, width: 100.sp, height: 100.sp,),
                    SizedBox(height: 3.h),
                    Image.asset(AssetsRes.TITLE_LOGO, width: 100.w),
                  ],
                ),
              ],
            ),
          );
        });
  }
}
