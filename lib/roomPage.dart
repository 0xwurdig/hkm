import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' as GET;
import 'package:hkm/main.dart';
import 'dart:math';

import 'package:hkm/size_config.dart';

const _chars = "QWERTYUIOPLKJHGFDSAZXCVBNM1234567890";
Random _rnd = Random();
String generate(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text?.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class RoomPage extends StatefulWidget {
  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  // Response response;
  Future<String> checkRoomNo(String room) async {
    Dio dio = new Dio();
    Response response = await dio.get('http://103.36.83.197:4902/hkm/$room');

    // print(response.data['exists']);
    String x = response.data['exists'];
    return x;
  }

  TextEditingController join = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: GET.Get.width,
        height: GET.Get.height,
        color: Colors.amber[900],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                var asd = generate(5);
                checkRoomNo(asd).then((x) {
                  while (x == "s") {
                    asd = generate(5);
                  }
                  GET.Get.to(GroupPlayer(
                      url:
                          "https://b-g-ca-2.betterstream.co:2222/hls-playback/44c86c0c8530769fe875616e77d15642911403beb91339f8a4b6154c658a5a07d7119ef35e8de75b926feea2e3dec054fe1e11b09f3c26f2c494c87aa8adc332ca09a1b5e28ef305cdf5bcf190f018aaa5f79874f8b3dc121fcda9e91c42eebfceb7a8b7d3ef90584ec3990b849d7024a95e4cd79f0d17e10b11a3968f43d0741330546c52ed71f664f6b16267f2213bee9fec6e68a7d5480b28e9fc0a487ff8/720/index.m3u8",
                      creator: true,
                      roomNo: asd));
                });
                // while (checkRoomNo(asd) == "s") {
                //   asd = generate(5);
                // }
                // GET.Get.to(GroupPlayer(
                //     url:
                //         "https://b-g-ca-2.betterstream.co:2222/hls-playback/44c86c0c8530769fe875616e77d15642911403beb91339f8a4b6154c658a5a07d7119ef35e8de75b926feea2e3dec054fe1e11b09f3c26f2c494c87aa8adc332ca09a1b5e28ef305cdf5bcf190f018aaa5f79874f8b3dc121fcda9e91c42eebfceb7a8b7d3ef90584ec3990b849d7024a95e4cd79f0d17e10b11a3968f43d0741330546c52ed71f664f6b16267f2213bee9fec6e68a7d5480b28e9fc0a487ff8/720/index.m3u8",
                //     creator: true,
                //     roomNo: asd));
              },
              child: Container(
                // color: Colors.grey[850],
                height: getHeight(60),
                width: getWidth(200),
                decoration: BoxDecoration(
                    color: Colors.grey[850],
                    // border: Border.all(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.all(
                      Radius.circular(getHeight(10)),
                    )),
                child: Center(
                    child: Text(
                  "Create Room",
                  style: TextStyle(
                      fontSize: getText(22),
                      color: Colors.white70,
                      decoration: TextDecoration.none),
                )),
              ),
            ),
            SizedBox(
              height: getHeight(20),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: getWidth(20)),
              // color: Colors.grey[850],
              height: getHeight(60),
              width: getWidth(200),
              decoration: BoxDecoration(
                  color: Colors.grey[800],
                  // border: Border.all(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(getHeight(10)),
                      topRight: Radius.circular(getHeight(10)))),
              child: TextField(
                controller: join,
                autocorrect: false,
                autofocus: false,
                cursorColor: Colors.white70,
                cursorHeight: getHeight(35),
                inputFormatters: [
                  UpperCaseTextFormatter(),
                ],
                // textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                    color: Colors.amberAccent[700],
                    fontSize: getText(35),
                    fontWeight: FontWeight.w900,
                    letterSpacing: getText(10),
                    // letterSpacing: 2.0,
                    decoration: TextDecoration.none),
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                checkRoomNo(join.text.toString()).then((x) {
                  x == "s"
                      ? GET.Get.to(GroupPlayer(
                          url:
                              "https://b-g-ca-2.betterstream.co:2222/hls-playback/44c86c0c8530769fe875616e77d15642911403beb91339f8a4b6154c658a5a07d7119ef35e8de75b926feea2e3dec054fe1e11b09f3c26f2c494c87aa8adc332ca09a1b5e28ef305cdf5bcf190f018aaa5f79874f8b3dc121fcda9e91c42eebfceb7a8b7d3ef90584ec3990b849d7024a95e4cd79f0d17e10b11a3968f43d0741330546c52ed71f664f6b16267f2213bee9fec6e68a7d5480b28e9fc0a487ff8/720/index.m3u8",
                          creator: false,
                          roomNo: join.text.toString()))
                      : GET.Get.snackbar(
                          "Error",
                          "Wrong Join Code",
                        );
                });
              },
              child: Container(
                // color: Colors.grey[850],
                height: getHeight(60),
                width: getWidth(200),
                decoration: BoxDecoration(
                    color: Colors.grey[850],
                    // border: Border.all(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(getHeight(10)),
                        bottomRight: Radius.circular(getHeight(10)))),
                child: Center(
                    child: Text(
                  "Join Room",
                  style: TextStyle(
                      fontSize: getText(22),
                      color: Colors.white70,
                      decoration: TextDecoration.none),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
