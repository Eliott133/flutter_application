import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Paramètres"),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            "Options de configuration",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
