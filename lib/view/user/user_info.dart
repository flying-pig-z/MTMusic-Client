import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../api/api_client.dart';
import '../../api/api_client_info.dart';
import '../../common_widget/app_data.dart';
import '../../view_model/home_view_model.dart';
import '../../widget/text_field.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  final listVM = Get.put(HomeViewModel());
  final TextEditingController _controller = TextEditingController();
  File? _selectedImage;
  bool needUpdate = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(true); // 或者根据具体逻辑返回其他值
        return false; // 返回 false 来防止默认的返回行为
      },
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/img/app_bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Get.back(result: true);
              },
              icon: Image.asset(
                "assets/img/back.png",
                width: 25,
                height: 25,
                fit: BoxFit.contain,
              ),
            ),
            title: const Text(
              "账户信息",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.w400),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildAvatarRow(),
                _buildNicknameRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 构建头像行
  Widget _buildAvatarRow() {
    return Container(
      height: 80,
      color: Colors.white.withOpacity(0.6),
      padding: const EdgeInsets.only(left: 48, right: 25),
      child: InkWell(
        onTap: () {
          _bottomSheet(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "头像",
              style: TextStyle(fontSize: 20),
            ),
            Row(
              children: [
                _buildAvatarImage(),
                const SizedBox(width: 20),
                Image.asset(
                  "assets/img/user_next.png",
                  width: 25,
                  height: 25,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 构建昵称行
  Widget _buildNicknameRow() {
    return Container(
      height: 80,
      color: Colors.white.withOpacity(0.6),
      padding: const EdgeInsets.only(left: 48, right: 25),
      child: InkWell(
        onTap: () {
          _showNicknameDialog();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "昵称",
              style: TextStyle(fontSize: 20),
            ),
            Row(
              children: [
                Text(
                  AppData().currentUsername,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 15),
                Image.asset(
                  "assets/img/user_next.png",
                  width: 25,
                  height: 25,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 显示头像的 Widget，根据是否是网络 URL 或本地路径来动态加载
  Widget _buildAvatarImage() {
    final avatarPath = AppData().currentAvatar;
    if (avatarPath.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          avatarPath,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(avatarPath),
            width: 64,
            height: 64,
            fit: BoxFit.cover,
          ),
      );
    }
  }

  Future _bottomSheet(BuildContext context) async {
    final picker = ImagePicker();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        height: 80,
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  _selectedImage = File(pickedFile.path);
                  setState(() {}); // 更新 UI

                  // 上传头像
                  await ChangeApiClient().changeHeader(
                      Authorization: AppData().currentToken,
                      avatar: _selectedImage!);

                  // 更新本地存储
                  _updatetouxiang(_selectedImage!.path);
                  // 拉取更新后的用户信息
                  await GetInfoApiClient()
                      .getInfo(Authorization: AppData().currentToken);

                  needUpdate = true;
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                "从相册上传头像",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNicknameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
              child: Text(
            "修改昵称",
            style: TextStyle(fontSize: 20),
          )),
          content: TextFieldColor(
            controller: _controller,
            hintText: '请输入新昵称',
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xff429482),
                      minimumSize: const Size(0, 50), // 移除固定宽度，保留高度
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    child: const Text(
                      "取消",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      _updateNickname();
                      await ChangeApiClient().changeName(
                          Authorization: AppData().currentToken,
                          userName: AppData().currentUsername);
                      Navigator.of(context).pop();
                      needUpdate = true;
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xff429482),
                      minimumSize: const Size(0, 50), // 移除固定宽度，保留高度
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    child: const Text(
                      "保存",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _updateNickname() {
    setState(() {
      AppData appData = AppData();
      appData.box.write('currentUsername', _controller.text);
    });
  }

  void _updatetouxiang(String path) {
    setState(() {
      AppData appData = AppData();
      appData.box.write('currentAvatar', path); // 更新头像路径到本地存储
    });
  }
}
