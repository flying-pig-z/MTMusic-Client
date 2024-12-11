import '../common_widget/app_data.dart';

class GetInfoBean {
  int? code;
  String? msg;
  int? id;
  String? avatar;
  String? username;

  GetInfoBean.formMap(Map map){
    code = map['code'];
    msg = map['msg'];
    if (map['data'] == '') return;
    Map? data = map['data'];
    if (data == null) return;
    id = data['id'];
    avatar = data['avatar'];
    if (avatar != null) {
      AppData appData = AppData();
      appData.box.write('currentAvatar', avatar);
    }
    username = data['username'];
    if (username != null) {
      AppData appData = AppData();
      appData.box.write('currentUsername', username);
    }
  }
}