import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player_miao/common_widget/app_data.dart';
import '../api/api_music_rank.dart';
import '../common/download_manager.dart';
import '../models/getRank_bean.dart';
import '../view_model/rank_view_model.dart';
import 'music_view.dart';
import '../common_widget/Song_widegt.dart';
import '../api/api_collection.dart';
import '../api/api_music_likes.dart';
import '../api/api_music_list.dart';
import '../models/universal_bean.dart';
import 'comment_view.dart';
import '../models/getMusicList_bean.dart';

class RankView extends StatefulWidget {
  const RankView({super.key});

  @override
  State<RankView> createState() => _RankViewState();
}

class _RankViewState extends State<RankView> with AutomaticKeepAliveClientMixin {
  final rankVM = Get.put(RankViewModel());
  List rankNames = [];
  List rankSingerName = [];
  List rankCoverPath = [];
  List rankMusicPath = [];
  List<Song> songs = [];

  final downloadManager = Get.put(DownloadManager());

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchTop50Data();
  }

  Future<void> _onRefresh() async {
    await _fetchTop50Data();
  }

  Future<void> _fetchTop50Data() async {
    try {
      RankBean bean2 = await GetRank().getRank(Authorization: AppData().currentToken);
      if (bean2.code != 200) return;
      rankNames.clear();
      rankSingerName.clear();
      rankCoverPath.clear();
      rankMusicPath.clear();

      setState(() {
        List<int> ids = bean2.data!.map((data) => data.id!).toList();
        rankNames = bean2.data!.map((data) => data.name!).toList();
        rankSingerName = bean2.data!.map((data) => data.singerName!).toList();
        rankCoverPath = bean2.data!.map((data) => data.coverPath!).toList();
        rankMusicPath = bean2.data!.map((data) => data.musicPath!).toList();

        for (int i = 0; i < ids.length; i++) {
          print(ids[i]);
        }

        songs.clear();

        if (rankNames.isNotEmpty &&
            rankNames.length == rankSingerName.length &&
            rankNames.length == rankCoverPath.length &&
            rankNames.length == rankMusicPath.length) {
          for (int i = 0; i < rankNames.length; i++) {
            songs.add(Song(
              artistPic: rankCoverPath[i],
              title: rankNames[i],
              artist: rankSingerName[i],
              musicurl: rankMusicPath[i],
              pic: rankCoverPath[i],
              id: ids[i],
              likes: null,
              collection: null,
            ));
          }
        }
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            //头部
            const Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    '喵听排行榜',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Top50',
                    style: TextStyle(
                        color: Color(0xffCE0000),
                        fontSize: 40,
                        fontWeight: FontWeight.w500),
                  ),
                  // SizedBox(height: 10),
                  // Text(
                  //   '2023/12/12更新  1期',
                  //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                // 播放全部
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MusicView(
                      songList: songs,
                      initialSongIndex: 0,
                      onSongStatusChanged: (index, isCollected, isLiked) {
                        setState(() {
                          songs[index].collection = isCollected;
                          songs[index].likes = isLiked;
                          downloadManager.updateSongInfo(songs[index].id, isCollected, isLiked);
                        });
                      },
                    ),
                  ),
                );
              },
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: null, // 移除按钮的点击事件，因为现在整个容器都是可点击的
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
                    const Text(
                      '50',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: const Color(0xff429482),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(), // 修改为始终可滚动
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          itemCount: rankNames.length,
                          itemBuilder: (context, index) {
                            int rankNum = index + 1;
                            return ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MusicView(
                                      songList: songs,
                                      initialSongIndex: index,
                                      onSongStatusChanged: (index, isCollected, isLiked) {
                                        setState(() {
                                          songs[index].collection = isCollected;
                                          songs[index].likes = isLiked;
                                          downloadManager.updateSongInfo(songs[index].id, isCollected, isLiked);
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                              title: Column(
                                children: [
                                  Row(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 25,
                                            child: RichText(
                                              text: TextSpan(
                                                text: rankNum.toString(),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xffCE0000),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Container(
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
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                rankCoverPath[index],
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    Container(
                                                      width: 60,
                                                      height: 60,
                                                      color: Colors.grey[100],
                                                      child: const Icon(Icons.music_note, size: 30),
                                                    ),
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  if (loadingProgress == null) return child;
                                                  return Container(
                                                    width: 60,
                                                    height: 60,
                                                    color: Colors.grey[100],
                                                    child: Center(
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor: const AlwaysStoppedAnimation<Color>(
                                                            Color(0xff429482)),
                                                        value: loadingProgress.expectedTotalBytes != null
                                                            ? loadingProgress.cumulativeBytesLoaded /
                                                            loadingProgress.expectedTotalBytes!
                                                            : null,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          SizedBox(
                                            width: 170,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  rankNames[index],
                                                  maxLines: 1,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  rankSingerName[index],
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 14
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                )
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 18),
                                        ],
                                      ),
                                      // IconButton(
                                      //   onPressed: () {
                                      //     _bottomSheet(context, index);
                                      //   },
                                      //   icon: Image.asset(
                                      //     'assets/img/More.png',
                                      //     width: 25,
                                      //     height: 25,
                                      //     errorBuilder: (context, error, stackTrace) {
                                      //       print('Error loading image: $error');
                                      //       return const Icon(Icons.error, size: 25);
                                      //     },
                                      //   ),
                                      // ),

                                    ],
                                  ),
                                  const SizedBox(height: 10)
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }

  Future _bottomSheet(BuildContext context, int index) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // 获取当前歌曲的点赞和收藏状态
          bool likesnot = songs[index].likes ?? false;
          bool collectionsnot = songs[index].collection ?? false;

          return Container(
            height: 150,
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          onPressed: (){},
                          icon: Image.asset("assets/img/list_add.png"),
                          iconSize: 60,
                        ),
                        const Text("加入歌单")
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          onPressed: (){},
                          icon: Image.asset("assets/img/list_download.png"),
                          iconSize: 60,
                        ),
                        const Text("下载")
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () async {
                            // 1. 立即更新UI显示，优化用户体验
                            setState(() {
                              collectionsnot = !collectionsnot;
                              songs[index].collection = collectionsnot;
                            });

                            // 2. 调用收藏API
                            UniversalBean response = await CollectionApiMusic().addCollection(
                              musicId: songs[index].id,
                              Authorization: AppData().currentToken,
                            );

                            // 3. 处理API响应
                            if (response.code != 200) {
                              // 如果API调用失败，恢复原状态
                              setState(() {
                                collectionsnot = !collectionsnot;
                                songs[index].collection = collectionsnot;
                              });
                            } else {
                              // 4. API调用成功，更新全局状态
                              downloadManager.updateSongInfo(
                                songs[index].id,        // 歌曲ID
                                collectionsnot,         // 新的收藏状态
                                songs[index].likes ?? false  // 保持原有的点赞状态
                              );
                            }
                          },
                          icon: SizedBox(
                            width: 60,
                            height: 60,
                            child: Image.asset(
                              // 根据收藏状态显示不同图标
                              collectionsnot
                                ? "assets/img/list_collection.png"    // 已收藏图标
                                : "assets/img/list_collection_un.png" // 未收藏图标
                            ),
                          ),
                        ),
                        const Text("收藏"),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () async {
                            // 1. 立即更新UI显示，优化用户体验
                            setState(() {
                              likesnot = !likesnot;
                              songs[index].likes = likesnot;
                            });

                            // 2. 调用点赞API
                            UniversalBean response = await LikesApiMusic().likesMusic(
                              musicId: songs[index].id,
                              Authorization: AppData().currentToken,
                            );

                            // 3. 处理API响应
                            if (response.code != 200) {
                              // 如果API调用失败，恢复原状态
                              setState(() {
                                likesnot = !likesnot;
                                songs[index].likes = likesnot;
                              });
                            } else {
                              // 4. API调用成功，更新全局状态
                              downloadManager.updateSongInfo(
                                songs[index].id,                    // 歌曲ID
                                songs[index].collection ?? false,   // 保持原有的收藏状态
                                likesnot                           // 新的点赞状态
                              );
                            }
                          },
                          icon: SizedBox(
                            width: 60,
                            height: 60,
                            child: Image.asset(
                              // 根据点赞状态显示不同图标
                              likesnot
                                ? "assets/img/list_good.png"    // 已点赞图标
                                : "assets/img/list_good_un.png" // 未点赞图标
                            ),
                          ),
                        ),
                        const Text("点赞"),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CommentView(
                                  id: songs[index].id,
                                  song: songs[index].title,
                                  singer: songs[index].artist,
                                  cover: songs[index].artistPic,
                                ),
                              ),
                            );
                          },
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
          );
        },
      ),
    );
  }
}