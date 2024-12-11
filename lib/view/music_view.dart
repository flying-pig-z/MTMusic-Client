// music_view.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player_miao/common_widget/app_data.dart';
import 'package:music_player_miao/models/universal_bean.dart';
import '../api/api_songlist_musics.dart';
import '../common/audio_player_controller.dart';
import '../common/download_count_controller.dart';
import '../common/download_manager.dart';
import '../common/songlist_bottom_sheet.dart';
import '../common_widget/Song_widegt.dart';
import 'comment_view.dart';

import 'dart:async';
import 'package:flutter/material.dart';

class ScrollingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double width;

  const ScrollingText({
    Key? key,
    required this.text,
    required this.style,
    required this.width,
  }) : super(key: key);

  @override
  State<ScrollingText> createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  bool _hasOverflow = false;
  final _textKey = GlobalKey();
  double? _textWidth;
  Timer? _scrollTimer;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _scheduleCheck();
  }

  void _initControllers() {
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
  }

  void _scheduleCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetAndCheckOverflow();
    });
  }

  void _resetAndCheckOverflow() {
    if (!mounted) return;

    // 重置所有状态
    setState(() {
      _hasOverflow = false;
      _textWidth = null;
      _isScrolling = false;
    });

    _scrollController.jumpTo(0);
    _scrollTimer?.cancel();
    _scrollTimer = null;

    // 重新检查溢出
    final RenderBox? textBox =
        _textKey.currentContext?.findRenderObject() as RenderBox?;
    if (textBox != null) {
      _textWidth = textBox.size.width;
      final shouldScroll = _textWidth! > widget.width;

      if (shouldScroll != _hasOverflow) {
        setState(() {
          _hasOverflow = shouldScroll;
        });

        if (shouldScroll && !_isScrolling) {
          _startScrolling();
        }
      }
    }
  }

  void _startScrolling() async {
    if (!mounted || !_hasOverflow || _textWidth == null || _isScrolling) return;

    _isScrolling = true;
    final double scrollDistance = _textWidth! - widget.width;

    Future<void> scroll() async {
      if (!mounted || !_hasOverflow) return;

      // 初始停留
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted || !_hasOverflow) return;

      const int steps = 1000;
      const int totalDurationMs = 10000;
      const int stepDurationMs = totalDurationMs ~/ steps;

      for (int i = 0; i < steps; i++) {
        if (!mounted || !_hasOverflow) return;
        final double position = (scrollDistance * i) / steps;
        _scrollController.jumpTo(position);
        await Future.delayed(Duration(milliseconds: stepDurationMs));
      }

      if (!mounted || !_hasOverflow) return;

      // 末尾停留
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted || !_hasOverflow) return;

      // 瞬间返回起点
      _scrollController.jumpTo(0);

      // 继续下一次滚动
      if (mounted && _hasOverflow) {
        scroll();
      }
    }

    scroll();
  }

  @override
  void didUpdateWidget(ScrollingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      // 文本改变时完全重置状态
      _scrollController.jumpTo(0);
      _isScrolling = false;
      _scrollTimer?.cancel();
      _scrollTimer = null;
      _scheduleCheck();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _scrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        physics: const NeverScrollableScrollPhysics(),
        child: Text(
          widget.text,
          key: _textKey,
          style: widget.style,
        ),
      ),
    );
  }
}

class MusicView extends StatefulWidget {
  final List<Song> songList;
  final int initialSongIndex;
  final Function(int index, bool isCollected, bool isLiked)?
      onSongStatusChanged;

  const MusicView({
    super.key,
    required this.songList,
    required this.initialSongIndex,
    this.onSongStatusChanged,
  });

  @override
  State<MusicView> createState() => _MusicViewState();
}

