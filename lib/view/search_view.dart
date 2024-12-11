import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/api_music_list.dart';
import '../common/download_manager.dart';
import '../common_widget/Song_widegt.dart';
import '../common_widget/app_data.dart';
import '../models/MusicsListBean.dart';
import 'main_tab_view/main_tab_view.dart';
import 'music_view.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final List<Song> songs = [];
  final TextEditingController _searchController = TextEditingController();
  final downloadManager = Get.put(DownloadManager());

  @override
  void initState() {
    super.initState();
    _loadRecommendData();
  }

  void _loadRecommendData() async {
    MusicsListBean bean = await GetMusic()
        .getMusicList(Authorization: AppData().currentToken, num: 10);
    if (bean.code == 200) {
      setState(() {
        songs.clear();
        for (var data in bean.data!) {
          songs.add(Song(
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/img/app_bg.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            const SizedBox(height: 60),
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildPlayAllButton(),
            Expanded(
              child: _buildSongsList(),
            ),
            MiniPlayer(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: '搜索你想找的音乐',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayAllButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          if (songs.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MusicView(
                  songList: songs,
                  initialSongIndex: 0,
                  onSongStatusChanged: _updateSongStatus,
                ),
              ),
            );
          }
        },
        leading: const Icon(Icons.play_circle_fill,
            color: Colors.blueGrey, size: 30),
        title: const Text(
          '播放全部',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Text(
          '${songs.length}首',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSongsList() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 10),
        itemCount: songs.length,
        itemBuilder: (context, index) => _buildSongItem(index),
      ),
    );
  }

  Widget _buildSongItem(int index) {
    final song = songs[index];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: InkWell(
        onTap: () => _onSongTap(index),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    song.pic,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.music_note, size: 30),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      song.artist,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.grey.shade400,
                ),
                onPressed: () {
                  // 实现更多操作的弹出菜单
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSongTap(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MusicView(
          songList: songs,
          initialSongIndex: index,
          onSongStatusChanged: _updateSongStatus,
        ),
      ),
    );
  }

  void _updateSongStatus(int index, bool isCollected, bool isLiked) {
    setState(() {
      songs[index].collection = isCollected;
      songs[index].likes = isLiked;
      downloadManager.updateSongInfo(songs[index].id, isCollected, isLiked);
    });
  }
}
