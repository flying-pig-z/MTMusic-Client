import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../common_widget/lits_songs_row.dart';
import '../view_model/home_view_model.dart';

class ListDetailsView extends StatefulWidget {
  const ListDetailsView({super.key});

  @override
  State<ListDetailsView> createState() => _ListDetailsViewState();
}

class _ListDetailsViewState extends State<ListDetailsView> {

  final listVM = Get.put(HomeViewModel());

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Get.back();
            },
            icon: Image.asset(
              "assets/img/back.png",
              width: 25,
              height: 25,
              fit: BoxFit.contain,
            ),
          ),

          title: const Text(
            "歌单",
            style: TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.w400),
          ),
        ),
        body: SingleChildScrollView(
            child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Image.asset(
                                "assets/img/list_pic.png",
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              const Text(
                                  "华语歌曲精选",
                                style: TextStyle(
                                  fontSize: 20,

                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                        ],
                      ),
                    ),
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: (){},
                            icon: Image.asset(
                              "assets/img/button_play.png",
                              width: 20,
                              height: 20,
                            ),
                          ),
                          const Text(
                            '播放全部',
                            style: TextStyle(
                              fontSize: 16
                            ),
                          ),
                          const SizedBox(width: 5,),
                          const Text(
                            '50',
                            style: TextStyle(
                                fontSize: 16
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 400,
                        width: 400,
                        child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 15),
                            itemCount: listVM.listDetailArr.length,
                            itemBuilder: (context, index) {
                              var sObj = listVM.listDetailArr[index];
                              return ListSongsRow(
                                sObj: sObj,
                                onPressed: () {
                                },
                                onPressedPlay: () {
                                  _bottomSheet(context);
                                },
                              );
                            }),
                      )
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
    );
  }
  Future _bottomSheet(BuildContext context){
    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        builder: (context) =>Container(
          height: 210,
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
                        onPressed: (){},
                        icon: Image.asset("assets/img/list_add.png"),
                        iconSize: 60,
                      ),
                      const Text("加入歌单")
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: (){},
                        icon: Image.asset("assets/img/list_download.png"),
                        iconSize: 60,
                      ),
                      const Text("下载")
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: (){},
                        icon: Image.asset("assets/img/list_collection.png"),
                        iconSize: 60,
                      ),
                      const Text("收藏")
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: (){},
                        icon: Image.asset("assets/img/list_good.png"),
                        iconSize: 60,
                      ),
                      const Text("点赞")
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: (){},
                        icon: Image.asset("assets/img/list_comment.png"),
                        iconSize: 60,
                      ),
                      const Text("评论")
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              ElevatedButton(
                onPressed: () {
                  // Get.to(()=>const MusicView());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffE6F4F1),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text(
                  "查看详情页",
                  style: TextStyle(color:Colors.black,fontSize: 18),
                ),

              ),
              ElevatedButton(
                onPressed: () =>Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff429482),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text(
                  "取消",
                  style: TextStyle(color:Colors.black,fontSize: 18),
                ),

              ),
            ],
          ),
        )

    );
  }
}
