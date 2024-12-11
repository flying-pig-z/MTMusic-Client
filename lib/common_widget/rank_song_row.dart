import 'package:flutter/material.dart';
import '../api/api_music_likes.dart'; // 导入点赞 API
import '../api/api_collection.dart'; // 导入收藏 API
import '../view_model/comment_page.dart'; // 导入评论页面

class RankSongsRow extends StatelessWidget {
  final Map sObj;
  final VoidCallback onPressedPlay;
  final VoidCallback onPressed;
  final String? rank;

  const RankSongsRow({
    super.key,
    required this.sObj,
    required this.onPressed,
    required this.onPressedPlay,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    rank: sObj["rank"];
    return Column(
      children: [
        Row(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 15,
                  child: RichText(
                    text: TextSpan(
                      text: sObj["rank"],
                      style: TextStyle(
                        fontSize: getRankFontSize(sObj["rank"]),
                        fontWeight: FontWeight.w700,
                        color: Color(0xffCE0000),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    sObj["image"],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 170,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sObj["name"],
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        sObj["artists"],
                        maxLines: 1,
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
            IconButton(
              onPressed: () {
                _bottomSheet(context);
              },
              icon: Image.asset(
                "assets/img/More.png",
                width: 25,
                height: 25,
              ),
            ),
            const SizedBox(height: 20)
          ],
        ),
        const SizedBox(height: 10)
      ],
    );
  }

  double getRankFontSize(String rank) {
    switch (rank) {
      case '1':
      case '2':
      case '3':
        return 30.0;
      default:
        return 20.0;
    }
  }

  Future _bottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        height: 210,
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
                        // TODO: 加入歌单的逻辑
                      },
                      icon: Image.asset("assets/img/list_add.png"),
                      iconSize: 60,
                    ),
                    Text("加入歌单"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        // TODO: 下载的逻辑
                      },
                      icon: Image.asset("assets/img/list_download.png"),
                      iconSize: 60,
                    ),
                    Text("下载"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () async {
                        // 点击收藏按钮时调用收藏 API
                        await _toggleCollect();
                      },
                      icon: Image.asset("assets/img/list_collection.png"),
                      iconSize: 60,
                    ),
                    Text("收藏"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () async {
                        // 点击点赞按钮时调用点赞 API
                        await _toggleLike();
                      },
                      icon: Image.asset("assets/img/list_good.png"),
                      iconSize: 60,
                    ),
                    Text("点赞"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        // 跳转到评论页面
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CommentPage(),
                          ),
                        );
                      },
                      icon: Image.asset("assets/img/list_comment.png"),
                      iconSize: 60,
                    ),
                    Text("评论"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // TODO: 查看详情页的逻辑
              },
              child: Text(
                "查看详情页",
                style: const TextStyle(color: Colors.black, fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffE6F4F1),
                padding: const EdgeInsets.symmetric(vertical: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "取消",
                style: const TextStyle(color: Colors.black, fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff429482),
                padding: const EdgeInsets.symmetric(vertical: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 点赞功能
  Future<void> _toggleLike() async {
    final api = LikesApiMusic(); // 实例化点赞 API
    try {
      String authorizationToken = 'eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiI1ZDBmY2Q3ZThlYmY0N2QzOThlNmVjNDQ0ZTM5NTAxNSIsInN1YiI6IjEiLCJpc3MiOiJmbHlpbmdwaWciLCJpYXQiOjE3MzEwNDM3NTgsImV4cCI6MTczMzYzNTc1OH0.5jfhZtK46YNSC7KCaBWiPxSLO7Ym6ntBXnQwfsvMrCw'; // 替换为实际的授权 Token
      await api.likesMusic(
        musicId: sObj['id'], // 使用当前音乐的 ID
        Authorization: authorizationToken,
      );
      print('Liked music ID: ${sObj['id']}');
    } catch (e) {
      print('Error liking music: $e');
    }
  }

  // 收藏功能
  Future<void> _toggleCollect() async {
    final api = CollectionApiMusic(); // 实例化收藏 API
    try {
      String authorizationToken = 'eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiI1ZDBmY2Q3ZThlYmY0N2QzOThlNmVjNDQ0ZTM5NTAxNSIsInN1YiI6IjEiLCJpc3MiOiJmbHlpbmdwaWciLCJpYXQiOjE3MzEwNDM3NTgsImV4cCI6MTczMzYzNTc1OH0.5jfhZtK46YNSC7KCaBWiPxSLO7Ym6ntBXnQwfsvMrCw'; // 替换为实际的授权 Token
      await api.addCollection(
        musicId: sObj['id'], // 使用当前音乐的 ID
        Authorization: authorizationToken,
      );
      print('Collected music ID: ${sObj['id']}');
    } catch (e) {
      print('Error collecting music: $e');
    }
  }
}
