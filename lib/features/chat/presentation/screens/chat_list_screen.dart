import 'package:flutter/material.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:park_chatapp/features/chat/presentation/screens/admin_chat_screen.dart';
import 'package:park_chatapp/features/chat/domain/models/group.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with SingleTickerProviderStateMixin {
  String _lastMessage = 'Do you have any query? We are here to help';
  DateTime _lastMessageTime = DateTime.now();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: Text(
          'Chats',
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
        ),
      ),
      body: _uid == null
          ? const Center(child: Text('Please sign in'))
          : Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Row(
                    children: [
                      _buildTab('All', 0),
                      const SizedBox(width: 8),
                      _buildTab('Chats', 1),
                      const SizedBox(width: 8),
                      _buildTab('Unread', 2),
                      const SizedBox(width: 8),
                      _buildTab('Groups', 3),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAllTab(),
                      _buildChatsTab(),
                      _buildUnreadTab(),
                      _buildGroupsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTab(String title, int index) {
    return GestureDetector(
      onTap: () => _tabController.animateTo(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 26),
        decoration: BoxDecoration(
          color: _tabController.index == index ? AppColors.white : Colors.white,
          border: Border.all(color: _tabController.index == index ? AppColors.primaryRed : Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: _tabController.index == index ? Colors.black : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildAllTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('threads')
          .where('isGroup', isEqualTo: false)
          .where('participants', arrayContains: _uid)
          .snapshots(),
      builder: (context, dmSnapshot) {
        if (dmSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final dmThreads = dmSnapshot.data?.docs ?? const [];

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('groups')
              .where('members', arrayContains: _uid)
              .snapshots(),
          builder: (context, groupsSnapshot) {
            if (groupsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final groups = groupsSnapshot.data?.docs ?? const [];

            if (dmThreads.isEmpty && groups.isEmpty) {
              return _buildEmptyListView();
            }

            return ListView(
              children: [
                _AdminChatTile(
                  lastMessage: _lastMessage,
                  lastMessageTime: _lastMessageTime,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminChatScreen(),
                      ),
                    );
                  },
                ),
                // const Divider(height: 0),
                ...groups.map((g) => _buildGroupTile(g)),
                ...dmThreads.map((t) => _buildDmTile(t)),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildChatsTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('threads')
          .where('isGroup', isEqualTo: false)
          .where('participants', arrayContains: _uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final threads = snapshot.data?.docs ?? const [];

        if (threads.isEmpty) {
          return _buildEmptyListView();
        }

        return ListView(
          children: [
            _AdminChatTile(
              lastMessage: _lastMessage,
              lastMessageTime: _lastMessageTime,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminChatScreen(),
                  ),
                );
              },
            ),
            const Divider(height: 0),
            ...threads.map((t) => _buildDmTile(t)),
          ],
        );
      },
    );
  }

  Widget _buildUnreadTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('threads')
          .where('isGroup', isEqualTo: false)
          .where('participants', arrayContains: _uid)
          .where('unreadCount', isGreaterThan: 0)
          .snapshots(),
      builder: (context, dmSnapshot) {
        if (dmSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final dmThreads = dmSnapshot.data?.docs ?? const [];

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('groups')
              .where('members', arrayContains: _uid)
              .where('unreadCount', isGreaterThan: 0)
              .snapshots(),
          builder: (context, groupsSnapshot) {
            if (groupsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final groups = groupsSnapshot.data?.docs ?? const [];

            if (dmThreads.isEmpty && groups.isEmpty) {
              return _buildEmptyListView();
            }

            return ListView(
              children: [
                ...groups.map((g) => _buildGroupTile(g)),
                ...dmThreads.map((t) => _buildDmTile(t)),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildGroupsTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .where('members', arrayContains: _uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final groups = snapshot.data?.docs ?? const [];

        if (groups.isEmpty) {
          return _buildEmptyListView();
        }

        return ListView(
          children: [
            ...groups.map((g) => _buildGroupTile(g)),
          ],
        );
      },
    );
  }

  Widget _buildEmptyListView() {
    return ListView(
      children: [
        _AdminChatTile(
          lastMessage: _lastMessage,
          lastMessageTime: _lastMessageTime,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminChatScreen(),
              ),
            );
          },
        ),
        const Divider(height: 0),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primaryRed.withOpacity(0.15),
            child: const Icon(
              Icons.group,
              color: AppColors.primaryRed,
            ),
          ),
          title: const Text('No chats yet'),
          subtitle: const Text('Start a new conversation'),
        ),
      ],
    );
  }

  Widget _buildGroupTile(QueryDocumentSnapshot<Map<String, dynamic>> g) {
    final data = g.data();
    final grp = Group(
      id: g.id,
      name: (data['name'] ?? 'Group') as String,
      members: List<String>.from(data['members'] ?? <String>[]),
      isAuthor: false,
    );
    DateTime? lastTime;
    final ts = data['lastMessageAt'];
    if (ts is Timestamp) {
      lastTime = ts.toDate();
    }
    final lastMsg = (data['lastMessage'] ?? '') as String;
    return _GroupTile(
      group: grp,
      lastMessage: lastMsg.isEmpty ? null : lastMsg,
      lastMessageTime: lastTime,
      onTap: () async {
        await Navigator.pushNamed(
          context,
          '/group_chat',
          arguments: grp,
        );
      },
    );
  }

  Widget _buildDmTile(QueryDocumentSnapshot<Map<String, dynamic>> t) {
    final data = t.data();
    DateTime? lastTime;
    final ts = data['lastMessageAt'];
    if (ts is Timestamp) {
      lastTime = ts.toDate();
    }
    final lastMsg = (data['lastMessage'] ?? '') as String;
    final participants = List<String>.from(data['participants'] ?? <String>[]);
    final otherUserId = participants.firstWhere((id) => id != _uid);

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
      builder: (context, userSnapshot) {
        String name = 'User';
        if (userSnapshot.hasData) {
          name = userSnapshot.data?.data()?['name'] ?? 'User';
        }
        return _GroupTile(
          group: Group(id: t.id, name: name, members: participants, isAuthor: false),
          lastMessage: lastMsg.isEmpty ? null : lastMsg,
          lastMessageTime: lastTime,
          onTap: () async {
            await Navigator.pushNamed(
              context,
              '/chat',
              arguments: t.id,
            );
          },
        );
      },
    );
  }
}

class _GroupTile extends StatelessWidget {
  final Group group;
  final VoidCallback onTap;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  const _GroupTile({
    required this.group,
    required this.onTap,
    this.lastMessage,
    this.lastMessageTime,
  });

  @override
  Widget build(BuildContext context) {
    final String subtitle = (lastMessage != null && lastMessage!.isNotEmpty)
        ? lastMessage!
        : 'No messages yet';
    final DateTime? time = lastMessageTime;

    return Card(
      elevation: 0.5,
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryRed.withOpacity(0.15),
          child: const Icon(Icons.group, color: AppColors.primaryRed),
        ),
        title: Text(group.name, style: AppTextStyles.bodyMediumBold),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: time == null
            ? null
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatTime(time),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(dt.hour);
    final minutes = twoDigits(dt.minute);
    return '$hours:$minutes';
  }
}

class _AdminChatTile extends StatelessWidget {
  final VoidCallback onTap;
  final String lastMessage;
  final DateTime lastMessageTime;

  const _AdminChatTile({
    required this.onTap,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color:  AppColors.white,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryRed.withOpacity(0.15),
          child: const Icon(Icons.person, color: AppColors.primaryRed),
        ),
        title: Text('Park View City', style: AppTextStyles.bodyMediumBold),
        subtitle: Text(
          lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(lastMessageTime),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(dt.hour);
    final minutes = twoDigits(dt.minute);
    return '$hours:$minutes';
  }
}