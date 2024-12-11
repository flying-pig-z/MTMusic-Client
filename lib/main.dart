import 'package:flutter/material.dart';
import 'package:music_player_miao/common/song_status_manager.dart';
import 'package:music_player_miao/common_widget/app_data.dart';
import 'package:music_player_miao/view/begin/begin_view.dart';
import 'package:music_player_miao/view/begin/login_v.dart';
import 'package:music_player_miao/view/home_view.dart';
import 'package:music_player_miao/view/splash_view.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:music_player_miao/view/user/user_view.dart';

import 'common/audio_player_controller.dart';
import 'common/download_count_controller.dart';
import 'common/download_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(AppData(), permanent: true);
  Get.put(DownloadManager(), permanent: true);
  Get.put(AudioPlayerController.instance, permanent: true);
  Get.put(DownloadCountController, permanent: true);
  await SongStatusManager().init();
  runApp(const MyApp());
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashView(),
    );
  }
}


