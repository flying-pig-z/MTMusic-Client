import 'package:get/get.dart';

import 'download_manager.dart';

class DownloadCountController extends GetxController {
  final _downloadCount = 0.obs;

  int get downloadCount => _downloadCount.value;

  void updateCount(int count) {
    _downloadCount.value = count;
  }

  void refreshCount(DownloadManager downloadManager) {
    _downloadCount.value = downloadManager.completedNumber();
  }
}