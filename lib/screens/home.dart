import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_list/services/firebase_service.dart';

import '../models/task.dart';
import '../utils/dialogs.dart';
import 'splash.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var tasks = <String, Task>{};
  XFile? image;

  @override
  void initState() {
    super.initState();
    var stream = FirebaseService.instance.tasksStream;

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
                        : (FirebaseService.instance.user!.photoURL != null)
                            ? Image.network(
                                FirebaseService.instance.user!.photoURL!)
                            : const Icon(Icons.person, size: 100),
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      image =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        await FirebaseService.instance.updatePhoto(image!);
                      }
                      setState(() {});
                    },
                  ),
                )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Icon(Icons.person),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      FirebaseService.instance.user?.displayName ?? " --- ",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    child: const Icon(Icons.edit),
                    onTap: () async {
                      String? nameEntered =
                          await inputDialog(context, "Your name");
                      if (nameEntered != null) {
                        await FirebaseService.instance
                            .updateDisplayName(nameEntered);
                        setState(() {});
                      }
                    },
                  )
                ],
              ),
            ),
            Spacer(),
            Text(
              "User: ${FirebaseService.instance.user?.uid}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text("User: ${FirebaseService.instance.user?.email}",
                style: Theme.of(context).textTheme.bodyMedium),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    FirebaseService.instance.signOut();
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => const Splash()));
                  },
                  child: const Text("Tancar Sessió")),
            ),
          ],
        ),
      ),
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            for (var taskId in tasks.keys)
              Row(
                children: [
                  Checkbox(
                      value: tasks[taskId]?.completed ?? false,
                      onChanged: (value) {
                        tasks[taskId]?.completed = value ?? false;
                        if (tasks[taskId] != null) {
                          FirebaseService.instance
                              .updateTask(taskId, tasks[taskId]!);
                        }
                        setState(() {});
                      }),
                  Expanded(child: Text(tasks[taskId]?.title ?? "-")),
                  InkWell(
                      onTap: () async {
                        FirebaseService.instance.deleteTask(taskId);
                      },
                      child: const Icon(Icons.delete))
                ],
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          var task = Task("Task ${tasks.length}", false);
          await FirebaseService.instance.addTask(task).then((String taskId) {
            tasks[taskId] = task;
          });
          setState(() {});
        },
      ),
    );
  }
}
