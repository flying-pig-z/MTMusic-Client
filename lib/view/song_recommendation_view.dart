import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../api/api_music_rank.dart';
import '../common_widget/app_data.dart';
import '../models/getRank_bean.dart';
import '../common_widget/Song_widegt.dart';
import 'music_view.dart'; // 导入MusicView
import 'package:music_player_miao/common_widget/app_data.dart';
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

class SongRecommendationView extends StatefulWidget {
  const SongRecommendationView({super.key});

  @override
  State<SongRecommendationView> createState() => _SongRecommendationViewState();
}

class _SongRecommendationViewState extends State<SongRecommendationView> with TickerProviderStateMixin {
  bool isLoading = false;
  List rankNames = [];
  List rankSingerName = [];
  List rankCoverPath = [];
  List rankMusicPath = [];
  List<double> relevanceValues = [];
  List<Song> songs = [];
  final downloadManager = Get.put(DownloadManager());
  late AnimationController _animationController;
  late List<Animation<double>> _circleFadeInAnimations;
  late List<AnimationController> _dotAnimationControllers;

  @override
  void initState() {
    super.initState();
    _loadRecommendedSongs();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _circleFadeInAnimations = [];
    _dotAnimationControllers = [];
  }

  Future<void> _loadRecommendedSongs() async {
    setState(() {
      isLoading = true;
    });

    try {
      RankBean bean2 = await GetRank().getRank(Authorization: AppData().currentToken);
      if (bean2.code != 200) return;

      rankNames.clear();
      rankSingerName.clear();
      rankCoverPath.clear();
      rankMusicPath.clear();
      relevanceValues.clear();

      setState(() {
        List<int> ids = bean2.data!.take(6).map((data) => data.id!).toList();
        rankNames = bean2.data!.take(6).map((data) => data.name!).toList();
        rankSingerName = bean2.data!.take(6).map((data) => data.singerName!).toList();
        rankCoverPath = bean2.data!.take(6).map((data) => data.coverPath!).toList();
        rankMusicPath = bean2.data!.take(6).map((data) => data.musicPath!).toList();

        songs.clear();
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
          relevanceValues.add(0.75);
        }
      });
    } catch (e) {
      print('Error fetching data: $e');
    }

    setState(() {
      isLoading = false;
    });

