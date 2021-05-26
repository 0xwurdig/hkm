import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' as asd;
import 'package:hkm/classes/liveSettings.dart';
import 'package:hkm/remotevid.dart';
import 'package:provider/provider.dart';
// import 'package:hkm/classes/RemoteRenderers.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:hkm/control.dart';
import 'size_config.dart';

class FaceFrame extends StatefulWidget {
  final String roomNo;
  final bool creator;
  FaceFrame({this.roomNo, this.creator});
  @override
  _FaceFrameState createState() => _FaceFrameState();
}

class _FaceFrameState extends State<FaceFrame> with WidgetsBindingObserver {
  // var a = widget.roomNo;
  RTCVideoRenderer localRenderer = new RTCVideoRenderer();
  Map<String, dynamic> remoteRenderers = {};
  Map<String, dynamic> peerConnections = {};
  IO.Socket socket;
  Duration du;
  // IO.Socket socket = IO.io('http://103.36.83.197:4813', <String, dynamic>{
  //   'transports': ['websocket'],
  //   'autoConnect': false,
  //   'query': {'room': }
  // });
  Map<String, dynamic> configuration = {
    "iceServers": [
      {"url": "stun:stun.l.google.com:19302"},
    ],
    'sdpSemantics': 'uinified-plan'
  };

