import 'dart:io';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class DownloadApi {
  final Dio dio = Dio();

  // 申请存储权限
  Future<bool> _requestStoragePermission(BuildContext context) async {
    // 检查权限状态
    PermissionStatus status = await Permission.manageExternalStorage.status;

    if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
      // 如果权限被拒绝，请求权限
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('需要存储权限'),
            content: const Text('下载音乐需要存储权限，请在设置中允许访问存储权限。'),
            actions: <Widget>[
              TextButton(
                child: const Text('取消'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('去设置'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Permission.manageExternalStorage.request();
                },
              ),
            ],
          ),
        );
      }
      return false;
    }
    return status.isGranted;
  }

  String _getFileExtension(String url) {
    // Remove query parameters
    final urlWithoutQuery = url.split('?').first;
    // Get the extension including the dot
    final extension = path.extension(urlWithoutQuery);
    return extension.isNotEmpty
        ? extension
        : '.mp3'; // Default to .mp3 if no extension found
  }

  Future<String?> downloadMusic({
    required String musicUrl,
    required String name,
    required BuildContext context,
    required Function(double) onProgress,
  }) async {
    try {
      String fileExtension = _getFileExtension(musicUrl);
      final fileName = '$name$fileExtension';

      // 检查并申请权限
      if (!await _requestStoragePermission(context)) {
        throw Exception('没有存储权限');
      }

      // 获取下载目录
      final downloadDir = Directory('/storage/emulated/0/MTMusic');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      // 构建完整的文件路径
      final filePath = '${downloadDir.path}/$fileName';

      print("Music URL: $musicUrl");
      print("Saving as: $filePath");

      // 开始下载
      await dio.download(
        musicUrl,
        filePath,
        options: Options(
          headers: {
            // 如果需要添加请求头可以在这里添加
          },
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // 计算下载进度并通过回调函数传递
            double progress = received / total;
            onProgress(progress); // 调用回调函数
          }
        },
      );

      return filePath;
    } catch (e) {
      print('Download error: $e');
      return null;
    }
  }
}
