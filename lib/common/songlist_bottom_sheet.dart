import 'package:flutter/material.dart';
import '../api/api_songlist.dart';
import '../models/search_bean.dart';
import '../common_widget/app_data.dart';

class SonglistBottomSheet extends StatefulWidget {
  final Function(int songlistId)? onSonglistSelected;

  const SonglistBottomSheet({Key? key, this.onSonglistSelected})
      : super(key: key);

  @override
  State<SonglistBottomSheet> createState() => _SonglistBottomSheetState();
}

class _SonglistBottomSheetState extends State<SonglistBottomSheet> {
  final SonglistApi _songlistApi = SonglistApi();
  SearchBean? _songlistData;
  bool _isLoading = true;
  String _error = '';
  bool _isDisposed = false; // 添加销毁状态标记

  @override
  void initState() {
    super.initState();
    _loadSonglists();
  }

  @override
  void dispose() {
    _isDisposed = true; // 组件销毁时设置标记
    super.dispose();
  }

  Future<void> _loadSonglists() async {
    if (_isDisposed) return; // 检查是否已销毁

    try {
      setState(() => _isLoading = true);
      final songlistData =
          await _songlistApi.getSonglist(Authorization: AppData().currentToken);

      if (!_isDisposed) {
        // 设置状态前检查是否已销毁
        setState(() {
          _songlistData = songlistData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!_isDisposed) {
        // 设置状态前检查是否已销毁
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xff429482),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createNewSonglist() async {
    if (_isDisposed) return; // 检查是否已销毁

    final TextEditingController controller = TextEditingController();
    final scaffoldMessenger = ScaffoldMessenger.of(context); // 提前获取引用

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('创建歌单'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: '请输入歌单名称',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );

    if (result != null && result.trim().isEmpty) {
      _showErrorMessage("歌单名称不能为空");
    }

    if (result != null && result.trim().isNotEmpty && result.isNotEmpty && !_isDisposed) {
      try {
        await _songlistApi.addSonglist(
          songlistName: result,
          Authorization: AppData().currentToken,
        );
        _showErrorMessage("创建成功");
        await _loadSonglists();
      } catch (e) {
        _showErrorMessage(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // 标题和添加按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '添加到歌单',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _createNewSonglist,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          const Divider(),
          // 内容区域
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xff429482)),
                    ),
                  )
                : _error.isNotEmpty
                    ? Center(child: Text(_error))
                    : _songlistData?.data == null ||
                            _songlistData!.data!.isEmpty
                        ? const Center(child: Text('暂无歌单'))
                        : ListView.builder(
                            itemCount: _songlistData!.data!.length,
                            itemBuilder: (context, index) {
                              final songlist = _songlistData!.data![index];
                              return InkWell(
                                onTap: () {
                                  if (songlist.id != null && !_isDisposed) {
                                    // 添加状态检查
                                    widget.onSonglistSelected
                                        ?.call(songlist.id!);
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              songlist.name ?? '未命名歌单',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${songlist.musicCount ?? 0} 首歌曲',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
