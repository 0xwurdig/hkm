import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:hkm/size_config.dart';

class RemoteVids extends StatefulWidget {
  final RTCVideoRenderer rtcVideoRenderer;
  RemoteVids({this.rtcVideoRenderer});

  @override
  _RemoteVidsState createState() => _RemoteVidsState();
}

class _RemoteVidsState extends State<RemoteVids> {
  bool micOn = true;
  bool camOn = true;
  bool showOptions = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              showOptions = !showOptions;
            });
          },
          child: Container(
            height: getHeight(55),
            padding: EdgeInsets.only(top: getHeight(10)),
            color: Colors.black87,
            child: camOn
                ? RTCVideoView(
                    widget.rtcVideoRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    filterQuality: FilterQuality.medium,
                    mirror: true,
                  )
                : Container(
                    color: Colors.amber,
                  ),
          ),
        ),
        if (showOptions)
          GestureDetector(
            onTap: () {
              setState(() {
                showOptions = !showOptions;
              });
            },
            child: Container(
              height: getHeight(55),
              padding: EdgeInsets.only(top: getHeight(10)),
              color: Colors.black.withOpacity(0.6),
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [micW(), camW()],
                ),
              ),
            ),
          ),
      ],
    );
  }

  micW() {
    return GestureDetector(
        onTap: () {
          setState(() {
            micOn = !micOn;
            widget.rtcVideoRenderer.srcObject.getAudioTracks()[0].enabled =
                !widget.rtcVideoRenderer.srcObject.getAudioTracks()[0].enabled;
          });
        },
        child: micOn
            ? SizedBox(
                child: SvgPicture.asset('assets/mic-on.svg'),
                width: getWidth(25),
                height: getHeight(20),
              )
            : SizedBox(
                child: SvgPicture.asset('assets/mic-off.svg'),
                width: getWidth(25),
                height: getHeight(20),
              ));
  }

  camW() {
    return GestureDetector(
        onTap: () {
          setState(() {
            camOn = !camOn;
            widget.rtcVideoRenderer.srcObject.getVideoTracks()[0].enabled =
                !widget.rtcVideoRenderer.srcObject.getVideoTracks()[0].enabled;
          });
        },
        child: camOn
            ? SizedBox(
                child: SvgPicture.asset('assets/cam-on.svg'),
                width: getWidth(23),
                height: getHeight(20),
              )
            : SizedBox(
                child: SvgPicture.asset('assets/cam-off.svg'),
                width: getWidth(23),
                height: getHeight(20),
              ));
  }
}
