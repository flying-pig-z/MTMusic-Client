
import 'package:dio/dio.dart';
import 'package:music_player_miao/models/universal_bean.dart';


const String _SonglistMusicURL = 'http://8.210.250.29:10010/songlist-musics';

class SonglistMusicApi {
  final Dio dio = Dio();

  Future<UniversalBean> addMusicToSongList({
    required int musicId,
    required int songlistId,
    required String Authorization
  }) async {
    Response response = await dio.post(
        _SonglistMusicURL,
        data: [{
          'musicId': musicId,
          'songlistId': songlistId,
        }],
        options: Options(
            headers: {
              'Authorization': Authorization,
              'Content-Type': 'application/json;charset=UTF-8'
            }
        )
    );
    return UniversalBean.formMap(response.data);
  }
}