class MyWorks {
  int? code;
  String? msg;
  List<DataBean>? data;

  MyWorks.formMap(Map map) {
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
  String? name;
  String? coverPath;
  String? musicPath;
  String? singerName;

  DataBean._formMap(Map map) {
    id = map['id'];
    name = map['name'];
    coverPath = map['coverPath'];
    musicPath = map['musicPath'];
    singerName = map['singerName'];
  }
}
