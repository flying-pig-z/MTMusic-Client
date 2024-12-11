
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../view/list_details_view.dart';


class ListRow extends StatelessWidget {
  final Map sObj;
  final VoidCallback onPressedPlay;
  final VoidCallback onPressed;
  const ListRow({
    super.key,
    required this.sObj,
    required this.onPressed,
    required this.onPressedPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: (){Get.to(ListDetailsView());},
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      sObj["image"],
                      width: 125,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    child: IconButton(
                      onPressed: onPressedPlay,
                      icon: Image.asset(
                        "assets/img/songs_run.png",
                        width: 30,
                        height: 30,
                      ),
                    ),
                    right: -5,
                    bottom: -5,
                  )
                ],
              ),
              const SizedBox(height: 5,),
              Text(
                sObj["text"],
                maxLines: 1,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
              ),

            ],

          ),
        ),
      ],
    );
  }
}
