import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
  String receivedMessage = '';

  @override
  void initState() {
    super.initState();
    initSocket();
  }

  void initSocket() {
    socket = IO.io('http://192.168.0.42:3030',
        IO.OptionBuilder().setTransports(['websocket']).build());

    socket.onConnect((_) {
      print('Connected');
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
    // Send data through socket

    setState(() {
      if (isRecording) {
        socket.emit('audioMessage', [widget.title, widget.user]);
        // print("recording true");
        return;
      }
    });

    // print("recording false");
  }

  void _listenAudioFinal() {
    socket.on('audioFinal', (data) {
      // Meng-handle data audio final yang diterima dari server
      print('pesan : $data');
    });
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
              socket.onDisconnect((_) {
                print('Disconnected');
                // Handle socket disconnection
              });
            },
          ),
          title: Row(
            children: [
              Text(widget.title),
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
