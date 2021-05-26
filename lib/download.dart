// import 'dart:html';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hkm/main.dart';
import 'package:hkm/size_config.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:sdp_transform/sdp_transform.dart';

class DownloadPage extends StatefulWidget {
  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  var playUrl;
  Dio dio = new Dio();
  bool downloading = false;
  bool downloaded = false;
  double progressString = 0;
  TextEditingController url = new TextEditingController();

  Future<void> downloadFileHDM(String a, String varurl) async {
    // String varurl =
    //     "https://hls.1o.to/vod/Tom%20and%20Jerry.mp4/chunklist.m3u8?keyendtime=1615044325&keyhash=ZdoIC9DXncum5jTV0bPRo09jdtqCwxeaDTOh9TCRioc=";
    Dio dio = Dio();
    var dir = await getExternalStorageDirectory();
    try {
      // print(dir.path);
      // String folder =
      //     varurl.split('/')[4].replaceAll('%20', '_').replaceAll('.mp4', '');
      // print(folder);
      await dio.download(varurl, "${dir.path}/$a/hk.m3u8",
          onReceiveProgress: (rec, total) {
        // print("Rec: $rec , Total: $total");
        setState(() {
          downloading = true;
        });
      });
    } catch (e) {
      print(e);
    }

    // setState(() {
    //   downloading = false;
    //   // progressString = "Completed";
    // });
    // print("Download completed");
    var file = File('${dir.path}/$a/hk.m3u8');
    List<String> contents = await file.readAsLines();
    print(contents[contents.length - 2]);
    int str =
        int.parse(contents[contents.length - 2].split('.')[0].split('_')[1]);
    print(str);
    String shell = contents[contents.length - 2].split('_')[0];
    getUrl(int x) {
      String url = varurl.split('chunklist.m3u8')[0] +
          shell +
          '_$x.ts' +
          varurl.split('chunklist.m3u8')[1];
      return url;
    }

    getList(x) {
      List<int> zxcxzc = [];
      for (int i = 1; i <= x; i = i + 1) {
        zxcxzc.add(i);
      }
      return zxcxzc;
    }

    try {
      await Future.wait(getList(str).map((e) => dio
          .download(getUrl(e), "${dir.path}/$a/$e",
              onReceiveProgress: (rec, total) {})
          .then((_) => setState(() {
                progressString += 1 / str;
                // print(e);
              }))));
    } catch (e) {
      print(e);
    }
    setState(() {
      downloading = false;
      playUrl = File('${dir.path}/$a/hk.m3u8');
      downloaded = true;
    });
  }

