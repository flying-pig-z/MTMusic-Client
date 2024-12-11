import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player_miao/common_widget/Song_widegt.dart';
import '../../api/api_music_likes.dart';
import '../../common/download_manager.dart';
import '../../common_widget/app_data.dart';
import '../../models/universal_bean.dart';
import '../../view_model/home_view_model.dart';
import '../music_view.dart';

class MyDownloadView extends StatefulWidget {
  const MyDownloadView({super.key});

  @override
  State<MyDownloadView> createState() => _MyDownloadViewState();
}

class _MyDownloadViewState extends State<MyDownloadView> {
  final listVM = Get.put(HomeViewModel());
  bool _isSelectMode = false;
  final List<bool> _mySongListSelections = List.generate(2, (index) => false);
  List<bool> _selectedItems = [];
  List<Song> _songs = [];
  final downloadManager = Get.put(DownloadManager());
  bool needUpdate = false;

  @override
  void initState() {
    super.initState();
    _getSongs();
  }

  void _toggleSelectMode() {
    setState(() {
      _isSelectMode = !_isSelectMode;
      if (!_isSelectMode) {
        _selectedItems = List.generate(_songs.length, (index) => false);
      }
    });
  }

  void _getSongs() async {
    setState(() {
      _songs = downloadManager.getLocalSongs();
      _selectedItems = List.generate(_songs.length, (index) => false);
    });
  }

  void _selectAll() {
    setState(() {
      _selectedItems = List.generate(_songs.length, (index) => true);
    });
  }

  void _deleteSongs(List<bool> selectedItems) {
    // List<Song> songsToDelete = [];
    for (int i = 0; i < selectedItems.length; i++) {
      if (selectedItems[i]) {
        // songsToDelete.add(_songs[i]);
        downloadManager.removeSong(_songs[i].id);
      }
    }

    // 重新加载歌曲列表
    _getSongs();
  }

  void _deleteSong(int index) {
    downloadManager.removeSong(_songs[index].id);
    _getSongs();
  }

