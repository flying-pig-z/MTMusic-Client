import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:music_player_miao/view/rank_view.dart';
import 'package:music_player_miao/view/user/user_view.dart';
import '../../common/audio_player_controller.dart';
import '../home_view.dart';
import '../release_view.dart';
import '../song_recommendation_view.dart';

// 迷你播放器组件
class MiniPlayer extends StatelessWidget {
  MiniPlayer({super.key}) : audioController = Get.find<AudioPlayerController>();

  final AudioPlayerController audioController;

  void _showPlaylist(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.only(top: 15),
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(bottom: 10),
                child: const Center(
                  child: Text(
                    "播放列表",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  child: Obx(() => ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: audioController.musicNames.length,
                        itemBuilder: (BuildContext context, int index) {
                          final isCurrentlyPlaying =
                              audioController.currentSongIndex.value == index;
                          return Container(
                            decoration: BoxDecoration(
                              color: isCurrentlyPlaying
                                  ? const Color(0xffE3F0ED)
                                  : Colors.white,
                            ),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      audioController.musicNames[index],
                                      style: const TextStyle(fontSize: 18),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isCurrentlyPlaying)
                                    Image.asset(
                                      "assets/img/songs_run.png",
                                      width: 25,
                                    ),
                                ],
                              ),
                              onTap: () {
                                audioController.changeSong(index);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      )),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayButton() {
    return SizedBox(
      width: 52,
      height: 52,
      child: Center(
        child: Obx(() {
          // 先检查歌单是否为空
          if (audioController.songList.isEmpty) {
            return IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 42,
                minHeight: 42,
                maxWidth: 42,
                maxHeight: 42,
              ),
              onPressed: null, // 禁用按钮
              icon: Image.asset(
                "assets/img/music_pause.png",
                width: 25,
                height: 25,
                color: Colors.grey, // 使用灰色表示禁用状态
              ),
            );
          }

          if (audioController.isLoading.value) {
            return const SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff429482)),
                strokeWidth: 1.0,
              ),
            );
          }

          return IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 42,
              minHeight: 42,
              maxWidth: 42,
              maxHeight: 42,
            ),
            onPressed: audioController.playOrPause,
            icon: Obx(() => Image.asset(
                  audioController.isPlaying.value
                      ? "assets/img/music_play.png"
                      : "assets/img/music_pause.png",
                  width: 25,
                  height: 25,
                )),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool hasPlaylist = audioController.songList.isNotEmpty;
      return GestureDetector(
        onHorizontalDragEnd: hasPlaylist
            ? (DragEndDetails details) {
                if (audioController.songList.isEmpty) return;
                final velocity = details.velocity.pixelsPerSecond.dx;
                const threshold = 300.0;

                if (velocity > threshold) {
                  audioController.playPrevious();
                  HapticFeedback.mediumImpact();
                } else if (velocity < -threshold) {
                  audioController.playNext();
                  HapticFeedback.mediumImpact();
                }
              }
            : null,
        child: Container(
          height: 64, // 增加高度使布局更加宽敞
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 歌曲封面
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Hero(
                    tag: 'album_cover',
                    flightShuttleBuilder: (
                      BuildContext flightContext,
                      Animation<double> animation,
                      HeroFlightDirection flightDirection,
                      BuildContext fromHeroContext,
                      BuildContext toHeroContext,
                    ) {
                      if (!hasPlaylist) {
                        return const Icon(Icons.music_note, size: 30);
                      }
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        clipBehavior: Clip.hardEdge,
                        child: Container(
                          width: 48,
                          height: 48,
                          child: Image.network(
                            audioController
                                .songList[
                                    audioController.currentSongIndex.value]
                                .pic,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.music_note, size: 30),
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      clipBehavior: Clip.hardEdge,
                      child: Obx(() {
                        final currentSong = audioController.songList.isEmpty
                            ? null
                            : audioController.songList[
                                audioController.currentSongIndex.value];
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: currentSong != null
                              ? Image.network(
                                  currentSong.pic,
                                  key: ValueKey(currentSong.pic),
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.music_note, size: 30),
                                )
                              : const Icon(Icons.music_note, size: 30),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              // 歌曲信息
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Obx(() => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  audioController.musicName.value == ''
                                      ? '喵听音乐'
                                      : audioController.musicName.value,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  audioController.artistName.value == ''
                                      ? '听你想听'
                                      : audioController.artistName.value,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            )),
                      ),
                      // 播放控制
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildPlayButton(),
                          const SizedBox(width: 12),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => _showPlaylist(context),
                              child: Container(
                                width: 42,
                                height: 42,
                                padding: const EdgeInsets.all(8),
                                child: ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                    Colors.grey[700]!,
                                    BlendMode.srcIn,
                                  ),
                                  child: Image.asset(
                                    "assets/img/music_list.png",
                                    width: 22,
                                    height: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView>
    with SingleTickerProviderStateMixin {
  TabController? controller;
  int selectTab = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? _lastPressedAt; // 记录上次点击返回时间

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 5, vsync: this);

    controller?.addListener(() {
      selectTab = controller?.index ?? 0;
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectTab != 0) {
          controller?.animateTo(0);
          return false;
        }

        if (_lastPressedAt == null ||
            DateTime.now().difference(_lastPressedAt!) >
                const Duration(seconds: 2)) {
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
              // 改成白色背景
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.1, // 调整位置
                left: 125, // 减小宽度
                right: 125, // 减小宽度
              ),
              shape: RoundedRectangleBorder(
                // 添加圆角
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 6,
              // 增加阴影
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ), // 调整内边距
            ),
          );
          return false;
        }
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: scaffoldKey,
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: controller,
                    children: const [
                      HomeView(),
                      RankView(),
                      SongRecommendationView(),
                      ReleaseView(),
                      UserView()
                    ],
                  ),
                ),
              ],
            ),
            // 底部迷你播放器和导航栏
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MiniPlayer(),
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: controller,
                      indicatorColor: Colors.transparent,
                      labelColor: Colors.black,
                      labelStyle: const TextStyle(fontSize: 12),
                      unselectedLabelColor: const Color(0xffCDCDCD),
                      unselectedLabelStyle: const TextStyle(fontSize: 12),
                      tabs: [
                        Tab(
                          height: 60,
                          icon: Image.asset(
                            selectTab == 0
                                ? "assets/img/home_tab.png"
                                : "assets/img/home_tab_un.png",
                            width: 32,
                            height: 32,
                          ),
                          text: "首页",
                        ),
                        Tab(
                          height: 60,
                          icon: Image.asset(
                            selectTab == 1
                                ? "assets/img/list_tab.png"
                                : "assets/img/list_tab_un.png",
                            width: 32,
                            height: 32,
                          ),
                          text: "排行榜",
                        ),
                        Tab(
                          height: 60,
                          icon: Image.asset(
                            selectTab == 2
                                ? "assets/img/list_tab.png"
                                : "assets/img/list_tab_un.png",
                            width: 32,
                            height: 32,
                          ),
                          text: "知音",
                        ),
                        Tab(
                          height: 60,
                          icon: Image.asset(
                            selectTab == 3
                                ? "assets/img/music_tab.png"
                                : "assets/img/music_tab_un.png",
                            width: 32,
                            height: 32,
                          ),
                          text: "发布",
                        ),
                        Tab(
                          height: 60,
                          icon: Image.asset(
                            selectTab == 4
                                ? "assets/img/user_tab.png"
                                : "assets/img/user_tab_un.png",
                            width: 32,
                            height: 32,
                          ),
                          text: "我的",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
