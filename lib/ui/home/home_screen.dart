import 'dart:developer';
import 'dart:ui';

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
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
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
      return GetX<HomeController>(
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
                                onAdDismissedFullScreenContent:
                                    (RewardedAd ad) {
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
                body: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            left: 0,
                            right: 0,
                            top: !chatController.isBeingConverted.value && !chatController.isLoading.value ? 5.h : 60.h,
                            bottom: 2.h,
                            duration: Duration(milliseconds: 800),
                            curve: Curves.easeIn,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 20.h,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                    gradient: LinearGradient(
                                        colors: [
                                          Color(0xff04AC84).withOpacity(0.4),
                                          Color(0xff04AC84).withOpacity(0.17)
                                        ]
                                    )
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(onPressed: () {
                                            chatController.isBeingConverted.value = true;
                                            chatController.isLoading.value = true;
                                          }, icon: Icon(Icons.close, color: Colors.white,))
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(10.sp),
                                        child: Text(
                                            chatController.message.value,
                                            style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 20.h,
                            bottom: 50.h,
                            child: Center(
                              child: SizedBox(
                                width: 25.w,
                                height: 60.h,
                                child: AnimatedOpacity(
                                  opacity: !chatController.isBeingConverted.value && !chatController.isLoading.value ? 0 : 1,
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.easeIn,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                          Color(0xff04AC84),
                                          shape: CircleBorder()),
                                      onPressed: () async {
                                        chatController.speechDown();
                                      },
                                      child: GetBuilder<ChatBotController>(
                                          builder: (chatBotController) {
                                            return chatController
                                                .speech.value.isListening
                                                ? Lottie.asset(
                                                AssetsRes.LOADING_ANIMATION,
                                                width: 300)
                                                : Icon(
                                              Icons.mic,
                                              color: Colors.white,
                                              size: 50,
                                            );
                                          })),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                    !chatController.converting.value && !chatController.isLoading.value
                        ? GestureDetector(
                            onTap: () {
                              chatController.converting.value = false;
                            },
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 5.0,
                                sigmaY: 5.0,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(30.0),
                                child: SizedBox(
                                  height: 70.h,
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    child: PdfPreview(
                                        build: (context) =>
                                            chatController.PDF.value,
                                        padding: EdgeInsets.all(20)),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ));
          });
    });
  }
}
