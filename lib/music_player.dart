import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_music_app/main.dart';
import 'package:flutter_music_app/track.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayer extends StatefulWidget {
  SongInfo songInfo;
  Function changeTrack;
  Container background;

  final GlobalKey<MusicPlayerState> key;
  MusicPlayer({
    this.songInfo,
    this.changeTrack,
    this.background,
    this.key,
  }) : super(key: key);
  @override
  MusicPlayerState createState() => MusicPlayerState();
}

final AudioPlayer player = AudioPlayer();
bool isplay = false;

class MusicPlayerState extends State<MusicPlayer> {
  double minv = 0.0;
  double maxv = 0.0;
  double currv = 0.0;
  String currT = '';
  String endT = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setsong(widget.songInfo);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nope = true;
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
  }

  refresh() {
    setState(() {});
  }

  void setsong(SongInfo songInfo) async {
    if (checksinging == true && nope != false) {
      print("${checksinging} is for true");
    } else {
      widget.songInfo = songInfo;
      await player.setUrl(widget.songInfo.uri);
      print("${checksinging} is for false");
    }

    currv = minv;
    maxv = player.duration.inMilliseconds.toDouble();

    setState(() {
      currT = getDuration(currv);
      endT = getDuration(maxv);
    });
    isplay = false;
    changeStatus();
    player.positionStream.listen((duration) {
      currv = duration.inMilliseconds.toDouble();
      setState(() {
        currT = getDuration(currv);
      });
      if (currv >= maxv) {
        widget.changeTrack(true);
      }
    });
  }

  String getDuration(double value) {
    Duration duration = Duration(milliseconds: value.round());

    return [duration.inMinutes, duration.inSeconds]
        .map((e) => e.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xb91c0035),
      appBar: AppBar(
        backgroundColor: Color(0xb935093a),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => Tracks())).then((value) {
              setState(() {});
            });
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white70,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Now playing',
          style: TextStyle(
            color: Colors.white70,
          ),
        ),
      ),
      body: Stack(
        children: [
          imagepath == null
              ? Container()
              : ColorFiltered(
                  colorFilter:
                      ColorFilter.mode(Colors.black38, BlendMode.darken),
                  child: Container(
                    child: widget.background,
                  ),
                ),
          Container(
            margin: EdgeInsets.fromLTRB(5, 30, 5, 0),
            child: Column(
              children: [
                Container(
                  height: 250,
                  width: 250,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: widget.songInfo.albumArtwork == null
                        ? AssetImage('images/music_note.png')
                        : FileImage(File(widget.songInfo.albumArtwork)),
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0x90601010),
                      width: 6,
                    ),
                    borderRadius: BorderRadius.circular(130),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 7),
                        blurRadius: 15,
                        spreadRadius: 5,
                        color: Color(0xa9111111),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(2, 10, 2, 7),
                  child: Text(
                    widget.songInfo.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
                  child: Text(
                    widget.songInfo.artist,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Container(
                  transform: Matrix4.translationValues(0, 10, 0),
                  margin: EdgeInsets.fromLTRB(5, 0, 5, 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text(
                          currT,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          endT,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Slider(
                  activeColor: Color(0xffb90000),
                  inactiveColor: Color(0x79b90000),
                  min: minv,
                  max: maxv,
                  value: currv,
                  onChanged: (value) {
                    setState(() {
                      currv = value;
                      player.seek(Duration(milliseconds: currv.round()));
                    });
                  },
                ),
                Divider(
                  height: 10,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        child: GestureDetector(
                          child: Icon(
                            Icons.skip_previous,
                            color: Color(0xd0ffe8e8),
                            size: 55,
                          ),
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            widget.changeTrack(false);
                          },
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            gradient: LinearGradient(colors: [
                              Color(0xc9bf0000),
                              Color(0xc97f0000),
                            ])),
                        padding: EdgeInsets.all(13.0),
                        child: GestureDetector(
                          child: Icon(
                            isplay ? Icons.pause : Icons.play_arrow,
                            color: Color(0xc9ffffff),
                            size: 60,
                          ),
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            changeStatus();
                          },
                        ),
                      ),
                      Container(
                        child: GestureDetector(
                          child: Icon(
                            Icons.skip_next,
                            color: Color(0xd0ffe8e8),
                            size: 55,
                          ),
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            widget.changeTrack(true);
                          },
                        ),
                      ),
                    ],
                  ), //controller
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
