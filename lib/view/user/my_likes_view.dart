import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player_miao/api/api_music_likes_list.dart';
import 'package:music_player_miao/common_widget/app_data.dart';
import 'package:music_player_miao/models/getLikeList_bean.dart';
import 'package:music_player_miao/view_model/home_view_model.dart';
import '../music_view.dart';
import '../../common_widget/Song_widegt.dart';
import '../../common/download_manager.dart';

/// 我的点赞页面
class MyLikesView extends StatefulWidget {
  const MyLikesView({Key? key}) : super(key: key);

  @override
  State<MyLikesView> createState() => _MyLikesViewState();
}

class _MyLikesViewState extends State<MyLikesView> {
  // 存储已点赞歌曲的列表
  List<LikeListData> likedSongs = [];
  // 是否处于多选模式
  bool _isSelectMode = false;
  // 记录每首歌曲是否被选中的状态
  List<bool> _selectedItems = [];
  // 获取全局状态管理器实例
  final listVM = Get.put(HomeViewModel());
  final downloadManager = Get.put(DownloadManager());

  @override
  void initState() {
    super.initState();
    // 页面初始化时获取点赞歌曲列表
    _fetchLikedSongs();
  }

  /// 从服务器获取用户点赞的歌曲列表
  Future<void> _fetchLikedSongs() async {
    try {
      // 调用API获取点赞列表
      LikeListBean response = await LikesListApi().getUserLikesList(
        Authorization: AppData().currentToken,
      );

      // 如果请求成功且数据不为空，更新状态
      if (response.code == 200 && response.data != null) {
        setState(() {
          likedSongs = response.data!;
          // 初始化选中状态列表，默认全部未选中
          _selectedItems = List.generate(likedSongs.length, (index) => false);
        });
      }
    } catch (error) {
      print('Error fetching liked songs: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // 设置背景图片
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/img/app_bg.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // 自定义应用栏
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          elevation: 0,
          // 根据是否是多选模式显示不同的前导图标
          leading: !_isSelectMode
              ? IconButton( // 非多选模式显示返回按钮
                  onPressed: () {
                    Get.back(result: true);
                  },
                  icon: Image.asset(
                    "assets/img/back.png",
                    width: 25,
                    height: 25,
                    fit: BoxFit.contain,
                  ),
                )
              : TextButton( // 多选模式显示全选按钮
                  onPressed: () {
                    setState(() {
                      _selectedItems = List.generate(likedSongs.length, (index) => true);
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    minimumSize: const Size(50, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text(
                    '全选',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
          // 根据是否是多选模式显示不同的标题
          title: _isSelectMode
              ? Text(
                  '已选中 ${_selectedItems.where((item) => item).length} 首歌曲',
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                )
              : const Text(
                  '我的点赞',
                  style: TextStyle(color: Colors.black),
                ),
          // 多选模式下显示完成按钮
          actions: [
            if (_isSelectMode)
              TextButton(
                onPressed: () {
                  setState(() {
                    _isSelectMode = false;
                    _selectedItems = List.generate(likedSongs.length, (index) => false);
                  });
                },
                child: const Text(
                  "完成",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ))
          ],
        ),
        // 主体内容
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              // 顶部操作栏
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 播放全部按钮组
                    Row(
                      children: [
                        IconButton(
                          onPressed: likedSongs.isEmpty
                              ? null
                              : () {
                                  // TODO: 实现播放全部功能
                                },
                          icon: Image.asset(
                            "assets/img/button_play.png",
                            width: 20,
                            height: 20,
                          ),
                        ),
                        const Text(
                          '播放全部',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '(${likedSongs.length})',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    // 多选模式切换按钮
                    IconButton(
                      onPressed: likedSongs.isEmpty ? null : () {
                        setState(() {
                          _isSelectMode = !_isSelectMode;
                          if (!_isSelectMode) {
                            _selectedItems = List.generate(likedSongs.length, (index) => false);
                          }
                        });
                      },
                      icon: Image.asset(
                        "assets/img/list_op.png",
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ],
                ),
              ),
              // 歌曲列表
              Expanded(
                child: ListView.builder(
                  itemCount: likedSongs.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final song = likedSongs[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                      // 根据是否是多选模式执行不同的点击操作
                      onTap: _isSelectMode
                          ? () {
                              setState(() {
                                _selectedItems[index] = !_selectedItems[index];
                              });
                            }
                          : () async {
                              // 创建Song对象列表用于播放
                              List<Song> songList = likedSongs.map((song) => Song(
                                    id: song.id ?? 0,
                                    title: song.name ?? '未知歌曲',
                                    artist: song.singerName ?? '未知歌手',
                                    artistPic: song.coverPath ?? '',
                                    pic: song.coverPath ?? '',
                                    musicurl: song.musicPath ?? '',
                                    likes: song.likes,
                                    collection: song.collection,
                                  )).toList();

                              // 导航到音乐播放页面
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MusicView(
                                    songList: songList,
                                    initialSongIndex: index,
                                    // 歌曲状态变化回调
                                    onSongStatusChanged: (index, isCollected, isLiked) {
                                      setState(() {
                                        songList[index].collection = isCollected;
                                        songList[index].likes = isLiked;
                                        downloadManager.updateSongInfo(
                                          songList[index].id,
                                          isCollected,
                                          isLiked,
                                        );
                                      });
                                    },
                                  ),
                                ),
                              );

                              // 从播放页面返回时刷新列表
                              if (result != null) {
                                _fetchLikedSongs();
                              }
                            },
                      // 歌曲列表项布局
                      title: Row(
                        children: [
                          // 多选模式下显示复选框
                          if (_isSelectMode)
                            Checkbox(
                              value: _selectedItems[index],
                              onChanged: (value) {
                                setState(() {
                                  _selectedItems[index] = value!;
                                });
                              },
                              shape: const CircleBorder(),
                              activeColor: const Color(0xff429482),
                            ),
                          // 歌曲封面图
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              song.coverPath ?? '',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  "assets/img/artist_pic.png",
                                  width: 60,
                                  height: 60,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // 歌曲信息
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.name ?? '未知歌曲',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  song.singerName ?? '未知歌手',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // 多选模式下显示底部操作栏
        bottomNavigationBar: _isSelectMode
            ? BottomAppBar(
                height: 140,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 底部操作按钮
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // "添加到"按钮
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  // TODO: 实现添加到功能
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 25,
                                      height: 25,
                                      child: Image.asset("assets/img/add.png"),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text("添加到"),
                                  ],
                                ),
                              ),
                            ),
                            // 分隔线
                            Container(
                              height: 50,
                              width: 2,
                              color: const Color(0xff429482),
                            ),
                            // "删除"按钮
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  // TODO: 实现批量删除功能
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: Image.asset("assets/img/delete.png"),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text("删除"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 取消按钮
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isSelectMode = false;
                            _selectedItems = List.generate(likedSongs.length, (index) => false);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff429482),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: const Text(
                          '取消',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }
} 