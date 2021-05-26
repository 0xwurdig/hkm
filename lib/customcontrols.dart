import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:hkm/classes/liveSettings.dart';
import 'package:hkm/size_config.dart';
import 'package:provider/provider.dart';

class CustomOrientationControls extends StatelessWidget {
  const CustomOrientationControls({
    Key key,
    this.flickManager,
    this.iconSize,
    this.fontSize,
    this.roomNo,
    this.creator,
  }) : super(key: key);
  final double iconSize;
  final double fontSize;
  final String roomNo;
  final bool creator;
  final FlickManager flickManager;
  @override
  Widget build(BuildContext context) {
    FlickVideoManager flickVideoManager =
        Provider.of<FlickVideoManager>(context);
    LiveStats liveStats = Provider.of<LiveStats>(context);
    Duration position = flickVideoManager.videoPlayerController.value.position;
    String positionInSec = position != null
        ? (position - Duration(minutes: position.inMinutes))
            .inSeconds
            .toString()
            .padLeft(2, '0')
        : null;
    String positionInMin = position != null
        ? (position - Duration(hours: position.inHours))
            .inMinutes
            .toString()
            .padLeft(2, '0')
        : null;
    Duration duration = flickVideoManager.videoPlayerController.value.duration;
    String durationInSec = duration != null
        ? (duration - Duration(minutes: duration.inMinutes))
            .inSeconds
            .toString()
            .padLeft(2, '0')
        : null;
    String durationInMin = duration != null
        ? (duration - Duration(hours: duration.inHours))
            .inMinutes
            .toString()
            .padLeft(2, '0')
        : null;
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Container(color: Colors.black38),
          ),
        ),
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: getHeight(8.0), horizontal: getWidth(8)),
                  child: Text(
                    '#$roomNo',
                    style:
                        TextStyle(color: Colors.white70, fontSize: getText(25)),
                  ),
                )),
          ),
        ),
        Positioned.fill(
          child: FlickShowControlsAction(
            child: FlickSeekVideoAction(
              child: Center(
                child: FlickAutoHideChild(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: getHeight(10.0),
                            horizontal: getWidth(10)),
                        child: GestureDetector(
                          onDoubleTap: () {
                            flickManager.flickControlManager
                                .seekBackward(Duration(seconds: 10));
                          },
                          child: Align(
                            alignment: Alignment.center,
                            child: AnimatedCrossFade(
                              duration: Duration(milliseconds: 100),
                              firstChild: IconTheme(
                                data: IconThemeData(color: Colors.transparent),
                                child: Icon(
                                  Icons.fast_rewind,
                                  size: getText(50),
                                ),
                              ),
                              crossFadeState: CrossFadeState.showFirst,
                              secondChild: IconTheme(
                                data: IconThemeData(color: Colors.white),
                                child: Icon(
                                  Icons.fast_rewind,
                                  size: getText(40),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: getHeight(8.0), horizontal: getWidth(8)),
                        child: FlickPlayToggle(
                          size: getText(40),
                          playChild: Icon(
                            Icons.play_arrow,
                            size: getText(40),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: getHeight(8.0), horizontal: getWidth(8)),
                        child: GestureDetector(
                          onDoubleTap: () {
                            !creator &&
                                    liveStats.position <
                                        flickVideoManager.videoPlayerController
                                                .value.position +
                                            Duration(seconds: 10)
                                ? flickManager.flickControlManager
                                    .seekTo(liveStats.position)
                                : flickManager.flickControlManager
                                    .seekForward(Duration(seconds: 10));
                          },
                          child: Align(
                            alignment: Alignment.center,
                            child: AnimatedCrossFade(
                              duration: Duration(milliseconds: 100),
                              firstChild: IconTheme(
                                  data: IconThemeData(
                                    color: Colors.transparent,
                                  ),
                                  child: Icon(
                                    Icons.fast_forward,
                                    size: getText(50),
                                  )),
                              crossFadeState: CrossFadeState.showFirst,
                              secondChild: IconTheme(
                                data: IconThemeData(color: Colors.white),
                                child: Icon(
                                  Icons.fast_forward,
                                  size: getText(40),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: getHeight(8.0), horizontal: getWidth(8)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            '${position.inHours}:$positionInMin:$positionInSec',
                            style: TextStyle(fontSize: fontSize),
                          ),
                          Text(
                            ' / ',
                            style: TextStyle(
                                color: Colors.white, fontSize: fontSize),
                          ),
                          Text(
                            '${duration != null ? duration.inHours : null}:$durationInMin:$durationInSec',
                            style: TextStyle(fontSize: fontSize),
                          )
                        ],
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      !creator
                          ? GestureDetector(
                              onTap: () {
                                flickManager.flickControlManager
                                    .seekTo(liveStats.position);
                              },
                              child: Container(
                                height: getHeight(30),
                                width: getWidth(60),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Colors.white)),
                                child: Center(child: Text('Live')),
                              ),
                            )
                          : Container(
                              height: getHeight(30),
                              width: getWidth(60),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Colors.white60)),
                              child: Center(child: Text('Live')),
                            ),
                      SizedBox(
                        width: getWidth(10),
                      ),
                      FlickFullScreenToggle(),
                    ],
                  ),
                  FlickVideoProgressBar(
                    flickProgressBarSettings: FlickProgressBarSettings(
                      height: getHeight(5),
                      handleRadius: 2,
                      curveRadius: 50,
                      backgroundColor: Colors.white24,
                      bufferedColor: Colors.white38,
                      playedColor: Colors.white,
                      handleColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
