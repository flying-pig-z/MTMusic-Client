// api/api_client.dart
// ignore_for_file: constant_identifier_names

import 'package:dio/dio.dart';
import 'package:music_player_miao/models/universal_bean.dart';
import 'dart:io';

import 'package:path/path.dart';

const String _ReleaseURL = 'http://8.210.250.29:10010/musics';

///上传
class ReleaseApi {
  final Dio dio = Dio();
  Future<UniversalBean> release({
    required File coverFile,
    required File musicFile,
    required String Authorization,
    required String singerName,
    required String name,
    required String introduce,
  }) async {
    String coverFileName = basename(coverFile.path);
    String musicFileName = basename(musicFile.path);
    FormData formData = FormData.fromMap({
      'Authorization': Authorization,
      'coverFile': await MultipartFile.fromFile(coverFile.path, filename: coverFileName),
      'musicFile': await MultipartFile.fromFile(musicFile.path, filename: musicFileName),
      'singerName': singerName,
      'name': name,
      'introduce': introduce,
    });
    Response response = await dio.post(
        _ReleaseURL,
        queryParameters: {'singerName':singerName,'name':name,'introduce':introduce},
        data: formData,
        options: Options(headers:{'Authorization':Authorization,
          })
    );
    print(response.data);
    return UniversalBean.formMap(response.data);

  }
}