    _resetCircleAnimations();
  }

  void _resetCircleAnimations() {
    _circleFadeInAnimations.clear();
    for (final controller in _dotAnimationControllers) {
      controller.dispose();
    }
    _dotAnimationControllers.clear();

    for (int i = 0; i < songs.length; i++) {
      final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(i * 0.1, (i + 1) * 0.1, curve: Curves.easeInOut),
        ),
      );
      _circleFadeInAnimations.add(fadeIn);

      final dotController = AnimationController(
        duration: Duration(milliseconds: (2000 - relevanceValues[i] * 1500).toInt()),
        vsync: this,
      )..repeat(reverse: true);
      _dotAnimationControllers.add(dotController);
    }

    _animationController.forward(from: 0);
  }

  double _generateRelevance() {
    return 0.6 + math.Random().nextDouble() * 0.4;
  }

  double _getCircleSize(double relevance) {
    return 20.0 + (relevance * 130);
  }

  Map<String, double> _getCirclePosition(int index, int totalItems, Size screenSize) {
    final radius = math.min(screenSize.width, screenSize.height) * 0.28;
    final angle = (index * 2 * math.pi / totalItems) - math.pi / 2;
    return {
      'left': radius * math.cos(angle),
      'top': radius * math.sin(angle),
    };
  }

  Color _getCircleColor(double relevance) {
    return Color(0xFFB2FF59).withOpacity(0.3);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final safeAreaPadding = MediaQuery.of(context).padding;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/img/app_bg.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    '知音推荐',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 先画连接线
                    CustomPaint(
                      size: Size(screenSize.width, screenSize.height),
                      painter: LinePainter(
                        recommendedSongs: songs,
                        relevanceValues: relevanceValues,
                        screenSize: screenSize,
                        lineAnimation: _animationController,
                      ),
                    ),
                    // 画六个圆圈按钮
                    if (!isLoading)
                      Stack(
                        children: List.generate(6, (index) {
                          final song = songs[index];
                          final relevance = relevanceValues[index];
                          final size = _getCircleSize(relevance);
                          final position = _getCirclePosition(index, songs.length, screenSize);

                          return AnimatedPositioned(
                            duration: Duration(milliseconds: 500),
                            left: screenSize.width / 2 + position['left']! - size / 2,
                            top: screenSize.height / 2 + position['top']! - size / 2 - safeAreaPadding.top + 1, // 稍微下移一点
                            child: FadeTransition(
                              opacity: _circleFadeInAnimations.isNotEmpty && index < _circleFadeInAnimations.length
                                  ? _circleFadeInAnimations[index]
                                  : AlwaysStoppedAnimation(0.0),
                              child: SongCircleButton(
                                relevance: relevance,
                                size: size,
                                songTitle: song.title ?? '',
                                artistName: song.artist ?? '',
                                relevancePercentage: (relevance * 100).toInt(),
                                songIndex: index,
                                songList: songs,
                                onPressed: () {
                                  print("Tapped on song: ${song.title} by ${song.artist}");
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
                              ),
                            ),
                          );
                        }),
                      ),
                    ..._dotAnimationControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final dotController = entry.value;

                      return AnimatedBuilder(
                        animation: dotController,
                        builder: (context, child) {
                          final progress = dotController.value;
                          final position = _getCirclePosition(index, songs.length, screenSize);
                          final radius = math.min(screenSize.width, screenSize.height) * 0.28;
                          final angle = (index * 2 * math.pi / songs.length) - math.pi / 2;

                          final dotPosition = Offset(
                            screenSize.width / 2 + position['left']! - progress * (radius - 60) * math.cos(angle),
                            screenSize.height / 2 + position['top']! - progress * (radius - 60) * math.sin(angle),
                          );

                          return Positioned(
                            left: dotPosition.dx - 4,
                            top: dotPosition.dy - 4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.4),
                                    blurRadius: 8,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                    // 中间的刷新按钮
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          isLoading ? Icons.hourglass_empty : Icons.refresh,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () {
                          if (!isLoading) {
                            _animationController.reverse(from: 1);
                            Future.delayed(const Duration(milliseconds: 500), () {
                              _loadRecommendedSongs();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Circle button widget
class SongCircleButton extends StatelessWidget {
  final double relevance;
  final double size;
  final String songTitle;
  final String artistName;
  final int relevancePercentage;
  final int songIndex;
  final List<Song> songList;
  final VoidCallback onPressed;

  const SongCircleButton({
    required this.relevance,
    required this.size,
    required this.songTitle,
    required this.artistName,
    required this.relevancePercentage,
    required this.songIndex,
    required this.songList,
    required this.onPressed,
  });

  Color _getCircleColor() {
    return Color(0xFFFFC1E3);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed, // 绑定点击事件
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _getCircleColor().withOpacity(0.9),

          borderRadius: BorderRadius.circular(size / 2),
          boxShadow: [
            BoxShadow(
              color: _getCircleColor().withOpacity(0.6), // 光晕的颜色
              blurRadius: 12, // 光晕的模糊程度
              spreadRadius: 8, // 光晕的扩散程度
            ),
          ],// 圆形按钮
        ),

        child: Center(
          child: Column(


            children: [
              // 显示相关度百分比
              Text(
                '    ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              // 显示歌曲标题
              Text(
                songTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              // 显示歌手名字
              Text(
                artistName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final List recommendedSongs;
  final List<double> relevanceValues;
  final Size screenSize;
  final Animation<double> lineAnimation;

  LinePainter({
    required this.recommendedSongs,
    required this.relevanceValues,
    required this.screenSize,
    required this.lineAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < recommendedSongs.length; i++) {
      final relevance = relevanceValues[i];
      final position = _getCirclePosition(i, recommendedSongs.length, size);
      final end = Offset(center.dx + position['left']!, center.dy + position['top']!);

      final paint = Paint()
        ..color = Colors.grey.withOpacity(0.2) // 浅灰色，透明度为0.5
        ..strokeWidth = 0.01 + math.pow(relevance, 2) * 10;

      canvas.drawLine(center, end, paint);
    }
  }

  Map<String, double> _getCirclePosition(int index, int totalItems, Size size) {
    final radius = math.min(size.width, size.height) * 0.28;
    final angle = (index * 2 * math.pi / totalItems) - math.pi / 2;
    return {
      'left': radius * math.cos(angle),
      'top': radius * math.sin(angle),
    };
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
