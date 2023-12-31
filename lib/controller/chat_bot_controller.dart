import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'dart:typed_data';
import 'package:logger/logger.dart';
import 'package:printing/printing.dart';
import 'package:sizer/sizer.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:byteai/constant/constant.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:byteai/constant/show_toast_dialog.dart';
import 'package:byteai/model/ai_responce_model.dart';
import 'package:byteai/model/characters_model.dart';
import 'package:byteai/model/chat.dart';
import 'package:byteai/model/chat_history_model.dart';
import 'package:byteai/model/guest_model.dart';
import 'package:byteai/model/reset_limit_model.dart';
import 'package:byteai/model/user_model.dart';
import 'package:byteai/service/api_services.dart';
import 'package:byteai/utils/Preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

//
class ChatBotController extends GetxController {
  RxList<Color> color = [
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.redAccent,
    Colors.yellowAccent,
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.redAccent,
    Colors.yellowAccent
  ].obs;
  RxList<int> duration = [900, 700, 600, 800, 500, 400, 800, 300].obs;

  final scrollController = ScrollController();

  void scrollDown() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  RxBool isBannerLoaded = true.obs;
  RxBool isLoading = true.obs;
  RxBool isBeingConverted = true.obs;
  late Rx<Uint8List> PDF = Uint8List(1).obs;
  RxBool converting = true.obs;
  RxBool doneListening = false.obs;
  RxBool isWorking = false.obs;
  RxString message = 'Bonjour'.obs;
  TextToSpeech tts = TextToSpeech();
  Rx<String> initialHello = "".obs;

  RxList chatList = <Chat>[].obs;
  Rx<TextEditingController> messageController = TextEditingController().obs;
  RxBool isClickable = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit

    loadAd();
    loadRewardAd();
    getUser();
    getArgument();
    sayInstructions();

