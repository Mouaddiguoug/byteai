import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:byteai/constant/constant.dart';
import 'package:byteai/constant/show_toast_dialog.dart';
import 'package:byteai/model/ai_responce_model.dart';
import 'package:byteai/model/category_model.dart';
import 'package:byteai/model/reset_limit_model.dart';
import 'package:byteai/service/api_services.dart';
import 'package:byteai/utils/Preferences.dart';

class WriterDetailsController extends GetxController {
  RxString question = "".obs;
  RxString answer = "".obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    loadAd();
    super.onInit();
  }

  BannerAd? bannerAd;
  RxBool bannerAdIsLoaded = false.obs;
  InterstitialAd? interstitialAd;

  loadAd() {
    InterstitialAd.load(
        adUnitId: Constant().getInterstitialAdUnitId().toString(),
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            log('$ad loaded');
            interstitialAd = ad;
            interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            log('InterstitialAd failed to load: $error.');
            interstitialAd = null;
          },
        ));

    bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: Constant().getBannerAdUnitId().toString(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            log('$BannerAd loaded.');
            bannerAdIsLoaded.value = true;
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            log('$BannerAd failedToLoad: $error');
            ad.dispose();
          },
          onAdOpened: (Ad ad) => log('$BannerAd onAdOpened.'),
          onAdClosed: (Ad ad) => log('$BannerAd onAdClosed.'),
        ),
        request: const AdRequest())
      ..load();
  }

  Rx<CategoryData> categoryData = CategoryData().obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      question.value = argumentData["pramot"];
      categoryData.value = argumentData["category"];
      sendResponse(question.value);
    }
  }

  Future sendResponse(String message) async {
    try {
      ShowToastDialog.showLoader('Please wait'.tr);

      Map<String, dynamic> bodyParams = {
        'model': 'gpt-3.5-turbo',
        'messages': [
          {"role": "user", "content": message}
        ],
      };

      final response = await http.post(Uri.parse(ApiServices.completions),
          headers: ApiServices.headerOpenAI, body: jsonEncode(bodyParams));
      log(response.statusCode.toString());
      log(response.body);
      Map<String, dynamic> responseBody =
          json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        ShowToastDialog.closeLoader();

        AiResponceModel aiResponceModel =
            AiResponceModel.fromJson(responseBody);
        if (aiResponceModel.choices != null &&
            aiResponceModel.choices!.isNotEmpty) {
          answer.value =
              aiResponceModel.choices!.first.message!.content.toString();

          if (Constant.isActiveSubscription == false) {
            if (Preferences.getBoolean(Preferences.isLogin)) {
              await savePrompt();
              await resetWriterLimit();
            } else {
              await resetGuestWriterLimit();
            }
          } else {
            if (Preferences.getBoolean(Preferences.isLogin)) {
              await savePrompt();
            }
          }
        } else {
          ShowToastDialog.showToast('Resource not found.'.tr);
        }
        update();
      } else {
        Map<String, dynamic> responseBody = json.decode(response.body);

        ShowToastDialog.closeLoader();
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future savePrompt() async {
    try {
      Map<String, String> bodyParams = {
        'user_id': Preferences.getString(Preferences.userId),
        'category_id': categoryData.value.id.toString(),
        'category_name': categoryData.value.name.toString(),
        'subject': question.value,
        'answer': answer.value,
      };
      final response = await http.post(Uri.parse(ApiServices.savePromsHistory),
          headers: ApiServices.header, body: jsonEncode(bodyParams));

      log(response.body);
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "Success") {
        return true;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
      } else {
        ShowToastDialog.showToast(
            'Something want wrong. Please try again later'.tr);
        throw Exception('Failed to load album');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<ResetLimitModel?> resetWriterLimit() async {
    try {
      Map<String, String> bodyParams = {
        'user_id': Preferences.getString(Preferences.userId),
        'type': 'writer',
      };
      ShowToastDialog.showLoader('Please wait'.tr);
      final response = await http.post(Uri.parse(ApiServices.resetLimit),
          headers: ApiServices.header, body: jsonEncode(bodyParams));

      log(response.body);
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "Success") {
        ResetLimitModel resetLimitModel =
            ResetLimitModel.fromJson(responseBody);
        await Constant().getUser();
        ShowToastDialog.closeLoader();
        return resetLimitModel;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            'Something want wrong. Please try again later'.tr);
        throw Exception('Failed to load album');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<ResetLimitModel?> resetGuestWriterLimit() async {
    try {
      Map<String, String> bodyParams = {
        'device_id': Preferences.getString(Preferences.deviceId),
        'type': 'writer',
      };
      ShowToastDialog.showLoader('Please wait'.tr);
      final response = await http.post(Uri.parse(ApiServices.guestResetLimit),
          headers: ApiServices.header, body: jsonEncode(bodyParams));

      log(response.body);
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "Success") {
        ResetLimitModel resetLimitModel =
            ResetLimitModel.fromJson(responseBody);
        await Constant().getGuestUserAPI();
        ShowToastDialog.closeLoader();
        return resetLimitModel;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            'Something want wrong. Please try again later'.tr);
        throw Exception('Failed to load album');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Rx<FlutterTts> flutterTts = FlutterTts().obs;
  RxBool textToSpeechQuesion = false.obs;
  RxBool textToSpeechAnswer = false.obs;
  Future speak({required String speechText}) async {
    flutterTts.value = FlutterTts();
    flutterTts.value.setSpeechRate(0.5);
    flutterTts.value.setVolume(1.0);
    flutterTts.value.setPitch(0.1);
    await flutterTts.value.speak(speechText);
    flutterTts.value.setCompletionHandler(() {
      textToSpeechQuesion.value = false;
      textToSpeechAnswer.value = false;
      update();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    flutterTts.value.stop();
    flutterTts.value = FlutterTts();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    flutterTts.value.stop();
    flutterTts.value = FlutterTts();
  }
}
