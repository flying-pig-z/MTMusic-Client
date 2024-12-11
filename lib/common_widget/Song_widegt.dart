class Song {
  String pic;
  String artistPic;
  String title;
  String artist;
  String? musicurl;
  int id;
  bool? likes;
  bool? collection;

  // 构造函数
  Song({
    required this.pic,
    required this.artistPic,
    required this.title,
    required this.artist,
    required this.musicurl,
    required this.id,
    required this.likes,
    required this.collection,
  });

  // 使用 Map 数据创建 Song 实例
  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      pic: map['coverPath'] ?? '',  // 封面图，假设是 coverPath
      artistPic: map['coverPath'] ?? '',  // 如果没有返回值或字段，可以为空字符串（示例中没有提供 artistPic）
      title: map['name'] ?? '',  // 歌曲名称，假设是 name
      artist: map['singerName'] ?? '',  // 歌手名称，假设是 singerName
      musicurl: map['musicPath'] ?? '',  // 歌曲路径，假设是 musicPath
      id: map['id'] ?? 0,  // 歌曲 ID，假设是 id
      likes: map['likeOrNot'] ?? false,  // 是否喜欢，假设是 likeOrNot
      collection: map['collectOrNot'] ?? false,  // 是否收藏，假设是 collectOrNot
    );
  }
}
