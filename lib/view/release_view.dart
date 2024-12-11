import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';  // 添加 dio 导入
import 'package:path/path.dart' as path;  // 添加 path 导入
import 'package:music_player_miao/common_widget/app_data.dart';
import '../widget/text_field.dart';

class ReleaseView extends StatefulWidget {
  const ReleaseView({Key? key});

  @override
  State<ReleaseView> createState() => _ReleaseViewState();
}

class SongInfo {
  String songName;
  String artistName;

  SongInfo({required this.songName, required this.artistName});
}

class _ReleaseViewState extends State<ReleaseView> with AutomaticKeepAliveClientMixin {

  List<File> coverImages = [];
  List<SongInfo> songInfoList = [];

  late File selectedMp3File;
  File? selectedCoverFile;
  File? selectedMusicFile;
  bool isUploading = false;
  double uploadProgress = 0.0;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/img/app_bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child:
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  ///立即发布
                  const Center(
                    child: Text(
                      "立即发布",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                    ),
                  ),
                  const SizedBox(height: 30,),
                  ///上传文件upload
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {
                            _showUploadDialog();
                          },
                          icon: Image.asset("assets/img/release_upload.png", width: 45,),
                        ),
                        const Text(
                          "上传文件",
                          style: TextStyle(
                              fontSize: 20
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 30,),
                ],
              ),
              ///音乐列表
              const Text(
                "音乐列表",
                style: TextStyle(
                    fontSize: 20
                ),
              ),
              const SizedBox(height: 20,),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child:
                  coverImages.isEmpty
                      ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: const Center(
                      child: Text(
                        "目前还是空的",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  )
                      :
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(songInfoList.length, (index) {
                      return ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: coverImages[index] != null
                                      ? Image.file(
                                    coverImages[index]!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                      : Container(
                                    color: const Color(0xffC4C4C4),
                                    width: 60,
                                    height: 60,
                                  ),
                                ),
                                const SizedBox(width: 20,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      songInfoList[index].songName,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    Text(songInfoList[index].artistName),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                _bottomSheet(context, index);
                              },
                              icon: Image.asset(
                                "assets/img/More.png",
                                width: 25,
                                height: 25,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _bottomSheet(BuildContext context, int index) async {
    await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        builder: (context) => Container(
          height: 200,
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          _editSongInformation(context, index);
                        },
                        icon: Image.asset("assets/img/release_info.png"),
                        iconSize: 60,
                      ),
                      const Text("编辑歌曲信息")
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          _confirmDelete(context, index);
                        },
                        icon: Image.asset("assets/img/release_delete.png"),
                        iconSize: 60,
                      ),
                      const Text("删除")
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30,),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "取消",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff429482),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }

  ///编辑信息
  void _editSongInformation(BuildContext context, int index) {
    TextEditingController songNameController = TextEditingController();
    TextEditingController artistNameController = TextEditingController();

    songNameController.text = songInfoList[index].songName;
    artistNameController.text = songInfoList[index].artistName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: const Center(child: Text('编辑歌曲信息')),
        content: SizedBox(
          height: 260,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("封面"),
                  IconButton(
                    onPressed: () {
                      _getImageFromGallery(index);
                    },
                    icon: coverImages[index] != null
                        ? Image.file(
                      coverImages[index]!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                        : Image.asset(
                      "assets/img/release_pic1.png",
                      width: 60,
                      height: 60,
                    ),
                    iconSize: 60,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text("歌名"),
              TextFieldColor(
                  controller: songNameController,
                  hintText: '请输入歌曲名称'
              ),
              const SizedBox(height: 20,),
              const Text("歌手"),
              TextFieldColor(
                  controller: artistNameController,
                  hintText: '请输入歌手名称'
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xff429482),
              minimumSize: const Size(130, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            child: const Text(
              "取消",
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              // Handle the edited song information here
              String editedSongName = songNameController.text;
              String editedArtistName = artistNameController.text;

              // Update the song information in your data structure
              songInfoList[index] = SongInfo(
                songName: editedSongName,
                artistName: editedArtistName,
              );

              // For demonstration, print the edited values
              print('Edited Song Name: $editedSongName');
              print('Edited Artist Name: $editedArtistName');

              // Update the displayed song information in the UI
              setState(() {});
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xff429482),
              minimumSize: const Size(130, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            child: const Text('确认', style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }

  ///上传
  Future<void> _showUploadDialog() async {
    final songNameController = TextEditingController();
    final artistNameController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false, // 防止误触关闭
      builder: (context) => StatefulBuilder( // 使用 StatefulBuilder 以更新对话框状态
        builder: (context, setState) => AlertDialog(
          title: const Text('上传音乐'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 音乐文件选择
                ListTile(
                  leading: const Icon(Icons.music_note),
                  title: Text(selectedMusicFile?.path.split('/').last ?? '未选择音乐文件'),
                  trailing: IconButton(
                    icon: const Icon(Icons.upload_file),
                    onPressed: () async {
                      final file = await _pickMusicFile();
                      if (file != null) {
                        setState(() => selectedMusicFile = file);
                      }
                    },
                  ),
                ),

                // 封面图片选择
                ListTile(
                  leading: const Icon(Icons.image),
                  title: Text(selectedCoverFile?.path.split('/').last ?? '未选择封面图片'),
                  trailing: IconButton(
                    icon: const Icon(Icons.upload_file),
                    onPressed: () async {
                      final file = await _pickImage();
                      if (file != null) {
                        setState(() => selectedCoverFile = file);
                      }
                    },
                  ),
                ),

                // 歌曲信息输入
                const SizedBox(height: 16),
                TextFieldColor(
                  controller: songNameController,
                  hintText: '请输入歌曲名称',
                ),
                const SizedBox(height: 8),
                TextFieldColor(
                  controller: artistNameController,
                  hintText: '请输入歌手名称',
                ),

                // 显示进度条
                if (isUploading) _buildProgressIndicator(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isUploading ? null : () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: isUploading
                  ? null
                  : () async {
                      if (_validateInputs(
                        selectedMusicFile,
                        selectedCoverFile,
                        songNameController.text,
                        artistNameController.text,
                      )) {
                        await _performUpload(
                          songNameController.text,
                          artistNameController.text,
                          setState,
                        );
                      }
                    },
              child: Text(isUploading ? '上传中...' : '确认上传'),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateInputs(
    File? musicFile,
    File? coverFile,
    String songName,
    String artistName,
  ) {
    if (musicFile == null) {
      _showErrorMessage('请选择音频文件');
      return false;
    }
    if (coverFile == null) {
      _showErrorMessage('请选择封面图片');
      return false;
    }
    if (songName.isEmpty) {
      _showErrorMessage('请输入歌曲名称');
      return false;
    }
    if (artistName.isEmpty) {
      _showErrorMessage('请输入歌手名称');
      return false;
    }

    // 检查文件大小
    if (musicFile.lengthSync() > 10 * 1024 * 1024) { // 10MB 限制
      _showErrorMessage('音乐文件大小不能超过10MB');
      return false;
    }
    if (coverFile.lengthSync() > 2 * 1024 * 1024) { // 2MB 限制
      _showErrorMessage('封面图片大小不能超过2MB');
      return false;
    }

    return true;
  }

  Future<void> _performUpload(
    String songName,
    String artistName,
    StateSetter setState,
  ) async {
    if (isUploading) return; // 防止重复触发

    setState(() {
      isUploading = true;
      uploadProgress = 0;
    });

    print('1' * 100);
    print(songName);

    try {
      final dio = Dio();

      // 设置拦截器来监听上传进度
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ));

      String coverFileName = path.basename(selectedCoverFile!.path);
      String musicFileName = path.basename(selectedMusicFile!.path);

      FormData formData = FormData.fromMap({
        'Authorization': AppData().currentToken,
        'coverFile': await MultipartFile.fromFile(
          selectedCoverFile!.path,
          filename: coverFileName,
        ),
        'musicFile': await MultipartFile.fromFile(
          selectedMusicFile!.path,
          filename: musicFileName,
        ),
        'singerName': artistName,
        'name': songName,
        'introduce': '暂无简介',
      });

      final response = await dio.post(
        'http://8.210.250.29:10010/musics',
        data: formData,
        options: Options(
          headers: {'Authorization': AppData().currentToken},
        ),
        onSendProgress: (count, total) {
          setState(() {
            uploadProgress = count / total;
          });
        },
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        _showSuccessDialog();
      } else {
        _showErrorMessage(response.data['msg'] ?? '上传失败');
      }
    } catch (e) {
      _showErrorMessage('上传失败: $e');
    } finally {
      setState(() {
        isUploading = false;
        uploadProgress = 0;
      });
    }
  }

  // 修改进度条显示
  Widget _buildProgressIndicator() {
    return Column(
      children: [
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: uploadProgress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xff429482)),
        ),
        const SizedBox(height: 8),
        Text(
          '上传进度: ${(uploadProgress * 100).toStringAsFixed(1)}%',
          style: TextStyle(
            color: Color(0xff429482),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Future<File?> _getImageFromGallery([int? index]) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (index != null && index < coverImages.length) {
          coverImages[index] = File(pickedFile.path);
        } else {
          coverImages.add(File(pickedFile.path));
        }
      });
      return File(pickedFile.path);
    }

    return null;
  }
  Future<File> _getMp3File() async {
    final filePickerResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );

    if (filePickerResult != null && filePickerResult.files.isNotEmpty) {
      return File(filePickerResult.files.first.path!);
    }

    return File('');
  }

  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:BorderRadius.circular(10),
        ),
        title: Image.asset("assets/img/warning.png",width: 47,height: 46,),
        content: const Text('确认删除？',textAlign: TextAlign.center,),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xff429482),
              minimumSize: const Size(130, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            child: const Text('取消',style: TextStyle(color: Colors.white),),
          ),
          TextButton(
            onPressed: () {
              // Remove the selected song from the lists
              setState(() {
                coverImages.removeAt(index);
                songInfoList.removeAt(index);
              });
              Navigator.pop(context); // Close the dialog
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xff429482),
              minimumSize: const Size(130, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            child: const Text('确认',style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }

  // 选择音乐文件
  Future<File?> _pickMusicFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );

    if (result != null && result.files.isNotEmpty) {
      return File(result.files.first.path!);
    }
    return null;
  }

  // 选择图片
  Future<File?> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // 显示错误消息
  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xff429482),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // 显示成功对话框
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Image.asset(
          "assets/img/correct.png",
          width: 47,
          height: 46,
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('上传成功'),
            Text('审核通过后将自动发布'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 关闭对话框
              // 清空输入和选择的文件
              setState(() {
                selectedMusicFile = null;
                selectedCoverFile = null;
                isUploading = false;
                uploadProgress = 0;
              });
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xff429482),
              foregroundColor: Colors.white,
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}