import 'dart:developer';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:byteai/constant/constant.dart';
import 'package:byteai/constant/show_toast_dialog.dart';
import 'package:byteai/controller/writer_details_controller.dart';
import 'package:byteai/theam/constant_colors.dart';
import 'package:byteai/ui/writer_screen/writer_screen.dart';
import 'package:selectable/selectable.dart';

class WriterDetailsScreen extends StatelessWidget {
  const WriterDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<WriterDetailsController>(
        init: WriterDetailsController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: ConstantColors.background,
            appBar: AppBar(title: Text('Email Writer'.tr), centerTitle: true),
            body: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Visibility(
                      visible: controller.bannerAdIsLoaded.value &&
                          Constant().isAdsShow() &&
                          controller.bannerAd != null,
                      child: Center(
                        child: SizedBox(
                            height: controller.bannerAd!.size.height.toDouble(),
                            width: controller.bannerAd!.size.width.toDouble(),
                            child: AdWidget(ad: controller.bannerAd!)),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    chatBubble(context),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (Constant().isAdsShow() &&
                              controller.interstitialAd != null) {
                            controller
                                    .interstitialAd!.fullScreenContentCallback =
                                FullScreenContentCallback(
                              onAdShowedFullScreenContent:
                                  (InterstitialAd ad) =>
                                      log('ad onAdShowedFullScreenContent.'),
                              onAdDismissedFullScreenContent:
                                  (InterstitialAd ad) {
                                ad.dispose();
                                controller.loadAd();
                                Get.off(const WriterScreen(), arguments: {
                                  "category": controller.categoryData.value,
                                });
                              },
                              onAdFailedToShowFullScreenContent:
                                  (InterstitialAd ad, AdError error) {
                                log('$ad onAdFailedToShowFullScreenContent: $error');
                                ad.dispose();
                                Get.off(const WriterScreen(), arguments: {
                                  "category": controller.categoryData.value,
                                });
                              },
                            );
                            controller.interstitialAd!.show();
                            controller.interstitialAd = null;
                          } else {
                            Get.back();
                          }

                          // final isLoaded = await controller.interstitialAd.isLoaded;
                          // if (isLoaded == true && Constant().isAdsShow()) {
                          //   controller.interstitialAd.show();
                          // } else {

                          // }
                        },
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: ConstantColors.primary,
                            shape: const StadiumBorder()),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 12),
                          child: Text('Ask to New Question'.tr,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  chatBubble(BuildContext context) {
    return GetBuilder<WriterDetailsController>(builder: (controller) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  controller.textToSpeechAnswer.value = false;
                  controller.textToSpeechQuesion.value = true;
                  controller.update();
                  controller.speak(
                      speechText:
                          controller.question.value.replaceFirst('\n\n', ''));
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: controller.textToSpeechQuesion.value == true
                      ? SizedBox.fromSize(size: const Size.fromRadius(10))
                      : SizedBox.fromSize(
                          size: const Size.fromRadius(10), // Image radius
                          child: const Icon(Icons.volume_up_outlined,
                              color: Colors.grey, size: 18),
                        ),
                ),
              ),
              Flexible(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                      color: ConstantColors.primary,
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10),
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (controller.textToSpeechQuesion.value == true)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: SizedBox(
                            width: 35,
                            height: 16,
                            child: Lottie.network(
                                'https://assets5.lottiefiles.com/packages/lf20_3r3rc9.json',
                                fit: BoxFit.fill),
                          ),
                        ),
                      DefaultTextStyle(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TyperAnimatedText(
                              speed: const Duration(milliseconds: 10),
                              controller.question.value
                                  .replaceFirst('\n\n', ''),
                            ),
                          ],
                          repeatForever: false,
                          totalRepeatCount: 1,
                        ),
                      ),
                      InkWell(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: controller.question.value));
                            ShowToastDialog.showToast('Copy!!'.tr);
                          },
                          child: const Align(
                              alignment: Alignment.bottomRight,
                              child: Icon(Icons.copy, color: Colors.white))),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Container(
                  decoration: BoxDecoration(
                      color: ConstantColors.background,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white)),
                  child: ClipOval(
                    child: SizedBox.fromSize(
                      size: const Size.fromRadius(15), // Image radius
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Image.asset('assets/icons/chat_gpt_icon.png'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Visibility(
            visible: controller.answer.isNotEmpty,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Container(
                    decoration: BoxDecoration(
                        color: ConstantColors.background,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white)),
                    child: ClipOval(
                      child: SizedBox.fromSize(
                        size: const Size.fromRadius(15), // Image radius
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Image.asset('assets/icons/chat_gpt_icon.png'),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                        color: ConstantColors.cardViewColor,
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(10),
                            topLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (controller.textToSpeechAnswer.value == true)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: SizedBox(
                              width: 35,
                              height: 16,
                              child: Lottie.network(
                                  'https://assets5.lottiefiles.com/packages/lf20_3r3rc9.json',
                                  fit: BoxFit.fill),
                            ),
                          ),
                        Selectable(
                          selectWordOnLongPress: true,
                          selectWordOnDoubleTap: true,
                          child: DefaultTextStyle(
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            child: AnimatedTextKit(
                              animatedTexts: [
                                TyperAnimatedText(
                                  speed: const Duration(milliseconds: 10),
                                  controller.answer.value
                                      .replaceFirst('\n\n', ''),
                                ),
                              ],
                              repeatForever: false,
                              totalRepeatCount: 1,
                            ),
                          ),
                        ),
                        InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(
                                  text: controller.answer.value
                                      .replaceFirst('\n\n', '')));
                              ShowToastDialog.showToast('Copy!!'.tr);
                            },
                            child: const Align(
                                alignment: Alignment.bottomRight,
                                child: Icon(Icons.copy, color: Colors.white))),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: controller.answer.isNotEmpty,
                  child: GestureDetector(
                    onTap: () {
                      controller.textToSpeechQuesion.value = false;
                      controller.textToSpeechAnswer.value = true;
                      controller.update();
                      controller.speak(
                          speechText:
                              controller.answer.value.replaceFirst('\n\n', ''));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: controller.textToSpeechAnswer.value == true
                          ? SizedBox.fromSize(
                              size: const Size.fromRadius(10),
                            )
                          : SizedBox.fromSize(
                              size: const Size.fromRadius(10), // Image radius
                              child: const Icon(Icons.volume_up_outlined,
                                  color: Colors.grey, size: 18),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
