import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppChatService {
  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  static String? get currentUid => _auth.currentUser?.uid;

  static CollectionReference<Map<String, dynamic>> get _threadsCol =>
      _firestore.collection('threads');

  // Pick an admin UID (first document in admins collection)
  static Future<String> _getAnyAdminUid() async {
    final snap = await _firestore.collection('admins').limit(1).get();
    if (snap.docs.isEmpty) {
      throw Exception('No admin available');
    }
    return snap.docs.first.id;
  }

  // Ensure a DM thread exists between current user and an admin
  static Future<String> createOrGetDmThreadWithAdmin() async {
    final String? userId = currentUid;
    if (userId == null) throw Exception('Not signed in');
    final String adminId = await _getAnyAdminUid();

    final query =
        await _threadsCol
            .where('isGroup', isEqualTo: false)
            .where('participants', arrayContains: userId)
            .orderBy('lastMessageAt', descending: true)
            .get();

    for (final doc in query.docs) {
      final participants = List<String>.from(doc.data()['participants'] ?? []);
      if (participants.contains(adminId)) {
        return doc.id;
      }
    }

    final docRef = await _threadsCol.add({
      'isGroup': false,
      'participants': <String>[userId, adminId],
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': null,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unreadCounts': {userId: 0, adminId: 0},
    });
    return docRef.id;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamThreadMessages(
    String threadId,
  ) {
    return _threadsCol
        .doc(threadId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  static Future<void> sendMessageToThread(String threadId, String text) async {
    final String? senderId = currentUid;
    if (senderId == null) throw Exception('Not signed in');
    final threadRef = _threadsCol.doc(threadId);
    final threadSnap = await threadRef.get();
    if (!threadSnap.exists) throw Exception('Thread not found');
    final data = threadSnap.data() as Map<String, dynamic>;
    final participants = List<String>.from(data['participants'] ?? []);

    await threadRef.collection('messages').add({
      'text': text,
      'senderId': senderId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final Map<String, dynamic> unread = Map<String, dynamic>.from(
      data['unreadCounts'] ?? {},
    );
    for (final pid in participants) {
      if (pid == senderId) continue;
      unread[pid] = (unread[pid] ?? 0) + 1;
    }

    await threadRef.update({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unreadCounts': unread,
    });
  }
}
