import 'package:get/get.dart';

import '../api/api_client.dart';
import '../common/password_manager.dart';
import '../common_widget/app_data.dart';
import '../models/getInfo_bean.dart';
import '../models/login_bean.dart';
import '../view/begin/begin_view.dart';
import '../view/main_tab_view/main_tab_view.dart';

class SplashViewModel extends GetxController {
  Future<void> loadView() async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      // 检查是否有存储的账号密码
      if (await PasswordManager.instance.hasCredentials()) {
        final account = await PasswordManager.instance.getAccount();
        final password = await PasswordManager.instance.getPassword(); // 获取原始密码

        if (account != null && password != null) {
          try {
            // 使用原始密码尝试自动登录
            LoginBean bean = await LoginApiClient().login(
              email: account,
              password: password,  // 使用原始密码
            );

            if (bean.code == 200) {
              // 登录成功，获取用户信息
              GetInfoBean bean1 = await GetInfoApiClient()
                  .getInfo(Authorization: AppData().currentToken);

              // 跳转到主页面
              Get.off(() => const MainTabView());
              return;
            }
          } catch (error) {
            // 登录失败，清空存储的账号密码
            await PasswordManager.instance.clearCredentials();
          }
        }
      }

      // 如果没有存储的账号密码或登录失败，跳转到登录页面
      Get.off(() => const BeginView());
    } catch (error) {
      // 发生异常，清空存储的账号密码并跳转到登录页面
      await PasswordManager.instance.clearCredentials();
      Get.off(() => const BeginView());
    }
  }
}