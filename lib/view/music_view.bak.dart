import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player_miao/common_widget/app_data.dart';
import '../../view_model/home_view_model.dart';
import '../api/api_music_likes.dart';
import '../api/api_collection.dart';
import '../api/api_music_list.dart';
import '../common/download_manager.dart';
import '../common_widget/Song_widegt.dart';
import '../models/getMusicList_bean.dart';
import '../view/comment_view.dart';
import '../models/universal_bean.dart';

class MusicView extends StatefulWidget {
  final List<Song> songList;
  final int initialSongIndex;
  final Function(int index, bool isCollected, bool isLiked)? onSongStatusChanged;

  const MusicView({
    super.key,
    required this.songList,
    required this.initialSongIndex,
    this.onSongStatusChanged,
  });

  @override
  State<MusicView> createState() => _MusicViewState();
}

class _MusicViewState extends State<MusicView> with SingleTickerProviderStateMixin {
  final homeVM = Get.put(HomeViewModel());
  bool _isDisposed = false;
  AppData appData = AppData();
  late int currentSongIndex;
  late AudioPlayer _audioPlayer;
  StreamSubscription? _playerStateSubscription;

  final downloadManager = Get.put(DownloadManager());

  // Stream values
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Current song info
  late String artistName;
  late String musicName;
  late bool likesnot;
  late bool collectionsnot;

  // Song lists
  List<int> id = [];
  List<String> song2 = [];
  List<String> artist = [];
  List<String> music = [];
  List<bool> likes = [];
  List<bool> collection = [];

