class SearchBean {
  int? code;
  String? msg;
  List<DataBean>? data;

  SearchBean.formMap(Map map) {
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
  int? musicCount;
  DataBean._formMap(Map map) {
    id = map['id'];
    name = map['name'];
    musicCount = map['musicCount'];
  }
}
