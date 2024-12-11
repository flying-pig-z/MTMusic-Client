import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_download.dart';
import '../common_widget/Song_widegt.dart';
import 'package:path/path.dart' as path;

class DownloadItem {
  final Song song;
  double progress;
  bool isCompleted;
  bool isDownloading;

  DownloadItem({
    required this.song,
    this.progress = 0.0,
    this.isCompleted = false,
    this.isDownloading = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'song': {
        'pic': song.pic,
        'artistPic': song.artistPic,
        'title': song.title,
        'artist': song.artist,
        'musicurl': song.musicurl,
        'id': song.id,
        'likes': song.likes,
        'collection': song.collection
      },
      'progress': progress,
      'isCompleted': isCompleted,
      'isDownloading': isDownloading,
    };
  }

  // 从JSON创建DownloadItem
  factory DownloadItem.fromJson(Map<String, dynamic> json) {
    return DownloadItem(
      song: Song(
        pic: json['song']['pic'],
        artistPic: json['song']['artistPic'],
        title: json['song']['title'],
        artist: json['song']['artist'],
        musicurl: json['song']['musicurl'],
        id: json['song']['id'],
        likes: json['song']['likes'],
        collection: json['song']['collection'],
      ),
      progress: json['progress'],
      isCompleted: json['isCompleted'],
      isDownloading: json['isDownloading'],
    );
  }
}

class DownloadManager extends GetxController {
  static const String PREFS_KEY = 'downloads_data';
  final _downloads = <String, DownloadItem>{}.obs;
  final downloadApi = DownloadApi();
  late SharedPreferences _prefs;

  @override
  void onInit() async {
    super.onInit();
    await _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadDownloadsFromPrefs();
  }

  // 从SharedPreferences加载数据
  Future<void> _loadDownloadsFromPrefs() async {
    final String? downloadsJson = _prefs.getString(PREFS_KEY);
    if (downloadsJson != null) {
      final Map<String, dynamic> downloadsMap = json.decode(downloadsJson);
      downloadsMap.forEach((key, value) {
        _downloads[key] = DownloadItem.fromJson(value);
      });
    }
  }

  // 保存数据到SharedPreferences
  Future<void> _saveDownloadsToPrefs() async {
    final Map<String, dynamic> downloadsMap = {};
    _downloads.forEach((key, value) {
      downloadsMap[key] = value.toJson();
    });
    await _prefs.setString(PREFS_KEY, json.encode(downloadsMap));
  }

  List<Song> getLocalSongs() {
    final localSongs = <Song>[];
    _downloads.forEach((key, value) {
      if (value.isCompleted) {
        localSongs.add(value.song);
      }
    });
    return localSongs;
  }

  Map<String, DownloadItem> get downloads => _downloads;

  bool isDownloading(int id) =>
      _downloads[id.toString()]?.isDownloading ?? false;

  bool isCompleted(int id) => _downloads[id.toString()]?.isCompleted ?? false;

  double getProgress(int id) => _downloads[id.toString()]?.progress ?? 0.0;

  Song? getLocalSong(int id) {
    final downloadItem = _downloads[id.toString()];
    if (downloadItem?.isCompleted ?? false) {
      return downloadItem!.song;
    }
    return null;
  }

  bool removeSong(int id) {
    if (_downloads[id.toString()]?.isCompleted ?? false) {
      File file =
          File.fromUri(Uri.parse(_downloads[id.toString()]!.song.musicurl!));
      file.deleteSync();
      _downloads.remove(id.toString());
      _saveDownloadsToPrefs();
      return true;
    }
    return false;
  }

  int completedNumber() {
    int count = 0;
    _downloads.forEach((key, value) {
      if (value.isCompleted) {
        count++;
      }
    });
    return count;
  }

  Future<void> startDownload({
    required Song song,
    required context,
  }) async {
    if (_downloads[song.id.toString()]?.isDownloading ?? false) return;

    final fileName = '${song.id}_${song.title}_${song.artist}';

    // 创建 Song 的副本
    final songCopy = Song(
        pic: song.pic,
        artistPic: song.artistPic,
        title: song.title,
        artist: song.artist,
        musicurl: song.musicurl,
        id: song.id,
        likes: song.likes,
        collection: song.collection);

    final downloadItem = DownloadItem(
      song: songCopy,
      isDownloading: true,
    );
    _downloads[song.id.toString()] = downloadItem;

    try {
      final filePath = await downloadApi.downloadMusic(
        musicUrl: songCopy.musicurl!,
        name: fileName,
        context: context,
        onProgress: (progress) {
          downloadItem.progress = progress;
          _downloads[song.id.toString()] = downloadItem;
        },
      );

      if (filePath != null) {
        downloadItem.isCompleted = true;
        downloadItem.isDownloading = false;
        downloadItem.progress = 1.0;
        songCopy.musicurl = _getLocalAudioPath(fileName, songCopy.musicurl!);
      } else {
        downloadItem.isDownloading = false;
        downloadItem.progress = 0.0;
      }
    } catch (e) {
      print('Download error: $e');
      downloadItem.isDownloading = false;
      downloadItem.progress = 0.0;
    }

    _downloads[song.id.toString()] = downloadItem;
    await _saveDownloadsToPrefs();
  }

  bool updateSongInfo(int id, bool isCollected, bool isLiked) {
    final downloadItem = _downloads[id.toString()];
    if (downloadItem != null) {
      downloadItem.song.collection = isCollected;
      downloadItem.song.likes = isLiked;
      _downloads[id.toString()] = downloadItem;
      _saveDownloadsToPrefs();
      return true;
    }
    return false;
  }

  String _getFileExtension(String url) {
    // Remove query parameters
    final urlWithoutQuery = url.split('?').first;
    // Get the extension including the dot
    final extension = path.extension(urlWithoutQuery);
    return extension.isNotEmpty
        ? extension
        : '.mp3'; // Default to .mp3 if no extension found
  }

  String _getLocalAudioPath(String fileName, String url) {
    final extension = _getFileExtension(url);
    final fullFileName = '$fileName$extension';
    return path.join('/storage/emulated/0/MTMusic', fullFileName);
  }
}
