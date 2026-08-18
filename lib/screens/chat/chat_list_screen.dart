import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_colors.dart';
import '../../services/chat_service.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final ChatService chatService = ChatService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Mensajes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatService.getChatsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los mensajes.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Aún no tienes conversaciones.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chatData = chats[index].data() as Map<String, dynamic>;
              final List<dynamic> participants = chatData['participants'] ?? [];

              String otherUserId = '';
              for (var id in participants) {
                if (id != currentUserId) {
                  otherUserId = id;
                  break;
                }
              }

              if (otherUserId.isEmpty) return const SizedBox.shrink();

              final lastMessage = chatData['lastMessage'] ?? '';
              final Timestamp? timestamp = chatData['lastMessageTime'];

              // --- NUEVO: Extraemos los datos del reporte guardados en el chat ---
              final reportId = chatData['reportId'] ?? 'sin_reporte';
              final petName = chatData['petName'] ?? 'Mascota';
              final petFotoBase64 = chatData['petFotoBase64'];
              // -------------------------------------------------------------------

              String timeString = '';
              if (timestamp != null) {
                final date = timestamp.toDate();
                timeString =
                    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
              }

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.hasError) {
                    return _buildChatTile(
                      context,
                      'Error al cargar',
                      otherUserId,
                      lastMessage,
                      timeString,
                      false,
                      reportId,
                      petName,
                      petFotoBase64,
                    );
                  }

                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.grey),
                      title: Text('Cargando...'),
                    );
                  }

                  final userData =
                      userSnapshot.data?.data() as Map<String, dynamic>? ?? {};
                  final otherUserName =
                      userData['nombre'] ?? 'Usuario Desconocido';

                  return _buildChatTile(
                    context,
                    otherUserName,
                    otherUserId,
                    lastMessage,
                    timeString,
                    false,
                    // --- NUEVO: Mandamos los datos a la tarjeta visual ---
                    reportId,
                    petName,
                    petFotoBase64,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildChatTile(
    BuildContext context,
    String name,
    String receiverId,
    String lastMessage,
    String time,
    bool unread,
    // --- NUEVO: Recibimos los datos en la función constructora ---
    String reportId,
    String petName,
    String? petFotoBase64,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // --- MODIFICADO: Agregamos el nombre de la mascota al título ---
      title: RichText(
        text: TextSpan(
          text: name,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: unread ? FontWeight.bold : FontWeight.w600,
            fontSize: 16,
          ),
          children: [
            TextSpan(
              text: ' ($petName)',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
        // --- MODIFICADO: Ahora pasamos todos los datos requeridos al chat ---
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(
              receiverId: receiverId,
              receiverName: name,
              reportId: reportId,
              tituloReporte: petName,
              fotoBase64Reporte: petFotoBase64,
            ),
          ),
        );
      },
    );
  }
}
