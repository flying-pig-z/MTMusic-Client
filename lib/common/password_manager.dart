import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordManager {
  // 私有构造函数
  PasswordManager._();

  // 单例实例
  static final PasswordManager _instance = PasswordManager._();

  // 获取单例实例的方法
  static PasswordManager get instance => _instance;

  // 存储键名常量
  static const String _accountKey = 'saved_account';
  static const String _passwordKey = 'saved_password';
  static const String _salt = "miao_salt"; // 加密盐值

  // 加密方法
  String _encryptPassword(String password) {
    var bytes = utf8.encode(password + _salt);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // 保存账号密码
  Future<void> saveCredentials(String account, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accountKey, account);
    // 存储原始密码
    await prefs.setString(_passwordKey, password);
  }

  // 检查是否存在已保存的账号密码
  Future<bool> hasCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_accountKey) && prefs.containsKey(_passwordKey);
  }

  // 获取保存的账号
  Future<String?> getAccount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accountKey);
  }

  // 获取原始密码
  Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passwordKey);
  }

  // 检查密码是否匹配
  Future<bool> checkPassword(String inputPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString(_passwordKey);
    if (savedPassword == null) return false;
    // 对比原始密码
    return savedPassword == inputPassword;
  }

  // 更新账号密码
  Future<void> updateCredentials(String newAccount, String newPassword) async {
    await saveCredentials(newAccount, newPassword);
  }

  // 清空保存的账号密码
  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accountKey);
    await prefs.remove(_passwordKey);
  }
}