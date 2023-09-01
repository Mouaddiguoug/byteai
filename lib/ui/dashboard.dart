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
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
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
            //  showDialog(context);
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
                  child: SalomonBottomBar(
                    selectedItemColor: Colors.white,
                    currentIndex: controller.index.value,
                    backgroundColor:
                        ConstantColors.background,
                    items: [
                      SalomonBottomBarItem(
                        icon: SvgPicture.asset(
                            'assets/icons/inactive_ic_home.svg',
                            semanticsLabel: 'Acme Logo'.tr),
                        activeIcon: Icon(Icons.home_outlined),
                        title: Text("Home"),
                      ),
                      SalomonBottomBarItem(
                        icon: SvgPicture.asset(
                            'assets/icons/inactive_ic_chat.svg',
                            semanticsLabel: 'Acme Logo'.tr),
                        activeIcon: Icon(Icons.chat_outlined),
                        title: Text("Chat"),
                      ),
                      SalomonBottomBarItem(
                        activeIcon: Icon(Icons.image_outlined),
                        icon: SvgPicture.asset(
                            'assets/icons/inactive_ic_image.svg',
                            semanticsLabel: 'Acme Logo'.tr),
                        title: Text("Images"),
                      ),
                      SalomonBottomBarItem(
                        activeIcon: Icon(Icons.settings_outlined),
                        icon: SvgPicture.asset(
                            'assets/icons/inactive_ic_setting.svg',
                            semanticsLabel: 'Acme Logo'.tr),
                        title: Text("Settings"),
                      ),
                    ],
                    onTap: (index) {
                      if(index == 1) {
                        return setCharacter();
                      }
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
