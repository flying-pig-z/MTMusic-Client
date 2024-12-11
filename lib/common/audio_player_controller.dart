// audio_player_controller.dart

import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../api/api_collection.dart';
import '../api/api_music_likes.dart';
import '../common_widget/Song_widegt.dart';
import '../models/getMusicList_bean.dart';
import '../common/download_manager.dart';
import '../common_widget/app_data.dart';
import '../api/api_music_list.dart';
import '../models/universal_bean.dart';

enum PlayMode {
  sequence,   // 顺序播放
  random,     // 随机播放
  single      // 单曲循环
}

class AudioPlayerController extends GetxController {
  static AudioPlayerController? _instance;
  static AudioPlayerController get instance {
    _instance ??= AudioPlayerController._();
    return _instance!;
  }

  AudioPlayerController._();

  AudioPlayer? _audioPlayer;
  final downloadManager = Get.find<DownloadManager>();
  final appData = AppData();

  // Observable values
  final currentSongIndex = 0.obs;
  final duration = Duration.zero.obs;
  final position = Duration.zero.obs;
  final isPlaying = false.obs;
  final isLoading = false.obs;
  final isRotating = false.obs;
  final isDisposed = false.obs;

  // Current song info
  final artistName = ''.obs;
  final musicName = ''.obs;
  final likesStatus = false.obs;
  final collectionsStatus = false.obs;

  // Song lists
  final songList = <Song>[].obs;
  final ids = <int>[].obs;
  final songUrls = <String>[].obs;
  final artists = <String>[].obs;
  final musicNames = <String>[].obs;
  final likes = <bool>[].obs;
  final collections = <bool>[].obs;

  final playMode = PlayMode.sequence.obs;

  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _playerStateSubscription;

  void togglePlayMode() {
    switch (playMode.value) {
      case PlayMode.sequence:
        playMode.value = PlayMode.random;
        break;
      case PlayMode.random:
        playMode.value = PlayMode.single;
        break;
      case PlayMode.single:
        playMode.value = PlayMode.sequence;
        break;
    }
  }

  void initWithSongs(List<Song> songs, int initialIndex) {
    if (_audioPlayer == null) {
      _audioPlayer = AudioPlayer();
    }

    // 清空之前的数据
    ids.clear();
    songUrls.clear();
    artists.clear();
    musicNames.clear();
    likes.clear();
    collections.clear();

    songList.value = songs;
    currentSongIndex.value = initialIndex;
    _initializeSongLists();
    _initializePlayer();
  }

  void syncPlayingState() {
    if (_audioPlayer != null) {
      isPlaying.value = _audioPlayer!.playing;
    }
  }

  void _initializeSongLists() {
    for (int i = 0; i < songList.length; i++) {
      ids.add(songList[i].id);
      songUrls.add(songList[i].musicurl ?? '');
      artists.add(songList[i].artist);
      musicNames.add(songList[i].title);
      likes.add(songList[i].likes ?? false);
      collections.add(songList[i].collection ?? false);
    }
    _updateCurrentSongInfo();
  }

