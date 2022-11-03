import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/task.dart';
import 'splash.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _user = FirebaseAuth.instance.currentUser!;
  final db = FirebaseFirestore.instance;

  var tasks = <String, Task>{};

  @override
  void initState() {
    super.initState();
    var stream =
        db.collection('users').doc(_user.uid).collection('tasks').snapshots();

    stream.listen((event) {
      tasks.clear();
      for (var doc in event.docs) {
        var task = Task.fromJson(doc.data());
        tasks[doc.id] = task;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "User: ${_user.uid}",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text("User: ${_user.email}",
                style: Theme.of(context).textTheme.titleLarge),
            for (var taskId in tasks.keys)
              Row(
                children: [
                  Checkbox(
                      value: tasks[taskId]?.completed ?? false,
                      onChanged: (value) {
                        tasks[taskId]?.completed = value ?? false;
                        if (tasks[taskId] != null) {
                          db
                              .collection('users')
                              .doc(_user.uid)
                              .collection('tasks')
                              .doc(taskId)
                              .update(tasks[taskId]!.toJson());
                        }
                        setState(() {});
                      }),
                  Expanded(child: Text(tasks[taskId]?.title ?? "-")),
                  InkWell(
                      onTap: () async {
                        await db
                            .collection('users')
                            .doc(_user.uid)
                            .collection('tasks')
                            .doc(taskId)
                            .delete();
                      },
                      child: const Icon(Icons.delete))
                ],
              ),
            ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const Splash()));
                },
                child: Text("Tancar Sessió")),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          var task = Task("Task ${tasks.length}", false);
          await db
              .collection('users')
              .doc(_user.uid)
              .collection('tasks')
              .add(task.toJson())
              .then((DocumentReference doc) {
            print("Document id : ${doc.id}");
            tasks[doc.id] = task;
          });
          setState(() {});
        },
      ),
    );
  }
}
