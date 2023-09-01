import 'package:byteai/res/assets_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:byteai/model/onboarding_model.dart';

class OnBoardingController extends GetxController {
  var selectedPageIndex = 0.obs;

  bool get isLastPage => selectedPageIndex.value == onBoardingList.length - 1;
  var pageController = PageController();

  List<OnboardingModel> onBoardingList = [
    OnboardingModel(
        AssetsRes.ONBOARDING,
        'ByteAi is intended to boost your productivity by quick access to information.'
            .tr,
        'Your AI assistant'.tr),

  ];
}
