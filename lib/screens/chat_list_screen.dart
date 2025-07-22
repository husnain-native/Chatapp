import 'package:flutter/material.dart';
import 'package:park_chatapp/theme/app_color.dart';
import 'package:park_chatapp/screens/chat_tabs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:park_chatapp/screens/user_list_screen.dart';
import 'package:park_chatapp/screens/chat_screen.dart'; // Added import for ChatScreen
import 'package:park_chatapp/screens/edit_profile_screen.dart'; // Added import for EditProfileScreen

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  // late TabController _tabController; // No longer needed

  int selectedTabIndex = 0;

  final List<Map<String, dynamic>> mockChats = [
    {
      'name': 'Adnan Ikram',
      'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
      'lastMessage': 'Voice call',
      'time': '17:19',
      'unread': false,
      'favourite': false,
      'group': false,
    },
    {
      'name': 'Faheem Raza',
      'avatar': 'https://randomuser.me/api/portraits/men/2.jpg',
      'lastMessage': 'Faheem reacted ❤️ to "Chlo good hai Ma..."',
      'time': '17:12',
      'unread': true,
      'favourite': false,
      'group': false,
    },
    {
      'name': 'Hardik',
      'avatar': 'https://randomuser.me/api/portraits/men/3.jpg',
      'lastMessage': 'Voice call',
      'time': '16:58',
      'unread': false,
      'favourite': false,
      'group': false,
    },
    {
      'name': '3 IDIOTS',
      'avatar': '',
      'lastMessage': 'You: MaShaAllah ',
      'time': '16:58',
      'unread': false,
      'favourite': true,
      'group': true,
    },
    {
      'name': 'Fresh Grad’s Internship & Jobs',
      'avatar': '',
      'lastMessage': '~ Rana Zeshan Ashraf pinned a message',
      'time': '15:04',
      'unread': true,
      'favourite': false,
      'group': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    // _tabController = TabController(length: 4, vsync: this); // No longer needed
  }

  @override
  void dispose() {
    // _tabController.dispose(); // No longer needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    Query<Map<String, dynamic>> baseQuery = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUser!.uid)
        .orderBy('lastMessageTime', descending: true);

    Query<Map<String, dynamic>> query;
    switch (selectedTabIndex) {
      case 1: // Unread
        query = baseQuery.where(
          'unreadCount_${currentUser.uid}',
          isGreaterThan: 0,
        );
        break;
      case 2: // Groups
        query = baseQuery.where('isGroup', isEqualTo: true);
        break;
      case 3: // Favourites
        query = baseQuery.where('favourites', arrayContains: currentUser.uid);
        break;
      default:
        query = baseQuery;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF111B21),
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: const Color(0xFF111B21),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Park View City',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color.fromARGB(255, 213, 238, 215),
            onSelected: (value) {
              if (value == 'edit_profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem<String>(
                    value: 'edit_profile',
                    child: Text('Edit Profile'),
                  ),
                ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(96),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search Chats',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF202C33),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              ChatTabs(
                initialIndex: selectedTabIndex,
                onTabSelected: (index) {
                  setState(() {
                    selectedTabIndex = index;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          print(
            'Chat list snapshot: hasData= [32m [1m${snapshot.hasData} [0m, docs= [32m [1m${snapshot.data?.docs.length} [0m',
          );
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No chats yet',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          final chats = snapshot.data!.docs;
          final currentUserId = currentUser.uid;
          return ListView.separated(
            padding: const EdgeInsets.only(top: 8),
            itemCount: chats.length,
            separatorBuilder:
                (context, index) => Divider(
                  color: Colors.grey[700],
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
            itemBuilder: (context, index) {
              final chat = chats[index].data();
              final isGroup = chat['isGroup'] == true;
              if (isGroup) {
                // Group chat UI (existing logic)
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.groups, color: Colors.white),
                    radius: 26,
                  ),
                  title: Text(
                    chat['groupName'] ?? 'Group',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    chat['lastMessage'] ?? '',
                    style: const TextStyle(color: Colors.white70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    chat['lastMessageTime'] != null
                        ? (chat['lastMessageTime'] as Timestamp)
                            .toDate()
                            .toLocal()
                            .toString()
                            .substring(11, 16)
                        : '',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  onTap: () {
                    // TODO: Navigate to group chat screen
                  },
                );
              } else {
                // 1-to-1 chat: find the other user's UID
                final List participants = List.from(chat['participants'] ?? []);
                final String otherUserId = participants.firstWhere(
                  (id) => id != currentUserId,
                  orElse: () => '',
                );
                if (otherUserId.isEmpty) {
                  return const SizedBox.shrink();
                }
                return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future:
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(otherUserId)
                          .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const ListTile(
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor: Color(0xFF202C33),
                        ),
                        title: SizedBox(
                          height: 16,
                          width: 80,
                          child: LinearProgressIndicator(),
                        ),
                      );
                    }
                    final userData = userSnapshot.data?.data();
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF512DA8),
                        backgroundImage:
                            (userData?['photoUrl'] ?? '').isNotEmpty
                                ? NetworkImage(userData!['photoUrl'])
                                : null,
                        child:
                            (userData?['photoUrl'] ?? '').isEmpty
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                        radius: 26,
                      ),
                      title: Text(
                        userData?['displayName'] ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        chat['lastMessage'] ?? '',
                        style: const TextStyle(color: Colors.white70),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            chat['lastMessageTime'] != null
                                ? (chat['lastMessageTime'] as Timestamp)
                                    .toDate()
                                    .toLocal()
                                    .toString()
                                    .substring(11, 16)
                                : '',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if ((chat['unreadCount_${currentUserId}'] ?? 0) > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                (chat['unreadCount_${currentUserId}'] > 9)
                                    ? '9+'
                                    : chat['unreadCount_${currentUserId}']
                                        .toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        // Navigate to chat screen with this user
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ChatScreen(
                                  peerId: otherUserId,
                                  peerName: userData?['displayName'] ?? 'User',
                                  peerPhotoUrl: userData?['photoUrl'] ?? '',
                                ),
                          ),
                        );
                      },
                    );
                  },
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserListScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 4, 29, 5),
        selectedItemColor: const Color.fromARGB(255, 90, 221, 3),
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.update), label: 'Updates'),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Communities',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: 'Calls'),
        ],
        currentIndex: 0,
        onTap: (index) {},
      ),
    );
  }

  Widget _buildChatList(List<Map<String, dynamic>> chats) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 8),
      itemCount: chats.length,
      separatorBuilder:
          (context, index) => const Divider(
            color: Color.fromARGB(255, 163, 198, 218),
            height: 0,
          ),
      itemBuilder: (context, index) {
        final chat = chats[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: chat['avatar'] == '' ? AppColors.primary : null,
            backgroundImage:
                chat['avatar'] != '' ? NetworkImage(chat['avatar']) : null,
            child:
                chat['avatar'] == ''
                    ? Icon(
                      chat['group'] ? Icons.groups : Icons.person,
                      color: Colors.white,
                    )
                    : null,
            radius: 26,
          ),
          title: Text(
            chat['name'],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            chat['lastMessage'],
            style: const TextStyle(color: Colors.white70),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            chat['time'],
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          onTap: () {},
        );
      },
    );
  }
}