  late AnimationController _rotationController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    currentSongIndex = widget.initialSongIndex;
    // _initializeAsync();
    _fetchSonglistData();
    _updateCurrentSong();
    playerInit();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (!_isDisposed) {
        if (state.playing) {
          _rotationController.repeat();
        } else {
          _rotationController.stop();
        }
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _playerStateSubscription?.cancel();
    _rotationController.stop();
    _rotationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _fetchSonglistData() async {
    setState(() {
      for (int i = 0; i < widget.songList.length; i++) {
        id.add(widget.songList[i].id);
        // TODO 处理为 musicurl 为空的情况, 需要通过网络
        if (widget.songList[i].musicurl == null) {
          song2.add("");
        } else {
          song2.add(widget.songList[i].musicurl!);
        }
        artist.add(widget.songList[i].artist);
        music.add(widget.songList[i].title);

        // 初始化喜欢和收藏状态，后续再更新
        likes.add(widget.songList[i].likes ?? false);
        collection.add(widget.songList[i].collection ?? false);
      }
    });
  }

  // 检查并更新歌曲状态的方法
  Future<void> _checkAndUpdateSongStatus(int index) async {
    // 只有当likes和collection为null时才需要请求
    if (widget.songList[index].likes == null || widget.songList[index].collection == null) {
      try {
        MusicListBean musicListBean = await GetMusic().getMusicById(
          id: id[index],
          Authorization: AppData().currentToken,
        );

        if (!_isDisposed && musicListBean.code == 200) {
          setState(() {
            likes[index] = musicListBean.likeOrNot!;
            collection[index] = musicListBean.collectOrNot!;
            // 如果是当前播放的歌曲，更新当前状态
            if (index == currentSongIndex) {
              likesnot = musicListBean.likeOrNot!;
              collectionsnot = musicListBean.collectOrNot!;
            }

            widget.onSongStatusChanged?.call(
              index,
              musicListBean.collectOrNot!,
              musicListBean.likeOrNot!,
            );

          });
        }
      } catch (e) {
        print('Error fetching song status: $e');
      }
    }
  }


  Future<void> _updateCurrentSong() async {
    if (_isDisposed) return;

    setState(() {
      _isLoading = true;
      _position = Duration.zero;
      _duration = Duration.zero;
      artistName = artist[currentSongIndex];
      musicName = music[currentSongIndex];
      likesnot = likes[currentSongIndex];
      collectionsnot = collection[currentSongIndex];
    });

    await _checkAndUpdateSongStatus(currentSongIndex);

    try {
      await _audioPlayer.stop();
      _rotationController.reset();

      // 检查本地文件
      final localSong = downloadManager.getLocalSong(currentSongIndex);
      final audioSource = localSong != null
          ? AudioSource.file(localSong.musicurl!)
          : AudioSource.uri(Uri.parse(song2[currentSongIndex]));

      // 设置音频源并获取时长
      await _audioPlayer.setAudioSource(audioSource, preload: true);

      // 等待获取真实的音频时长
      final duration = await _audioPlayer.duration;

      if (!_isDisposed) {
        setState(() {
          _duration = duration ?? Duration.zero;
          _isLoading = false;
        });
      }

      // 开始播放
      await _audioPlayer.play();
    } catch (e) {
      print('Error loading audio source: $e');
      if (!_isDisposed) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void playerInit() async {
    _audioPlayer = AudioPlayer();
    await _checkAndUpdateSongStatus(widget.initialSongIndex);
    // 初始化第一首歌的信息
    artistName = widget.songList[widget.initialSongIndex].artist;
    musicName = widget.songList[widget.initialSongIndex].title;
    likesnot = widget.songList[widget.initialSongIndex].likes!;
    collectionsnot = widget.songList[widget.initialSongIndex].collection!;

    // 监听播放位置
    _audioPlayer.positionStream.listen((position) {
      if (!_isDisposed) {
        setState(() => _position = position);
      }
    });

    // 监听音频时长
    _audioPlayer.durationStream.listen((duration) {
      if (!_isDisposed) {
        setState(() => _duration = duration ?? Duration.zero);
      }
    });

    // 修改播放状态监听
    _audioPlayer.playerStateStream.listen((state) {
      if (_isDisposed) return;

      if (state.processingState == ProcessingState.completed) {
        // 在这里直接调用下一首，而不是通过 Stream
        _handleSongCompletion();
      }
    });
  }

  // 新增方法处理歌曲播放完成
  void _handleSongCompletion() {
    if (_isDisposed) return;

    setState(() {
      _position = Duration.zero;
      _duration = Duration.zero;
    });

    // 使用 Future.microtask 确保状态更新后再切换歌曲
    Future.microtask(() {
      if (!_isDisposed) {
        playNextSong();
      }
    });
  }

  // 修改构建 Slider 的部分
  Widget _buildProgressSlider() {
    // 确保最大值至少为 0.1 以避免除零错误
    final max = _duration.inSeconds.toDouble() == 0 ? 0.1 : _duration.inSeconds.toDouble();
    // 确保当前值不超过最大值
    final current = _position.inSeconds.toDouble().clamp(0, max);

    return SliderTheme(
      data: const SliderThemeData(
        trackHeight: 3.0,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7.0),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 12.0),
      ),
      child: Slider(
        min: 0,
        max: max,
        value: current.toDouble(),
        onChanged: (value) async {
          if (!_isDisposed && _duration.inSeconds > 0) {
            await _audioPlayer.seek(Duration(seconds: value.toInt()));
            setState(() {});
          }
        },
        activeColor: const Color(0xff429482),
        inactiveColor: const Color(0xffE3F0ED),
      ),
    );
  }

  Widget _buildPlayButton() {
    return SizedBox(
      width: 52,
      height: 52,
      child: Center(
        child: _isLoading
            ? const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xff429482)),
          strokeWidth: 3.0,
        )
            : IconButton(
          padding: EdgeInsets.zero, // 移除内边距
          constraints: const BoxConstraints(
            minWidth: 52,
            minHeight: 52,
            maxWidth: 52,
            maxHeight: 52,
          ),
          onPressed: playOrPause,
          icon: _audioPlayer.playing
              ? Image.asset(
            "assets/img/music_play.png",
            width: 52,
            height: 52,
          )
              : Image.asset(
            "assets/img/music_pause.png",
            width: 52,
            height: 52,
          ),
        ),
      ),
    );
  }

  void playOrPause() async {
    if (_isDisposed) return;  // 添加状态检查

    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
      if (!_isDisposed) {  // 再次检查状态
        _rotationController.stop();
      }
    } else {
      await _audioPlayer.play();
      if (!_isDisposed) {  // 再次检查状态
        _rotationController.repeat();
      }
    }
    if (!_isDisposed) {
      setState(() {});
    }
  }

  void playNextSong() {
    if (currentSongIndex < widget.songList.length - 1) {
      currentSongIndex++;
    } else {
      currentSongIndex = 0;
    }
    _updateCurrentSong();
  }

  void playPreviousSong() {
    if (currentSongIndex > 0) {
      currentSongIndex--;
    } else {
      currentSongIndex = widget.songList.length - 1;
    }
    _updateCurrentSong();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _initializeAsync() async {
    await _fetchSonglistData();
    await _updateCurrentSong();
  }

  void _changeCurrentSong(int index) {
    if (!_isDisposed) {
      setState(() {
        currentSongIndex = index;
        _updateCurrentSong();
      });
    }
  }

  Widget _buildRotatingAlbumCover() {
    return RotationTransition(
      turns: _rotationController,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            child: ClipRRect(
              child: Image.network(
                widget.songList[currentSongIndex].artistPic,
                width: 225,
                height: 225,
                fit: BoxFit.cover,
              ),
            ),
          ),
          ClipRRect(
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

  @override
  Widget build(BuildContext context) {
    return Container(
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
            padding: const EdgeInsets.only(top: 45, left: 10, right: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Image.asset(
                        "assets/img/back.png",
                        width: 25,
                        height: 25,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Image.asset(
                            "assets/img/music_add.png",
                            width: 30,
                            height: 30,
                          ),
                        ),
                        IconButton(
                          onPressed: downloadManager.isDownloading(id[currentSongIndex]) ||
                              downloadManager.isCompleted(id[currentSongIndex])
                              ? null
                              : () async {
                            await downloadManager.startDownload(
                              song: widget.songList[currentSongIndex],
                              context: context,
                            );
                          },
                          icon: Obx(() {
                            if (downloadManager.isDownloading(id[currentSongIndex])) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      value: downloadManager.getProgress(id[currentSongIndex]),
                                      backgroundColor: Colors.grey[200],
                                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff429482)),
                                      strokeWidth: 3.0,
                                    ),
                                  ),
                                  Text(
                                    '${(downloadManager.getProgress(id[currentSongIndex]) * 100).toInt()}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              );
                            }
                            return Image.asset(
                              downloadManager.isCompleted(id[currentSongIndex])
                                  ? "assets/img/music_download_completed.png"
                                  : "assets/img/music_download.png",
                              width: 30,
                              height: 30,
                            );
                          }),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 80,
                ),
                Center(
                  child: _buildRotatingAlbumCover(),
                ),
                const SizedBox(
                  height: 60,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          musicName,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          artistName,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () async{
                            setState(() {
                              likesnot = !likesnot;
                              likes[currentSongIndex] = !likes[currentSongIndex];
                            });

                            UniversalBean response = await LikesApiMusic().likesMusic(musicId: id[currentSongIndex], Authorization: AppData().currentToken);
                            if (response.code != 200) {
                              likesnot = !likesnot;
                              likes[currentSongIndex] = !likes[currentSongIndex];
                            }

                            widget.onSongStatusChanged?.call(
                                currentSongIndex,
                                collection[currentSongIndex],  // 传递当前的收藏状态
                                likes[currentSongIndex]
                            );
                          },
                          icon: Image.asset(
                            likesnot
                                ? "assets/img/music_good.png"
                                : "assets/img/music_good_un.png",
                            width: 29,
                            height: 29,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              collectionsnot = !collectionsnot;
                              collection[currentSongIndex] = !collection[currentSongIndex];
                            });

                            UniversalBean response = await CollectionApiMusic().addCollection(musicId: id[currentSongIndex], Authorization: AppData().currentToken);
                            if (response.code != 200) {
                              collectionsnot = !collectionsnot;
                              collection[currentSongIndex] = !collection[currentSongIndex];
                            }

                            widget.onSongStatusChanged?.call(
                                currentSongIndex,
                                collection[currentSongIndex],
                                likes[currentSongIndex]  // 传递当前的点赞状态
                            );
                          },
                          icon: Image.asset(
                            collectionsnot
                                ? "assets/img/music_star.png"
                                : "assets/img/music_star_un.png",
                            width: 29,
                            height: 29,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CommentView(
                                  id: id[currentSongIndex],
                                  song: musicName,
                                  singer: artistName,
                                  cover: widget.songList[currentSongIndex].artistPic,
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
                    )
                  ],
                ),
                const SizedBox(
                  height: 80,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDuration(_position),
                      style: const TextStyle(color: Colors.black),
                    ),
                    Expanded(
                      child: _buildProgressSlider(),
                    ),
                    Text(
                      formatDuration(_duration),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Image.asset(
                        "assets/img/music_random.png",
                        width: 35,
                        height: 35,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: playPreviousSong,
                          icon: Image.asset(
                            "assets/img/music_back.png",
                            width: 42,
                            height: 42,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        _buildPlayButton(), // 这里使用新的方法替换原来的IconButton
                        const SizedBox(
                          width: 10,
                        ),
                        IconButton(
                          onPressed: playNextSong,
                          icon: Image.asset(
                            "assets/img/music_next.png",
                            width: 42,
                            height: 42,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: _showPlaylist,
                      icon: Image.asset(
                        "assets/img/music_more.png",
                        width: 35,
                        height: 35,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPlaylist() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.only(top: 15),
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Text(
                  "播放列表",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: music.length,
                  itemBuilder: (BuildContext context, int index) {
                    bool isCurrentlyPlaying = currentSongIndex == index;
                    return ListTile(
                      tileColor: isCurrentlyPlaying ? const Color(0xffE3F0ED) : null,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            // Add left padding
                            child: Text(
                              music[index],
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            // Add right padding
                            child: Image.asset(
                              "assets/img/songs_run.png",
                              width: 25,
                            ), // Add your desired icon here
                          ),
                        ],
                      ),
                      onTap: () {
                        _changeCurrentSong(index);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
