import 'dart:developer';
import 'dart:math';

import 'package:byteai/res/assets_res.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:byteai/constant/constant.dart';
import 'package:byteai/constant/show_toast_dialog.dart';
import 'package:byteai/controller/text_to_image_controller.dart';
import 'package:byteai/model/image_model.dart';
import 'package:byteai/theam/constant_colors.dart';
import 'package:byteai/ui/subscription/subscription_screen.dart';
import 'package:byteai/ui/text_to_image/full_screen.dart';
import 'package:byteai/widget/custom_alert_dialog.dart';
import 'package:sizer/sizer.dart';

class TextToImageScreen extends StatelessWidget {
  const TextToImageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<TextToImageController>(
        init: TextToImageController(),
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
            body: Padding(
              padding: EdgeInsets.only(left: 2.w, right: 2.w, top: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10, top: 5),
                        child: SizedBox(
                          width: 65.w,
                          height: 17.h,
                          child: TextField(
                            maxLines: 8,
                            controller: controller.textController.value,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Ex.Travel ....'.tr,
                              hintStyle: TextStyle(
                                  color: ConstantColors.hintTextColor),
                              suffixIcon: Padding(
                                padding: EdgeInsets.only(top: 10.h),
                                child: InkWell(
                                  onTap: (() async {
                                    FocusScope.of(context).unfocus();
                                    if (controller
                                        .selectedImageOption.isEmpty) {
                                      ShowToastDialog.showToast(
                                          'Please select Size'.tr);
                                    } else {
                                      if (controller.imageLimit.value == "0" &&
                                          Constant.isActiveSubscription ==
                                              false) {
                                        ShowToastDialog.showToast(
                                            "Your free limit is over.Please subscribe to package to get unlimited limit."
                                                .tr);
                                        Get.to(const SubscriptionScreen());
                                      } else {
                                        if (Constant().isAdsShow() &&
                                            controller.interstitialAd != null) {
                                          controller.interstitialAd!
                                                  .fullScreenContentCallback =
                                              FullScreenContentCallback(
                                            onAdShowedFullScreenContent:
                                                (InterstitialAd ad) => debugPrint(
                                                    'ad onAdShowedFullScreenContent.'),
                                            onAdDismissedFullScreenContent:
                                                (InterstitialAd ad) {
                                              ad.dispose();
                                              controller.loadAd();
                                              controller.sendImageResponse(
                                                  controller.textController
                                                      .value.text);
                                            },
                                            onAdFailedToShowFullScreenContent:
                                                (InterstitialAd ad,
                                                    AdError error) {
                                              ad.dispose();
                                              controller.sendImageResponse(
                                                  controller.textController
                                                      .value.text);
                                            },
                                          );
                                          controller.interstitialAd!.show();
                                          controller.interstitialAd = null;
                                        } else {
                                          controller.sendImageResponse(
                                              controller
                                                  .textController.value.text);
                                        }
                                      }
                                    }
                                  }),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Container(
                                      width: 12.w,
                                      height: 6.h,
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              begin:
                                                  const FractionalOffset(0, 0),
                                              end: const FractionalOffset(1, 1),
                                              stops: const [
                                                0,
                                                1.0
                                              ],
                                              colors: [
                                                Color(0xff64229c),
                                                Color(0xff4975aa),
                                              ]),
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: Image.asset(AssetsRes.SEND,
                                          width: 2.h),
                                    ),
                                  ),
                                ),
                              ),
                              filled: true,
                              fillColor:
                                  ConstantColors.searchField.withOpacity(0.15),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: ConstantColors.cardViewColor),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: ConstantColors.cardViewColor),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 25.w,
                              child: GestureDetector(
                                onTap: () {
                                  controller.selectedImageOption.value =
                                      "256x256";
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      image: controller
                                                  .selectedImageOption.value ==
                                              "256x256"
                                          ? DecorationImage(
                                              image:
                                                  AssetImage(AssetsRes.SHADOW),
                                              fit: BoxFit.fill,
                                            )
                                          : null,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.20),
                                        ),
                                        BoxShadow(
                                            color:
                                                Colors.white.withOpacity(0.25),
                                            spreadRadius: -4.0,
                                            blurRadius: 4.0,
                                            offset: Offset(0, 1)),
                                      ],
                                      shape: BoxShape.rectangle,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Center(
                                        child: Text(
                                      "256x256".tr,
                                      style: TextStyle(color: Colors.white),
                                    )),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10.h,
                            ),
                            SizedBox(
                              width: 25.w,
                              child: GestureDetector(
                                onTap: () {
                                  controller.selectedImageOption.value =
                                      "512x512";
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      image: controller
                                                  .selectedImageOption.value ==
                                              "512x512"
                                          ? DecorationImage(
                                              image:
                                                  AssetImage(AssetsRes.SHADOW),
                                              fit: BoxFit.fill,
                                            )
                                          : null,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.20),
                                        ),
                                        BoxShadow(
                                            color:
                                                Colors.white.withOpacity(0.25),
                                            spreadRadius: -4.0,
                                            blurRadius: 4.0,
                                            offset: Offset(0, 1)),
                                      ],
                                      shape: BoxShape.rectangle,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Center(
                                        child: Text(
                                      "512x512".tr,
                                      style: TextStyle(color: Colors.white),
                                    )),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10.h,
                            ),
                            SizedBox(
                              width: 25.w,
                              child: GestureDetector(
                                onTap: () {
                                  controller.selectedImageOption.value =
                                      "1024x024";
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      image: controller
                                                  .selectedImageOption.value ==
                                              "1024x024"
                                          ? DecorationImage(
                                              image:
                                                  AssetImage(AssetsRes.SHADOW),
                                              fit: BoxFit.fill,
                                            )
                                          : null,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.20),
                                        ),
                                        BoxShadow(
                                            color:
                                                Colors.white.withOpacity(0.25),
                                            spreadRadius: -4.0,
                                            blurRadius: 4.0,
                                            offset: Offset(0, 1)),
                                      ],
                                      shape: BoxShape.rectangle,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Center(
                                        child: Text(
                                      "1024x024".tr,
                                      style: TextStyle(color: Colors.white),
                                    )),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: MasonryGridView.count(
                        itemCount: controller.imageList.length,
                        crossAxisCount: 2,
                        mainAxisSpacing: 10.0,
                        crossAxisSpacing: 10.0,
                        itemBuilder: (context, index) {
                          ImageData data = controller.imageList[index];
                          return InkWell(
                            onTap: () {
                              Get.to(ImageView(
                                index: index,
                                imageList: controller.imageList,
                              ));
                            },
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              child: CachedNetworkImage(
                                width: 100.w,
                                fit: BoxFit.cover,
                                height: (Random().nextInt(5) * 12).h,
                                imageUrl: data.url.toString(),
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
