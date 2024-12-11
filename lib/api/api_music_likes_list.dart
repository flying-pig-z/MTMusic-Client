import 'package:dio/dio.dart';
import '../models/getLikeList_bean.dart';

const String _LikesListURL = 'http://8.210.250.29:10010/likes/user-like-list';

class LikesListApi {
  final Dio dio = Dio();

  /// 获取用户点赞歌曲列表
  Future<LikeListBean> getUserLikesList({
    required String Authorization,
  }) async {
    try {
      Response response = await dio.get(
        _LikesListURL,
        options: Options(
          headers: {
            'Authorization': Authorization,
            'Content-Type': 'application/json;charset=UTF-8'
          }
        ),
      );
      
      print('点赞列表响应数据: ${response.data}');
      return LikeListBean.formMap(response.data);
      
    } catch (e) {
      print('获取点赞列表失败: $e');
      rethrow;
    }
  }
} 