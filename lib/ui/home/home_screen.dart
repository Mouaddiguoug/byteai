import 'dart:developer';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:byteai/controller/chat_bot_controller.dart';
import 'package:byteai/res/assets_res.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:byteai/constant/constant.dart';
import 'package:byteai/controller/home_controller.dart';
import 'package:byteai/model/banner_model.dart';
import 'package:byteai/model/category_model.dart';
import 'package:byteai/model/history_model.dart';
import 'package:byteai/theam/constant_colors.dart';
import 'package:byteai/ui/ai_code/aicode_screen.dart';
import 'package:byteai/ui/astrology/astrology_screen.dart';
import 'package:byteai/ui/history/history_details_screen.dart';
import 'package:byteai/ui/history/history_screen.dart';
import 'package:byteai/ui/home/category_list_screen.dart';
import 'package:byteai/ui/writer_screen/writer_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';

import '../../model/chat.dart';
import '../../widget/custom_alert_dialog.dart';
//

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final PageController _controller =
      PageController(viewportFraction: 1.0, keepPage: true);

  @override
  Widget build(BuildContext context) {
    var chatController = Get.put(ChatBotController());
    return Sizer(builder: (context, orientation, deviceType) {
      return GetBuilder<HomeController>(
          init: HomeController(),
          builder: (controller) {
            return Scaffold(
              backgroundColor: ConstantColors.background,
              appBar: AppBar(title: Text('byteai'.tr), actions: [
                InkWell(
                  onTap: () {
                    showDialog(
                      barrierColor: Colors.black26,
                      context: context,
                      builder: (context) {
                        return CustomAlertDialog(
                          title: "Watch Video to increase your limit",
                          onPressNegative: () {
                            Get.back();
                          },
                          onPressPositive: () {
                            Get.back();
                            if (controller.rewardedAd == null) {
                              return;
                            }
                            controller.rewardedAd!.fullScreenContentCallback =
                                FullScreenContentCallback(
                              onAdShowedFullScreenContent: (RewardedAd ad) =>
                                  log('ad onAdShowedFullScreenContent.'),
                              onAdDismissedFullScreenContent: (RewardedAd ad) {
                                ad.dispose();
                                controller.increaseLimit();
                                controller.loadRewardAd();
                              },
                              onAdFailedToShowFullScreenContent:
                                  (RewardedAd ad, AdError error) {
                                ad.dispose();
                                controller.loadRewardAd();
                              },
                            );

                            controller.rewardedAd!.setImmersiveMode(true);
                            controller.rewardedAd!.show(onUserEarnedReward:
                                (AdWithoutView ad, RewardItem reward) {
                              log('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
                            });
                            controller.rewardedAd = null;
                          },
                        );
                      },
                    );
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        AssetsRes.REWARD,
                        width: 30.sp,
                      ),
                      const Expanded(child: Text("Reward ads"))
                    ],
                  ),
                )
              ]),
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Lottie.asset(AssetsRes.COMP1, width: 100.w, height: 50.h),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                              "Bonjour, comment puis-je vous aider aujourd'hui",
                              textStyle: TextStyle(color: Colors.white)),
                          TypewriterAnimatedText(
                              "commencez votre phrase par convertir afin que je puisse convertir votre document en pdf pour vous",
                              textStyle: TextStyle(color: Colors.white)),
                          TypewriterAnimatedText(
                              "commencez votre phrase par convertir afin que je puisse convertir votre document en pdf pour vous",
                              textStyle: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: 25.w,
                        height: 25.h,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: ConstantColors.cardViewColor,
                                shape: CircleBorder()),
                            onPressed: () async {
                              chatController.speechDown();
                            },
                            child: GetBuilder<ChatBotController>(
                                builder: (chatBotController) {
                              return chatController.speech.value.isListening
                                  ? Lottie.asset(AssetsRes.LOADING_ANIMATION,
                                      width: 300)
                                  : Icon(
                                      Icons.mic,
                                      color: Colors.white,
                                      size: 40,
                                    );
                            })),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
    });
  }
}
