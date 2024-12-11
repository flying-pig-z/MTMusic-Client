class MusicListBean {
  int? code;
  String? msg;
  int? id;
  String? name;
  String? coverPath;
  String? musicPath;
  String? singerName;
  String? uploadUserName;
  bool? likeOrNot;
  bool? collectOrNot;


  MusicListBean.formMap(Map map){
    code = map['code'];
    msg= map['msg'];
    if (map['data'] == '') return;
    Map? data = map['data'];
    if (data == null) return;
    id = data['id'];
    name = data['name'];
    coverPath = data['coverPath'];
    musicPath = data['musicPath'];
    singerName = data['singerName'];
    uploadUserName = data['uploadUserName'];
    likeOrNot = data['likeOrNot'];
    collectOrNot = data['collectOrNot'];
  }
}