  Future<void> downloadFileMF(String a, String varurl) async {
    Dio dio = Dio();
    var dir = await getExternalStorageDirectory();
    // String varurl =
    //     'https://b-g-ca-1.betterstream.co:2222/hls-playback/bf22759ed14e753313962459b64b023168d78471bd3fe1d6ceb0289b9e48f8281fc7ee5fcde359465880486eca0f957f09ec9683892ae2e5f518b509a0bc2e3068175a7e649bc2b06318706fc81abbc9f7106fe0db420bf9a645703926ebbf17748da3fc08f2b079e0f8f654eda3f2dc2038f1a05abde22e07c0dfd3fd555a3aa0f08110cfbddf00df0ca77bdb76699d9d893f51542e41b0b5c18f58b6d682b4/720/index.m3u8';
    try {
      // print(dir.path);
      // String folder =
      //     varurl.split('/')[4].replaceAll('%20', '_').replaceAll('.mp4', '');
      // print(folder);
      await dio.download(varurl, "${dir.path}/$a/hk.m3u8",
          onReceiveProgress: (rec, total) {
        // print("Rec: $rec , Total: $total");

        setState(() {
          downloading = true;
        });
      });
    } catch (e) {
      print(e);
    }
    // print("Download completed");
    var file = File('${dir.path}/$a/hk.m3u8');
    List<String> qwe = [];
    List<String> contents = await file.readAsLines();
    contents.forEach((string) {
      try {
        string.contains('seg')
            ? string = string.split('-')[1]
            : string = string;
        // print(string);
      } catch (e) {
        print(e);
      }
      qwe.add(string);
    });
    var sink = file.openWrite();
    for (String a in qwe) {
      sink.writeln(a);
    }
    sink.close();

    // print('done!!');
    int str = int.parse(contents[contents.length - 2].split('-')[1]);
    String shell = contents[contents.length - 2];
    getUrl(int a) {
      // print(contents[contents.length - 2]);
      String x = shell.replaceAll(str.toString(), a.toString());
      String url = varurl.replaceAll('index.m3u8', x);
      return url;
    }

    getList(x) {
      List<int> zxcxzc = [];
      for (int i = 1; i <= x; i = i + 1) {
        zxcxzc.add(i);
      }
      return zxcxzc;
    }

    try {
      await Future.wait(getList(str).map((e) => dio
          .download(getUrl(e), "${dir.path}/$a/$e",
              onReceiveProgress: (rec, total) {})
          .then((_) => setState(() {
                progressString += 1 / str;
                // print(e);
              }))));
    } catch (e) {
      print(e);
    }
    setState(() {
      downloading = false;
      playUrl = File('${dir.path}/$a/hk.m3u8');
      downloaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          // width: Get.size.longestSide,
          color: Colors.amber,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: getWidth(120), vertical: getHeight(80)),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: getWidth(10)),
                      height: getHeight(50),
                      width: getWidth(400),
                      decoration: BoxDecoration(
                          color: Color(0xFF1B1109),
                          // border: Border.all(color: Color(0xFF1B1109), width: 2),
                          borderRadius: BorderRadius.all(
                            Radius.circular(getHeight(10)),
                          )),
                      child: TextField(
                        controller: url,
                        decoration: InputDecoration(
                            hintText: "Enter Url",
                            focusColor: Colors.black,
                            focusedBorder: InputBorder.none),
                        cursorColor: Colors.white,
                        cursorHeight: getHeight(25),
                      ),
                    ),
                    SizedBox(
                      width: getWidth(20),
                    ),
                    downloaded
                        ? GestureDetector(
                            onTap: () {
                              Get.to(GroupPlayer(
                                  url:
                                      'file:///storage/emulated/0/Android/data/com.example.hkm/files/FRIEaaNDSS1E1/hk.m3u8'));

                              // downloadFileHDM();
                              // asd();
                              // downloadFile();
                            },
                            child: Container(
                              height: getHeight(50),
                              width: getWidth(80),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Color(0xFF60555F), width: 2),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(getHeight(10)),
                                  )),
                              child: Center(
                                child: Icon(Icons.play_arrow),
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              downloadFileMF('GOTS1E1',
                                  'https://b-g-ca-2.betterstream.co:2222/hls-playback/44c86c0c8530769fe875616e77d15642911403beb91339f8a4b6154c658a5a07d7119ef35e8de75b926feea2e3dec054fe1e11b09f3c26f2c494c87aa8adc332c10fde82dd81a4d7b35dc35c5867931240eb0b3a154e76e0e73de71108c97b87c33a957aad6db11a59fa52274fc0209906b1cd5e004446dacad0f3513fa0a7f15f568ff8b265a671a1f2a378ab4688896d75b331c3116db66a958813eb44e3fe/720/index.m3u8');
                              // downloadFileHDM();
                              // asd();
                              // downloadFile();
                            },
                            child: Container(
                              height: getHeight(50),
                              width: getWidth(80),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Color(0xFF60555F), width: 2),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(getHeight(10)),
                                  )),
                              child: downloading
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.transparent,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.black),
                                        value: progressString,
                                      ),
                                    )
                                  : Center(
                                      child: Icon(Icons.download_sharp),
                                    ),
                            ),
                          )
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
