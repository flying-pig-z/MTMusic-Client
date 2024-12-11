
import '../common_widget/app_data.dart';

class LoginBean {
  int? code;
  String? msg;
  int? id;
  String? email;
  String? token;

  LoginBean.formMap(Map map){
    code = map['code'];
    msg= map['msg'];
    if (map['data'] == '') return;
    Map? data = map['data'];
    if (data == null) return;
    id = data['id'];
    email = data['email'];
    token = data['token'];
    if (token != null) {
      AppData appData = AppData();
      appData.box.write('currentToken', token);
    }
  }
}

