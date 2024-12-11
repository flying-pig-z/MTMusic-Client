import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppData extends GetxController{
  final box = GetStorage();
  bool get isLikes => box.read('isLikes');
  String get currentToken => box.read('currentToken');
  String get currentUsername => box.read('currentUsername') ?? '游客';
  String get currentAvatar=> box.read('currentAvatar') ?? 'http://b.hiphotos.baidu.com/image/pic/item/e824b899a9014c08878b2c4c0e7b02087af4f4a3.jpg';
  set currentToken(String token) => box.write('currentToken', token);
  set currentUsername(String username) => box.write('currentUsername', username);
  set currentAvatar(String avatar) => box.write('currentAvatar', avatar);
}