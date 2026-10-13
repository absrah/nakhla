import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class NakhlaApp extends StatelessWidget {
  const NakhlaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nakhla',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text('Connected to ${Firebase.app().options.projectId}'),
        ),
      ),
    );
  }
}