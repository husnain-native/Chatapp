import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select User'),
        backgroundColor: const Color(0xFF111B21),
      ),
      backgroundColor: const Color(0xFF111B21),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No users found',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          final users =
              snapshot.data!.docs
                  .where((doc) => doc.id != currentUser?.uid)
                  .toList();
          return ListView.separated(
            itemCount: users.length,
            separatorBuilder:
                (context, index) =>
                    const Divider(color: Color(0xFF202C33), height: 0),
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF512DA8),
                  backgroundImage:
                      (user['photoUrl'] ?? '').isNotEmpty
                          ? NetworkImage(user['photoUrl'])
                          : null,
                  child:
                      (user['photoUrl'] ?? '').isEmpty
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                ),
                title: Text(
                  user['displayName'] ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  user['email'] ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ChatScreen(
                            peerId: users[index].id,
                            peerName: user['displayName'] ?? '',
                            peerPhotoUrl: user['photoUrl'] ?? '',
                          ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
