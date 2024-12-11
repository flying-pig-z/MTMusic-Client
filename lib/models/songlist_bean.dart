class SonglistBean {
  int? code;
  String? msg;
  int? id;
  String? name;
  int? musicCount;

  SonglistBean.formMap(Map map) {
    code = map['code'];
    msg = map['msg'];
    if (map['data'] == '') return;
    Map? data = map['data'];
    if (data == null) return;
    id = map['id'];
    name = map['name'];
    musicCount = map['musicCount'];
  }
}
