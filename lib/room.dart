import 'package:flutter/material.dart';
import 'package:tradingcontest/globals.dart' as globals;
import 'package:web3dart/web3dart.dart';

class RoomPage extends StatefulWidget {
  RoomPage({Key key, this.title, this.roomKey}) : super(key: key);

  final String title;
  final String roomKey;

  @override
  RoomPageState createState() => RoomPageState();
}

class RoomPageState extends State<RoomPage> {
  final buyTextController = TextEditingController();
  final sellTextController = TextEditingController();
  var currentEuros = BigInt.from(0);
  var currentEth = BigInt.from(0);
  
  void onPressBuy() async {
    var contract = await globals.getContract();

    globals.ethClient.sendTransaction(
      globals.credentials, 
      Transaction.callContract(
      contract: contract,
      function: contract.function("trade"), 
      parameters: [
        BigInt.parse(buyTextController.text),
        BigInt.parse(widget.roomKey),
        true
      ]
    )).then((res) {
      print(res);
      globals.getWallet()
      .then((res) {
        setState(() {
          currentEuros = res[0];
          currentEth = res[1];
        });
      });
    });
  }

  void onPressSell() async {
    var contract = await globals.getContract();

    globals.ethClient.sendTransaction(
      globals.credentials, 
      Transaction.callContract(
      contract: contract,
      function: contract.function("trade"), 
      parameters: [
        BigInt.parse(buyTextController.text),
        BigInt.parse(widget.roomKey),
        false
      ]
    )).then((res) {
      print(res);
      globals.getWallet()
      .then((res) {
        setState(() {
          currentEuros = res[0];
          currentEth = res[1];
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title + " : " + widget.roomKey),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            TextField(controller: buyTextController,),
            RaisedButton(
              onPressed: onPressBuy,
              child: Text('BUY'),
            ),
            TextField(controller: sellTextController,),
            RaisedButton(
              onPressed: onPressSell,
              child: Text('SELL'),
            ),
            Text("You got $currentEuros\€ and $currentEth\ETH")
          ],
        ),
      ),
    );
  }
}
