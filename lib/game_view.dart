import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'entities/remote_game_state.dart';

class GameView extends StatefulWidget {
  @override
  _GameViewState createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  WebViewController controller;
  Completer jsReady = new Completer();

  JavascriptChannel rpc;
  RemoteGameState gameState;
  HttpServer server;

  bool isListening = false;
  int port;
  String addr;

  @override
  void initState() {
    rpc = new JavascriptChannel(name: 'rpc', onMessageReceived: _onMessage);
    gameState = new RemoteGameState();

    HttpServer.bind(InternetAddress.loopbackIPv4, 42151).then((server) async {
      setState(() {
        isListening = true;
        addr = server.address.address;
      });

      print('listening');

      print(server.address.address);
      print(server.port);

      Map<String, String> cache = {};

      server.listen((HttpRequest request) async {
        String path = request.requestedUri.path;
        String data;

        print(path);

        if (path == '/') {
          path = 'index.html';
        }

        try {
          if (cache.containsKey(path)) {
            data = cache[path];
          } else {
            data = await rootBundle.loadString('assets/$path');
            cache[path] = data;
          }
        } catch (err) {
          request.response.statusCode = 404;
          request.response.close();
          return;
        }

        request.response.headers
            .add('Content-Type', 'text/html; charset=utf-8');

        request.response.write(data);
        request.response.close();
      });
    });

    super.initState();
  }

  _onMessage(JavascriptMessage data) {
    final message = json.decode(data.message);

    switch (message['type']) {
      case 'ready':
        setState(() {
          gameState.start();
        });
        break;

      case 'health':
        setState(() {
          if (gameState.health > 0) {
            gameState.health += message['payload']['diff'];
          }

          if (gameState.health == 0) {
            gameState.kill();
          }
        });
        break;

      case 'score':
        setState(() {
          gameState.score += message['payload']['scoreDiff'];
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return Material(
      color: Color.fromARGB(255, 0x00, 0xd2, 0xff),
      child: Stack(
        children: [
          if (isListening)
            WebView(
              initialUrl: 'http://127.0.0.1:42151',
              javascriptMode: JavascriptMode.unrestricted,
              javascriptChannels: Set()..add(rpc),
              onWebViewCreated: (controller) async {
                gameState.controller = controller;
              },
              debuggingEnabled: true,
              onPageFinished: (d) {
                print(d);
              },
            ),
          if (gameState.isPaused)
            Container(
              color: Colors.black.withAlpha(120),
              child: Center(
                child: Text('PAUSED', style: TextStyle(fontSize: 30)),
              ),
            ),
          Align(
            alignment: AlignmentDirectional.bottomStart,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                        !gameState.isPaused ? Icons.pause : Icons.play_arrow),
                    iconSize: 50,
                    splashColor: Colors.white,
                    onPressed: () {
                      setState(() {
                        (!gameState.isPaused
                            ? gameState.pause
                            : gameState.resume)();
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.replay),
                    iconSize: 50,
                    splashColor: Colors.white,
                    onPressed: () {
                      setState(() {
                        gameState.restart();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.heart,
                          size: 30,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(
                            'x${gameState.health}',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: Text(
                            '${gameState.score}x',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        Icon(
                          FontAwesomeIcons.circle,
                          size: 30,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!gameState.isStarted)
            Container(
              constraints: BoxConstraints.expand(),
              color: Color.fromARGB(255, 0x00, 0xd2, 0xff),
            ),
        ],
      ),
    );
  }
}
