import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
class UserViewModel extends GetxController {
  RxString _nickname = "默认昵称".obs;

  String get nickname => _nickname.value;

  void setNickname(String newNickname) {
    _nickname.value = newNickname;
  }
}
