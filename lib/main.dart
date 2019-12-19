import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ppf/game_view.dart';

void main() async {
  SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        canvasColor: Colors.blue[400],
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 0x00, 0xd2, 0xff),
        body: GameView(),
        resizeToAvoidBottomPadding: false,
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}
