import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hkm/classes/liveSettings.dart';
import 'package:hkm/customcontrols.dart';
import 'package:hkm/download.dart';
// import 'package:hkm/control.dart';
// import 'package:hkm/customcontrols.dart';
import 'package:hkm/frame.dart';
import 'package:hkm/roomPage.dart';
import 'package:hkm/size_config.dart';
// import 'package:hkm/size_config.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flick_video_player/flick_video_player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp
  ]).then((_) {
    runApp(new MyApp());
  });
}

// Future<void> asd() async {
//   try {
//     var dir = await getApplicationDocumentsDirectory();
//     print(dir.path);
//   } catch (e) {
//     print(e);
//   }
// }

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: RoomPage(),
      // home: GroupPlayer(
      //     url:
      //         'https://b-g-ca-2.betterstream.co:2222/hls-playback/44c86c0c8530769fe875616e77d15642911403beb91339f8a4b6154c658a5a07d7119ef35e8de75b926feea2e3dec054fe1e11b09f3c26f2c494c87aa8adc33252aad4c5562cc824a3b23be08db1332bd414cc478a938620f7b62cad48b7f0fef877d4463bd17337ab94f50b68e4dd6fc18922fde859ae443e4ce3ed71e0333df9fc79e782d30273e2b7d95f0e6a77c62e81a758b4ee69e34afd2ce2a695d4c5/720/index.m3u8'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GroupPlayer extends StatefulWidget {
  final String url;
  final String roomNo;
  final bool creator;
  GroupPlayer(
      {@required this.url, @required this.creator, @required this.roomNo});
  @override
  _GroupPlayerState createState() => _GroupPlayerState();
}

class _GroupPlayerState extends State<GroupPlayer> {
  FlickManager flickManager;
  LiveStats liveStats = LiveStats(
      position:
          Duration(hours: 00, minutes: 00, seconds: 00, milliseconds: 00));
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    flickManager = FlickManager(
      videoPlayerController:
          widget.url.contains('storage') ? VideoPlayerController.file(
              // 'https://b-g-eu-3.betterstream.co:2222/hls-playback/fc3c0cd1c39b99f00315cae19123d195c9e80f56ae7ece8f709c6d008662ca87968f134fa992f3ec829a339caf8f4982624fa3afa09a1ef44205c9e49e22aaf2a49c61f697cf787b0512137e9118581cb531244ad47efbb2f8ba90d8c67ca5498cdec28b82bd8f8aa68c7915a936ecacb635773c6bfb2363b3ab168995a37f592b6a86ac5d6d5429e7b97f10016d301745986e8ca5ac900c548e2bdf529e09d5/720/index.m3u8'
              // widget.url
              File(widget.url)) : VideoPlayerController.network(widget.url),
    );
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FlickVideoManager>.value(
          value: flickManager.flickVideoManager,
        ),
        ChangeNotifierProvider<LiveStats>.value(
          value: liveStats,
        ),
      ],
      child: Scaffold(
        body: Container(
          width: Get.size.longestSide,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Container(
              //   color: Colors.black,

              //   width: getWidth(80),
              // ),
              Expanded(
                child: Container(
                  child: FlickVideoPlayer(
                    flickManager: flickManager,
                    preferredDeviceOrientation: [
                      DeviceOrientation.landscapeLeft,
                      DeviceOrientation.landscapeRight,
                    ],
                    flickVideoWithControls: FlickVideoWithControls(
                      // aspectRatioWhenLoading:
                      //     Get.width - 1280 / 720 * getHeight(45) / Get.height,
                      videoFit: BoxFit.fitHeight,
                      controls: CustomOrientationControls(
                        flickManager: flickManager,
                        fontSize: getText(12),
                        iconSize: getText(20),
                        roomNo: widget.roomNo,
                        creator: widget.creator,
                      ),
                    ),
                  ),
                  // color: Colors.yellowAccent,
                ),
              ),
              FaceFrame(
                roomNo: widget.roomNo,
                creator: widget.creator,
              )
            ],
          ),
        ),
      ),
    );
  }
}
