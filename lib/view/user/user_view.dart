import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player_miao/api/api_songlist.dart';
import 'package:music_player_miao/common_widget/app_data.dart';
import 'package:music_player_miao/models/songlist_bean.dart';
import 'package:music_player_miao/models/universal_bean.dart';
import 'package:music_player_miao/view/begin/begin_view.dart';
import 'package:music_player_miao/view/mycollection_view.dart';
import 'package:music_player_miao/view/mylike_view.dart';
import 'package:music_player_miao/view/user/my_download_view.dart';
import 'package:music_player_miao/view/user/my_music_view.dart';
import 'package:music_player_miao/view/user/user_info.dart';
import 'package:music_player_miao/widget/text_field.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../view_model/home_view_model.dart';
import '../../api/api_client.dart';
import '../../common/audio_player_controller.dart';
import '../../common/download_count_controller.dart';
import '../../common/download_manager.dart';
import '../../common/password_manager.dart';
import '../../models/search_bean.dart';
import 'my_work_view.dart';
import 'my_likes_view.dart';
import 'package:music_player_miao/api/api_music_likes_list.dart';  // 点赞列表API
import 'package:music_player_miao/models/getLikeList_bean.dart';   // 点赞列表数据模型

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver  {
  final homeVM = Get.put(HomeViewModel());
  final TextEditingController _controller = TextEditingController();
  int playlistCount = 0;
  List playlistNames = [];
  List<int> playlistid = [];
  List<int> playListSongsNum = [];
  int downloadCount = 0;
  String avatar = AppData().currentAvatar;
  String username = AppData().currentUsername;
  final audioController = Get.find<AudioPlayerController>();
  int likesCount = 0;
  final downloadManager = Get.put(DownloadManager());
  final downloadCountController = Get.put(DownloadCountController());
  bool _isVisible = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeData();

  }

  @override
  void dispose() {
    // 移除观察者
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isVisible) {
      _fetchSonglistData();
      _fetchLikesCount();
      downloadCountController.refreshCount(downloadManager);
    }
  }

  void _onVisibilityChanged(bool visible) {
    if (visible && visible != _isVisible) {
      // 页面变为可见时刷新数据
      _fetchSonglistData();
      _fetchLikesCount();
      downloadCountController.refreshCount(downloadManager);
    }
    _isVisible = visible;
  }

  Future<void> _initializeData() async {
    await _fetchSonglistData();
    await _fetchLikesCount();
    downloadCountController.refreshCount(downloadManager);
    downloadCount = downloadManager.completedNumber();
  }

  Future<void> _fetchSonglistData() async {
    try {
      SearchBean bean2 = await SonglistApi().getSonglist(
        Authorization: AppData().currentToken,
      );

      if (!mounted) return;

      // 提取新数据
      final List newNames = bean2.data!.map((data) => data.name!).toList();
      final List<int> newIds = bean2.data!.map((data) => data.id!).toList();
      final List<int> newSongsNum = bean2.data!.map((data) => data.musicCount!).toList();

      // 检查是否有数据变化
      bool hasChanges = false;

      // 长度不同，一定有变化
      if (playlistNames.length != newNames.length) {
        hasChanges = true;
      } else {
        // 长度相同，逐一比较每个元素
        for (int i = 0; i < newNames.length; i++) {
          if (playlistNames[i] != newNames[i] ||
              playlistid[i] != newIds[i] ||
              playListSongsNum[i] != newSongsNum[i]) {
            hasChanges = true;
            break;
          }
        }
      }

      // 只有在数据真正变化时才更新状态
      if (hasChanges) {
        setState(() {
          playlistNames = newNames;
          playlistid = newIds;
          playListSongsNum = newSongsNum;
          playlistCount = playlistNames.length;
        });
      }
    } catch (error) {
      print('Error fetching songlist data: $error');
    }
  }

  Future<void> _fetchLikesCount() async {
    try {
      LikeListBean response = await LikesListApi().getUserLikesList(
        Authorization: AppData().currentToken,
      );

      if (response.code == 200 && response.data != null && mounted) {
        final newLikesCount = response.data!.length;
        if (newLikesCount != likesCount) {
          setState(() {
            likesCount = newLikesCount;
          });
        }
      }
    } catch (error) {
      print('Error fetching likes count: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return VisibilityDetector(
      key: const Key('user-view'),
      onVisibilityChanged: (VisibilityInfo info) {
        _onVisibilityChanged(info.visibleFraction > 0);
      },
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/img/app_bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 55),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///头部--头像、昵称、下弹框
                  Padding(
                    padding:
                    const EdgeInsets.only(left: 15, right: 10, bottom: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                avatar,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(
                              width: 25,
                            ),
                            Text(
                              username,
                              style: const TextStyle(fontSize: 20),
                            )
                          ],
                        ),
                        IconButton(
                            onPressed: () {
                              _bottomSheet(context);
                            },
                            icon: Image.asset("assets/img/user_more.png"))
                      ],
                    ),
                  ),

                  ///我的音乐库
                  const Text(
                    '我的音乐库',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  Container(
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, top: 20, bottom: 20),

                      //我的收藏，点赞，下载
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // 我的点赞
                          InkWell(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyLikesView(),
                                ),
                              );

                              if (result == true) {
                                _fetchLikesCount();
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset("assets/img/artist_pic.png"),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "我的点赞",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    Text(
                                      "$likesCount首",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 80),
                                Image.asset("assets/img/user_next.png")
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          // 我的收藏
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const MyCollectionView(), //进入我的收藏界面
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset("assets/img/artist_pic.png"),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "我的收藏",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    Text(
                                      "19首",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 80,
                                ),
                                Image.asset(
                                  "assets/img/user_next.png",
                                )
                              ],
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          //我的收藏和本地下载分界
                          InkWell(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyDownloadView(),
                                ),
                              );

                              if (result == true) {
                                Get.find<DownloadCountController>().refreshCount(downloadManager);
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset("assets/img/artist_pic.png"),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "本地下载",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    Obx(() => Text(
                                      '${downloadCountController.downloadCount}首',
                                      style: TextStyle(fontSize: 16),
                                    )),
                                  ],
                                ),
                                const SizedBox(
                                  width: 80,
                                ),
                                Image.asset(
                                  "assets/img/user_next.png",
                                )
                              ],
                            ),
                          ),
                        ],
                      )),

                  ///歌单
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 歌单标题行
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '歌单 $playlistCount',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      _showAddPlaylistDialog();
                                    },
                                    icon: Image.asset(
                                      "assets/img/user_add.png",
                                      width: 31,
                                      color: const Color(0xff404040),
                                    )
                                ),
                              ],
                            )
                          ],
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        // 歌单列表
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            children: List.generate(
                              playlistNames.length,
                                  (index) => Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      print('点击成功');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MyMusicView(
                                              songlistIdd: playlistid[index]
                                          ),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Image.asset("assets/img/artist_pic.png"),
                                        const SizedBox(width: 25),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                playlistNames[index],
                                                style:
                                                const TextStyle(fontSize: 20),
                                              ),
                                              Text(
                                                '${playListSongsNum[index]}首',
                                                style:
                                                const TextStyle(fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Image.asset("assets/img/user_next.png"),
                                      ],
                                    ),
                                  ),
                                  if (index < playlistNames.length - 1)
                                    const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  const Text(
                    '已发布音乐',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  Container(
                      padding: const EdgeInsets.only(
                          left: 15, right: 20, top: 20, bottom: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyWorkView(),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset("assets/img/artist_pic.png"),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "我的作品",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    Text(
                                      "10首",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 80,
                                ),
                                Image.asset(
                                  "assets/img/user_next.png",
                                )
                              ],
                            ),
                          ),
                        ],
                      )),
                  const SizedBox(
                    height: 120,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///下弹框--退出，个人信息修改
  Future _bottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      isScrollControlled: true, // 设置弹出框根据内容高度自适应
      builder: (context) => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 使Column高度适应内容
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        bool result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserInfo(),
                          ),
                        );
                        if (result) {
                          setState(() {
                            avatar = AppData().currentAvatar;
                            username = AppData().currentUsername;
                          });
                        }
                      },
                      icon: Image.asset("assets/img/user_infor.png"),
                      iconSize: 60,
                    ),
                    const Text("账户信息")
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () async {
                        AppData().currentToken = '';
                        AppData().currentUsername = '';
                        AppData().currentAvatar = '';
                        audioController.pause();
                        Navigator.pop(context);
                        await PasswordManager.instance.clearCredentials();
                        Get.to(const BeginView());
                        await LogoutApiClient().logout(
                          Authorization: AppData().currentToken,
                        );
                      },
                      icon: Image.asset("assets/img/user_out.png"),
                      iconSize: 60,
                    ),
                    const Text("退出登录")
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  ///弹出框--添加歌单
  void _showAddPlaylistDialog() {
    _controller.clear();
    showDialog(
      context: context,
      barrierDismissible: false,  // 防止点击空白区域关闭对话框
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              "新建歌单",
              style: TextStyle(fontSize: 20),
            ),
          ),
          content: TextFieldColor(controller: _controller, hintText: '请输入歌单名称'),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "取消",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      if (_controller.text.trim().isEmpty) {
                        _showErrorMessage("歌单名称不能为空");
                        return;
                      }

                      String enteredSongName = _controller.text;
                      UniversalBean bean = await SonglistApi().addSonglist(
                          songlistName: enteredSongName,
                          Authorization: AppData().currentToken);

                      if (bean.code == 200) {
                        _fetchSonglistData();
                        Navigator.of(context).pop();
                        _showErrorMessage("创建成功");

                      } else {
                        _showErrorMessage(bean.msg == "java.lang.RuntimeException: 重复添加歌单" ? "已存在，请不要重复添加" : "创建歌单失败");
                      }
                    },
                    child: const Text(
                      "确认",
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xff429482),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  ///删除
  Future<bool> _showDeleteConfirmationDialog(
      BuildContext context, int index) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Image.asset(
            "assets/img/warning.png",
            width: 47,
            height: 46,
          ),
          content: const Text(
            "确认删除?",
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xff429482),
                minimumSize: const Size(130, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              child: const Text(
                "取消",
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
                UniversalBean bean = await SonglistApi().delSonglist(
                  Authorization: AppData().currentToken,
                  id: playlistid[index],
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xff429482),
                minimumSize: const Size(130, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              child: const Text(
                "确认",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    return confirmDelete == true;
  }
}
