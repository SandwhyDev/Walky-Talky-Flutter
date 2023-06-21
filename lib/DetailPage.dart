// import 'dart:io' as io;

// import 'package:flutter/material.dart';
// import 'package:flutter_audio_recorder3/flutter_audio_recorder3.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// class DetailPage extends StatelessWidget {
//   DetailPage(
//       {required this.title, required this.desc, required this.randomNumber});

//   final String title;
//   final String desc;
//   final String randomNumber;

//   List<String> username = [
//     "user 1",
//     "user 2",
//     "user 3",
//   ];

//   @override
//   Widget build(BuildContext context) {
//     print(title);
//     print(randomNumber);
//     return Scaffold(
//         appBar: AppBar(title: Text("Room | $randomNumber")),
//         body: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(height: 20),
//             Flexible(
//               child: ListView.builder(
//                 itemCount: username.length,
//                 itemBuilder: (context, index) {
//                   return Padding(
//                     padding: EdgeInsets.only(right: 16),
//                     child: Align(
//                       alignment: Alignment.centerRight,
//                       child: Text(
//                         "joined | ${username[index]}",
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Expanded(
//                   child: Align(
//                     alignment: Alignment.center,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         MicButton(),
//                         SizedBox(height: 10),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Tambahan konten lainnya di sini
//               ],
//             ),
//           ],
//         ));
//   }
// }

// class MicButton extends StatefulWidget {
//   @override
//   _MicButtonState createState() => _MicButtonState();
// }

// class _MicButtonState extends State<MicButton> {
//   bool isPressed = false;
//   String MerekamSuara = "";

//   late FlutterAudioRecorder3 _recorder;
//   Recording? _currentRecording;

//   @override
//   void initState() {
//     super.initState();
//     _initializeRecorder();
//   }

//   void _initializeRecorder() async {
//     try {
//       PermissionStatus status = await Permission.microphone.request();
//       String customPath = "/flutter_audio_recorder";
//       if (status.isGranted) {
//         io.Directory appDocDirectory;
// //        io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
//         if (io.Platform.isIOS) {
//           appDocDirectory = await getApplicationDocumentsDirectory();
//         } else {
//           appDocDirectory = await getExternalStorageDirectory();
//         }

//         // can add extension like ".mp4" ".wav" ".m4a" ".aac"
//         customPath = appDocDirectory.path +
//             customPath +
//             DateTime.now().millisecondsSinceEpoch.toString();

//         // String customPath = 'assets/audio/recording.wav';
//         _recorder = FlutterAudioRecorder3(customPath,
//             audioFormat: AudioFormat.WAV, sampleRate: 44100);

//         await _recorder.initialized;
//       } else if (status.isDenied) {
//         // Izin ditolak oleh pengguna
//         print('Access to microphone denied');
//       } else if (status.isPermanentlyDenied) {
//         // Izin ditolak secara permanen oleh pengguna
//         print('Access to microphone permanently denied');
//       }
//     } catch (e) {
//       print('Failed to initialize recorder: $e');
//     }
//   }

//   Future<void> _startRecording() async {
//     try {
//       if (_recorder != null) {
//         await _recorder.start();
//         var recording = await _recorder.current(channel: 0);
//         var streamrecording = await _recorder
//             .current(channel: 0)
//             .then((e) => {print("test stream ===> ${e}")});

//         setState(() {
//           _currentRecording = recording;
//           MerekamSuara = "Sedang Merekam...";

//           // Mengambil data audio saat ini

//           // print("audio test ===> ${streamrecording}");
//         });
//       } else {
//         print('Recorder is not initialized');
//       }
//     } catch (e) {
//       print('Failed to start recording: $e');
//     }
//   }

//   Future<void> _stopRecording() async {
//     try {
//       if (_recorder != null) {
//         var result = await _recorder.stop();
//         setState(() {
//           _currentRecording = result;
//           MerekamSuara = "";
//         });
//       } else {
//         print('Recorder is not initialized');
//       }
//     } catch (e) {
//       print('Failed to stop recording: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: (_) {
//         setState(() {
//           isPressed = true;
//           MerekamSuara = "Sedang Merekam...";
//           _startRecording();
//         });
//       },
//       onTapUp: (_) {
//         setState(() {
//           isPressed = false;
//           MerekamSuara = "";
//           _stopRecording();
//         });
//       },
//       onTapCancel: () {
//         setState(() {
//           isPressed = false;
//           MerekamSuara = "";
//           _stopRecording();
//         });
//       },
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               color: isPressed ? Colors.blue : Colors.grey[300],
//               shape: BoxShape.circle,
//             ),
//             padding: EdgeInsets.all(10),
//             child: Icon(
//               Icons.mic,
//               color: Colors.white,
//               size: 100,
//             ),
//           ),
//           SizedBox(height: 10),
//           Text(
//             MerekamSuara,
//             style: TextStyle(fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }
// }
