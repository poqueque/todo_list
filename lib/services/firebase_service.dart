import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' hide Task;
import 'package:image_picker/image_picker.dart';
import 'package:todo_list/models/task.dart';

import '../firebase_options.dart';
import '../models/user.dart';

class FirebaseService {
  static FirebaseService? _instance;

  static FirebaseService get instance {
    _instance ??= FirebaseService();
    return _instance!;
  }

  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  User? get user => FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot<Map<String, dynamic>>> get tasksStream =>
      _db.collection('users').doc(user?.uid).collection('tasks').snapshots();

  Future<void> updatePhoto(XFile image) async {
    TaskSnapshot taskSnapshot = await _storage
        .ref("users/${user?.uid}/profile")
        .putFile(File(image.path));
    var url = await taskSnapshot.ref.getDownloadURL();
    user?.updatePhotoURL(url);
    UserModel userModel = UserModel(url);
    _db.collection('users').doc(user?.uid).update(userModel.toJson());
  }

  Future<void> updateDisplayName(String nameEntered) async {
    await FirebaseAuth.instance.currentUser?.updateDisplayName(nameEntered);
  }

  Future<void> updateTask(String taskId, Task task) async {
    await _db
        .collection('users')
        .doc(user?.uid)
        .collection('tasks')
        .doc(taskId)
        .update(task.toJson());
  }

  Future<void> deleteTask(String taskId) async {
    await _db
        .collection('users')
        .doc(user?.uid)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<String> addTask(Task task) async {
    DocumentReference doc = await _db
        .collection('users')
        .doc(user?.uid)
        .collection('tasks')
        .add(task.toJson());
    return doc.id;
  }

  static Future<String> init() async {
    String status = "";
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).catchError((error) {
      status = "Error: ${error.toString()}";
    });
    status = "Firebase inicialitzat";
    return status;
  }
}
