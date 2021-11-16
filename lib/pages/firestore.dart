import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestorePage extends StatefulWidget {
  const FirestorePage({Key? key}) : super(key: key);

  @override
  _FirestorePageState createState() => _FirestorePageState();
}

class _FirestorePageState extends State<FirestorePage> {
  int _counter = 0;
  final Stream<DocumentSnapshot<Map<String, dynamic>>> _firstCounterStream =
      FirebaseFirestore.instance.collection('counter').doc('first').snapshots();

  Future<void> _incrementCounter() async {
    DocumentReference<Map<String, dynamic>> documentReference =
        FirebaseFirestore.instance.collection('counter').doc('first');
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await transaction.get(documentReference);
        if (!snapshot.exists) {
          throw Exception('Counter does not exist!');
        }
        int newCounterValue = snapshot.data()!['value'] + 1;
        transaction.update(documentReference, {"value": newCounterValue});
      });
    } catch (e) {
      try {
        await FirebaseFirestore.instance
            .collection('counter')
            .doc('first')
            .update({'value': _counter + 1});
      } catch (e) {
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore page'),
      ),
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _firstCounterStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                          snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("Loading");
                    }
                    final int value = snapshot.data!['value'];
                    _counter = value;
                    return Text(
                      value.toString(),
                      style: Theme.of(context).textTheme.headline4,
                    );
                  }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
