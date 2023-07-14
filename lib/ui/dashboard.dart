import 'dart:ui';

import 'package:byteai/controller/character_controller.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:byteai/constant/constant.dart';
import 'package:byteai/controller/dashboard_controller.dart';
import 'package:byteai/theam/constant_colors.dart';
import 'package:byteai/ui/chat_bot/select_character_screen.dart';
import 'package:byteai/ui/home/home_screen.dart';
import 'package:byteai/ui/subscription/subscription_screen.dart';
import 'package:sizer/sizer.dart';

import '../utils/Preferences.dart';
import 'chat_bot/chat_bot_screen.dart';
import 'setting/setting_screen.dart';
import 'text_to_image/text_to_image_screen.dart';

class DashBoard extends StatelessWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return GetX<DashBoardController>(
        init: DashBoardController(),
        initState: (state) {
          if (Constant.isActiveSubscription == false) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(context);
            });
          }
        },
        builder: (controller) {
          return Scaffold(
              backgroundColor: ConstantColors.background,
              body: controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : controller.index.value == 0
                      ? HomeScreen()
                      : controller.index.value == 2
                          ? const TextToImageScreen()
                          : SettingScreen(),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ConvexAppBar(
                    initialActiveIndex: controller.index.value,
                    backgroundColor: ConstantColors.cardViewColor.withOpacity(0.9),
                    activeColor: ConstantColors.cardViewColor.withOpacity(0.1),
                    color: Colors.white,
                    height: 55,
                    onTabNotify: (index) {
                      if (index == 1) {
                        setCharacter();
                        // Get.to(const ChatBotScreen());
                        return false;
                      }
                      return true;
                    },
                    items: [
                      TabItem(
                        activeIcon: Padding(
                          padding:  EdgeInsets.only(top: 3.5.h),
                          child: SvgPicture.asset('assets/icons/ic_home.svg',
                              semanticsLabel: 'Acme Logo'.tr),
                        ),
                        icon: SvgPicture.asset(
                            'assets/icons/inactive_ic_home.svg',
                            semanticsLabel: 'Acme Logo'.tr),
                      ),
                      TabItem(
                        activeIcon: Padding(
                          padding:  EdgeInsets.only(top: 3.5.h),
                          child: SvgPicture.asset(
                              'assets/icons/inactive_ic_chat.svg',
                              semanticsLabel: 'Acme Logo'.tr),
                        ),
                        icon: SvgPicture.asset(
                            'assets/icons/inactive_ic_chat.svg',
                            semanticsLabel: 'Acme Logo'.tr),
                      ),
                      TabItem(
                        activeIcon: Padding(
                          padding:  EdgeInsets.only(top: 3.5.h),
                          child: SvgPicture.asset('assets/icons/ic_image.svg',
                              semanticsLabel: 'Acme Logo'.tr),
                        ),
                        icon: SvgPicture.asset(
                            'assets/icons/inactive_ic_image.svg',
                            semanticsLabel: 'Acme Logo'.tr),
                      ),
                      TabItem(
                        activeIcon: Padding(
                          padding:  EdgeInsets.only(top: 3.5.h),
                          child: SvgPicture.asset('assets/icons/ic_setting.svg',
                              semanticsLabel: 'Acme Logo'.tr),
                        ),
                        icon: SvgPicture.asset(
                            'assets/icons/inactive_ic_setting.svg',
                            semanticsLabel: 'Acme Logo'.tr),
                      ),
                    ],
                    onTap: (index) {
                      controller.index.value = index;
                    },
                  ),
                ),
              ));
        },
      );
    });
  }

  showDialog(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return const FractionallySizedBox(
              heightFactor: 0.99, child: SubscriptionScreen());
        });
  }
}

Future<void> setCharacter() async {
  var characters = Get.put(CharacterController());
  await Preferences.setString(Preferences.selectedCharacters,
      characters.selectedCharacter.value!.name.toString());
  Get.to(const ChatBotScreen(),
      arguments: {'charactersData': characters.selectedCharacter.value});
}