  void _showSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Row(
            children: [
              const Text(
                "添加到",
              ),
              Text(
                '(${_selectedItems.where((item) => item).length} 首)',
                style: const TextStyle(color: Color(0xff429482), fontSize: 16),
              )
            ],
          ),
          content: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                for (int i = 0; i < _mySongListSelections.length; i++)
                  _buildSongListTile(i),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xff429482),
                minimumSize: const Size(130, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              child: const Text(
                "保存",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSongListTile(int index) {
    return ListTile(
      title: Text("我的歌单 $index"),
      trailing: Checkbox(
        value: _mySongListSelections[index],
        onChanged: (value) {
          setState(() {
            _mySongListSelections[index] = value ?? false;
          });
        },
        shape: const CircleBorder(),
        activeColor: const Color(0xff429482),
      ),
      onTap: () {
        setState(() {
          _mySongListSelections[index] = !_mySongListSelections[index];
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(true); // 或者根据具体逻辑返回其他值
        return false; // 返回 false 来防止默认的返回行为
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
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            centerTitle: true,
            elevation: 0,
            leading: !_isSelectMode
                ? IconButton(
                    onPressed: () {
                      Get.back(result: needUpdate);
                    },
                    icon: Image.asset(
                      "assets/img/back.png",
                      width: 25,
                      height: 25,
                      fit: BoxFit.contain,
                    ),
                  )
                : TextButton(
                    onPressed: _selectAll,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      minimumSize: const Size(50, 40), // 设置最小宽度，确保文字有足够空间
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8), // 添加水平内边距
                    ),
                    child: const Text(
                      '全选',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
            title: _isSelectMode
                ? Text(
                    '已选中 ${_selectedItems.where((item) => item).length} 首歌曲',
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  )
                : const Text(
                    '本地下载',
                    style: TextStyle(color: Colors.black),
                  ),
            actions: [
              if (_isSelectMode)
                TextButton(
                    onPressed: () {
                      setState(() {
                        _isSelectMode = false;
                        _selectedItems =
                            List.generate(_songs.length, (index) => false);
                      });
                    },
                    child: const Text(
                      "完成",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ))
            ],
          ),
          body: Container(
            padding: const EdgeInsets.only(left: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: _songs.isEmpty
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MusicView(
                                        songList: _songs,
                                        initialSongIndex: 0,
                                        onSongStatusChanged:
                                            (index, isCollected, isLiked) {
                                          setState(() {
                                            // 更新父组件中的数据
                                            _songs[index].collection =
                                                isCollected;
                                            _songs[index].likes = isLiked;
                                            downloadManager.updateSongInfo(
                                                _songs[index].id,
                                                isCollected,
                                                isLiked);
                                          });
                                        },
                                      ),
                                    ),
                                  );
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
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          '${_songs.length}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: _songs.isEmpty ? null : _toggleSelectMode,
                      icon: Image.asset(
                        "assets/img/list_op.png",
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _songs.length,
                    itemBuilder: (BuildContext context, int index) {
                      final song = _songs[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: ListTile(
                          leading: _isSelectMode
                              ? Checkbox(
                                  value: _selectedItems[index],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedItems[index] = value!;
                                    });
                                  },
                                  shape: const CircleBorder(),
                                  activeColor: const Color(0xff429482),
                                )
                              : null,
                          title: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  song.artistPic,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 10), // 添加一些间距
                              Expanded(
                                // 使用 Expanded 让文本占据剩余空间
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      song.title,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      song.artist,
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          trailing: _isSelectMode
                              ? null
                              : Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: InkWell(
                                    onTap: () async {
                                      setState(() {
                                        song.likes = !song.likes!;
                                      });

                                      UniversalBean response =
                                          await LikesApiMusic().likesMusic(
                                              musicId: song.id,
                                              Authorization:
                                                  AppData().currentToken);

                                      if (response.code != 200) {
                                        setState(() {
                                          song.likes = !song.likes!;
                                        });
                                      }
                                    },
                                    child: song.likes!
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
                          // 添加点击事件
                          onTap: _isSelectMode
                              ? () {
                                  // 在选择模式下点击整行触发复选框
                                  setState(() {
                                    _selectedItems[index] =
                                        !_selectedItems[index];
                                  });
                                }
                              : () {
                                  // 非选择模式下跳转到播放页面
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MusicView(
                                        songList: _songs,
                                        initialSongIndex: index,
                                        onSongStatusChanged:
                                            (index, isCollected, isLiked) {
                                          setState(() {
                                            // 更新父组件中的数据
                                            _songs[index].collection =
                                                isCollected;
                                            _songs[index].likes = isLiked;
                                            downloadManager.updateSongInfo(
                                                song.id,
                                                isCollected,
                                                isLiked);
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _isSelectMode
              ? BottomAppBar(
                  height: 140, // 增加 BottomAppBar 的高度
                  child: SingleChildScrollView(
                    // 使用 SingleChildScrollView 包装内容
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // 左半边 "添加到" 按钮
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    _showSelectionDialog();
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 25,
                                        height: 25,
                                        child:
                                            Image.asset("assets/img/add.png"),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text("添加到"),
                                    ],
                                  ),
                                ),
                              ),
                              // 中间分隔线
                              Container(
                                height: 50,
                                width: 2,
                                color: const Color(0xff429482),
                              ),
                              // 右半边 "删除" 按钮
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    _deleteSongs(_selectedItems);
                                    needUpdate = true;
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: Image.asset(
                                            "assets/img/delete.png"),
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
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isSelectMode = false;
                              _selectedItems = List.generate(
                                  _songs.length, (index) => false);
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
      ),
    );
  }

  Future _bottomSheet(BuildContext context, int index) {
    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        builder: (context) => Container(
              height: 150,
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          IconButton(
                            onPressed: () {
                              _deleteSong(index);
                              Navigator.pop(context);
                            },
                            icon: Image.asset("assets/img/list_remove.png"),
                            iconSize: 60,
                          ),
                          const Text("删除")
                        ],
                      ),
                      Column(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Image.asset("assets/img/list_collection.png"),
                            iconSize: 60,
                          ),
                          const Text("收藏")
                        ],
                      ),
                      Column(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Image.asset("assets/img/list_good.png"),
                            iconSize: 60,
                          ),
                          const Text("点赞")
                        ],
                      ),
                      Column(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Image.asset("assets/img/list_comment.png"),
                            iconSize: 60,
                          ),
                          const Text("评论")
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ));
  }
}
