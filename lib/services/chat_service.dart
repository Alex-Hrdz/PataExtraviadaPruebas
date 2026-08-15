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

  Stream<QuerySnapshot> getMessagesStream(String receiverId) {
    final currentUserId = _auth.currentUser?.uid;
    final chatId = _getChatId(currentUserId!, receiverId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> sendMessage(String receiverId, String message) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null || message.trim().isEmpty) return;

    final chatId = _getChatId(currentUserId, receiverId);
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

    await _firestore.collection('chats').doc(chatId).set({
      'participants': [currentUserId, receiverId],
      'lastMessage': message.trim(),
      'lastMessageTime': timestamp,
    }, SetOptions(merge: true));
  }

  String _getChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }
}
