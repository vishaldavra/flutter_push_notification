import 'package:flutter/material.dart';

class NewScreen extends StatelessWidget {
  final String info;
  const NewScreen({Key? key, required this.info}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase Messaging"),
      ),
      body: Center(
        child: Text(info),
      ),
    );
  }
}
