import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:get/get.dart';
import 'package:music_player_miao/api/api_music_return.dart';
import 'package:music_player_miao/common_widget/app_data.dart';
import 'package:music_player_miao/models/search_bean.dart';
import 'package:music_player_miao/view/comment_view.dart';
import 'package:music_player_miao/view/search_view.dart';
import '../../view_model/home_view_model.dart';
import '../api/api_music_likes.dart';
import '../api/api_music_list.dart';
import '../common/download_manager.dart';
import '../common_widget/Song_widegt.dart';
import '../common_widget/list_cell.dart';
import '../models/MusicsListBean.dart';
import '../models/getMusicList_bean.dart';
import '../models/universal_bean.dart';
import 'music_view.dart';
import '../api/api_collection.dart';
import '../api/api_music_likes.dart';
import '../models/universal_bean.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin {
  final homeVM = Get.put(HomeViewModel());

  // final TextEditingController _controller = TextEditingController();
  bool _isSearching = false;
  final downloadManager = Get.put(DownloadManager());
  List<Song> selectedSongs = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchSonglistData();
  }

  Future<void> _onRefresh() async {
    try {
      // 重新获取数据
      await _fetchSonglistData();
    } catch (e) {
      print('Refresh error: $e');
      // 可以在这里添加错误提示
    }
  }

  Future<void> _fetchSonglistData() async {
    try {
      MusicsListBean bean = await GetMusic()
          .getMusicList(Authorization: AppData().currentToken, num: 10);
      setState(() {
        selectedSongs = [];
        for (var data in bean.data!) {
          selectedSongs.add(Song(
            artistPic: data.coverPath!,
            title: data.name!,
            artist: data.singerName!,
            musicurl: data.musicPath!,
            pic: data.coverPath!,
            id: data.id!,
            likes: data.likeOrNot!,
            collection: data.collectOrNot!,
          ));
        }
      });
    } catch (e) {
      print('Error occurred while fetching song list: $e');
    }
  }

  ///轮播图
  List<Map> imgList = [
    {"image": "assets/img/banner.png"},
    {"image": "assets/img/banner1.png"},
    {"image": "assets/img/banner2.png"},
  ];

  List<Song> _filteredData = [];

  Future<void> _filterData(String query) async {
    if (query.isNotEmpty) {
      try {
        // 发起搜索请求
        SearchBean bean = await SearchMusic().search(
          keyword: query,
          Authorization: AppData().currentToken,
        );

        // 如果请求成功且返回的数据不为空
        if (bean.code == 200 && bean.data != null) {
          // 创���一个临时列表来存储所有异步请求
          List<Future<Song?>> songDetailsFutures = [];

          // 循环处理每个搜索结果，通过 id 请求详细信息
          for (var data in bean.data!) {
            if (data.id != null) {
              // 确保 id 不为 null
              // 使用每个歌曲的 id 获取详细信息，并返回一个 Future
              songDetailsFutures.add(GetMusicDetail()
                  .getMusicDetail(
                songId: data.id!,
                Authorization: AppData().currentToken,
              )
                  .then((details) {
                if (details != null) {
                  // 将详细歌曲信息封装成 Song 对象
                  return Song(
                    artistPic: details.artistPic ?? '',
                    // 歌手封面图
                    title: data.name ?? '',
                    // 歌曲名称
                    artist: details.artist ?? '',
                    // 歌手名称
                    musicurl: details.musicurl ?? '',
                    // 歌曲路径
                    pic: details.pic ?? '',
                    // 封面图片路径
                    id: details.id,
                    // 歌曲 ID
                    likes: details.likes,
                    // 是否喜欢
                    collection: details.collection, // 是否收藏
                  );
                }
                return null; // 如果没有详情返回 null
              }).catchError((error) {
                print("Error occurred while fetching song details: $error");
                return null; // 异常处理，返回 null
              }));
            } else {
              print("Song ID is null for song: ${data.name}");
            }
          }

          // 使用 Future.wait 等待所有异步请求完成
          List<Song?> songDetailsList = await Future.wait(songDetailsFutures);

          // 过滤掉 null 值
          List<Song> validSongDetails = songDetailsList
              .where((song) => song != null)
              .cast<Song>()
              .toList();

          // 最后更新 UI，一次性更新 _filteredData
          setState(() {
            _filteredData = validSongDetails; // 更新搜索结果
            _isSearching = true; // 设置正在搜索中
          });

          // 打印最终结果
          print("Filtered Data: $_filteredData");
        } else {
          setState(() {
            _filteredData = [];
            _isSearching = false;
          });
        }
      } catch (error) {
        print("Error occurred during search: $error");
        setState(() {
          _filteredData = [];
          _isSearching = false;
        });
      }
    } else {
      setState(() {
        _filteredData = [];
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    ///轮播图
    var MySwiperWidget = Swiper(
      itemBuilder: (BuildContext context, int index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8), // 添加圆角
          child: Image.asset(
            imgList[index]['image'],
            fit: BoxFit.fill,
          ),
        );
      },
      itemCount: imgList.length,
      pagination: SwiperPagination(
        builder: DotSwiperPaginationBuilder(
          color: Colors.white.withOpacity(0.85),
          activeColor: const Color(0xff429482),
        ),
      ),
      autoplay: true,
      // 开启自动播放
      loop: true,
      // 开启循环
      autoplayDelay: 5000,
      control: const SwiperControl(color: Colors.transparent),
      // 隐藏默认的左右箭头按钮
      viewportFraction: 1.0, // 设置视图比例为1.0，确保图片填充整个容器
    );

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
          children: [
            ///头部
            Container(
              padding: const EdgeInsets.only(left: 20, top: 50),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '喵听',
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10),
                  Text(
                    '你的云端音乐库',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            ///搜索
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchView(),
                        ),
                      );
                    },
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xffF9F2AF),
                        borderRadius: BorderRadius.circular(19),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 1),
                            blurRadius: 0.1,
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 20),
                            alignment: Alignment.centerLeft,
                            width: 30,
                            child: Image.asset(
                              "assets/img/home_search.png",
                              width: 20,
                              height: 20,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "搜索你想找的音乐",
                            style: TextStyle(
                              color: Color(0xffA5A5A5),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            ///推荐+轮播图
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: const Color(0xff429482),
                backgroundColor: Colors.white,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///推荐+轮播图
                      Container(
                        padding:
                            const EdgeInsets.only(left: 20, right: 20, top: 10),
                        child: const Text(
                          '每日推荐',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        height: 186,
                        width: double.infinity,
                        child: MySwiperWidget,
                      ),

                      const SizedBox(height: 10),

                      ///精选歌曲
                      Container(
                        alignment: Alignment.topLeft,
                        padding:
                            const EdgeInsets.only(left: 20, right: 20, top: 5),
                        child: const Text(
                          '精选歌曲',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: selectedSongs.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Container(
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
                                  selectedSongs[index].pic,
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
                                  // loadingBuilder: (context, child, loadingProgress) {
                                  //   if (loadingProgress == null) return child;
                                  //   return Container(
                                  //     width: 60,
                                  //     height: 60,
                                  //     color: Colors.grey[100],
                                  //     child: Center(
                                  //       child: CircularProgressIndicator(
                                  //         strokeWidth: 2,
                                  //         valueColor: const AlwaysStoppedAnimation<Color>(
                                  //             Color(0xff429482)),
                                  //         value: loadingProgress.expectedTotalBytes != null
                                  //             ? loadingProgress.cumulativeBytesLoaded /
                                  //             loadingProgress.expectedTotalBytes!
                                  //             : null,
                                  //       ),
                                  //     ),
                                  //   );
                                  // },
                                ),
                              ),
                            ),
                            title: Text(
                              selectedSongs[index].title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            subtitle: Text(
                              selectedSongs[index].artist,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            trailing: Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: InkWell(
                                onTap: () async {
                                  setState(() {
                                    selectedSongs[index].likes = !selectedSongs[index].likes!;
                                  });

                                  UniversalBean response = await LikesApiMusic()
                                      .likesMusic(
                                      musicId: selectedSongs[index].id,
                                      Authorization: AppData().currentToken);

                                  if (response.code != 200) {
                                    setState(() {
                                      selectedSongs[index].likes = !selectedSongs[index].likes!;
                                    });
                                  }
                                },
                                child: selectedSongs[index].likes!
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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MusicView(
                                    songList: selectedSongs,
                                    initialSongIndex: index,
                                    onSongStatusChanged: (index, isCollected, isLiked) {
                                      setState(() {
                                        selectedSongs[index].collection = isCollected;
                                        selectedSongs[index].likes = isLiked;
                                        downloadManager.updateSongInfo(
                                            selectedSongs[index].id,
                                            isCollected,
                                            isLiked);
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 110,
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
          bool likesnot = selectedSongs[index].likes ?? false;
          bool collectionsnot = selectedSongs[index].collection ?? false;

          return Container(
            height: 150,
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 加入歌单按钮
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Image.asset("assets/img/list_add.png"),
                          iconSize: 60,
                        ),
                        const Text("加入歌单"),
                      ],
                    ),

                    // 下载按钮
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Image.asset("assets/img/list_download.png"),
                          iconSize: 60,
                        ),
                        const Text("下载"),
                      ],
                    ),

                    // 收藏按钮及功能
                    Column(
                      children: [
                        IconButton(
                          onPressed: () async {
                            // 1. 立即更新UI状态，提供即时反馈
                            setState(() {
                              collectionsnot = !collectionsnot;
                              selectedSongs[index].collection = collectionsnot;
                            });

                            // 2. 调用收藏API
                            UniversalBean response =
                                await CollectionApiMusic().addCollection(
                              musicId: selectedSongs[index].id,
                              Authorization: AppData().currentToken,
                            );

                            // 3. 处理API响应
                            if (response.code != 200) {
                              // 3.1 如果API调用失败，回滚状态变化
                              setState(() {
                                collectionsnot = !collectionsnot;
                                selectedSongs[index].collection =
                                    collectionsnot;
                              });
                            } else {
                              // 3.2 API调用成功，更新全局状态管理器
                              downloadManager.updateSongInfo(
                                  selectedSongs[index].id, // 当前歌曲ID
                                  collectionsnot, // 新的收藏状态
                                  selectedSongs[index].likes ??
                                      false // 保持原有的点赞状态
                                  );
                            }
                          },
                          icon: SizedBox(
                            width: 60,
                            height: 60,
                            child: Image.asset(
                                // 根据收藏状态显示对应图标
                                collectionsnot
                                    ? "assets/img/list_collection.png" // 已收藏状态图标
                                    : "assets/img/list_collection_un.png" // 未收藏状态图标
                                ),
                          ),
                        ),
                        const Text("收藏"),
                      ],
                    ),

                    // 点赞按钮及功能
                    Column(
                      children: [
                        IconButton(
                          onPressed: () async {
                            // 1. 立即更新UI状态，提供即时反馈
                            setState(() {
                              likesnot = !likesnot;
                              selectedSongs[index].likes = likesnot;
                            });

                            // 2. 调用点赞API
                            UniversalBean response =
                                await LikesApiMusic().likesMusic(
                              musicId: selectedSongs[index].id,
                              Authorization: AppData().currentToken,
                            );

                            // 3. 处理API响应
                            if (response.code != 200) {
                              // 3.1 如果API调用失败，回滚状态变化
                              setState(() {
                                likesnot = !likesnot;
                                selectedSongs[index].likes = likesnot;
                              });
                            } else {
                              // 3.2 API调用成功，更新全局状态管理器
                              downloadManager.updateSongInfo(
                                  selectedSongs[index].id, // 当前歌曲ID
                                  selectedSongs[index].collection ?? false,
                                  // 保持原有的收藏状态
                                  likesnot // 新的点赞状态
                                  );
                            }
                          },
                          icon: SizedBox(
                            width: 60,
                            height: 60,
                            child: Image.asset(
                                // 根据点赞状态显示对应图标
                                likesnot
                                    ? "assets/img/list_good.png" // 已点赞状态图标
                                    : "assets/img/list_good_un.png" // 未点赞状态图标
                                ),
                          ),
                        ),
                        const Text("点赞"),
                      ],
                    ),

                    // 评论按钮
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            // 关闭底部弹出栏
                            Navigator.pop(context);
                            // 导航到评论页面
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CommentView(
                                  id: selectedSongs[index].id,
                                  song: selectedSongs[index].title,
                                  singer: selectedSongs[index].artist,
                                  cover: selectedSongs[index].artistPic,
                                ),
                              ),
                            );
                          },
                          icon: Image.asset("assets/img/list_comment.png"),
                          iconSize: 60,
                        ),
                        const Text("评论"),
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
