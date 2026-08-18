import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getChatsStream() {
    final currentUserId = _auth.currentUser?.uid;

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  // --- MODIFICADO: Ahora requiere el reportId para aislar la conversación ---
  Stream<QuerySnapshot> getMessagesStream(String receiverId, String reportId) {
    final currentUserId = _auth.currentUser?.uid;
    final chatId = _getChatId(currentUserId!, receiverId, reportId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // --- MODIFICADO: Acepta los datos del reporte para guardarlos en el chat ---
  Future<void> sendMessage(
    String receiverId,
    String message, {
    required String reportId,
    String? petName,
    String? petFotoBase64,
  }) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null || message.trim().isEmpty) return;

    final chatId = _getChatId(currentUserId, receiverId, reportId);
    final timestamp = FieldValue.serverTimestamp();

    final messageData = {
      'senderId': currentUserId,
      'receiverId': receiverId,
      'message': message.trim(),
      'timestamp': timestamp,
    };

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    // Guardamos la referencia visual de la mascota en la raíz del chat
    Map<String, dynamic> chatContextData = {
      'participants': [currentUserId, receiverId],
      'lastMessage': message.trim(),
      'lastMessageTime': timestamp,
      'reportId': reportId,
    };

    if (petName != null) chatContextData['petName'] = petName;
    if (petFotoBase64 != null) chatContextData['petFotoBase64'] = petFotoBase64;

    await _firestore
        .collection('chats')
        .doc(chatId)
        .set(chatContextData, SetOptions(merge: true));
  }

  // --- MODIFICADO: El ID de la sala ahora incluye el reporte ---
  String _getChatId(String userId1, String userId2, String reportId) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return '${ids.join('_')}_$reportId';
  }
}
