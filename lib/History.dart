import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class History extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CollectionReference data = FirebaseFirestore.instance.collection('output');
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: data.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return new ListView(
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              return GestureDetector(
                onDoubleTap: () {
                  FirebaseFirestore.instance
                      .collection('output')
                      .doc(document.id)
                      .delete();
                },
                child: Column(
                  children: [
                    new Container(
                      height: MediaQuery.of(context).size.height * 1 / 100,
                    ),
                    new Container(
                      child: new Text(document.data()['output']),
                    ),
                    Row(children: [
                      Text(
                        "double tap to delete",
                        style: TextStyle(fontSize: 9),
                      )
                    ]),
                    new Container(
                      color: Colors.black,
                      height: 3,
                      child: Row(),
                    )
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
