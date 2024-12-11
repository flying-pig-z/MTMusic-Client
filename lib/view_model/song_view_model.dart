import 'package:get/get.dart';

class SongViewModel extends GetxController {
  final recommendedSongs = [
    {
      "id": 1,
      "title": "背对背拥抱",
      "artist": "林俊杰",
      "relevance": 0.9,
      "coverPath": "https://i.scdn.co/image/ab67616d0000b273b9659e2caa82191d633d6363"
    },
    {
      "id": 2,
      "title": "Alone",
      "artist": "Jon Caryl",
      "relevance": 0.8,
      "coverPath": "https://cdns-images.dzcdn.net/images/cover/7c99f6bb157544db8775430007bb7979/264x264.jpg"
    },
    {
      "id": 3,
      "title": "Poyga",
      "artist": "Konsta & Shokir",
      "relevance": 0.7,
      "coverPath": "https://is3-ssl.mzstatic.com/image/thumb/Music112/v4/9f/a7/98/9fa798ea-25fc-f447-196a-c9f8bc894669/cover.jpg/600x600bf-60.jpg"
    },
    {
      "id": 4,
      "title": "光年之外",
      "artist": "邓紫棋",
      "relevance": 0.85,
      "coverPath": "https://i.scdn.co/image/ab67616d0000b273b9659e2caa82191d633d6363"
    },
    {
      "id": 5,
      "title": "起风了",
      "artist": "买辣椒也用券",
      "relevance": 0.75,
      "coverPath": "https://cdns-images.dzcdn.net/images/cover/7c99f6bb157544db8775430007bb7979/264x264.jpg"
    },
    {
      "id": 6,
      "title": "晴天",
      "artist": "周杰伦",
      "relevance": 0.95,
      "coverPath": "https://i.scdn.co/image/ab67616d0000b273b9659e2caa82191d633d6363"
    },
  ].obs;

  // 模拟加载推荐歌曲的方法
  Future<List<Map<String, dynamic>>> loadRecommendedSongs() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));
    return recommendedSongs;
  }
}
