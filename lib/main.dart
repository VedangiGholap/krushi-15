import 'package:flutter/material.dart';
import 'package:krushi_version16/pages/customer/home.dart'; // Make sure this path is correct
import 'package:krushi_version16/pages/farmer/farmer_home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; //cloud firestore db

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Krushi App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const FarmerHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}
