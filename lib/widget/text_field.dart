import 'package:flutter/material.dart';

class TextFieldColor extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final String? Function(String?)? onChanged;
  final bool enabled; // 添加enabled属性

  const TextFieldColor({
    super.key,
    required this.controller,
    required this.hintText,
    this.suffixIcon,
    this.onTap,
    this.validator,
    this.focusNode,
    this.onChanged,
    this.enabled = true, // 设置默认值
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      validator: validator,
      controller: controller,
      focusNode: focusNode,
      onTap: onTap,
      textInputAction: TextInputAction.next,
      onChanged: onChanged,
      maxLines: 1,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        disabledBorder: OutlineInputBorder( // 添加禁用状态的边框样式
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        fillColor: enabled ? const Color(0xffE3F0ED) : const Color(0xffE3F0ED).withOpacity(0.7), // 禁用时稍微调整透明度
        filled: true,
        hintText: hintText,
        alignLabelWithHint: true,
        hintStyle: TextStyle(
          color: enabled ? const Color(0xff6E6E6E) : const Color(0xff6E6E6E).withOpacity(0.5),
          fontSize: 16,
        ),
      ),
    );
  }
}