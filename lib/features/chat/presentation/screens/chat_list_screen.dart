import 'package:flutter/material.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:park_chatapp/features/chat/presentation/screens/admin_chat_screen.dart';
import 'package:park_chatapp/features/chat/domain/models/group.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with SingleTickerProviderStateMixin {
  final String _lastMessage = 'Do you have any query? We are here to help';
  final DateTime _lastMessageTime = DateTime.now();
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
  final threadsRef = FirebaseDatabase.instance.ref("threads");
  final groupsRef = FirebaseDatabase.instance.ref("groups");

  return StreamBuilder<DatabaseEvent>(
    stream: threadsRef.orderByChild("isGroup").equalTo(false).onValue,
    builder: (context, dmSnapshot) {
      if (dmSnapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      final dmValue = dmSnapshot.data?.snapshot.value;
      final dmData = dmValue is Map<dynamic, dynamic> ? dmValue : <dynamic, dynamic>{};
      final dmThreads = <Map<String, dynamic>>[];

      dmData.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          final thread = Map<String, dynamic>.from(value);
          final participants = thread["participants"];
          List<String> participantList = [];
          if (participants is Map<dynamic, dynamic>) {
            participantList = participants.keys.map((e) => e.toString()).toList();
          } else if (participants is List) {
            participantList = participants.map((e) => e.toString()).toList();
          }
          if (participantList.contains(_uid)) {
            dmThreads.add({"id": key, ...thread});
          }
        }
      });

      return StreamBuilder<DatabaseEvent>(
        stream: groupsRef.onValue,
        builder: (context, groupsSnapshot) {
          if (groupsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final groupsValue = groupsSnapshot.data?.snapshot.value;
          final groupsData = groupsValue is Map<dynamic, dynamic> ? groupsValue : <dynamic, dynamic>{};
          final groups = <Map<String, dynamic>>[];

          groupsData.forEach((key, value) {
            if (value is Map<dynamic, dynamic>) {
              final group = Map<String, dynamic>.from(value);
              final members = group["members"];
              List<String> memberList = [];
              if (members is Map<dynamic, dynamic>) {
                memberList = members.keys.map((e) => e.toString()).toList();
              } else if (members is List) {
                memberList = members.map((e) => e.toString()).toList();
              }
              if (memberList.contains(_uid)) {
                groups.add({"id": key, ...group});
              }
            }
          });

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
  final threadsRef = FirebaseDatabase.instance.ref("threads");

  return StreamBuilder<DatabaseEvent>(
    stream: threadsRef.orderByChild("isGroup").equalTo(false).onValue,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
        return _buildEmptyListView();
      }

      final value = snapshot.data!.snapshot.value;
      final data = value is Map<dynamic, dynamic> ? value : <dynamic, dynamic>{};
      final threads = <Map<String, dynamic>>[];

      data.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          final thread = Map<String, dynamic>.from(value);
          final participants = thread["participants"];
          List<String> participantList = [];
          if (participants is Map<dynamic, dynamic>) {
            participantList = participants.keys.map((e) => e.toString()).toList();
          } else if (participants is List) {
            participantList = participants.map((e) => e.toString()).toList();
          }
          if (participantList.contains(_uid)) {
            threads.add({"id": key, ...thread});
          }
        }
      });

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
  final threadsRef = FirebaseDatabase.instance.ref("threads");
  final groupsRef = FirebaseDatabase.instance.ref("groups");

  return StreamBuilder<DatabaseEvent>(
    stream: threadsRef.orderByChild("isGroup").equalTo(false).onValue,
    builder: (context, dmSnapshot) {
      if (dmSnapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      final dmThreads = <Map<String, dynamic>>[];
      if (dmSnapshot.hasData && dmSnapshot.data!.snapshot.value != null) {
        final dmValue = dmSnapshot.data!.snapshot.value;
        final data = dmValue is Map<dynamic, dynamic> ? dmValue : <dynamic, dynamic>{};

        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            final thread = Map<String, dynamic>.from(value);
            final participants = thread["participants"];
            List<String> participantList = [];
            if (participants is Map<dynamic, dynamic>) {
              participantList = participants.keys.map((e) => e.toString()).toList();
            } else if (participants is List) {
              participantList = participants.map((e) => e.toString()).toList();
            }
            final unreadCount = (thread["unreadCount"] ?? 0) as int;
            if (participantList.contains(_uid) && unreadCount > 0) {
              dmThreads.add({"id": key, ...thread});
            }
          }
        });
      }

      return StreamBuilder<DatabaseEvent>(
        stream: groupsRef.onValue,
        builder: (context, groupsSnapshot) {
          if (groupsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final groups = <Map<String, dynamic>>[];
          if (groupsSnapshot.hasData && groupsSnapshot.data!.snapshot.value != null) {
            final groupsValue = groupsSnapshot.data!.snapshot.value;
            final groupsData = groupsValue is Map<dynamic, dynamic> ? groupsValue : <dynamic, dynamic>{};

            groupsData.forEach((key, value) {
              if (value is Map<dynamic, dynamic>) {
                final group = Map<String, dynamic>.from(value);
                final members = group["members"];
                List<String> memberList = [];
                if (members is Map<dynamic, dynamic>) {
                  memberList = members.keys.map((e) => e.toString()).toList();
                } else if (members is List) {
                  memberList = members.map((e) => e.toString()).toList();
                }
                final unreadCount = (group["unreadCount"] ?? 0) as int;
                if (memberList.contains(_uid) && unreadCount > 0) {
                  groups.add({"id": key, ...group});
                }
              }
            });
          }

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
  final groupsRef = FirebaseDatabase.instance.ref("groups");

  return StreamBuilder<DatabaseEvent>(
    stream: groupsRef.onValue,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
        return _buildEmptyListView();
      }

      final value = snapshot.data!.snapshot.value;
      final data = value is Map<dynamic, dynamic> ? value : <dynamic, dynamic>{};
      final groups = <Map<String, dynamic>>[];

      data.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          final group = Map<String, dynamic>.from(value);
          final members = group["members"];
          List<String> memberList = [];
          if (members is Map<dynamic, dynamic>) {
            memberList = members.keys.map((e) => e.toString()).toList();
          } else if (members is List) {
            memberList = members.map((e) => e.toString()).toList();
          }
          if (memberList.contains(_uid)) {
            groups.add({"id": key, ...group});
          }
        }
      });

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
Widget _buildGroupTile(Map<String, dynamic> g) {
  List<String> memberList = [];
  final members = g["members"];
  if (members is Map<dynamic, dynamic>) {
    memberList = members.keys.map((e) => e.toString()).toList();
  } else if (members is List) {
    memberList = members.map((e) => e.toString()).toList();
  }

  final grp = Group(
    id: g["id"] as String,
    name: (g["name"] ?? "Group") as String,
    members: memberList,
    isAuthor: false,
  );

  DateTime? lastTime;
  final ts = g["lastMessageAt"];
  if (ts is int) {
    // RTDB usually stores timestamps as millisecondsSinceEpoch
    lastTime = DateTime.fromMillisecondsSinceEpoch(ts);
  }

  final lastMsg = (g["lastMessage"] ?? "") as String;

  return _GroupTile(
    group: grp,
    lastMessage: lastMsg.isEmpty ? null : lastMsg,
    lastMessageTime: lastTime,
    onTap: () async {
      await Navigator.pushNamed(
        context,
        "/group_chat",
        arguments: grp,
      );
    },
  );
}

