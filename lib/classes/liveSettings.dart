import 'package:flutter/foundation.dart';

class LiveStats with ChangeNotifier {
  Duration position;
  // RTCVideoRenderer renderer = new RTCVideoRenderer();
  void changePosition(Duration posi) {
    position = posi;
    // status = stat;
    notifyListeners();
  }

  LiveStats({this.position});
}
