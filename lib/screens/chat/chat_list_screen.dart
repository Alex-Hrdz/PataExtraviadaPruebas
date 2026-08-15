import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Mensajes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildChatTile(
            context,
            'María López',
            'Creo que la vi cerca del parque...',
            '10:42 AM',
            true,
          ),
          _buildChatTile(
            context,
            'Carlos Ruiz',
            '¡Gracias por compartir el reporte!',
            'Ayer',
            false,
          ),
          _buildChatTile(
            context,
            'Ana Sánchez',
            'Estaré atenta por mi colonia.',
            'Lunes',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(
    BuildContext context,
    String name,
    String lastMessage,
    String time,
    bool unread,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary,
        child: Text(
          name[0],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: unread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text(
        time,
        style: TextStyle(
          color: unread ? AppColors.primary : Colors.grey,
          fontSize: 12,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(userName: name),
          ),
        );
      },
    );
  }
}
