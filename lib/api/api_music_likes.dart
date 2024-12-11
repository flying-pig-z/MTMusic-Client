// api/api_client.dart
// ignore_for_file: constant_identifier_names

import 'package:dio/dio.dart';
import 'package:music_player_miao/models/universal_bean.dart';

const String _LikesURL = 'http://8.210.250.29:10010/likes';

class LikesApiMusic {
  final Dio dio = Dio();

  ///点赞
  Future<UniversalBean> likesMusic({
    required int musicId,
    required String Authorization,
  }) async {
    Response response = await dio.post(_LikesURL,
        data: {
          "Authorization": Authorization,
        },
        queryParameters: {'musicId': musicId},
        options: Options(headers: {
          'Authorization': Authorization,
          'Content-Type': 'application/json;charset=UTF-8'
        }));
    print(response.data);
    return UniversalBean.formMap(response.data);
  }
}
