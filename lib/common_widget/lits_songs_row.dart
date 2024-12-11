import 'package:flutter/material.dart';


class ListSongsRow extends StatelessWidget {
  final Map sObj;
  final VoidCallback onPressedPlay;
  final VoidCallback onPressed;
  const ListSongsRow({
    super.key,
    required this.sObj,
    required this.onPressed,
    required this.onPressedPlay,
  });

  @override
  Widget build(BuildContext context) {
    return
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(width: 20,),
                Text(
                  sObj["name"]+"-" ??"",
                  maxLines: 1,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w400),
                ),
                Text(
                  sObj["artists"] ?? "",
                  maxLines: 1,
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ],
            ),


            const SizedBox(width: 20,),

            IconButton(
              onPressed: onPressedPlay,
              icon: Image.asset(
                "assets/img/More.png",
                width: 25,
                height: 25,
              ),
            ),
          ],
        );

  }
}