  final Map<String, dynamic> offerSdpConstraints = {
    "mandatory": {
      "OfferToReceiveAudio": true,
      "OfferToReceiveVideo": true,
    },
    "optional": [],
  };
  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    remoteRenderers.forEach((key, value) {
      value.dispose();
    });
    peerConnections.forEach((key, value) {
      value.dispose();
    });
    localRenderer.dispose();
  }

  @override
  void initState() {
    super.initState();
    socket = IO.io('http://103.36.83.197:4902', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'room': widget.roomNo}
    });
    connectToServer();
    initRenderers();
    WidgetsBinding.instance.addObserver(this);
  }
  // AppLifecycleState _notification;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // user returned to our app
      localRenderer.srcObject.getTracks().forEach((element) {
        element.enabled = false;
      });
      remoteRenderers.forEach((key, value) {
        value.srcObject.getTracks().forEach((track) {
          track.enabled = false;
        });
      });
    }
  }

  initRenderers() async {
    await localRenderer.initialize();
  }

  _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': {
        'mandatory': {
          'echoCancellation': false,
          'googEchoCancellation': false,
          'googAutoGainControl': false,
          'googAutoGainControl2': false,
          'googNoiseSuppression': false,
          'googHighpassFilter': false,
          'googTypingNoiseDetection': false,
          'googAudioMirroring': false,
          // 'sampleSize': 16,
          // 'channelCount': 2
        }
      },
      'video': {
        'width': 1280,
        'height': 720,
        // 'aspectRatio': 1.777777778,
        // 'frameRate': {'max': 30},
        'facingMode': 'user'
      },
      'options': {
        'mirror': true,
      }
    };
    MediaStream stream =
        await navigator.mediaDevices.getUserMedia(mediaConstraints);
    setState(() {
      localRenderer.srcObject = stream;
    });
    // sendToPeer('onlinePeers', null, {'local': socket.id});
  }

  _createPeerConnection(socketId) async {
    try {
      RTCPeerConnection pc = await createPeerConnection(
        configuration,
        offerSdpConstraints,
      );
      print(
          'PEERCONNECTION^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
      print(pc);
      // add pc to peerConnections object
      setState(() {
        peerConnections['$socketId'] = pc;
        print(peerConnections);
      });

      pc.onIceCandidate = (e) => {
            if (e.candidate.isNotEmpty)
              {
                socket.emit('candidate', {
                  'candidate': e.candidate.toString(),
                  'sdpMid': e.sdpMid.toString(),
                  'sdpMlineIndex': e.sdpMlineIndex,
                  'local': socket.id,
                  'remote': socketId
                })
                //   this.sendToPeer('candidate', e.candidate,
                //       {'local': socket.id, 'remote': socketId})
                // }
              }
          };
      pc.onAddStream = (stream) async {
        RTCVideoRenderer remoteRenderer = new RTCVideoRenderer();
        await remoteRenderer.initialize();
        remoteRenderer.srcObject = stream;
        setState(() {
          remoteRenderers[socketId] = remoteRenderer;
        });
      };
      // pc.onTrack = (e) {
      //   if (e != null) {
      //     MediaStream _remoteStream;
      //     RemoteRenderers remoteVideo;
      //     // 1. check if stream already exists in remoteRenderers
      //     var rVideos = remoteRenderers
      //         .where((element) => element.id == socketId)
      //         .toList();
      //     // 2. if it does exist then add track
      //     if (rVideos.length != 0) {
      //       _remoteStream = rVideos[0].renderer.srcObject;
      //       _remoteStream.addTrack(e.track);
      //       remoteVideo.id = socketId;
      //       remoteVideo.renderer.srcObject = _remoteStream;
      //       setState(() {
      //         remoteRenderers.add(remoteVideo);
      //       });
      //     } else {
      //       _remoteStream.addTrack(e.track);
      //       remoteVideo.id = socketId;
      //       remoteVideo.renderer.srcObject = _remoteStream;
      //       setState(() {
      //         remoteRenderers.add(remoteVideo);
      //       });
      //     }
      //   }
      // };

      if (localRenderer != null) {
        pc.addStream(localRenderer.srcObject);
        //   // localRenderer.srcObject
        //   //     .getTracks()
        //   //     .forEach((track) => {pc.addTrack(track, localRenderer.srcObject)});

      }

      // return pc
      print(
          'PEERConnection^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
      return (pc);
    } catch (e) {
      print('Something went wrong! pc not created!!');
      print(e);
      // return;
      return (null);
    }
  }

  connectToServer() {
    try {
      // Connect to websocket
      socket.connect();
    } catch (e) {
      print(e.toString());
    }

    socket.on('connection-success', (data) {
      _getUserMedia();
      socket.emit('onlinePeers', {'local': socket.id});
      print('connection-sucess############################################');
      // if (du != null) {
      //   print(du);
      //   socket.emit('liveStrem', {'position': du});
      // }
      // print(data['success']);
    });

    socket.on('peer-disconnected', (data) {
      print('peer-disconnected');
      print(data);

      // var remoteRenderer = remoteRenderers
      //     .where((a) => a.renderer.srcObject.id != data['socketID']);

      setState(() {
        remoteRenderers.remove(data['socketID']);
      });
    });

    // this.socket.on('offerOrAnswer', (sdp) => {

    //   this.textref.value = JSON.stringify(sdp)

    //   // set sdp as remote description
    //   this.pc.setRemoteDescription(new RTCSessionDescription(sdp))
    // })

    socket.on('online-peer', (data) async {
      print('connected peers%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
      print(data['id']);

      // create and send offer to the peer (data.socketID)
      // 1. Create new pc
      _createPeerConnection(data['id']).then((pc) async {
        if (pc != null) {
          print(
              'creating offer@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
          RTCSessionDescription description =
              await pc.createOffer(offerSdpConstraints);
          // description.sdp.replaceAll('useinbandfec=1',
          //     'useinbandfec=1; stereo=1; maxaveragebitrate=510000');
          description.sdp.replaceAll('useinbandfec=1', 'cbr=1');
          pc.setLocalDescription(description);
          socket.emit('offer', {
            'sdp': description.sdp,
            'local': socket.id,
            'remote': data['id']
          });
          // sendToPeer(
          //     'offer', sdp, {'local': this.socket.id, 'remote': socketID});
        }
      });
      // 2. Create Offer
    });

    socket.on('offer', (data) {
      _createPeerConnection(data['socketID']).then((pc) async {
        pc.addStream(localRenderer.srcObject);
        await pc
            .setRemoteDescription(RTCSessionDescription(data['sdp'], 'offer'))
            .then((_) async {
          // 2. Create Answer
          RTCSessionDescription description =
              await pc.createAnswer(offerSdpConstraints);
          // description.sdp.replaceAll('useinbandfec=1',
          //     'useinbandfec=1; stereo=1; maxaveragebitrate=510000');
          description.sdp.replaceAll('useinbandfec=1', 'cbr=1');
          pc.setLocalDescription(description);
          socket.emit('answer', {
            'sdp': description.sdp,
            'local': socket.id,
            'remote': data['socketID']
          });
          // this.sendToPeer('answer', sdp,
          //     {'local': this.socket.id, 'remote': data.socketID});
        });
      });
    });

    socket.on('answer', (data) async {
      // get remote's peerConnection
      RTCPeerConnection pc = peerConnections['${data['socketID']}'];
      // print(data.sdp);
      await pc
          .setRemoteDescription(RTCSessionDescription(data['sdp'], 'answer'));
    });

    socket.on('candidate', (data) async {
      // get remote's peerConnection
      RTCPeerConnection pc = peerConnections[data['local']];

      if (pc != null) {
        await pc.addCandidate(new RTCIceCandidate(
            data['candidate'], data['sdpMid'], data['sdpMlineIndex']));
      }
    });
  }

  bool mic = false;
  bool cam = false;
  @override
  Widget build(BuildContext context) {
    if (widget.creator) {
      FlickVideoManager flickVideoManager =
          Provider.of<FlickVideoManager>(context);
      print(
          (flickVideoManager.videoPlayerController.value.position).toString());
      socket.emit('liveStream', {
        'position':
            (flickVideoManager.videoPlayerController.value.position).toString()
      });
    } else {
      LiveStats liveStats = Provider.of<LiveStats>(context);
      socket.on('liveStream', (data) {
        liveStats.changePosition(data['position']);
      });
    }
    if (localRenderer.srcObject != null) {
      localRenderer.srcObject.getAudioTracks()[0].enabled = mic;
      localRenderer.srcObject.getVideoTracks()[0].enabled = cam;
    }
    return Container(
        color: Colors.black,
        width: 1280 / 720 * getHeight(45),
        height: asd.Get.size.height,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      SizedBox(
                        height: getHeight(10),
                      ),
                      SizedBox(
                        height: getHeight(45),
                        // color: Colors.white,
                        child: cam
                            ? RTCVideoView(
                                localRenderer,
                                objectFit: RTCVideoViewObjectFit
                                    .RTCVideoViewObjectFitCover,
                                filterQuality: FilterQuality.medium,
                                mirror: true,
                              )
                            : Container(
                                color: Colors.amber,
                              ),
                      ),
                      remoteRenderers.length != 0
                          ? Column(
                              children:
                                  remoteRenderers.values.toList().map((e) {
                                return SizedBox(
                                    height: getHeight(45),
                                    child: RemoteVids(rtcVideoRenderer: e));
                              }).toList(),
                            )
                          // ListView.builder(
                          //     scrollDirection: Axis.vertical,
                          //     shrinkWrap: true,
                          //     itemCount: remoteRenderers.length,
                          //     itemBuilder: (BuildContext context, int index) {
                          //       String key = remoteRenderers.keys.elementAt(index);
                          //       return new Container(
                          //         height: getHeight(45),
                          //         color: Colors.white,
                          //         child: cam
                          //             ? RTCVideoView(
                          //                 remoteRenderers[key],
                          //                 objectFit: RTCVideoViewObjectFit
                          //                     .RTCVideoViewObjectFitCover,
                          //                 filterQuality: FilterQuality.medium,
                          //                 mirror: true,
                          //               )
                          //             : Container(
                          //                 color: Colors.amber,
                          //               ),
                          //       );
                          //     },
                          //   )
                          : Container(
                              color: Colors.red,
                              height: getHeight(10),
                            ),
                      SizedBox(
                        height: getHeight(10),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: getHeight(10),
              ),
              Column(children: [
                Container(
                  height: getHeight(30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [micW(), camW()],
                  ),
                ),
                SizedBox(
                  height: getHeight(10),
                ),
                Container(
                  width: getWidth(60),
                  height: getHeight(30),
                  // color: Colors.red,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 2),
                      borderRadius: BorderRadius.all(
                        Radius.circular(getHeight(10)),
                      )),
                  child: Center(
                      child: Text(
                    'Exit',
                    style:
                        TextStyle(color: Colors.white, fontSize: getText(18)),
                  )),
                ),
                SizedBox(
                  height: getHeight(10),
                )
              ]),
            ]));
  }

  micW() {
    return GestureDetector(
        onTap: () {
          setState(() {
            mic = !mic;
            // localRenderer.srcObject.getAudioTracks()[0].enabled = mic;
          });
        },
        child: mic
            ? SizedBox(
                child: SvgPicture.asset('assets/mic-on.svg'),
                width: getWidth(30),
                height: getHeight(25),
              )
            : SizedBox(
                child: SvgPicture.asset('assets/mic-off.svg'),
                width: getWidth(30),
                height: getHeight(25),
              ));
  }

  camW() {
    return GestureDetector(
        onTap: () {
          setState(() {
            cam = !cam;
            // localRenderer.srcObject.getVideoTracks()[0].enabled = cam;
          });
        },
        child: cam
            ? SizedBox(
                child: SvgPicture.asset('assets/cam-on.svg'),
                width: getWidth(28),
                height: getHeight(25),
              )
            : SizedBox(
                child: SvgPicture.asset('assets/cam-off.svg'),
                width: getWidth(28),
                height: getHeight(25),
              ));
  }

  // videos() {
  //   remoteRenderers.forEach((key, value) {
  //     return Container(
  //       height: getHeight(45),
  //       color: Colors.white,
  //       child: cam
  //           ? RTCVideoView(
  //               value,
  //               objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
  //               filterQuality: FilterQuality.medium,
  //               mirror: true,
  //             )
  //           : Container(
  //               color: Colors.amber,
  //             ),
  //     );
  //   });
  // }
}
