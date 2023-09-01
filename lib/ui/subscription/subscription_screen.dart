import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:byteai/res/assets_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:byteai/constant/constant.dart';
import 'package:byteai/constant/show_toast_dialog.dart';
import 'package:byteai/controller/subscription_controller.dart';
import 'package:byteai/model/customer_subscription_model.dart';
import 'package:byteai/model/subscription_model.dart';
import 'package:byteai/theam/constant_colors.dart';
import 'package:byteai/ui/auth/login_screen.dart';
import 'package:byteai/utils/Preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<SubscriptionController>(
          init: SubscriptionController(),
          builder: (controller) {
            return Scaffold(
              backgroundColor: ConstantColors.background,
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.h),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40, right: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,

                            children: [

                              SvgPicture.asset('assets/icons/closeBtn.svg',
                                  width: 5.w, semanticsLabel: 'Acme Logo'),
                            ],
                          ),
                        ),
                      ),

                      Stack(
                        children: [

                          Positioned(
                            left: -30.w,
                            right: -30.w,
                            bottom: 40.h,
                            top: 0,
                            child: Image.asset(
                              AssetsRes.ONBOARDING,
                                width: 50.sp,
                                height: 50.sp,
                                ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               SizedBox(
                                height:50.h,
                              ),
                              Center(
                                child: Text(
                                  'Choisissez votre plan !'.tr,
                                  style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 15.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 2),
                                ),
                              ),
                              SizedBox(
                                height: 4.h,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                          text: "${'High word limit for questions and answers'.tr} ",
                                          style: TextStyle(
                                              color: Colors.white,
                                              letterSpacing: 1.5)),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 1.h,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                          text: '${'Unlimited questions and answers'.tr} ',
                                          style: TextStyle(
                                              color: Colors.white,
                                              letterSpacing: 1.5)),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 1.h,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                          text: '${'Ads free experience'.tr} ',
                                          style: TextStyle(
                                              color: Colors.white,
                                              letterSpacing: 1.5)),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 13.h,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () async {
                                    if (Preferences.getBoolean(Preferences.isLogin)) {
                                      await initPlatformState(controller,
                                          controller.selectedSubscription.value);
                                    } else {
                                      Get.off(const LoginScreen(
                                        redirectType: "subscription",
                                      ));
                                    }
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: ConstantColors.background,
                                        shape: BoxShape.rectangle,
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
                                        borderRadius: BorderRadius.circular(20)

                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      child: Center(
                                        child: Text(
                                          "Continue".tr,
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),

                            ],
                          ),


                        ],
                      ),

                      controller.isLoading.value
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : ListView.builder(
                              itemCount: controller.subscriptionList.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                SubscriptionData subscriptionData =
                                    controller.subscriptionList[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: InkWell(
                                    onTap: () {
                                      controller.selectedSubscription.value =
                                          subscriptionData;
                                    },
                                    child: Obx(
                                      () => Container(
                                        decoration: controller
                                                    .selectedSubscription
                                                    .value ==
                                                subscriptionData
                                            ? const BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                        'assets/images/subscrption_item.png'),
                                                    fit: BoxFit.fill),
                                                borderRadius:
                                                    BorderRadius.all(
                                                        Radius.circular(10)))
                                            : BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.4),
                                                shape: BoxShape.rectangle,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10))),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical:
                                                  subscriptionData.discount !=
                                                              null &&
                                                          subscriptionData
                                                                  .discount !=
                                                              "0"
                                                      ? 10
                                                      : 22,
                                              horizontal: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      subscriptionData.name
                                                          .toString()
                                                          .tr,
                                                      style: const TextStyle(
                                                          color:
                                                              Colors.white),
                                                    ),
                                                  ),
                                                  Text(
                                                    "\$${subscriptionData.price.toString()}",
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                              Visibility (
                                                visible: subscriptionData
                                                            .discount !=
                                                        null &&
                                                    subscriptionData
                                                            .discount !=
                                                        "0",
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  children: [
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape
                                                            .rectangle,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius
                                                                    .circular(
                                                                        30)),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal:
                                                                    10,
                                                                vertical: 3),
                                                        child: Text(
                                                          "${'Save'.tr} ${subscriptionData.discount}",
                                                          style: const TextStyle(
                                                              color: Colors
                                                                  .orangeAccent,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                      Row(children: [


                      ]),
                      const SizedBox(
                        height: 20,
                      ),

                    ],
                  ),
                ),
              ),
            );
          });

  }

  Future<void> initPlatformState(SubscriptionController controller,
      SubscriptionData subscriptionData) async {
    try {
      if (Platform.isAndroid) {
        await Purchases.purchaseProduct(
                subscriptionData.androidSubscriptionKey.toString())
            .then((value) async {
          log("-------->");
          log(value.toJson().toString());
          CustomerInfo customerInfo = value;
          CustomerSubscriptionModel customerSubscriptionModel =
              CustomerSubscriptionModel.fromJson(customerInfo.toJson());
          Constant.isActiveSubscription = customerSubscriptionModel
              .entitlements!.active!
              .toJson()
              .isNotEmpty;

          if (Constant.isActiveSubscription == true) {
            Map<String, String> bodyParams = {
              'user_id': Preferences.getString(Preferences.userId),
              'subscription_id': subscriptionData.id.toString(),
              'transaction_details':
                  jsonEncode(customerSubscriptionModel.toJson()),
            };
            await controller.sendSubscriptionData(bodyParams);
          }
        });
      } else if (Platform.isIOS) {
        await Purchases.purchaseProduct(
                subscriptionData.iosSubscriptionKey.toString())
            .then((value) async {
          log("-------->");
          log(value.toJson().toString());
          CustomerInfo customerInfo = value;
          CustomerSubscriptionModel customerSubscriptionModel =
              CustomerSubscriptionModel.fromJson(customerInfo.toJson());
          Constant.isActiveSubscription = customerSubscriptionModel
              .entitlements!.active!
              .toJson()
              .isNotEmpty;

          if (Constant.isActiveSubscription == true) {
            Map<String, String> bodyParams = {
              'user_id': Preferences.getString(Preferences.userId),
              'subscription_id': subscriptionData.id.toString(),
              'transaction_details':
                  jsonEncode(customerSubscriptionModel.toJson()),
            };
            await controller.sendSubscriptionData(bodyParams);
          }
        });
      }
    } on PlatformException catch (e) {
      //ShowToastDialog.showToast(e.message.toString().tr);
      // Error fetching customer info
    }
  }
}
