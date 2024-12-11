import 'package:dio/dio.dart';

import '../common_widget/Song_widegt.dart';
import '../models/MusicsListBean.dart';
import '../models/getMusicList_bean.dart';
import '../models/getRank_bean.dart';

const String _getMusicList = "http://8.210.250.29:10010/musics/random";
const String _getMusic = 'http://8.210.250.29:10010/musics/';
const String _getMusic1 = 'http://8.210.250.29:10010/musics/1';
const String _getMusic2 = 'http://8.210.250.29:10010/musics/2';
const String _getMusic3 = 'http://8.210.250.29:10010/musics/3';
const String _getSongDetail = 'http://8.210.250.29:10010/musics';

/// 精选歌曲
class GetMusic {
  final Dio dio = Dio();

  Future<MusicsListBean> getMusicList({required String Authorization, required int num}) async {
    Response response = await dio.get(
        '$_getMusicList?num=$num',
        data: {
          'Authorization': Authorization,
        },
        options: Options(headers: {
          'Authorization': Authorization,
          'Content-Type': 'application/json;charset=UTF-8'
        }));
    return MusicsListBean.fromMap(response.data);
  }

  Future<MusicListBean> getMusicById({required int id, required String Authorization}) async {
    print(_getMusic + id.toString());
    Response response = await dio.get(
        _getMusic + id.toString(),
        data: {
          'Authorization': Authorization,
        },
        options: Options(headers: {
          'Authorization': Authorization,
          'Content-Type': 'application/json;charset=UTF-8'
        }));
    print(response.data);
    return MusicListBean.formMap(response.data);
  }

  Future<MusicListBean> getMusic1({required String Authorization}) async {
    Response response = await dio.get(
        _getMusic1,
        data: {
          'Authorization': Authorization,
        },
        options: Options(headers: {
          'Authorization': Authorization,
          'Content-Type': 'application/json;charset=UTF-8'
        }));
    print(response.data);
    return MusicListBean.formMap(response.data);
  }

  Future<MusicListBean> getMusic2({required String Authorization}) async {
    Response response = await dio.get(
        _getMusic2,
        data: {
          'Authorization': Authorization,
        },
        options: Options(headers: {
          'Authorization': Authorization,
          'Content-Type': 'application/json;charset=UTF-8'
        }));
    print(response.data);
    return MusicListBean.formMap(response.data);
  }
  Future<MusicListBean> getMusic3({required String Authorization}) async {
    Response response = await dio.get(
        _getMusic3,
        data: {
          'Authorization': Authorization,
        },
        options: Options(headers: {
          'Authorization': Authorization,
          'Content-Type': 'application/json;charset=UTF-8'
        }));
    print(response.data);
    return MusicListBean.formMap(response.data);
  }
}

// 获取歌曲详细信息
class GetMusicDetail {
  final Dio dio = Dio();

  // 根据歌曲ID获取歌曲详情
  Future<Song> getMusicDetail({required int songId, required String Authorization}) async {
    try {
      // 更新路径，将 songId 作为路径参数插入 URL
      final String url = 'http://8.210.250.29:10010/musics/$songId'; // 假设这个是你的API路径

      // 发起 GET 请求
      Response response = await dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': Authorization,
            'Content-Type': 'application/json;charset=UTF-8',
          },
        ),
      );

      print("Song detail response: ${response.data}");

      // 检查响应的状态码和数据
      if (response.statusCode == 200) {
        // 将返回的响应数据封装成Song对象
        return Song.fromMap(response.data['data']);
      } else {
        throw Exception("Failed to load song details");
      }
    } catch (e) {
      print("Error occurred while fetching song details: $e");
      rethrow; // 抛出异常以供调用方处理
    }
  }
}
