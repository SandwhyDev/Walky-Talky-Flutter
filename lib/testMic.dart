import 'dart:async';
import 'dart:math';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum Command {
  start,
  stop,
  change,
}

const AUDIO_FORMAT = AudioFormat.ENCODING_PCM_16BIT;
IO.Socket socket = IO.io('http://192.168.0.42:3030',
    IO.OptionBuilder().setTransports(['websocket']).build());

void main() {
  print("socket");
  runApp(MicStreamExampleApp(
    desc: '',
    randomNumber: "",
    title: '',
  ));
}

class MicStreamExampleApp extends StatefulWidget {
  final String title;
  final String desc;
  final String randomNumber;

  MicStreamExampleApp(
      {required this.title, required this.desc, required this.randomNumber});

  @override
  _MicStreamExampleAppState createState() => _MicStreamExampleAppState();
}

class _MicStreamExampleAppState extends State<MicStreamExampleApp>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Stream? stream;
  StreamSubscription? listener;
  List<int>? currentSamples = [];
  List<int> visibleSamples = [];
  int? localMax;
  int? localMin;

  Random rng = new Random();

  // Refreshes the Widget for every possible tick to force a rebuild of the sound wave
  late AnimationController controller;

  Color _iconColor = Colors.white;
  bool isRecording = false;
  bool memRecordingState = false;
  late bool isActive;
  DateTime? startTime;

  int page = 0;
  List state = ["SoundWavePage", "IntensityWavePage", "InformationPage"];

  @override
  void initState() {
    socket.connect();

    initSocket();
    print("Init application");

    super.initState();
    WidgetsBinding.instance.addObserver(this);

    setState(() {
      initPlatformState();
    });
  }

  void initSocket() {
    socket.onConnect((_) {
      print('Connection established');
      _listenAudioFinal();
    });

    socket.emit("join-room-walkie-talkie",
        ["${widget.title}", "${widget.randomNumber}"]);

    socket.onDisconnect((_) => print('Connection Disconnection : ${_}'));
    socket.onConnectError((err) => print(err));
    socket.onError((err) => print(err));
  }

  void _controlPage(int index) => setState(() => page = index);

  // Responsible for switching between recording / idle state
  Future<void> _controlMicStream({Command command: Command.change}) async {
    // print("command is : ${command}");
    // print("record is : ${isRecording}");

    switch (command) {
      case Command.change:
        await _changeListening();
        break;
      case Command.start:
        await _startListening();
        break;
      case Command.stop:
        await _stopListening();
        break;
    }
  }

  Future<Object> _changeListening() async =>
      !isRecording ? await _startListening() : await _stopListening();

  late int bytesPerSample;
  late int samplesPerSecond;

  Future<bool> _startListening() async {
    // print("START LISTENING : RECORD IS $isRecording");
    if (isRecording) return false;
    // if this is the first time invoking the microphone()
    // method to get the stream, we don't yet have access
    // to the sampleRate and bitDepth properties
    // print("wait for stream");

    // Default option. Set to false to disable request permission dialogue
    MicStream.shouldRequestPermission(true);

    stream = await MicStream.microphone(
        audioSource: AudioSource.DEFAULT,
        // sampleRate: 1000 * (rng.nextInt(50) + 30),
        sampleRate: 48000,
        channelConfig: ChannelConfig.CHANNEL_IN_MONO,
        audioFormat: AUDIO_FORMAT);

    // print("wait for stream record is : $stream");

    // after invoking the method for the first time, though, these will be available;
    // It is not necessary to setup a listener first, the stream only needs to be returned first

    // print(
    //     "Start Listening to the microphone, sample rate is ${await MicStream.sampleRate}, bit depth is ${await MicStream.bitDepth}, bufferSize: ${await MicStream.bufferSize}");
    bytesPerSample = (await MicStream.bitDepth)! ~/ 8;
    samplesPerSecond = (await MicStream.sampleRate)!.toInt();
    localMax = null;
    localMin = null;

    // Start listening to the stream

    setState(() {
      isRecording = true;
      startTime = DateTime.now();
      // StreamSubscription? listener = stream
      //     ?.listen((samples) => {print("ini stream audio ===> ${samples}")});
    });

    // print("wait for stream record is : $isRecording");
    visibleSamples = [];
    listener = stream!.listen(_calculateSamples, onError: (error) {
      print("error listen : ${error}");
    });

    return true;
  }

  void _calculateSamples(samples) {
    if (page == 0)
      // _calculateWaveSamples(samples);
      print("halo");
    else if (page == 1) {
      // _calculateIntensitySamples(samples);
      _listenStream(samples);
    }
  }

  void _listenStream(samples) {
    // print(
    //     "ini audio stream ${widget.title} dari room ${widget.randomNumber} ===> ${samples}");

    socket.emit('audioMessage',
        "ini audio stream ${widget.title} dari room ${widget.randomNumber}");

    // Menutup koneksi socket setelah selesai
    // socket.close();
  }

  void _listenAudioFinal() {
    socket.on('audioFinal', (data) {
      // Meng-handle data audio final yang diterima dari server
      print('Menerima audio final: $data');

      // Lakukan tindakan lain sesuai kebutuhan Anda
    });
  }

  Future<bool> _stopListening() async {
    if (!isRecording) return false;
    print("Stop Listening to the microphone");

    await listener?.cancel();

    setState(() {
      isRecording = false;
      currentSamples = null;
      startTime = null;
    });
    return true;
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (!mounted) return;
    isActive = true;

    Statistics(false);

    controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..addListener(() {
            if (isRecording) setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed)
              controller.reverse();
            else if (status == AnimationStatus.dismissed) controller.forward();
          })
          ..forward();
  }

  Color _getBgColor() => (!isRecording) ? Colors.red : Colors.cyan;
  Icon _getIcon() =>
      (isRecording) ? Icon(Icons.stop) : Icon(Icons.keyboard_voice);

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
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await _controlMicStream();
            },
            child: _getIcon(),
            foregroundColor: _iconColor,
            backgroundColor: _getBgColor(),
            tooltip: (isRecording) ? "Stop recording" : "Start recording",
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.broken_image),
                label: "Sound Wave",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.broken_image),
                label: "Intensity Wave",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.view_list),
                label: "Statistics",
              )
            ],
            backgroundColor: Colors.black26,
            elevation: 20,
            currentIndex: page,
            onTap: _controlPage,
          ),
          body: (page == 0 || page == 1)
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _getBgColor(),
                        ),
                      ),
                    ),
                  ],
                )
              : Statistics(
                  isRecording,
                  startTime: startTime,
                )),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      isActive = true;
      print("Resume app");

      _controlMicStream(
          command: memRecordingState ? Command.start : Command.stop);
    } else if (isActive) {
      memRecordingState = isRecording;
      _controlMicStream(command: Command.stop);

      print("Pause app");
      isActive = false;
    }
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    listener?.cancel();
    controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class Statistics extends StatelessWidget {
  final bool isRecording;
  final DateTime? startTime;

  Statistics(this.isRecording, {this.startTime});

  @override
  Widget build(BuildContext context) {
    return ListView(children: <Widget>[
      ListTile(
          leading: Icon(Icons.title),
          title: Text("Microphone Streaming Example App")),
      ListTile(
        leading: Icon(Icons.keyboard_voice),
        title: Text((isRecording ? "Recording" : "Not recording")),
      ),
      ListTile(
          leading: Icon(Icons.access_time),
          title: Text((isRecording
              ? DateTime.now().difference(startTime!).toString()
              : "Not recording"))),
    ]);
  }
}
