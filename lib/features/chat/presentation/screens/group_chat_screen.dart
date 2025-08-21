import 'package:flutter/material.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/chat/domain/models/group.dart';

class GroupChatScreen extends StatefulWidget {
  final Group group;

  const GroupChatScreen({super.key, required this.group});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.group.name,
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
            ),
            Text(
              '${widget.group.members.length} members',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: _handleMenu,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'group_info',
                    child: Text('Group info'),
                  ),
                  const PopupMenuItem(
                    value: 'add_member',
                    child: Text('Add member'),
                  ),
                  const PopupMenuItem(
                    value: 'rename',
                    child: Text('Rename group'),
                  ),
                  const PopupMenuItem(
                    value: 'clear',
                    child: Text('Clear messages'),
                  ),
                  const PopupMenuItem(
                    value: 'leave',
                    child: Text('Leave group'),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: widget.group.messages.length,
              itemBuilder: (context, index) {
                final GroupMessage message = widget.group.messages[index];
                return _GroupMessageBubble(message: message);
              },
            ),
          ),
          const Divider(height: 1),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Message',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.primaryRed,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _handleSend,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenu(String value) {
    switch (value) {
      case 'group_info':
        _showGroupInfo();
        break;
      case 'add_member':
        _promptAddMember();
        break;
      case 'rename':
        _promptRename();
        break;
      case 'clear':
        setState(() => widget.group.messages.clear());
        break;
      case 'leave':
        Navigator.pop(context);
        break;
    }
  }

  void _handleSend() {
    final String text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      widget.group.messages.add(
        GroupMessage(text: text, sender: 'You', timestamp: DateTime.now()),
      );
    });
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showGroupInfo() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Group info', style: AppTextStyles.headlineLarge),
              const SizedBox(height: 12),
              Text(
                'Name: ${widget.group.name}',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Members (${widget.group.members.length})',
                style: AppTextStyles.bodyMediumBold,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    widget.group.members
                        .map((m) => Chip(label: Text(m)))
                        .toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _promptAddMember() async {
    final TextEditingController controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add member'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Member name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    if (result != null && result.isNotEmpty) {
      setState(() => widget.group.members.add(result));
    }
  }

  void _promptRename() async {
    final TextEditingController controller = TextEditingController(
      text: widget.group.name,
    );
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename group'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Group name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (result != null && result.isNotEmpty) {
      setState(() => widget.group.name = result);
    }
  }
}

class _GroupMessageBubble extends StatelessWidget {
  final GroupMessage message;

  const _GroupMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isMe = message.sender == 'You';
    final Color bubbleColor =
        isMe ? AppColors.primaryRed : Colors.grey.shade200;
    final Color textColor = isMe ? Colors.white : Colors.black87;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 6,
          bottom: 6,
          left: isMe ? 60 : 12,
          right: isMe ? 12 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Text(
                  message.sender,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
            Text(message.text, style: TextStyle(color: textColor)),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: isMe ? Colors.white70 : Colors.black45,
              ),
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
