class UniversalBean {
  int? code;
  String? msg;
  String? data;

  UniversalBean.formMap(Map map) {
    code = map['code'];
    msg = map['msg'];


    if (map['data'] is String) {
      data = map['data'];
    } else if (map['data'] is bool) {
      data = map['data'].toString();
    } else {
      data = null;
    }
  }
}