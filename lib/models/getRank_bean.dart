class RankBean {
  int? code;
  String? msg;
  List<DataBean>? data;

  RankBean.formMap(Map map) {
    code = map['code'];
    msg = map['msg'];
    if (map['data'] == null) return;

    List<dynamic>? dataList = map['data'];
    if (dataList == null) return;

    data = dataList
        .map((item) => DataBean._formMap(item))
        .toList();
  }
}

class DataBean {
  int? id;
  String? singerName;
  String? coverPath;
  String? musicPath;
  String? name;

  DataBean._formMap(Map map) {
    id = map['id'];
    singerName = map['singerName'];
    coverPath = map['coverPath'];
    musicPath = map['musicPath'];
    name = map['name'];
  }
}
