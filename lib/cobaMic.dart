import 'dart:async';
import 'dart:convert';
// import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:coba/testMic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:mic_stream/mic_stream.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

const AUDIO_FORMAT = AudioFormat.ENCODING_PCM_16BIT;
FlutterSound myPlayer = FlutterSound();
const blockSize = 4096;

void main() {
  runApp(SimpleMicStreamApp(
    title: 'Simple Mic Stream App',
    user: "User ",
  ));
}

class SimpleMicStreamApp extends StatefulWidget {
  final String title;
  final String user;

  const SimpleMicStreamApp({required this.title, required this.user});

  @override
  _SimpleMicStreamAppState createState() => _SimpleMicStreamAppState();
}

class _SimpleMicStreamAppState extends State<SimpleMicStreamApp> {
  late IO.Socket socket;
  bool isRecording = false;
  Stream? stream;
  StreamSubscription? listener;
  late int bytesPerSample;
  late int samplesPerSecond;
  int? localMax;
  int? localMin;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    initSocket();
    Isolate.spawn(runInBackground, null);
  }

  void _initAudioPlayer() async {
    await myPlayer.thePlayer.openPlayer();
    await myPlayer.thePlayer.startPlayerFromStream(
        codec: Codec.pcm16, numChannels: 1, sampleRate: 48000);
  }

  void initSocket() {
    socket = IO.io('http://192.168.1.228:3030',
        IO.OptionBuilder().setTransports(['websocket']).build());

    socket.onConnect((_) {
      print('Connected');
      socket.emit('client', "halo server");

      _listenAudioFinal();
      // Socket is connected, you can send messages
    });

    socket.emit("join-room-walkie-talkie", [widget.user, widget.title]);

    socket.onDisconnect((_) {
      print('Disconnected');

      // Handle socket disconnection
    });

    // socket.connect();
  }

  void toggleRecording() {
    // setState(() {
    //   isRecording = !isRecording;
    // });

    print(isRecording);

    if (isRecording) {
      startMicStream();
    } else {
      stopMicStream();
    }
  }

  Future<void> startMicStream() async {
    print("halo ini mic");
    MicStream.shouldRequestPermission(true);

    stream = await MicStream.microphone(
        audioSource: AudioSource.DEFAULT,
        // sampleRate: 1000 * (rng.nextInt(50) + 30),
        sampleRate: 48000,
        channelConfig: ChannelConfig.CHANNEL_IN_MONO,
        audioFormat: AUDIO_FORMAT);

    bytesPerSample = (await MicStream.bitDepth)! ~/ 8;
    samplesPerSecond = (await MicStream.sampleRate)!.toInt();
    localMax = null;
    localMin = null;

    if (isRecording) {
      listener = stream!.listen(_calculateSamples, onError: (error) {
        print("error listen : ${error}");
      });
    }
  }

  void _calculateSamples(samples) async {
    if (samples.isNotEmpty) {
      print(samples);

      Uint8List audioData = Uint8List.fromList(samples);

      // myPlayer.thePlayer.foodSink?.add(FoodData(audioData));

      socket.emit('audioMessage', audioData);
    }
  }

  bool isPlayerRunning = false;

  void _listenAudioFinal() {
    var i = 0;
    socket.on('audioFinal', (data) async {
      if (!isPlayerRunning) {
        print("test 1");

        Uint8List audioData = Uint8List.fromList(data);

        // await myPlayer.thePlayer.startPlayerFromStream(
        //     codec: Codec.pcm16, numChannels: 1, sampleRate: 48000);

        myPlayer.thePlayer.foodSink?.add(FoodData(audioData));
        print(audioData);

        print(("cek stop"));
      }
    });
  }

  void stopMicStream() {
    listener?.cancel();
    listener = null;
    stream = null;
  }

  void runInBackground(Null message) {
    // Memulai kode untuk dijalankan di isolate terpisah
    startMicStream();
    _listenAudioFinal();
    print('halo');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.pop(context);
              socket.emit("user-out-room", [widget.user, widget.title]);
              // socket.onDisconnect((_) {
              //   print('Disconnected');
              //   // Handle socket disconnection
              // });
            },
          ),
          title: Row(
            children: [
              Text(
                widget.title,
              ),
              SizedBox(width: 8),
            ],
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                widget.user,
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isRecording ? Colors.red : Colors.blue,
                ),
                child: InkWell(
                  onTapDown: (TapDownDetails details) {
                    setState(() {
                      isRecording = true;
                    });
                    toggleRecording();
                  },
                  onTapUp: (TapUpDetails details) {
                    setState(() {
                      isRecording = false;
                    });
                    toggleRecording();
                  },
                  child: Text(
                    isRecording ? 'Recording' : 'Send Message',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
