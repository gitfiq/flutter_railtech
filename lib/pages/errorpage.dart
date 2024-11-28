import 'package:flutter/material.dart';

class Errorpage extends StatelessWidget {
  const Errorpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "TrackSafe System",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color.fromARGB(255, 39, 145, 232),
      body: const Center(
        child: Text('404 - Page Not Found. Refresh The Application.',
            style: TextStyle(fontSize: 30)),
      ),
    );
  }
}
