import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_player_miao/common/color_extension.dart';
import 'package:music_player_miao/view/begin/login_v.dart';
import 'package:music_player_miao/view/begin/setup_view.dart';

class BeginView extends StatefulWidget {
  const BeginView({super.key});

  @override
  State<BeginView> createState() => _BeginViewState();
}

class _BeginViewState extends State<BeginView> with TickerProviderStateMixin {
  late TabController tabController;
  DateTime? _lastPressedAt; // 添加上次点击时间记录

  @override
  void initState() {
    tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        FocusScope.of(context).unfocus();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_lastPressedAt == null ||
            DateTime.now().difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = DateTime.now();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                '再按一次退出程序',
                style: TextStyle(color: Colors.black87),
              ),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.white,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.1,
                left: 125,
                right: 125,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 6,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
          );
          return false;
        }
        SystemNavigator.pop();
        return false;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/img/app_bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(
                physics: const NeverScrollableScrollPhysics(),
              ),
              child: Column(
                children: [
                  // 顶部欢迎部分
                  Padding(
                    padding:
                    const EdgeInsets.only(top: 110, left: 40, right: 40),
                    child: Row(
                      children: [
                        const Column(
                          children: [
                            Text(
                              "你好吖喵星来客,",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500),
                            ),
                            Row(
                              children: [
                                Text(
                                  "欢迎来到",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "喵听",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(width: 25),
                        Image.asset("assets/img/app_logo.png", width: 80),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 剩余部分使用 Expanded
                  Expanded(
                    child: Column(
                      children: [
                        // TabBar部分
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Material(
                            color: Colors.white,
                            elevation: 3,
                            borderRadius: BorderRadius.circular(10),
                            child: TabBar(
                              controller: tabController,
                              unselectedLabelColor: const Color(0xffCDCDCD),
                              labelColor: Colors.black,
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicator: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: MColor.LGreen),
                              tabs: [
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: const Text(
                                    '登录',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: const Text(
                                    '注册',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // TabBarView部分
                        Expanded(
                          child: TabBarView(
                            controller: tabController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: const [
                              LoginV(),
                              SignUpView(),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}