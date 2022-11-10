import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' hide Task;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_list/models/user.dart';

import '../models/task.dart';
import 'splash.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final User _user = FirebaseAuth.instance.currentUser!;
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  var tasks = <String, Task>{};
  XFile? image;

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
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
                decoration: const BoxDecoration(color: Colors.blue),
                child: Center(
                  child: InkWell(
                    child: image != null
                        ? Image.file(File(image!.path))
                        : (_user.photoURL != null)
                            ? Image.network(_user.photoURL!)
                            : const Icon(Icons.person, size: 100),
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      image =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        TaskSnapshot taskSnapshot = await storage
                            .ref("users/${_user.uid}/profile")
                            .putFile(File(image!.path));
                        var url = await taskSnapshot.ref.getDownloadURL();
                        _user.updatePhotoURL(url);
                        UserModel userModel = UserModel(url);
                        db.collection('users').doc(_user.uid).update(userModel.toJson());
                      }
                      setState(() {});
                    },
                  ),
                )),
            Row(
              children: [
                const Icon(Icons.person),
                Text(_user.displayName ?? " --- ")
              ],
            )
          ],
        ),
      ),
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
