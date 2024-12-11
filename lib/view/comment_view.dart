import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player_miao/api/api_music_return.dart';
import 'package:music_player_miao/common_widget/app_data.dart';
import 'package:music_player_miao/models/getComment_bean.dart';
import 'package:music_player_miao/models/universal_bean.dart';
import 'package:music_player_miao/widget/text_field.dart';

class CommentView extends StatefulWidget {
  final int id;
  final String song;
  final String singer;
  final String cover;

  const CommentView({
    super.key,
    required this.id,
    required this.song,
    required this.singer,
    required this.cover,
  });

  @override
  _CommentViewState createState() => _CommentViewState();
}

class _CommentViewState extends State<CommentView> {
  List comments = [];
  ScrollController _scrollController = ScrollController();
  TextEditingController commentController = TextEditingController();
  FocusNode commentFocusNode = FocusNode();
  List commentTimes = [];
  List commentHeader = [];
  List commentName = [];
  bool ascendingOrder = true;
  int _page = 1;
  int _pageSize = 10;
  int _total = 0;
  bool _isLoading = false;
  bool _hasMoreData = true;
  bool _isSendingComment = false;

  String avatar = AppData().currentAvatar;
  String username = AppData().currentUsername;

  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchCommentData();
    commentController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    commentController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMoreData) {
        _loadMoreData();
      }
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    _page++;
    await _fetchCommentData();

    setState(() {
      _isLoading = false;
    });
  }

  String formatDateTime(String dateTimeStr) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeStr);
      // 格式化时间，只保留年月日时分
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateTimeStr; // 如果解析失败，返回原始字符串
    }
  }

  Future<void> _fetchCommentData() async {
    print('Fetching page $_page');
    try {
      GetCommentBean bean1 = await getCommentApi().getComment(
        musicId: widget.id,
        pageNo: _page,
        pageSize: _pageSize,
        Authorization: AppData().currentToken,
      );

      if (bean1.rows == null || bean1.rows!.isEmpty) {
        setState(() {
          _hasMoreData = false;
          _isInitialLoading = false;
        });
        return;
      }

      _total = bean1.total!;

      setState(() {
        if (_page == 1) {
          comments =
              bean1.rows!.map((rows) => rows.content ?? 'No content').toList();
          commentTimes = bean1.rows!
              .map((rows) => formatDateTime(rows.time ?? 'Unknown time'))
              .toList();
          commentHeader = bean1.rows!
              .map((rows) => rows.avatar ?? 'Default avatar')
              .toList();
          commentName =
              bean1.rows!.map((rows) => rows.username ?? 'Anonymous').toList();
        } else {
          comments.addAll(
              bean1.rows!.map((rows) => rows.content ?? 'No content').toList());
          commentTimes.addAll(bean1.rows!
              .map((rows) => formatDateTime(rows.time ?? 'Unknown time'))
              .toList());
          commentHeader.addAll(bean1.rows!
              .map((rows) => rows.avatar ?? 'Default avatar')
              .toList());
          commentName.addAll(
              bean1.rows!.map((rows) => rows.username ?? 'Anonymous').toList());
        }

        _hasMoreData = comments.length < _total;
        _isInitialLoading = false;
      });
    } catch (error) {
      print('Error fetching comment data: $error');
      setState(() {
        _isLoading = false;
        _isInitialLoading = false;
      });
    }
  }

  void _sortComments() {
    setState(() {
      comments = comments.reversed.toList();
      commentTimes = commentTimes.reversed.toList();
      commentHeader = commentHeader.reversed.toList();
      commentName = commentName.reversed.toList();
    });
  }

  // 新增：检查评论是否有效
  bool isCommentValid() {
    String comment = commentController.text.trim();
    return comment.isNotEmpty;
  }

  void submitComment() async {
    String comment = commentController.text.trim();
    if (!isCommentValid()) {
      return; // 直接返回，不显示提示
    }

    setState(() {
      _isSendingComment = true;
    });

    try {
      UniversalBean bean = await commentMusic().comment(
        musicId: widget.id,
        content: comment,
        Authorization: AppData().currentToken,
      );

      if (bean.code == 200) {
        commentController.clear();
        setState(() {
          comments = [comment, ...comments];
          commentTimes = [
            formatDateTime(DateTime.now().toString()),
            ...commentTimes
          ];
          commentHeader = [avatar, ...commentHeader];
          commentName = [username, ...commentName];
          _total++;
        });
      }
    } catch (error) {
      print('Error submitting comment: $error');
    } finally {
      setState(() {
        _isSendingComment = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xffF6FFD1),
        title: Text(
          '评论($_total)',
          style: TextStyle(color: Colors.black, fontSize: 22),
        ),
        elevation: 0,
        leading: IconButton(
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
      ),
      body: Column(
        children: [
          Container(
            height: 80,
            padding: const EdgeInsets.only(left: 20, right: 10),
            decoration: BoxDecoration(
                color: const Color(0xffF9F2AF),
                borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( // 添加 Expanded 来限制整个左侧 Row 的宽度
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.cover,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded( // 添加 Expanded 来限制文本列的宽度
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.song,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.singer,
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
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 评论区标题和排序
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "评论区",
                  style: TextStyle(fontSize: 18),
                ),
                Row(
                  children: [
                    const Text(
                      "时间",
                      style: TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          ascendingOrder = !ascendingOrder;
                          _sortComments();
                        });
                      },
                      icon: Image.asset(
                        ascendingOrder
                            ? "assets/img/commend_up.png"
                            : "assets/img/commend_down.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          // 评论列表
          Expanded(
            child: _isInitialLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xff429482),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: comments.length + 1, // +1 为了显示加载更多的提示
                    itemBuilder: (context, index) {
                      if (index == comments.length) {
                        // 显示加载状态或"没有更多数据"的提示
                        return Container(
                          padding: const EdgeInsets.all(16.0),
                          alignment: Alignment.center,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Color(0xff429482),
                                )
                              : _hasMoreData
                                  ? const Text('上拉加载更多')
                                  : const Text('没有更多评论了'),
                        );
                      }

                      return ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(commentHeader[index])),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(commentName[index],
                                        style: const TextStyle(fontSize: 18)),
                                    Text(
                                      commentTimes[index],
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 50, top: 10, bottom: 20),
                              child: Text(
                                comments[index],
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                            Container(
                              width: 560,
                              height: 2,
                              color: const Color(0xffE3F0ED),
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // 评论输入框
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFieldColor(
                    controller: commentController,
                    hintText: '来发表你的评论吧!',
                    enabled: !_isSendingComment,
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: isCommentValid() && !_isSendingComment
                      ? submitComment
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff429482),
                    foregroundColor: Colors.black45,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(30, 44),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: _isSendingComment
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          '发送',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
