class MusicsListBean {
  int? code;
  String? msg;
  List<MusicItem>? data;

  MusicsListBean.fromMap(Map map) {
    code = map['code'];
    msg = map['msg'];
    if (map['data'] != null && map['data'] is List) {
      data = (map['data'] as List).map((item) => MusicItem.fromMap(item)).toList();
    }
  }
}

class MusicItem {
  int? id;
  String? name;
  String? coverPath;
  String? musicPath;
  String? singerName;
  String? uploadUserName;
  bool? likeOrNot;
  bool? collectOrNot;

  MusicItem.fromMap(Map map) {
    id = map['id'];
    name = map['name'];
    coverPath = map['coverPath'];
    musicPath = map['musicPath'];
    singerName = map['singerName'];
    uploadUserName = map['uploadUserName'];
    likeOrNot = map['likeOrNot'];
    collectOrNot = map['collectOrNot'];
  }
}