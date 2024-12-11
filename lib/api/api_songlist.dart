import 'package:dio/dio.dart';
import 'package:music_player_miao/models/getMyLike_bean.dart';
import 'package:music_player_miao/models/search_bean.dart';
import 'package:music_player_miao/models/songlist_bean.dart';

import '../models/getAllSongs_bean.dart';
import '../models/universal_bean.dart';
import 'package:music_player_miao/models/getMyWorks_bean.dart';
const String _SonglistURL = 'http://8.210.250.29:10010/songlists';
const String _MyWorksURL = 'http://8.210.250.29:10010/musics/upload-music';
const String _MyLikeURL = 'http://8.210.250.29:10010/likes/user-like-list';
const String _MyCollectionURL = 'http://8.210.250.29:10010/collections/user-collection-list';

class SonglistApi {
  final Dio dio = Dio();

  ///获取我的收藏
  Future<MyLikes> getMyCollection({required String Authorization}) async {
    Response response = await dio.get(_MyCollectionURL,
        data: {
          'Authorization': Authorization,
        },
        options: Options(headers: {
          'Authorization': Authorization,
          'Content-Type': 'application/json;charset=UTF-8'
        }));
    print(response.data);
    return MyLikes.formMap(response.data);
  }
  ///获取歌单中所有歌曲
  Future<MyMusicListBean> getAllSongs({required int id, required String Authorization}) async {
    String urlWithId = 'http://8.210.250.29:10010/songlist-musics/$id/music-list';
    Response response = await dio.get(urlWithId,
        options: Options(headers: {
          'Authorization': Authorization,
          'Content-Type': 'application/json;charset=UTF-8'
        }));
    print(response.data);
    return MyMusicListBean.formMap(response.data);
  }
  ///获取我的点赞
  Future<MyLikes> getMyLike({required String Authorization}) async {
    Response response = await dio.get(_MyLikeURL,
        data: {
          'Authorization': Authorization,
        },
        options: Options(headers: {
          'Authorization': Authorization,
          'Content-Type': 'application/json;charset=UTF-8'
        }));
    print(response.data);
    return MyLikes.formMap(response.data);
  }

  ///获取我的作品
  Future<MyWorks> getMyworks({required String Authorization}) async {
    Response response = await dio.get(_MyWorksURL,
        data: {
          'Authorization': Authorization,
        },
        options: Options(headers: {
          'Authorization': Authorization,
          'Content-Type': 'application/json;charset=UTF-8'
        }));
    print(response.data);
    return MyWorks.formMap(response.data);
  }
  ///返回歌单
  Future<SearchBean> getSonglist({required String Authorization}) async {
    Response response = await dio.get(_SonglistURL,
        data: {
          'Authorization': Authorization,
        },
        options: Options(headers: {
          'Authorization': Authorization,
          'Content-Type': 'application/json;charset=UTF-8'
        }));
    print(response.data);
    return SearchBean.formMap(response.data);
  }

  ///添加歌单
  Future<UniversalBean> addSonglist(
      {required String songlistName, required String Authorization}) async {
    Response response = await dio.post(_SonglistURL,
        data: {
          'Authorization': Authorization,
        },
        queryParameters: {'songlistName': songlistName},
        options: Options(headers: {
          'Authorization': Authorization,
          'Content-Type': 'application/json;charset=UTF-8'
        }));
    print(response.data);
    return UniversalBean.formMap(response.data);
  }

  ///删除歌单
  Future<UniversalBean> delSonglist({required String Authorization,required int id}) async {
    String urlWithId = '$_SonglistURL/$id';
    Response response = await dio.delete(
        urlWithId,
        data: {
          'Authorization': Authorization,
        },
        options: Options(headers: {
          'Authorization': Authorization,
          'Content-Type': 'application/json;charset=UTF-8'
        }));

    print(response.data);
    return UniversalBean.formMap(response.data);
  }
}
