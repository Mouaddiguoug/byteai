import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:byteai/constant/constant.dart';
import 'package:byteai/constant/show_toast_dialog.dart';
import 'package:byteai/model/user_model.dart';
import 'package:byteai/service/api_services.dart';

class ProfileUpdationController extends GetxController {
  final formKey = GlobalKey<FormState>().obs;

  Rx<String> name = "".obs;
  Rx<String> email = "".obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getUser();
    super.onInit();
  }

  Rx<UserModel> userModel = UserModel().obs;

  getUser() {
    userModel.value = Constant.getUserData();
    name.value = userModel.value.data!.name.toString();
    email.value = userModel.value.data!.email.toString();
  }

  Future<bool?> updateProfile(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader('Please wait'.tr);
      final response = await http.post(Uri.parse(ApiServices.updateProfile),
          headers: ApiServices.header, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody = json.decode(response.body);

      log(responseBody.toString());
      if (response.statusCode == 200 && responseBody['success'] == "Success") {
        ShowToastDialog.closeLoader();
        return true;
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
