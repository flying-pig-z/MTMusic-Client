// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player_miao/common/color_extension.dart';
import 'package:music_player_miao/view/main_tab_view/main_tab_view.dart';

import '../../api/api_client.dart';
import '../../models/universal_bean.dart';
import '../../widget/my_text_field.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final confirmPSWController = TextEditingController();
  final confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  IconData iconPassword = CupertinoIcons.eye_fill;
  bool obscurePassword = true;
  bool signUpRequired = false;

  final _nameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _confirmPSWFocusNode = FocusNode();
  final _confirmFocusNode = FocusNode();

  // 添加计时器相关变量
  Timer? _timer;
  int _countDown = 60;
  bool _canSendCode = true;

  @override
  void dispose() {
    _timer?.cancel(); // 页面销毁时取消计时器
    super.dispose();
  }

  // 开始倒计时
  void startTimer() {
    setState(() {
      _canSendCode = false;
      _countDown = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countDown == 0) {
        setState(() {
          _canSendCode = true;
          timer.cancel();
        });
      } else {
        setState(() {
          _countDown--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: MyTextField(
                  controller: nameController,
                  hintText: '请输入用户名',
                  focusNode: _nameFocusNode,
                  obscureText: false,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Image.asset("assets/img/login_user.png"),
                  validator: (val) {
                    if (val!.isEmpty) {
                      return '输入不能为空！';
                    } else if (val.length > 30) {
                      return '用户名过长！';
                    }
                    return null;
                  }),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: MyTextField(
                  controller: emailController,
                  hintText: '请输入邮箱名',
                  obscureText: false,
                  focusNode: _emailFocusNode,
                  keyboardType: TextInputType.name,
                  prefixIcon: Image.asset("assets/img/setup_email.png"),
                  validator: (val) {
                    if (val!.isEmpty) {
                      return '输入不能为空！';
                    }
                    return null;
                  }),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: MyTextField(
                  controller: passwordController,
                  hintText: '请输入密码',
                  obscureText: obscurePassword,
                  focusNode: _passwordFocusNode,
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
                  validator: (val) {
                    if (val!.isEmpty) {
                      return '输入不能为空！';
                    } else if (val.length < 8) {
                      return '密码长度不能小于8';
                    }
                    return null;
                  }),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: MyTextField(
                  controller: confirmPSWController,
                  hintText: '请确认密码',
                  obscureText: obscurePassword,
                  focusNode: _confirmPSWFocusNode,
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
                  validator: (val) {
                    if (val!.isEmpty) {
                      return '输入不能为空！';
                    } else if (passwordController.text !=
                        confirmPSWController.text) {
                      return '请确保两次密码一致';
                    }
                    return null;
                  }),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.48,
                  // height: MediaQuery.of(context).size.width * 0.16,
                  child: MyTextField(
                      controller: confirmController,
                      hintText: '请输入验证码',
                      obscureText: false,
                      focusNode: _confirmFocusNode,
                      keyboardType: TextInputType.name,
                      prefixIcon: Image.asset("assets/img/setup_confirm.png"),
                      validator: (val) {
                        if (val!.isEmpty) {
                          return '输入不能为空！';
                        }
                        return null;
                      }),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.313,
                  height: MediaQuery.of(context).size.width * 0.13,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canSendCode ? MColor.LGreen : Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: _canSendCode
                        ? () async {
                      _nameFocusNode.unfocus();
                      _emailFocusNode.unfocus();
                      _passwordFocusNode.unfocus();
                      _confirmPSWFocusNode.unfocus();
                      _confirmFocusNode.unfocus();
                      UniversalBean bean = await SetupApiClient().verification(
                        email: emailController.text,
                      );

                      if (bean.code == 200) {
                        startTimer(); // 发送成功后开始倒计时
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Center(
                              child: Text(
                                '验证码发送成功',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            duration: const Duration(seconds: 2),
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
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Center(
                              child: Text(
                                '请检查邮箱',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0, // 设置字体大小
                                ),
                              ),
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.white,
                            elevation: 3,
                            // width: 220,
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
                    }
                        : null,
                    child: Text(
                      _canSendCode ? "获取" : "${_countDown}s后重试",
                      style: TextStyle(
                        color: _canSendCode ? Colors.black45 : Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: TextButton(
                  onPressed: () async {
                    _nameFocusNode.unfocus();
                    _emailFocusNode.unfocus();
                    _passwordFocusNode.unfocus();
                    _confirmPSWFocusNode.unfocus();
                    _confirmFocusNode.unfocus();
                    if (_formKey.currentState?.validate() == false) {
                      const Text(
                        '',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      );
                    }
                    if (nameController.text.isNotEmpty &&
                        emailController.text.isNotEmpty &&
                        passwordController.text.isNotEmpty &&
                        confirmPSWController.text.isNotEmpty &&
                        confirmController.text.isNotEmpty) {
                      UniversalBean bean = await SetupApiClient().register(
                          email: emailController.text,
                          password: passwordController.text,
                          username: nameController.text,
                          verificationCode: confirmController.text);
                      _showSuccessDialog(context,
                          title: bean.code == 200
                              ? 'assets/img/correct.png'
                              : 'assets/img/warning.png',
                          errorMessage:
                          bean.code == 200
                              ? '注册成功，一键登录'
                              : '注册失败，验证码错误');
                      if (bean.code == 200) Get.to(const MainTabView());
                    }
                  },
                  style: TextButton.styleFrom(
                      elevation: 3.0,
                      backgroundColor: MColor.LGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                    child: Text(
                      '确认',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w400),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context,
      {required String errorMessage, required String title}) {
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
          content: Text(errorMessage, textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Get.to(const MainTabView());
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xff429482),
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
