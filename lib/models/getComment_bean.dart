class GetCommentBean {
  int? code;
  String? msg;
  int? total;
  List<CommentBean>? rows;

  GetCommentBean.formMap(Map<String, dynamic> map) {
    code = map['code'] as int?;
    msg = map['msg'] as String?;

    // 首先获取 data 字段，然后在 data 中查找 total 和 rows
    Map<String, dynamic>? data = map['data'];
    if (data != null) {
      total = data['total'] as int?;

      List<dynamic>? rowList = data['rows'];
      if (rowList != null) {
        rows = rowList.map((item) => CommentBean.formMap(item as Map<String, dynamic>)).toList();
      } else {
        rows = []; // 如果 rows 为空，初始化为空列表
      }
    } else {
      rows = []; // 如果 data 为空，初始化为空列表
    }
  }
}

class CommentBean {
  int? id;
  String? content;
  String? time;
  String? username;
  String? avatar;

  CommentBean.formMap(Map<String, dynamic> map) {
    id = map['id'] as int?;
    content = map['content'] as String? ?? 'No content';
    time = map['time'] as String? ?? 'Unknown time';
    username = map['username'] as String? ?? 'Anonymous';
    avatar = map['avatar'] as String? ?? 'Default avatar';
  }
}