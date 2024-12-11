// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player_miao/common_widget/app_data.dart';
import 'package:music_player_miao/view/main_tab_view/main_tab_view.dart';

import '../../api/api_client.dart';
import '../../common/color_extension.dart';
import '../../common/password_manager.dart';
import '../../models/getInfo_bean.dart';
import '../../models/login_bean.dart';
import '../../widget/my_text_field.dart';

class LoginV extends StatefulWidget {
  const LoginV({super.key});

  @override
  State<LoginV> createState() => _LoginVState();
}

class _LoginVState extends State<LoginV> {
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool signInRequired = false;
  IconData iconPassword = CupertinoIcons.eye_fill;
  bool obscurePassword = true;

  final _passwordFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 30),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: MyTextField(
                    controller: nameController,
                    hintText: '请输入账号',
                    focusNode: _nameFocusNode,
                    obscureText: false,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Image.asset("assets/img/login_user.png"))),
            const SizedBox(height: 15),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: Center(
                child: MyTextField(
                  controller: passwordController,
                  hintText: '请输入密码',
                  focusNode: _passwordFocusNode,
                  obscureText: obscurePassword,
                  keyboardType: TextInputType.visiblePassword,
                  prefixIcon: Image.asset("assets/img/login_lock.png"),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                        if (obscurePassword) {
                          iconPassword = CupertinoIcons.eye_fill;
                        } else {
                          iconPassword = CupertinoIcons.eye_slash_fill;
                        }
                      });
                    },
                    icon: Icon(
                      iconPassword,
                      color: MColor.DGreen,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            !signInRequired
                ? SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: TextButton(
                        onPressed: () async {
                          try {
                            _nameFocusNode.unfocus();
                            _passwordFocusNode.unfocus();
                            Get.dialog(
                              Center(
                                child: CircularProgressIndicator(
                                  color: const Color(0xff429482),
                                  backgroundColor: Colors.grey[200],
                                ),
                              ),
                              barrierDismissible: false, // 防止用户点击背景关闭
                            );

                            LoginBean bean = await LoginApiClient().login(
                              email: nameController.text,
                              password: passwordController.text,
                            );
                            if (bean.code == 200) {
                              await PasswordManager.instance.saveCredentials(
                                  nameController.text,
                                  passwordController.text
                              );
                              Get.back();
                              Get.off(() => const MainTabView());
                              GetInfoBean bean1 = await GetInfoApiClient()
                                  .getInfo(
                                      Authorization: AppData().currentToken);
                            } else {
                              throw Exception("账号或密码错误");
                            }
                          } catch (error) {
                            Get.back();
                            print(error.toString());
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Center(
                                  child: Text(
                                    error.toString().replaceAll ('Exception: ', ''),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0, // 设置字体大小
                                    ),
                                  ),
                                ),
                                duration: const Duration(seconds: 3),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.white,
                                elevation: 3,
                                margin: EdgeInsets.only(
                                  bottom: 50,  // 距离底部50像素
                                  right: (MediaQuery.of(context).size.width - 200) / 2,  // 水平居中
                                  left: (MediaQuery.of(context).size.width - 200) / 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                            elevation: 3.0,
                            backgroundColor: MColor.LGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          child: Text(
                            '确认',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w400),
                          ),
                        )),
                  )
                : const CircularProgressIndicator(),
          ],
        ));
  }

  void _showDialog(BuildContext context,
      {required String title, required String message}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Image.asset(
            title,
            width: 47,
            height: 46,
          ),
          content: Text(message, textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                backgroundColor: MColor.DGreen,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(5.0), // Adjust the radius as needed
                ),
              ),
              child: const Text(
                '确认',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
