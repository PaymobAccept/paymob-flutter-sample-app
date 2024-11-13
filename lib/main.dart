import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

enum CardType{OmanNet, JCB, Meeza, Maestro, Amex, Visa, MasterCard}

class SavedBankCard {
  final String token;
  final String maskedPanNumber;
  final String cardType;

  SavedBankCard({required this.token, required this.maskedPanNumber, required this.cardType});

  // Convert the custom CardType class to a Map (which can be serialized to JSON)
  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'maskedPanNumber': maskedPanNumber,
      'cardType': cardType,
    };
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const methodChannel = MethodChannel('paymob_sdk_flutter');

  // Method to call native code
  Future<void> _payWithPaymob(
      String pk,
      String csk,
      { SavedBankCard? savedCard,
        String? appName,
        Color? buttonBackgroundColor,
        Color? buttonTextColor,
        bool? saveCardDefault,
        bool? showSaveCard} ) async {

    try {
      final String result = await methodChannel.invokeMethod('payWithPaymob', {
        "publicKey": pk,
        "clientSecret": csk,
        "savedBankCard": savedCard?.toMap(),
        "appName": appName,
        "buttonBackgroundColor": buttonBackgroundColor?.value,
        "buttonTextColor": buttonTextColor?.value,
        "saveCardDefault": saveCardDefault,
        "showSaveCard": showSaveCard
      });
      print('Native result: $result');
      switch (result) {
        case 'Successfull':
          print('Transaction Successfull Dart');
          // Do something for accepted
          break;
        case 'Rejected':
          print('Transaction Rejected Dart');
          // Do something for rejected
          break;
        case 'Pending':
          print('Transaction Pending Dart');
          // Do something for pending
          break;
        default:
          print('Unknown response');
      // Handle unknown response
      }
    } on PlatformException catch (e) {
      print("Failed to call native SDK: '${e.message}'.");
    }
  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: ElevatedButton(
          onPressed: () {
            _payWithPaymob( "place public key here",
                "place client secret key here",
                savedCard: SavedBankCard(token: "98aed441d8d03e4abd5e323b6fae1c579499b4145886d31d786da65e", maskedPanNumber: "2346", cardType: CardType.MasterCard.name),
                appName: "hello",
                buttonTextColor: Colors.red,
              showSaveCard: false,
              saveCardDefault: true
            );
          },
          child: Text('Pay With Paymob'),
        ),
      ),
    );
  }
}
