// api/api_collection.dart

import 'package:dio/dio.dart';
import 'package:music_player_miao/models/universal_bean.dart';

const String _CollectionURL = 'http://8.210.250.29:10010/collections';

class CollectionApiMusic {
  final Dio dio = Dio();

  /// 添加收藏
  Future<UniversalBean> addCollection({
    required int musicId,
    required String Authorization,
  }) async {

      Response response = await dio.post(
        _CollectionURL,
        queryParameters: {'musicId': musicId},
        options: Options(headers: {
          'Authorization': Authorization,
          'Content-Type': 'application/json;charset=UTF-8'
        })
      );

      print(response.data);
      return UniversalBean.formMap(response.data); // 将返回的数据转换为 UniversalBean 对象

  }
}
