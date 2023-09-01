import 'dart:developer';
import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:byteai/controller/chat_bot_controller.dart';
import 'package:byteai/res/assets_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:byteai/controller/home_controller.dart';
import 'package:byteai/theam/constant_colors.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';
import 'package:printing/printing.dart';
import 'package:sizer/sizer.dart';

import '../../constant/show_toast_dialog.dart';
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
                appBar: AppBar(
                    title: Image.asset(AssetsRes.LOGIN_LOGO_NEW_V2,
                        width: 45.sp, height: 45.sp),
                    centerTitle: true,
                    actions: [
                      // InkWell(
                      //   onTap: () {
                      //     showDialog(
                      //       barrierColor: Colors.black26,
                      //       context: context,
                      //       builder: (context) {
                      //         return CustomAlertDialog(
                      //           title: "Watch Video to increase your limit",
                      //           onPressNegative: () {
                      //             Get.back();
                      //           },
                      //           onPressPositive: () {
                      //             Get.back();
                      //             if (controller.rewardedAd == null) {
                      //               return;
                      //             }
                      //             controller.rewardedAd!.fullScreenContentCallback =
                      //                 FullScreenContentCallback(
                      //               onAdShowedFullScreenContent: (RewardedAd ad) =>
                      //                   log('ad onAdShowedFullScreenContent.'),
                      //               onAdDismissedFullScreenContent:
                      //                   (RewardedAd ad) {
                      //                 ad.dispose();
                      //                 controller.increaseLimit();
                      //                 controller.loadRewardAd();
                      //               },
                      //               onAdFailedToShowFullScreenContent:
                      //                   (RewardedAd ad, AdError error) {
                      //                 ad.dispose();
                      //                 controller.loadRewardAd();
                      //               },
                      //             );
                      //
                      //             controller.rewardedAd!.setImmersiveMode(true);
                      //             controller.rewardedAd!.show(onUserEarnedReward:
                      //                 (AdWithoutView ad, RewardItem reward) {
                      //               log('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
                      //             });
                      //             controller.rewardedAd = null;
                      //           },
                      //         );
                      //       },
                      //     );
                      //   },
                      //   child: Column(
                      //     children: [
                      //       Image.asset(
                      //         AssetsRes.REWARD,
                      //         width: 30.sp,
                      //       ),
                      //       const Expanded(child: Text("Reward ads"))
                      //     ],
                      //   ),
                      // )
                    ]),
                body: Stack(
                  children: [
                    Image.asset(AssetsRes.COLOR_SHARP),
                    AnimatedPositioned(
                        top: 0,
                        left: chatController.speech.value.isListening
                            ? 100.w
                            : 80.w,
                        right: 0,
                        bottom: 40.h,
                        duration: Duration(milliseconds: 600),
                        child: Image.asset(AssetsRes.HOME_SHAPE2)),
                    AnimatedPositioned(
                      top: 40.h,
                      left: 0,
                      right: chatController.speech.value.isListening
                          ? 100.w
                          : 80.w,
                      bottom: 0,
                      duration: Duration(milliseconds: 600),
                      child: Image.asset(
                        AssetsRes.HOME_SHAPE,
                      ),
                    ),
                    Stack(
                      children: [
                        SizedBox(
                          height: 100.h,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 3.h,
                              ),
                              Text(
                                chatController.speech.value.isListening
                                    ? "Listening...".tr
                                    : "Welcome".tr,
                                style: TextStyle(
                                    fontSize: 15.sp, color: Colors.white),
                              ),
                              Stack(
                                children: [
                                  Column(
                                    children: [
                                      AnimatedOpacity(
                                        opacity: !chatController
                                                .speech.value.isListening
                                            ? 0
                                            : 1,
                                        duration: Duration(milliseconds: 600),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: 0, left: 1.w, right: 1.w),
                                          child: SingleChildScrollView(
                                            child: SizedBox(
                                              height: 50.h,
                                              child: Text(
                                                  chatController.message.value,
                                                  style: TextStyle(
                                                      fontSize: 15.sp,
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: chatController
                                            .speech.value.isListening,
                                        child: LottieBuilder.asset(
                                            AssetsRes.AUDIO_WAVE,
                                            width: 100.w),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      AnimatedOpacity(
                                          opacity: chatController
                                                  .speech.value.isListening
                                              ? 0
                                              : 1,
                                          duration: Duration(milliseconds: 600),
                                          child: Image.asset(
                                              AssetsRes.BLOOM_GIF,
                                              width: 100.w)),
                                      AnimatedOpacity(
                                        opacity: chatController
                                                .speech.value.isListening
                                            ? 0
                                            : 1,
                                        duration: Duration(milliseconds: 600),
                                        child: Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.sp),
                                            child: AnimatedTextKit(
                                              totalRepeatCount: 1,
                                              animatedTexts: [
                                                TyperAnimatedText(
                                                    chatController
                                                        .initialHello.value,
                                                    textAlign: TextAlign.center,
                                                    textStyle: TextStyle(
                                                        fontSize: 10.sp,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w700))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Visibility(
                                visible: chatController
                                            .speech.value.lastStatus ==
                                        "notListening" ||
                                    chatController.speech.value.lastStatus ==
                                        "done" ||
                                    chatController.speech.value.lastStatus ==
                                        "",
                                child: Center(
                                  child: SizedBox(
                                    width: 25.w,
                                    height: 25.h,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFF000000),
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
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  ConstantColors.background,
                                              shape: CircleBorder()),
                                          onPressed: () async {
                                            chatController.speechDown();
                                          },
                                          child: Stack(
                                            children: [
                                              chatController
                                                      .speech.value.isListening
                                                  ? Lottie.asset(
                                                      AssetsRes.MIC_ANIME)
                                                  : Container(),
                                              Positioned(
                                                bottom: 0,
                                                top: 0,
                                                right: 0,
                                                left: 0,
                                                child: GetBuilder<
                                                        ChatBotController>(
                                                    builder:
                                                        (chatBotController) {
                                                  return chatController.speech
                                                          .value.isListening
                                                      ? Lottie.asset(
                                                          AssetsRes
                                                              .LOADING_ANIMATION,
                                                          width: 60.sp)
                                                      : Icon(
                                                          Icons.mic,
                                                          color: Colors.white,
                                                          size: 30,
                                                        );
                                                }),
                                              ),
                                            ],
                                          )),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedPositioned(
                          left: 0,
                          right: 0,
                          top: !chatController.isBeingConverted.value &&
                                  !chatController.isLoading.value
                              ? 5.h
                              : 60.h,
                          bottom: 30.h,
                          duration: Duration(milliseconds: 800),
                          curve: Curves.easeIn,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AnimatedOpacity(
                              opacity: !chatController.isBeingConverted.value &&
                                      !chatController.isLoading.value
                                  ? 1
                                  : 0,
                              duration: Duration(milliseconds: 500),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 5.0,
                                  sigmaY: 8.0,
                                ),
                                child: Container(
                                  height: 20.h,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      gradient: LinearGradient(colors: [
                                        Color(0xff081a37).withOpacity(0.4),
                                        Color(0xff072e41)
                                      ])),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                                highlightColor:
                                                    Colors.transparent,
                                                splashColor: Colors.transparent,
                                                onPressed: () {
                                                  chatController
                                                      .isBeingConverted
                                                      .value = true;
                                                  chatController
                                                      .isLoading.value = true;
                                                },
                                                icon: Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                ))
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(10.sp),
                                          child: Text(
                                              chatController.message.value,
                                              style: TextStyle(
                                                  color: Color(0xff04AC84),
                                                  fontWeight: FontWeight.w400)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    chatController.converting.value &&
                            !chatController.isLoading.value
                        ? BackdropFilter(
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
                                  child: Stack(
                                    children: [
                                      PdfPreview(
                                          previewPageMargin: EdgeInsets.all(0),
                                          allowSharing: false,
                                          canChangeOrientation: false,
                                          canChangePageFormat: false,
                                          canDebug: false,
                                          maxPageWidth: 100.w,
                                          pdfPreviewPageDecoration:
                                              BoxDecoration(
                                                  color: Colors.transparent),
                                          build: (context) =>
                                              chatController.PDF.value),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        bottom: 66.h,
                                        left: 75.w,
                                        child: GestureDetector(
                                          onTap: () {
                                            chatController.converting.value =
                                                false;
                                          },
                                          child: Container(
                                            height: 3.h,
                                            decoration: BoxDecoration(
                                                color:
                                                    ConstantColors.background,
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(10))),
                                            width: 20.w,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.close_rounded,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    AnimatedPositioned(
                        top: 0,
                        left: chatController.isWorking.value ? -50.w : 0,
                        right: chatController.isWorking.value ? -50.w : 0,
                        bottom: chatController.isWorking.value ? 25.h : 35.h,
                        duration: Duration(milliseconds: 600),
                        child: Visibility(
                          visible: chatController.isWorking.value,
                          child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 5.0,
                                sigmaY: 8.0,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Image.asset(AssetsRes.BLOOM_GIF),
                                    Text("Working on it...".tr, style: TextStyle(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w700),)
                                  ],
                                ),
                              )),
                        )),
                  ],
                ));
          });
    });
  }
}
