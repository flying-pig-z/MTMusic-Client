import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class HomeViewModel extends GetxController {

  void removeSong(int index) {
    listDetailArr.removeAt(index);
  }
  final txtSearch = TextEditingController().obs;
  final all =['你好'];

  final songsArr = [
    {
      "image": "assets/img/song_cover1.png",
      "name": "晴天",
      "artists": "周杰伦"
    },
    {
      "image": "assets/img/song_cover2.png",
      "name": "光年之外",
      "artists": "邓紫棋"
    },
    {
      "image": "assets/img/song_cover3.png",
      "name": "起风了",
      "artists": "买辣椒也用券"
    },
  ].obs;

  final listArr = [
    {
      "image": "assets/img/list_pic1.png",
      "text": "流行音乐精选",
    },
    {
      "image": "assets/img/list_pic2.png",
      "text": "经典老歌回忆",
    },
    {
      "image": "assets/img/list_pic3.png",
      "text": "摇滚音乐精选",
    },
    {
      "image": "assets/img/list_pic4.png",
      "text": "轻音乐放松",
    },
  ].obs;
  final listDetailArr = [
    {
      "rank": "1",
      "name": "背对背拥抱",
      "artists": ""
    },
    {
      "rank": "2",
      "name": "背对背拥抱",
      "artists": "林俊杰"
    },
    {
      "rank": "3",
      "name": "背对背拥抱r",
      "artists": "林俊杰"
    },
    {
      "rank": "4",
      "name": "背对背拥抱",
      "artists": "林俊杰"
    },
    {
      "rank": "5",
      "name": "背对背拥抱",
      "artists": "林俊杰"
    },
    {
      "rank": "6",
      "name": "背对背拥抱",
      "artists": "林俊杰"
    },
    {
      "rank": "7",
      "name": "背对背拥抱",
      "artists": "林俊杰"
    },
    {
      "rank": "8",
      "name": "背对背拥抱",
      "artists": "林俊杰"
    },
    {
      "rank": "9",
      "name": "背对背拥抱",
      "artists": "林俊杰"
    },

  ].obs;
}
