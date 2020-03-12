import 'package:flutter/material.dart';
import 'package:tradingcontest/room.dart';
import 'package:web3dart/web3dart.dart';
import 'package:path/path.dart' show join, dirname;
import 'package:web_socket_channel/io.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';
import 'dart:io';
import 'globals.dart' as globals;
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final roomKeyController = TextEditingController();
  final privateKeyController = TextEditingController();
  var roomCreatedId = -1;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    roomKeyController.dispose();
    super.dispose();
  }

  Future<Credentials> getCredentials(String address) async {
    return globals.ethClient
        .credentialsFromPrivateKey(address)
        .catchError((err) {
      print("ON_ERROOOOOOOOOOOOOOOOOOOOOOR");
      print(err);
    });
  }

  void checkAddress() {
    String address = privateKeyController.text;
    getCredentials(address).then((cred) {
      globals.credentials = cred;
      cred.extractAddress().then((addr) {
        print(addr);
        globals.ethClient.getBalance(addr).catchError((err) {
          print("Error getBalance()");
          print(err);
          return;
        }).then((balance) {
          if (balance == null) return;
          print("OnValue : ");
          print(balance.getInEther);
        });
      });
    });
  }

  void generateRandomPrivateKey() {
    var rng = new Random.secure();
    var random = EthPrivateKey.createRandom(rng);
    random.extractAddress().then((add) {
      //privateKeyController.text = add.hex.toString();
      privateKeyController.text =
          globals.accountPrivateKey;
    });
  }

  void joinRoom() {
    globals.getContract().then((contract) {
      globals.ethClient.sendTransaction(
        globals.credentials, 
        Transaction.callContract(
        contract: contract,
        function: contract.function("joinContest"), 
        parameters: [BigInt.parse(roomKeyController.text)],
        maxGas: 100000,
        gasPrice: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 2200),
        value: EtherAmount.fromUnitAndValue(EtherUnit.wei, 1)
      )).then((res) {
        globals.ethClient.call(
          contract: contract, 
          function: contract.function("getTraderWallet"), 
          params: [EthereumAddress.fromHex(globals.accountAddress)]
        ).then((rawVal) {
          print(rawVal);
          Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomPage(
              title: 'room',
              roomKey: roomKeyController.text,
            )));
        });
      });
    });
  }

  void createRoom() {
    setState(() {
      roomCreatedId = roomCreatedId + 1;
    });
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
            RaisedButton(
              onPressed: generateRandomPrivateKey,
              child: Text('FILL WITH TEST ADDRESS'),
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'ENTER YOU ADDRESS',
              ),
              controller: privateKeyController,
            ),
            RaisedButton(
              onPressed: checkAddress,
              child: Text('CHECK ADDRESS'),
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter a room key',
              ),
              controller: roomKeyController,
            ),
            RaisedButton(
              onPressed: joinRoom,
              child: Text('JOIN ROOM'),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
