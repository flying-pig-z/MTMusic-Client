import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../view/music_view.dart';


class SongsRow extends StatelessWidget {
  final Map sObj;
  final VoidCallback onPressedPlay;
  final VoidCallback onPressed;
  const SongsRow({
    super.key,
    required this.sObj,
    required this.onPressed,
    required this.onPressedPlay
  });

  @override
  Widget build(BuildContext context) {
    int currentMusic = 0;

    final player = AudioPlayer();
    bool isOpened = false;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onPressed,
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
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
                  Positioned(
                    child: Image.asset(
                        "assets/img/songs_run.png",
                        width: 20,
                        height: 20,
                      ),
                    right: 0,
                    bottom: 0,
                  )
                ],
              ),
              const SizedBox(width: 20,),
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
        ),
        const SizedBox(height: 10,)
      ],
    );
  }
}