Widget _buildDmTile(Map<String, dynamic> t) {
  DateTime? lastTime;
  final ts = t["lastMessageAt"];
  if (ts is int) {
    // RTDB stores timestamps as milliseconds since epoch
    lastTime = DateTime.fromMillisecondsSinceEpoch(ts);
  }

  final lastMsg = (t["lastMessage"] ?? "") as String;

  List<String> participantList = [];
  final participants = t["participants"];
  if (participants is Map<dynamic, dynamic>) {
    participantList = participants.keys.map((e) => e.toString()).toList();
  } else if (participants is List) {
    participantList = participants.map((e) => e.toString()).toList();
  }

  final otherUserId = participantList.firstWhere((id) => id != _uid, orElse: () => "");

  return FutureBuilder<DatabaseEvent>(
    future: FirebaseDatabase.instance.ref("users/$otherUserId").once(),
    builder: (context, userSnapshot) {
      String name = "User";

      if (userSnapshot.hasData && userSnapshot.data!.snapshot.value != null) {
        final userData = Map<String, dynamic>.from(
          userSnapshot.data!.snapshot.value as Map,
        );
        name = userData["name"] ?? "Agent";
      }

      return _GroupTile(
        group: Group(
          id: t["id"] as String, // we inject "id" earlier when parsing threads
          name: name,
          members: participantList,
          isAuthor: false,
        ),
        lastMessage: lastMsg.isEmpty ? null : lastMsg,
        lastMessageTime: lastTime,
        onTap: () async {
          await Navigator.pushNamed(
            context,
            "/chat",
            arguments: t["id"],
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