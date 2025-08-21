import 'package:flutter/material.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/chat/presentation/screens/admin_chat_screen.dart';
import 'package:park_chatapp/features/chat/domain/models/group.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String _lastMessage = 'Do you have any query? We are here to help';
  DateTime _lastMessageTime = DateTime.now();
  final List<Group> _groups = <Group>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: Text(
          'Chats',
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'create_group') {
                final result = await Navigator.pushNamed(
                  context,
                  '/create_group',
                );
                if (!mounted) return;
                if (result is Group) {
                  setState(() => _groups.add(result));
                  await Navigator.pushNamed(
                    context,
                    '/group_chat',
                    arguments: result,
                  );
                  if (!mounted) return;
                  setState(() {});
                }
              }
            },
            itemBuilder:
                (context) => const [
                  PopupMenuItem(
                    value: 'create_group',
                    child: Text('Create group'),
                  ),
                ],
          ),
        ],
      ),
      body: ListView(
        children: [
          _AdminChatTile(
            lastMessage: _lastMessage,
            lastMessageTime: _lastMessageTime,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminChatScreen()),
              );
              if (result is Map) {
                final String? text = result['lastMessageText'] as String?;
                final DateTime? time = result['lastMessageTime'] as DateTime?;
                if (text != null && text.trim().isNotEmpty && time != null) {
                  setState(() {
                    _lastMessage = text.trim();
                    _lastMessageTime = time;
                  });
                }
              } else if (result is String && result.trim().isNotEmpty) {
                setState(() {
                  _lastMessage = result.trim();
                  _lastMessageTime = DateTime.now();
                });
              }
            },
          ),
          const Divider(height: 0),
          if (_groups.isEmpty)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryRed.withOpacity(0.15),
                child: const Icon(Icons.group, color: AppColors.primaryRed),
              ),
              title: const Text('No groups yet'),
              subtitle: const Text('Use the menu to create a group'),
            )
          else
            ..._groups.map(
              (g) => _GroupTile(
                group: g,
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    '/group_chat',
                    arguments: g,
                  );
                  if (!mounted) return;
                  setState(() {});
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  final Group group;
  final VoidCallback onTap;

  const _GroupTile({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final String subtitle =
        group.messages.isNotEmpty
            ? group.messages.last.text
            : 'No messages yet';
    final DateTime? time =
        group.messages.isNotEmpty ? group.messages.last.timestamp : null;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
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
        trailing:
            time == null
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
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
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
