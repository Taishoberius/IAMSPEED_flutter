import 'package:flutter/material.dart';
import 'package:tradingcontest/room.dart';
import 'package:http/http.dart'; //You can also import the browser version
import 'package:web3dart/web3dart.dart';
import 'globals.dart' as globals;


import 'home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var httpClient = new Client();
    globals.ethClient = new Web3Client(globals.apiUrl, httpClient);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(title: "Trading Contest"),
        '/room': (context) => RoomPage(),
      },
    );
  }
}
