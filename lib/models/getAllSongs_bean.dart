class MyMusicListBean {
  int? code;
  String? msg;
  List<DataBean>? data;

  MyMusicListBean.formMap(Map map) {
    code = map['code'];
    msg = map['msg'];
    if (map['data'] is! List) return;

    data = (map['data'] as List)
        .map((item) => DataBean._formMap(item))
        .toList();
  }
}

class DataBean {
  int? songlistId;
  SongDetails? musicDetail; // 修改为单个SongDetails对象

  DataBean._formMap(Map map) {
    songlistId = map['songlistId'];
    musicDetail = SongDetails._formMap(map['musicDetail']); // 直接处理单个对象
  }
}

class SongDetails {
  int? id;
  String? name;
  String? coverPath;
  String? musicPath;
  String? singerName;
  String? uploadUserName;

  SongDetails._formMap(Map map) {
    id = map['id'];
    name = map['name'];
    coverPath = map['coverPath'];
    musicPath = map['musicPath'];
    singerName = map['singerName'];
    uploadUserName = map['uploadUserName'];
  }
}