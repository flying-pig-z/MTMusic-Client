import 'package:flutter/material.dart';


class IconTextRow extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onTap;
  const IconTextRow({super.key, required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 44,
          child: ListTile(
            leading: Image.asset(
              icon,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
            title: Text(
              title,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600
              ),
            ),
            onTap: (){

            },
          ),
        ),
        Divider(
          color: Colors.black,
          indent: 70,
        ),
      ],
    );
  }
}
