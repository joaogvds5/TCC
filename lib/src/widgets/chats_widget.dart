import 'package:flutter/material.dart';

class ChatsWidget extends StatelessWidget {
  const ChatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = ["Show ao vivo", "Feira tech", "Jogo de futebol"];

    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.event)),
          title: Text(chats[index]),
          subtitle: const Text("Última mensagem..."),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Abrir chat: ${chats[index]}")),
            );
          },
        );
      },
    );
  }
}
