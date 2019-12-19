import 'dart:convert';

import 'package:webview_flutter/webview_flutter.dart';

class Sender {
  Sender({this.controller});

  WebViewController controller;

  sendMessage(dynamic message) {
    controller.evaluateJavascript('''window.onmessage({
      data: ${json.encode(json.encode(message))}
    })''');
  }
}
