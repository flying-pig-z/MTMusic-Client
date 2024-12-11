import 'package:get/get.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SongStatus {
  final int id;
  RxBool isLiked;
  RxBool isCollected;

  SongStatus({
    required this.id,
    required bool liked,
    required bool collected,
  })  : isLiked = liked.obs,
        isCollected = collected.obs;

  Map<String, dynamic> toJson() => {
    'id': id,
    'isLiked': isLiked.value,
    'isCollected': isCollected.value,
  };

  factory SongStatus.fromJson(Map<String, dynamic> json) => SongStatus(
    id: json['id'],
    liked: json['isLiked'],
    collected: json['isCollected'],
  );
}

class SongStatusManager {
  // 单例实例
  static final SongStatusManager _instance = SongStatusManager._internal();

  // 工厂构造函数
  factory SongStatusManager() => _instance;

  // 私有构造函数
  SongStatusManager._internal();

  // 歌曲状态Map，使用RxMap使整个Map都是响应式的
  final RxMap<int, SongStatus> _songStatuses = <int, SongStatus>{}.obs;

  // SharedPreferences实例
  SharedPreferences? _prefs;

  // 初始化方法
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadFromStorage();
  }

  // 从持久化存储加载数据
  Future<void> _loadFromStorage() async {
    if (_prefs == null) return;

    final String? storedData = _prefs!.getString('song_statuses');
    if (storedData != null) {
      try {
        final List<dynamic> decoded = json.decode(storedData);
        final Map<int, SongStatus> loadedStatuses = {};

        for (var item in decoded) {
          final status = SongStatus.fromJson(item);
          loadedStatuses[status.id] = status;
        }

        _songStatuses.value = loadedStatuses;
      } catch (e) {
        print('Error loading song statuses: $e');
      }
    }
  }

  // 保存数据到持久化存储
  Future<void> _saveToStorage() async {
    if (_prefs == null) return;

    try {
      final List<Map<String, dynamic>> encoded =
      _songStatuses.values.map((status) => status.toJson()).toList();
      await _prefs!.setString('song_statuses', json.encode(encoded));
    } catch (e) {
      print('Error saving song statuses: $e');
    }
  }

  // 更新单个歌曲状态
  Future<void> updateSongStatus(int songId, {bool? isLiked, bool? isCollected}) async {
    if (_songStatuses.containsKey(songId)) {
      final status = _songStatuses[songId]!;
      if (isLiked != null) status.isLiked.value = isLiked;
      if (isCollected != null) status.isCollected.value = isCollected;
    } else {
      _songStatuses[songId] = SongStatus(
        id: songId,
        liked: isLiked ?? false,
        collected: isCollected ?? false,
      );
    }
    await _saveToStorage();
  }

  // 从网络响应更新状态
  Future<void> updateFromNetworkResponse(int songId, {required bool isLiked, required bool isCollected}) async {
    await updateSongStatus(songId, isLiked: isLiked, isCollected: isCollected);
  }

  // 获取歌曲状态
  SongStatus? getSongStatus(int songId) => _songStatuses[songId];

  // 获取歌曲点赞状态的响应式值
  bool getLikedStatus(int songId) =>
      _songStatuses[songId]?.isLiked.value ?? false;

  // 获取歌曲收藏状态的响应式值
  bool getCollectedStatus(int songId) =>
      _songStatuses[songId]?.isCollected.value ?? false;

  // 批量更新歌曲状态
  Future<void> updateBatchSongStatus(List<SongStatus> statuses) async {
    for (var status in statuses) {
      _songStatuses[status.id] = status;
    }
    await _saveToStorage();
  }

  // 清除所有状态
  Future<void> clearAllStatuses() async {
    _songStatuses.clear();
    await _saveToStorage();
  }
}