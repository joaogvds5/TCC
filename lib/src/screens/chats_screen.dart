// lib/src/screens/chats_screen.dart
import 'package:flutter/material.dart';
import 'package:nearu/src/widgets/chats_widget.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const ChatsWidget(),
    );
  }
}
