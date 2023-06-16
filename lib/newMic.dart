import 'dart:async';
import 'dart:math';
import 'dart:core';
import 'package:coba/main.dart';
import 'package:flutter/material.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

const AUDIO_FORMAT = AudioFormat.ENCODING_PCM_16BIT;
IO.Socket socket = IO.io('http://192.168.0.42:3030',
    IO.OptionBuilder().setTransports(['websocket']).build());

void main() {
  print("socket");
  runApp(MyHomePage(
    randomNumber: "",
    title: '',
  ));
}

class MyHomePage extends StatefulWidget {
  final String title;
  final String randomNumber;

  MyHomePage({required this.title, required this.randomNumber});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Stream? stream;
  StreamSubscription? listener;
  List<int>? currentSamples = [];
  List<int> visibleSamples = [];
  int? localMax;
  int? localMin;

  Random rng = new Random();

  @override
  void initState() {
    socket.connect();

    initSocket();
    print("Init application");

    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void initSocket() {
    socket.onConnect((_) {
      print('Connection established');
      // _listenAudioFinal();
    });

    socket.emit("join-room-walkie-talkie",
        ["${widget.title}", "${widget.randomNumber}"]);

    socket.on("user", (data) => print(data));

    socket.onDisconnect((_) => print('Connection Disconnection : ${_}'));
    socket.onConnectError((err) => print(err));
    socket.onError((err) => print(err));
  }

  // Color _getBgColor() => (!isRecording) ? Colors.red : Colors.cyan;
  // Icon _getIcon() =>
  //     (isRecording) ? Icon(Icons.stop) : Icon(Icons.keyboard_voice);

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('ROOM | ${widget.randomNumber}'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.title}',
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    listener?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