class _MusicViewState extends State<MusicView>
    with SingleTickerProviderStateMixin {
  final audioController = Get.find<AudioPlayerController>();
  final downloadManager = Get.find<DownloadManager>();
  late AnimationController _rotationController;

  bool _isInitialLoading = true;
  bool _isAlbumImageLoaded = false;
  bool _isDiscImageLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        audioController.initWithSongs(widget.songList, widget.initialSongIndex);
        _setupRotationController();
        _preloadImages();
      }
    });
  }

  void _preloadImages() {
    // 预加载网络图片
    final albumImage =
        NetworkImage(widget.songList[widget.initialSongIndex].artistPic);
    albumImage
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((info, synchronousCall) {
      if (mounted) {
        setState(() {
          _isAlbumImageLoaded = true;
          _checkAllImagesLoaded();
        });
      }
    }));

    // 预加载本地图片
    final discImage = AssetImage("assets/img/music_Ellipse.png");
    discImage
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((info, synchronousCall) {
      if (mounted) {
        setState(() {
          _isDiscImageLoaded = true;
          _checkAllImagesLoaded();
        });
      }
    }));
  }

  void _checkAllImagesLoaded() {
    if (_isAlbumImageLoaded && _isDiscImageLoaded) {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  void _setupRotationController() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    ever(audioController.isPlaying, (playing) {
      if (!mounted) return;

      if (playing) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    });


  }

  Widget _buildRotatingAlbumCover() {
    // 初始加载检查
    if (_isInitialLoading && (!_isAlbumImageLoaded || !_isDiscImageLoaded)) {
      return Container(
        width: 350,
        height: 350,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xff429482)),
        ),
      );
    }

    return RotationTransition(
      turns: _rotationController,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 只对图片URL的变化进行响应
          Positioned(
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: Obx(() {
                if (!mounted) return const SizedBox();

                final currentSong =
                    widget.songList[audioController.currentSongIndex.value];

                return ClipRRect(
                  borderRadius: BorderRadius.circular(112.5),
                  child: Image.network(
                    currentSong.artistPic,
                    width: 225,
                    height: 225,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 225,
                        height: 225,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(112.5),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xff429482)),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 225,
                        height: 225,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(112.5),
                        ),
                        child: const Icon(Icons.error_outline, size: 40),
                      );
                    },
                  ),
                );
              }),
            ),
          ),
          // 唱片背景
          Positioned(
            child: Image.asset(
              "assets/img/music_Ellipse.png",
              width: 350,
              height: 350,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSlider() {
    return SliderTheme(
      data: const SliderThemeData(
        trackHeight: 3.0,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7.0),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 12.0),
      ),
      child: Obx(() {
        if (!mounted) return const Slider(value: 0, onChanged: null);

        final max = audioController.duration.value.inSeconds.toDouble();
        final current =
            audioController.position.value.inSeconds.toDouble().clamp(0, max);

        return Slider(
          min: 0,
          max: max == 0 ? 0.1 : max,
          value: current.toDouble(),
          onChanged: (value) =>
              audioController.seekTo(Duration(seconds: value.toInt())),
          activeColor: const Color(0xff429482),
          inactiveColor: const Color(0xffE3F0ED),
        );
      }),
    );
  }

  Widget _buildPlayButton() {
    return SizedBox(
      width: 52,
      height: 52,
      child: Center(
        child: Obx(() {
          if (!mounted) return const SizedBox();

          if (audioController.isLoading.value) {
            return const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff429482)),
              strokeWidth: 3.0,
            );
          }

          return IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 52,
              minHeight: 52,
              maxWidth: 52,
              maxHeight: 52,
            ),
            onPressed: audioController.playOrPause,
            icon: Obx(
              () => ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.grey[700]!,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    audioController.isPlaying.value
                        ? "assets/img/pause.png"
                        : "assets/img/play.png",
                    width: 64,
                    height: 64,
                  )
              ),
            ),
          );
        }),
      ),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void _showPlaylist() {
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
                color: Colors.white, // 标题背景设为白色
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
                  // 使用 ClipRRect 裁剪列表内容
                  child: Obx(() => ListView.builder(
                        padding: EdgeInsets.zero, // 移除 ListView 的内边距
                        itemCount: audioController.musicNames.length,
                        itemBuilder: (BuildContext context, int index) {
                          final isCurrentlyPlaying =
                              audioController.currentSongIndex.value == index;
                          return Container(
                            // 使用 Container 包裹 ListTile
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
                                    // 使用 Expanded 包裹文本
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/img/app_bg.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 45, left: 10, right: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Image.asset(
                        "assets/img/back.png",
                        width: 25,
                        height: 25,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              enableDrag: true,
                              isDismissible: true,
                              builder: (context) => SonglistBottomSheet(
                                onSonglistSelected: (songlistId) async {
                                  try {
                                    // 提前获取 scaffoldMessenger 引用
                                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                                    UniversalBean response = await SonglistMusicApi().addMusicToSongList(
                                        musicId: audioController.ids[audioController.currentSongIndex.value],
                                        songlistId: songlistId,
                                        Authorization: AppData().currentToken
                                    );

                                    if (mounted) {  // 检查组件是否还在挂载状态
                                      if (response.code == 200) {
                                        scaffoldMessenger.clearSnackBars();  // 先清除当前所有的 SnackBar
                                        scaffoldMessenger.showSnackBar(
                                          const SnackBar(
                                            content: Text('已添加到歌单'),
                                            duration: Duration(milliseconds: 1500),
                                          ),
                                        );
                                      } else {
                                        scaffoldMessenger.clearSnackBars();  // 先清除当前所有的 SnackBar
                                        scaffoldMessenger.showSnackBar(
                                          SnackBar(
                                            content: Text(response.msg!),
                                            duration: const Duration(milliseconds: 1500),
                                          ),
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    if (mounted) {  // 检查组件是否还在挂载状态
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(e.toString()),
                                          duration: const Duration(milliseconds: 1500),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            );
                          },
                          icon: Image.asset(
                            "assets/img/music_add.png",
                            width: 30,
                            height: 30,
                          ),
                        ),
                        Obx(() {
                          final currentId = audioController
                              .ids[audioController.currentSongIndex.value];
                          return IconButton(
                            onPressed:
                                downloadManager.isDownloading(currentId) ||
                                        downloadManager.isCompleted(currentId)
                                    ? null
                                    : () async {
                                        await downloadManager.startDownload(
                                          song: widget.songList[audioController
                                              .currentSongIndex.value],
                                          context: context,
                                        );
                                        Get.find<DownloadCountController>().refreshCount(downloadManager);
                                      },
                            icon: downloadManager.isDownloading(currentId)
                                ? Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 32,
                                        height: 32,
                                        child: CircularProgressIndicator(
                                          value: downloadManager
                                              .getProgress(currentId),
                                          backgroundColor: Colors.grey[200],
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                  Color>(Color(0xff429482)),
                                          strokeWidth: 3.0,
                                        ),
                                      ),
                                      Text(
                                        '${(downloadManager.getProgress(currentId) * 100).toInt()}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  )
                                : Image.asset(
                                    downloadManager.isCompleted(currentId)
                                        ? "assets/img/music_download_completed.png"
                                        : "assets/img/music_download.png",
                                    width: 30,
                                    height: 30,
                                  ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.07),
                Center(
                  child: SizedBox(
                    width: screenWidth * 0.85,
                    height: screenWidth * 0.85,
                    child: _buildRotatingAlbumCover(),
                  ),
                ),
                SizedBox(height: screenHeight * 0.08),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 歌曲信息部分
                    Container(
                      padding: EdgeInsets.only(left: screenWidth * 0.03),
                      child: Obx(() => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ScrollingText(
                                text: audioController.musicName.value,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                                width: screenWidth * 0.46,
                              ),
                              ScrollingText(
                                text: audioController.artistName.value,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                                width: screenWidth * 0.4,
                              ),
                            ],
                          )),
                    ),
                    // 按钮组部分
                    Container(
                      padding: EdgeInsets.only(right: screenWidth * 0.02),
                      // 右边距
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            // 按钮之间的间距
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            onPressed: () async {
                              await audioController.toggleLike();
                              widget.onSongStatusChanged?.call(
                                audioController.currentSongIndex.value,
                                audioController.collectionsStatus.value,
                                audioController.likesStatus.value,
                              );
                            },
                            icon: Obx(
                              () => audioController.likesStatus.value
                                  ? Image.asset(
                                      'assets/img/like.png',
                                      width: 24,
                                      height: 24,
                                    )
                                  : ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                        Colors.grey[700]!,
                                        BlendMode.srcIn,
                                      ),
                                      child: Image.asset(
                                        'assets/img/unlike.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                            ),
                          ),
                          IconButton(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            onPressed: () async {
                              await audioController.toggleCollection();
                              widget.onSongStatusChanged?.call(
                                audioController.currentSongIndex.value,
                                audioController.collectionsStatus.value,
                                audioController.likesStatus.value,
                              );
                            },
                            icon: Obx(() => Image.asset(
                                  audioController.collectionsStatus.value
                                      ? "assets/img/music_star.png"
                                      : "assets/img/music_star_un.png",
                                  width: 29,
                                  height: 29,
                                )),
                          ),
                          IconButton(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CommentView(
                                    id: audioController.ids[
                                        audioController.currentSongIndex.value],
                                    song: audioController.musicName.value,
                                    singer: audioController.artistName.value,
                                    cover: widget
                                        .songList[audioController
                                            .currentSongIndex.value]
                                        .artistPic,
                                  ),
                                ),
                              );
                            },
                            icon: Image.asset(
                              "assets/img/music_commend_un.png",
                              width: 29,
                              height: 29,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.04),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                  // 添加整体左右边距
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => Text(
                            formatDuration(audioController.position.value),
                            style: const TextStyle(color: Colors.black),
                          )),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.01),
                          child: _buildProgressSlider(),
                        ),
                      ),
                      Obx(() => Text(
                            formatDuration(audioController.duration.value),
                            style: const TextStyle(color: Colors.black),
                          )),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      iconSize: screenWidth * 0.08,
                      onPressed: () {
                        audioController.togglePlayMode();
                      },
                      icon: Obx(() {
                        return ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Colors.grey[700]!,
                              BlendMode.srcIn,
                            ),
                            child: switch (audioController.playMode.value) {
                              PlayMode.sequence => Image.asset(
                                  "assets/img/sequence.png",
                                  width: 32,
                                  height: 32,
                                ),
                              PlayMode.random => Image.asset(
                                  "assets/img/random.png",
                                  width: 32,
                                  height: 32,
                                ),
                              PlayMode.single => Image.asset(
                                  "assets/img/single.png",
                                  width: 32,
                                  height: 32,
                                ),
                            });
                      }),
                    ),
                    Row(
                      children: [
                        IconButton(
                          iconSize: screenWidth * 0.08,
                          onPressed: () {
                            audioController.playPrevious();
                            _rotationController.reset();
                          },
                          icon: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Colors.grey[700]!,
                              BlendMode.srcIn,
                            ),
                            child: Image.asset(
                              "assets/img/prev.png",
                              width: 42,
                              height: 42,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        _buildPlayButton(),
                        const SizedBox(width: 15),
                        IconButton(
                          iconSize: screenWidth * 0.08,
                          onPressed: () {
                            audioController.playNext(manual: true);
                            _rotationController.reset();
                          },
                          icon:ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Colors.grey[700]!,
                              BlendMode.srcIn,
                            ),
                            child: Image.asset(
                              "assets/img/next.png",
                              width: 42,
                              height: 42,
                            ),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      iconSize: screenWidth * 0.08,
                      onPressed: _showPlaylist,
                      icon: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.grey[700]!,
                          BlendMode.srcIn,
                        ),
                        child: Image.asset(
                          "assets/img/music_list.png",
                          width: 32,
                          height: 32,
                          scale: 0.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (!mounted) return;
    if (_rotationController.isAnimating) {
      _rotationController.stop();
    }
    _rotationController.dispose();
    // audioController.clearState();
    audioController.syncPlayingState();
    super.dispose();
  }
}