  void _initializePlayer() {
    // 取消之前的订阅
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();

    // Position updates
    _positionSubscription = _audioPlayer!.positionStream.listen((pos) {
      position.value = pos;
    });

    // Duration updates
    _durationSubscription = _audioPlayer!.durationStream.listen((dur) {
      duration.value = dur ?? Duration.zero;
    });

    _audioPlayer!.playingStream.listen((playing) {
      if (isPlaying.value != playing) {
        isPlaying.value = playing;
      }
    });

    // Player state updates
    _playerStateSubscription = _audioPlayer!.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      if (state.processingState == ProcessingState.completed) {
        if (playMode.value == PlayMode.single) {
          // For single mode, replay from start
          _audioPlayer!.seek(Duration.zero);
          _audioPlayer!.play();
        } else {
          playNext(manual: false);
        }
      }
    });

    // Initial load
    _loadAndPlayCurrentSong();
  }

  void _updateCurrentSongInfo() {
    artistName.value = artists[currentSongIndex.value];
    musicName.value = musicNames[currentSongIndex.value];
    likesStatus.value = likes[currentSongIndex.value];
    collectionsStatus.value = collections[currentSongIndex.value];
  }

  Future<void> toggleLike() async {
    final currentIndex = currentSongIndex.value;
    likesStatus.value = !likesStatus.value;
    likes[currentIndex] = likesStatus.value;
    UniversalBean response = await LikesApiMusic().likesMusic(musicId: ids[currentIndex], Authorization: AppData().currentToken);
    if (response.code != 200) {
      likesStatus.value = !likesStatus.value;
      likes[currentIndex] = likesStatus.value;
    }
  }

  Future<void> toggleCollection() async {
    final currentIndex = currentSongIndex.value;
    collectionsStatus.value = !collectionsStatus.value;
    collections[currentIndex] = collectionsStatus.value;
    UniversalBean response = await CollectionApiMusic().addCollection(musicId: ids[currentIndex], Authorization: AppData().currentToken);
    if (response.code != 200) {
      collectionsStatus.value = !collectionsStatus.value;
      collections[currentIndex] = collectionsStatus.value;
    }
  }

  Future<void> _loadAndPlayCurrentSong() async {
    isLoading.value = true;

    // 先停止播放和清除状态
    await _audioPlayer!.stop();
    position.value = Duration.zero;
    duration.value = Duration.zero;

    // 等待一帧确保 UI 更新
    await Future.microtask(() {});

    _updateCurrentSongInfo();
    await _checkAndUpdateSongStatus(currentSongIndex.value);

    try {
      final localSong = downloadManager.getLocalSong(songList[currentSongIndex.value].id);

      if (localSong == null && songUrls[currentSongIndex.value] == '') {
        // TODO 获取歌源
      }

      final audioSource = localSong != null
          ? AudioSource.file(localSong.musicurl!)
          : AudioSource.uri(Uri.parse(songUrls[currentSongIndex.value]));

      await _audioPlayer!.setAudioSource(audioSource, preload: true);

      // 等待获取实际时长
      final realDuration = await _audioPlayer!.duration;
      duration.value = realDuration ?? Duration.zero;

      isPlaying.value = false;
      isLoading.value = false;
      await _audioPlayer!.play();
      isPlaying.value = true;
    } catch (e) {
      print('Error loading audio source: $e');
      isLoading.value = false;
    }
  }

  Future<void> _checkAndUpdateSongStatus(int index) async {
    if (songList[index].likes == null || songList[index].collection == null) {
      try {
        MusicListBean musicListBean = await GetMusic().getMusicById(
          id: ids[index],
          Authorization: appData.currentToken,
        );

        if (musicListBean.code == 200) {
          likes[index] = musicListBean.likeOrNot!;
          collections[index] = musicListBean.collectOrNot!;

          if (index == currentSongIndex.value) {
            likesStatus.value = musicListBean.likeOrNot!;
            collectionsStatus.value = musicListBean.collectOrNot!;
          }
        }
      } catch (e) {
        print('Error fetching song status: $e');
      }
    }
  }

  void playOrPause() async {
    if (songList.isEmpty) return;
    if (_audioPlayer!.playing) {
      await _audioPlayer!.pause();
      isPlaying.value = false;
    } else {
      isPlaying.value = true;
      await _audioPlayer!.play();
    }
  }

  void pause() async {
    if (songList.isEmpty) return;
    if (_audioPlayer!.playing) {
      await _audioPlayer!.pause();
      isPlaying.value = false;
    }
  }

  void playNext({bool manual = false}) {
    if (manual) {
      if (currentSongIndex.value < songList.length - 1) {
        currentSongIndex.value++;
      } else {
        currentSongIndex.value = 0;
      }
      _loadAndPlayCurrentSong();
      return;
    }

    if (playMode.value == PlayMode.single) {
      _loadAndPlayCurrentSong();
      return;
    }

    if (playMode.value == PlayMode.random) {
      int nextIndex;
      if (songList.length > 1) {
        do {
          nextIndex = Random().nextInt(songList.length);
        } while (nextIndex == currentSongIndex.value);
      } else {
        nextIndex = 0;
      }
      currentSongIndex.value = nextIndex;
    } else {
      if (currentSongIndex.value < songList.length - 1) {
        currentSongIndex.value++;
      } else {
        currentSongIndex.value = 0;
      }
    }
    _loadAndPlayCurrentSong();
  }

  void playPrevious() {
    if (currentSongIndex.value > 0) {
      currentSongIndex.value--;
    } else {
      currentSongIndex.value = songList.length - 1;
    }
    _loadAndPlayCurrentSong();
  }

  void seekTo(Duration position) async {
    await _audioPlayer!.seek(position);
  }

  void changeSong(int index) {
    currentSongIndex.value = index;
    _loadAndPlayCurrentSong();
  }

  @override
  void onClose() {
    isDisposed.value = true;
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer?.dispose();
    _audioPlayer = null;
    super.onClose();
  }
}