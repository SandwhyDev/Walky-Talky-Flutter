import 'package:flutter/material.dart';
import 'package:openid_client/openid_client_io.dart';
import 'package:url_launcher/url_launcher.dart';
import "Home.dart";
import 'dart:math';
import "cobaMic.dart";

String generateRandomNumber() {
  Random random = Random();
  int first =
      random.nextInt(900) + 100; // Menghasilkan angka acak dari 100 hingga 999
  int second = random.nextInt(900) + 100;
  int third = random.nextInt(900) + 100;
  return '$first-$second-$third'; // Menggabungkan angka-angka tersebut dengan tanda hubung (-)
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String authUri = 'https://auth.hundredapps.co/oidc';
  String clientId = "w-e-Qa-f5WFm0LKD4kUYN";
  String clientSecret =
      "mLlhZzTz-8JRBENRFzkjieGooy_1OY5hx_VBoCrV-5gUlyxWDuJJhltD9WoedKFO2bJ5sxyFfWgTCXzLZyhK6Q";
  Uri uri = Uri.parse("https://auth.hundredapps.co/oidc");
  List<String> scopes = [
    'openid',
    'profile',
    'email',
  ];

  Future<UserInfo> auth(BuildContext context) async {
    // create the client
    var issuer = await Issuer.discover(uri);
    var client = Client(issuer, clientId, clientSecret: clientSecret);

    // create a function to open a browser with an url
    urlLauncher(String url) async {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url),
            webViewConfiguration: const WebViewConfiguration(
              enableJavaScript: true,
            ));
      } else {
        throw 'Could not launch $url';
      }
    }

    // create an authenticator
    var authenticator = Authenticator(
      client,
      scopes: scopes,
      urlLancher: urlLauncher,
      redirectUri: Uri.parse('http://localhost:3000/login/callback'),
    );

    // starts the authentication
    var c = await authenticator.authorize();

    // close the webview when finished
    closeInAppWebView();

    UserInfo response = await c.getUserInfo();

    String username = response.name!;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Home(
          title: username,
          desc: "tust",
        ),
      ),
    );

    print(response);

    // return the user info
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // auth(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Home(
                      title: generateRandomNumber(),
                      desc: "tust",
                    ),
                  ),
                );
              },
              child: Text('Login'),
            ),
            SizedBox(
                height:
                    16), // Mengatur jarak antara tombol sebelumnya dan tombol baru
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SimpleMicStreamApp(
                        title: generateRandomNumber(), user: "jhon doe"),
                  ),
                );
              },
              child: Text('Simple Mic Stream'),
            ),
          ],
        ),
      ),
    );
  }
}