    messageController.value.text = 'bonjour';
    // chatLimit.value = '10';
    super.onInit();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    initSpeechToText();
  }

  RewardedAd? rewardedAd;

  loadRewardAd() {
    RewardedAd.load(
        adUnitId: Constant().getRewardAdUnitId().toString(),
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            log('$ad loaded.');
            log('$ad loaded.');
            rewardedAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            log('RewardedAd failed to load: $error');
            rewardedAd = null;
            loadAd();
          },
        ));
  }

  Future<void> sayInstructions() async {
    Locale deviceLocale = window.locale;
    String langCode = deviceLocale.languageCode;

    if (langCode == "fr") {
      tts.setLanguage("fr-FR");
      initialHello.value =
          "Bonjour, comment puis-je vous aider aujourd'hui, commencez votre phrase par convertir afin que je puisse convertir votre document en pdf pour vous";
    } else {
      tts.setLanguage("en-US");
      initialHello.value =
          "hello, how can i help you today. start your sentence with convert so i can convert your document to a pdf.";
    }
    await tts.setPitch(1.0);
    await tts.setRate(1.0);

    await tts.speak(initialHello.value);
  }

  BannerAd? bannerAd;
  RxBool bannerAdIsLoaded = false.obs;

  loadAd() {
    try {
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
    } catch (e) {
      debugPrint(Constant().getBannerAdUnitId().toString());
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
  }

  Rx<CharactersData?> selectedCharacter = CharactersData().obs;

  getArgument() {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      selectedCharacter.value = argumentData["charactersData"];
    }
  }

  RxString chatLimit = "0".obs;
  Rx<UserModel> userModel = UserModel().obs;
  Rx<GuestModel> guestUserModel = GuestModel().obs;

  getUser() {
    if (Preferences.getBoolean(Preferences.isLogin)) {
      userModel.value = Constant.getUserData();
      chatLimit.value = userModel.value.data!.chatLimit.toString();
    } else {
      guestUserModel.value = Constant.getGuestUser();
      chatLimit.value = guestUserModel.value.data!.chatLimit.toString();
    }
  }

  Future<dynamic> getChat() async {
    try {
      Map<String, dynamic> bodyParams = {
        'user_id': Preferences.getString(Preferences.userId)
      };
      final response = await http.post(Uri.parse(ApiServices.getChatHistory),
          headers: ApiServices.header, body: jsonEncode(bodyParams));
      log(response.request.toString());
      log(response.body);
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "Success") {
        isLoading.value = false;
        ChatHistoryModel model = ChatHistoryModel.fromJson(responseBody);
        chatList.value = model.data!;
        Future.delayed(const Duration(milliseconds: 50))
            .then((_) => scrollDown());
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        chatList.clear();
        isLoading.value = false;
      } else {
        isLoading.value = false;
        ShowToastDialog.showToast(
            'Something want wrong. Please try again later'.tr);
        throw Exception('Failed to load album');
      }
    } on TimeoutException catch (e) {
      isLoading.value = false;
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      isLoading.value = false;
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      isLoading.value = false;
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future saveChat(String chat, String msg) async {
    try {
      Map<String, String> bodyParams = {
        'user_id': Preferences.getString(Preferences.userId),
        'chat': chat,
        'msg': msg,
      };
      final response = await http.post(Uri.parse(ApiServices.saveChatHistory),
          headers: ApiServices.header, body: jsonEncode(bodyParams));
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

  Future sendResponse(String message) async {
    try {
      Map<String, dynamic> bodyParams = {
        'model': 'gpt-3.5-turbo',
        'messages': [
          {"role": "user", "content": message}
        ],
      };
      final response = await http.post(Uri.parse(ApiServices.completions),
          headers: ApiServices.headerOpenAI, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody =
          json.decode(utf8.decode(response.bodyBytes));

      Logger().i(responseBody);

      if (response.statusCode == 200) {
        AiResponceModel aiResponceModel =
            AiResponceModel.fromJson(responseBody);
        if (aiResponceModel.choices != null &&
            aiResponceModel.choices!.isNotEmpty) {
          Chat chat = Chat(
              msg: aiResponceModel.choices!.first.message!.content.toString(),
              chat: "1");
          chatList.add(chat);
          messageController.value.clear();

          if (Constant.isActiveSubscription == false) {
            if (Preferences.getBoolean(Preferences.isLogin)) {
              await resetChatLimit();
              await saveChat("0", message);
              await saveChat("1",
                  aiResponceModel.choices!.first.message!.content.toString());
            } else {
              await resetGuestChatLimit();
            }
          } else {
            if (Preferences.getBoolean(Preferences.isLogin)) {
              await saveChat("1",
                  aiResponceModel.choices!.first.message!.content.toString());
            }
          }

          Future.delayed(const Duration(milliseconds: 50))
              .then((_) => scrollDown());
        } else {
          ShowToastDialog.showToast('Resource not found.'.tr);
        }

        return aiResponceModel.choices!.first.message!.content.toString();
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

  Future<ResetLimitModel?> resetChatLimit() async {
    try {
      Map<String, String> bodyParams = {
        'user_id': Preferences.getString(Preferences.userId),
        'type': 'chat',
      };
      final response = await http.post(Uri.parse(ApiServices.resetLimit),
          headers: ApiServices.header, body: jsonEncode(bodyParams));

      log(response.request.toString());
      log(response.body);
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "Success") {
        ResetLimitModel resetLimitModel =
            ResetLimitModel.fromJson(responseBody);
        await Constant().getUser();
        getUser();
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

  Future<ResetLimitModel?> resetGuestChatLimit() async {
    try {
      Map<String, String> bodyParams = {
        'device_id': Preferences.getString(Preferences.deviceId),
        'type': 'chat',
      };
      ShowToastDialog.showLoader('Please wait'.tr);
      final response = await http.post(Uri.parse(ApiServices.guestResetLimit),
          headers: ApiServices.header, body: jsonEncode(bodyParams));

      log(response.request.toString());
      log(response.body);
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "Success") {
        ResetLimitModel resetLimitModel =
            ResetLimitModel.fromJson(responseBody);
        await Constant().getGuestUserAPI();
        getUser();
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

  Future<dynamic> increaseLimit() async {
    ShowToastDialog.showToast("Please wait");
    try {
      Map<String, dynamic> bodyParams = {
        'user_type':
            Preferences.getBoolean(Preferences.isLogin) ? "app" : "guest",
        'user_id': Preferences.getBoolean(Preferences.isLogin)
            ? Preferences.getString(Preferences.userId)
            : "",
        'device_id': Preferences.getBoolean(Preferences.isLogin) == false
            ? Preferences.getString(Preferences.deviceId)
            : "",
      };

      log(bodyParams.toString());
      final response = await http.post(
          Uri.parse(ApiServices.adsSeenLimitIncrease),
          headers: ApiServices.authHeader,
          body: jsonEncode(bodyParams));
      log(response.request.toString());
      log(response.body);
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "Success") {
        ShowToastDialog.closeLoader();
        if (Preferences.getBoolean(Preferences.isLogin)) {
          await Constant().getUser();
        } else {
          await Constant().getGuestUserAPI();
        }
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
      } else {
        ShowToastDialog.showToast(
            'Something want wrong. Please try again later'.tr);
        ShowToastDialog.closeLoader();
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
      log('FireStoreUtils.getCurrencys Parse error $e');
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Rx<stt.SpeechToText> speech = stt.SpeechToText().obs;
  Rx<FlutterTts> flutterTts = FlutterTts().obs;
  RxDouble value = 0.0.obs;
  Rx<Chat> chatItem = Chat(msg: '', chat: '').obs;

  initSpeechToText() async {
    try {
      await speech.value
          .initialize(onStatus: statusListener, onError: errorListner);
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    }
  }

  speechDown() async {
    converting.value = true;
    isLoading.value = true;

    final pdf = pw.Document();

    Locale deviceLocale = window.locale; // or html.window.locale
    String langCode = deviceLocale.languageCode;

    if (!speech.value.isListening) {
      try {
        tts.stop();
        tts.setPitch(1.0);
        tts.setRate(1.0);
        if (langCode == "en") {
          tts.setLanguage("en-US");
        } else {
          tts.setLanguage("fr-FR");
        }

        speech.value.listen(onResult: (v) async {
          Logger().i(speech.value.lastStatus);
          messageController.value.text = v.recognizedWords.toString();
          message.value = messageController.value.text;
          Logger().i(messageController.value.text);
          if (speech.value.lastStatus == "notListening" &&
              messageController.value.text.isNotEmpty) {
            isWorking.value = true;
            var responseMessage = await sendResponse(
                messageController.value.text.replaceAll("convert", "make"));
            if (message.split(" ")[0] == "convert" ||
                message.split(" ")[0] == "convertir" ||
                message.split(" ")[0] == "write" ||
                message.split(" ")[0] == "ecrire") {
              if (langCode == "en") {
                tts.speak("your document is being converted");
              } else {
                tts.speak("votre document est en cours de conversion");
              }
              final netImage = await networkImage(
                  'https://images.unsplash.com/photo-1692200929451-15654e4c611d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2080&q=80');
              pdf.addPage(
                pw.Page(build: (pw.Context context) {
                  return pw.Text(responseMessage);
                }),
              );

              PDF.value = await pdf.save();
              isLoading.value = false;
              isWorking.value = false;
              //final file = File('${appDocumentsDir.toString().replaceAll("'", "")}');
              //await file.writeAsBytes(await pdf.save(), mode: FileMode.write);
            } else {
              converting.value = false;
              isBeingConverted.value = false;
              isLoading.value = false;
              Logger().i(responseMessage);
              message.value = responseMessage;
              tts.speak(responseMessage);
              isWorking.value = false;
            }
          } else if (messageController.value.text.isEmpty) {
            doneListening.value = true;
          }
        });
      } catch (e) {
        ShowToastDialog.showToast(e.toString());
      }
    } else {
      speech.value.stop();
      update();
    }
  }

  void errorListner(v) {
    update();
  }

  void statusListener(String v) {
    update();
    // if (v.contains('listening')) {
    //   update();
    // } else if (v.contains('done')) {
    //   update();
    // }
  }

  Future speak({required Chat speechText, required int index}) async {
    flutterTts.value = FlutterTts();
    flutterTts.value.setSpeechRate(0.5);
    flutterTts.value.setVolume(1.0);
    flutterTts.value.setPitch(0.1);
    await flutterTts.value.speak(speechText.msg.toString());
    flutterTts.value.setCompletionHandler(() {
      chatList[index].active = false;
      update();
    });
  }

  updateIcon() {
    for (var element in chatList) {
      element.active = false;
    }
    flutterTts.value.stop();
    speech.value = stt.SpeechToText();
    update();
  }

  @override
  void onClose() {
    super.onClose();
    flutterTts.value.stop();
    flutterTts.value = FlutterTts();
    speech.value.stop();
    bannerAd?.dispose();
  }

  Future<void> deleteChatHistory() async {
    try {
      Map<String, String> bodyParams = {
        'user_id': Preferences.getString(Preferences.userId),
      };
      ShowToastDialog.showLoader('Please wait'.tr);
      final response = await http.post(Uri.parse(ApiServices.deleteChatHistory),
          headers: ApiServices.header, body: jsonEncode(bodyParams));

      log(response.request.toString());
      log(response.body);
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "Success") {
        ShowToastDialog.closeLoader();
        chatList.clear();
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
}
