import 'package:dio/dio.dart';

import '../models/getRank_bean.dart';

const String _getRank = 'http://8.210.250.29:10010/musics/rank-list';
///排行榜
class GetRank {
  final Dio dio = Dio();

  Future<RankBean> getRank({required String Authorization,}) async {
    Response response = await dio.get(
        _getRank,
        data: {
          'Authorization': Authorization,
        },
        options: Options(headers: {
          'Authorization': Authorization,
          'Content-Type': 'application/json;charset=UTF-8'
        })
    );
    print(response.data);
    return RankBean.formMap(response.data);
  }
}