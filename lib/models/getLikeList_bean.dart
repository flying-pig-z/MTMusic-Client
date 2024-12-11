class LikeListBean {
  int? code;
  String? msg;
  List<LikeListData>? data;

  LikeListBean.formMap(Map map) {
    code = map['code'];
    msg = map['msg'];
    if (map['data'] is! List) return;
    
    data = (map['data'] as List)
        .map((item) => LikeListData._formMap(item))
        .toList();
  }
}

class LikeListData {
  int? id;
  String? name;
  String? coverPath;
  String? musicPath;
  String? singerName;
  String? uploadUserName;
  bool? likes;
  bool? collection;

  LikeListData._formMap(Map map) {
    id = map['id'];
    name = map['name'];
    coverPath = map['coverPath'];
    musicPath = map['musicPath'];
    singerName = map['singerName'];
    uploadUserName = map['uploadUserName'];
    likes = map['likes'];
    collection = map['collection'];
  }

  // 转换为Map方法,用于数据存储
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coverPath': coverPath,
      'musicPath': musicPath,
      'singerName': singerName,
      'uploadUserName': uploadUserName,
      'likes': likes,
      'collection': collection,
    };
  }
} 