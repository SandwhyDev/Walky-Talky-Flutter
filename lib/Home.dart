import 'package:coba/newMic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mic_stream/mic_stream.dart';
import 'DetailPage.dart';
import 'dart:math';
import "testMic.dart";
import "cobaMic.dart";

void main() {
  runApp(MaterialApp(
      title: "App",
      home: Home(
        desc: '',
        title: '',
      )));
}

class Home extends StatelessWidget {
  //menentukan variabel untuk dikirim
  final String title;
  final String desc;

  Home({required this.title, required this.desc});

  String roomCode = '';
  String generateRandomNumber() {
    Random random = Random();
    int first = random.nextInt(900) +
        100; // Menghasilkan angka acak dari 100 hingga 999
    int second = random.nextInt(900) + 100;
    int third = random.nextInt(900) + 100;
    return '$first-$second-$third'; // Menggabungkan angka-angka tersebut dengan tanda hubung (-)
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController roomController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text("Latihan Pindah Halaman"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Halo $title',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Container(
              width: 300,
              alignment: Alignment.center,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 1,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: roomController,
                      decoration: InputDecoration(
                        hintText: "Masukkan kode room",
                        labelText: "Room",
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final text = newValue.text.replaceAll('-', '');
                          final formattedText = StringBuffer();
                          for (int i = 0; i < text.length; i++) {
                            if (i == 3 || i == 6) {
                              formattedText.write('-');
                            }
                            formattedText.write(text[i]);
                          }

                          if (formattedText.length > 11) {
                            return oldValue;
                          }

                          // Update nilai roomCode
                          roomCode = formattedText.toString();

                          return TextEditingValue(
                            text: formattedText.toString(),
                            selection: TextSelection.collapsed(
                                offset: formattedText.length),
                          );
                        }),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Flexible(
                    flex: 1,
                    child: Container(
                      color: Colors
                          .blue, // Warna latar belakang untuk ElevatedButton
                      child: ElevatedButton(
                        onPressed: () {
                          String roomName = roomController.text;

                          if (roomCode.isEmpty || roomCode.length < 11) {
                            // Alert jika inputan tidak ada atau kurang dari 9 angka
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Peringatan"),
                                content: Text(
                                    "Masukkan kode room dengan benar (minimal 9 angka)."),
                                actions: [
                                  TextButton(
                                    child: Text("OK"),
                                    onPressed: () {
                                      Navigator.pop(context); // Menutup dialog
                                    },
                                  ),
                                ],
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SimpleMicStreamApp(
                                  user: title,
                                  title: roomName,
                                ),
                              ),
                            );
                            roomController.clear();
                          }
                        },
                        child: Text('Join Room'),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10), // Spasi vertikal di antara tombol
            Text(
              "Or",
              style: TextStyle(fontSize: 18),
            ),

            SizedBox(
                height: 20), // Spasi vertikal antara input field dan tombol
            ElevatedButton(
              onPressed: () {
                String roomName = roomController.text;
                String randomNumber = generateRandomNumber();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SimpleMicStreamApp(
                      user: title,
                      title: randomNumber,
                    ),
                    // builder: (context) => MicStreamExampleApp(),
                  ),
                );
              },
              child: Text("Buat Room"),
            ),
          ],
        ),
      ),
    );
  }
}
