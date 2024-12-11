import 'package:flutter/material.dart';

class CommentPage extends StatefulWidget {
  const CommentPage({Key? key}) : super(key: key);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _comments = ["这是第一个评论", "很喜欢这首歌！"]; // 初始评论示例

  void _addComment() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _comments.insert(0, _controller.text); // 插入到顶部
      });
      _controller.clear(); // 清空输入框
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('评论'),
      ),
      body: Column(
        children: [
          // 评论列表区域
          Expanded(
            child: ListView.builder(
              reverse: true, // 新评论显示在顶部
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(_comments[index]),
                  subtitle: Text('${DateTime.now().difference(DateTime.now().subtract(Duration(minutes: index * 5))).inMinutes} 分钟前'),
                );
              },
            ),
          ),
          const Divider(),
          // 评论输入区域
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '输入你的评论...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onSubmitted: (_) => _addComment(), // 按回车提交评论
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
