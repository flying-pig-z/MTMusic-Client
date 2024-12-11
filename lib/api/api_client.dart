// api/api_client.dart
// ignore_for_file: constant_identifier_names

import 'package:dio/dio.dart';
import 'package:music_player_miao/models/universal_bean.dart';
import '../models/getInfo_bean.dart';
import '../models/login_bean.dart';

const String _LoginURL = 'http://8.210.250.29:10010/users/login';
const String _LogoutURL = 'http://8.210.250.29:10010/users/logout';
const String _SetupURL = 'http://8.210.250.29:10010/email/register';
const String _verificationURL = 'http://8.210.250.29:10010/email/verificationCode';
const String _GetInfoURL = 'http://8.210.250.29:10010/users/info';

///登录
class LoginApiClient {
  final Dio dio = Dio();
  Future<LoginBean> login({
    required String email,
    required String password,
  }) async {
    Response response = await dio.post(
        _LoginURL,
        data: {
          'email': email,
          'password': password,
        },
        options: Options(headers:{'Content-Type':'application/json;charset=UTF-8'})
    );
    print(response.data);
    return LoginBean.formMap(response.data);

  }
}
///登出
class LogoutApiClient {
  final Dio dio = Dio();
    Future<UniversalBean> logout({
      required String Authorization,
    }) async {
      Response response = await dio.post(
          _LogoutURL,
          data: {
            'Authorization': Authorization,
          },
          options: Options(headers:{'Authorization':Authorization,'Content-Type':'application/json;charset=UTF-8'})
      );
      print(response.data);
      return UniversalBean.formMap(response.data);
    }

}
///注册
class SetupApiClient{
  final Dio dio = Dio();
  Future<UniversalBean> register({
    required String email,
    required String password,
    required String username,
    required String verificationCode,
  }) async {
    Response response = await dio.post(
        _SetupURL,
        data: {
      'email': email,
      'password': password,
      "username": username,
      "verificationCode": verificationCode,
    },
        options: Options(headers:{'Content-Type':'application/json;charset=UTF-8'})
    );
    print(response.data);
    return UniversalBean.formMap(response.data);
  }

  Future<UniversalBean> verification({required String email,}) async {
    Response response = await dio.get(
        _verificationURL,
        queryParameters: {'email':email},
    );
    print(response.data);
    return UniversalBean.formMap(response.data);
  }
}
///获取用户信息
class GetInfoApiClient{
  final Dio dio = Dio();
  Future<GetInfoBean> getInfo({required String Authorization,}) async {
    Response response = await dio.get(
      _GetInfoURL,
      data: {
        'Authorization':Authorization
      },
        options: Options(headers:{'Authorization':Authorization,'Content-Type':'application/json;charset=UTF-8'})
    );
    print(response.data);
    return GetInfoBean.formMap(response.data);
  }
}





