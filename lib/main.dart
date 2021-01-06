import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'History.dart';

var url, url1;
double fontsize = 16;
var output;
var cmd;
var cmd1;
var cmdoutput;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.wanderingCubes
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = Colors.white
      ..backgroundColor = Colors.blue
      ..indicatorColor = Colors.white
      ..textColor = Colors.white
      ..maskColor = Colors.blue.withOpacity(0.5)
      ..userInteractions = true
      ..dismissOnTap = false;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {"/": (context) => Myhome(), "/history": (context) => History()},
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      builder: EasyLoading.init(),
    );
  }
}

class Myhome extends StatefulWidget {
  @override
  _MyhomeState createState() => _MyhomeState();
}

class _MyhomeState extends State<Myhome> {
  var urlController = TextEditingController();
  var cmdController = TextEditingController();
  RunCmd() async {
    print("run cmd");
    try {
      var data = await http.get("http://$url/cgi-bin/cmd.py?cmd=$cmd");

      output =
          "Status code: ${data.statusCode.toString()} \n\n Cmd: $cmd \n\n Output : \n${data.body.toString()}";
      cmd = null;
    } catch (e) {
      output = "Failed to run this command due to : \n\n $e";
      print(output);
    }

    print("hello in second");
    await FirebaseFirestore.instance
        .collection("output")
        .add({"output": output, "time": DateTime.now().millisecondsSinceEpoch})
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
    await FirebaseFirestore.instance
        .collection("output")
        .orderBy('time')
        .limitToLast(1)
        .get()
        .then((value) {
      value.docs.every((element) {
        setState(() {
          cmdoutput = element['output'];
        });
        return true;
      });
    });
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Linux Command"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/history");
            },
            icon: Icon(Icons.history),
          )
        ],
      ),
      body: ListView(children: [
        Container(
          height: MediaQuery.of(context).size.height * 2 / 100,
        ),
        Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 80 / 100,
              decoration: BoxDecoration(
                color: Colors.blue[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 3.0, 9.0, 3.0),
                child: TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: url == null ? "Enter ip(192.168.43.135)" : url,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (txt) {
                    url1 = txt;
                  },
                ),
              ),
            ),
            FloatingActionButton(
              heroTag: "set url",
              onPressed: () {
                setState(() {
                  url = url1;
                });

                urlController.clear();
              },
              child: Icon(Icons.done),
            )
          ],
        ),
        Container(
          height: MediaQuery.of(context).size.height * 1 / 100,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(3, 5, 3, 5),
                child: Text("Font Size"),
              ),
            ),
            Card(
              color: Colors.blue[200],
              child: FlatButton(
                  onPressed: () {
                    setState(() {
                      fontsize += 1;
                    });
                  },
                  child: Icon(Icons.add)),
            ),
            Card(
              color: Colors.blue[200],
              child: FlatButton(
                  onPressed: () {
                    setState(() {
                      fontsize -= 1;
                    });
                  },
                  child: Icon(Icons.remove)),
            ),
          ],
        ),
        Container(
          height: MediaQuery.of(context).size.height * 2 / 100,
        ),
        Container(
            child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            cmdoutput == null ? "Start Running Commands" : cmdoutput,
            style: TextStyle(fontSize: fontsize),
          ),
        ))
      ]),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 80 / 100,
            decoration: BoxDecoration(
              color: Colors.blue[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 3.0, 9.0, 3.0),
              child: TextField(
                controller: cmdController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter Command",
                ),
                keyboardType: TextInputType.multiline,
                onChanged: (txt) {
                  cmd1 = txt;
                },
              ),
            ),
          ),
          FloatingActionButton(
            heroTag: "run cmd",
            onPressed: () {
              cmd = cmd1;
              EasyLoading.show(status: "Running Command");
              RunCmd();
              cmdController.clear();
            },
            child: Icon(Icons.send),
          )
        ],
      ),
    );
  }
}
