import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_music_app/main.dart';
import 'package:flutter_music_app/music_player.dart';
import 'package:flutter_music_app/song%20convert.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Tracks extends StatefulWidget {
  @override
  _TracksState createState() => _TracksState();
}

bool checksinging;
bool isbackplay = false;
int currentIndex = 0;
String imagepath;
bool nope = false;

class _TracksState extends State<Tracks> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  List<SongInfo> songs = [];

  final GlobalKey<MusicPlayerState> key =
      GlobalKey<MusicPlayerState>(); //初始化key

  void getSong() async {
    songs = await audioQuery.getSongs(); //載入本機歌曲
    setState(() {
      songs = songs;
    });
  }

  void changeStatus() {
    setState(() {
      isplay = !isplay;
    });
    if (isplay) {
      player.play();
    } else {
      player.pause();
    }
    print(isplay);
  }

  void changeTrack(bool isnext) {
    if (isnext) {
      if (currentIndex == songs.length - 1) {
        currentIndex = 0;
      } else {
        currentIndex++;
      }
    } else {
      if (currentIndex != 0) {
        currentIndex--;
      }
    }
    key.currentState.setsong(songs[currentIndex]); //轉歌
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSong();
    print("init1 ok");
    setState(() {});
    isbackplay = true;
    nope = false;
    loadImage();
  }

  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() async {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        saveImage(_image.path);
        loadImage();
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> saveImage(path) async {
    SharedPreferences saveimage = await SharedPreferences.getInstance();
    saveimage.setString("imagepath", path);
  }

  Future<void> loadImage() async {
    setState(() {});
    SharedPreferences saveimage = await SharedPreferences.getInstance();
    imagepath = saveimage.getString("imagepath");
  }

  Container imagefunc() {
    return Container(
      decoration: imagepath != null
          ? BoxDecoration(
              image: DecorationImage(
                  image: FileImage(
                    File(
                      imagepath,
                    ),
                  ),
                  fit: BoxFit.cover),
            )
          : BoxDecoration(),
      height: double.infinity,
    );
  }

  @override
  Widget build(BuildContext context) {
    bottomControl() {
      if (isbackplay == true) {
        setState(() {
          print("$currentIndex is the now song ");
        });
        return GestureDetector(
          onTap: () {
            checksinging = true;
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return MusicPlayer(
                songInfo: songs[currentIndex],
                changeTrack: changeTrack,
                background: imagefunc(),
                key: key,
              );
            }));
          },
          child: Container(
            width: double.infinity,
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15),
                      topLeft: Radius.circular(15)),
                  gradient: LinearGradient(colors: [
                    Color(0x80673AB7),
                    Color(0x50673AB7),
                    Color(0x80673AB7),
                  ]),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff683ab0).withOpacity(0.4),
                      spreadRadius: 10,
                      blurRadius: 12,
                      offset: Offset(3, 3), // changes position of shadow
                    ),
                  ]),
              height: 65,
              child: Row(
                children: [
                  GestureDetector(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      padding: EdgeInsets.all(7.0),
                      child: Icon(
                        isplay ? Icons.pause : Icons.play_arrow,
                        color: Colors.white70,
                        size: 30,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple[400],
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      changeStatus();
                    },
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${currentIndex <= songs.length - 1 ? songs[currentIndex].title : "no song"}",
                          style: kststyle(16),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "${currentIndex <= songs.length - 1 ? songs[currentIndex].artist : "no artist"}",
                          style: kststyle(12),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                ],
              ),
              alignment: Alignment.center,
            ),
          ),
        );
      } else {
        return Container(height: 0);
      }
    }

    return Scaffold(
      backgroundColor: _image == null ? Color(0xb91c0045) : Color(0x00000000),
      appBar: AppBar(
        backgroundColor: Color(0xff35093a),
        leading: Icon(
          Icons.music_note,
          color: Color(0xff790000),
        ),
        title: Text(
          'Music App',
          style: TextStyle(
            color: Colors.white70,
          ),
        ),
        actions: [
          PopupMenuButton(
            color: Colors.purple[600],
            icon: Icon(
              Icons.menu,
              color: Color(0xa0ffffff),
            ),
            onSelected: (v) {
              if (v == "Image") {
                getImage();
              } else {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Download()));
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: "Image",
                  child: Text('background image'),
                ),
                const PopupMenuItem(
                  value: "download",
                  child: Text('download song'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Container(
        child: Stack(
          children: [
            imagepath != null
                ? ColorFiltered(
                    child: imagefunc(),
                    colorFilter:
                        ColorFilter.mode(Colors.black38, BlendMode.darken),
                  )
                : Container(),
            Container(
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                itemCount: songs.length,
                itemBuilder: (context, index) => ListTile(
                  focusColor: Colors.white54,
                  leading: CircleAvatar(
                    backgroundImage: songs[index].albumArtwork == null
                        ? AssetImage('images/music_gradient.jpg')
                        : FileImage(File(songs[index].albumArtwork)),
                  ),
                  title: Text(
                    songs[index].title,
                  ),
                  subtitle: Text(
                    songs[index].artist,
                  ),
                  onTap: () {
                    currentIndex = index;
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      checksinging = false;
                      return MusicPlayer(
                        songInfo: songs[currentIndex],
                        changeTrack: changeTrack,
                        background: imagefunc(),
                        key: key,
                      );
                    }));
                  },
                ),
              ),
            ),
            bottomControl(),
          ],
        ),
      ),
    );
  }
}

TextStyle kststyle(double fontsize) {
  return TextStyle(
    color: Colors.white60,
    fontSize: fontsize,
  );
}
