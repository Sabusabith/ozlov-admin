import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:prototype/auth/login.dart';
import 'package:prototype/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance
      .collection('notificationsToSend')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .listen((snapshot) {
        for (var doc in snapshot.docChanges) {
          if (doc.type == DocumentChangeType.added) {
            final data = doc.doc.data()!;
            // Show notification locally
            print('New notification: ${data['body']}');
          }
        }
      });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(debugShowCheckedModeBanner: false, home: LoginPage());
  }
}
