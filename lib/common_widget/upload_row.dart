import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:music_player_miao/view/list_details_view.dart';
import 'package:music_player_miao/view/main_tab_view/main_tab_view.dart';

import '../view/music_view.dart';


class UploadRow extends StatelessWidget {
  final Map sObj;
  final VoidCallback onPressedPlay;
  final VoidCallback onPressed;// Add this callback
  const UploadRow({
    super.key,
    required this.sObj,
    required this.onPressed,
    required this.onPressedPlay
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
            children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      sObj["image"],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
              const SizedBox(width: 15,),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sObj["name"],
                        maxLines: 1,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        sObj["artists"],
                        maxLines: 1,
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      )
                    ],
                  )),

              IconButton(
                onPressed: onPressedPlay,
                icon: Image.asset(
                  "assets/img/More.png",
                  width: 25,
                  height: 25,

                ),
              ),
                ],
              ),
        const SizedBox(height: 10,)
      ],
    );
  }
}
