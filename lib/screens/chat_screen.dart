import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerName;
  final String peerPhotoUrl;

  const ChatScreen({
    Key? key,
    required this.peerId,
    required this.peerName,
    required this.peerPhotoUrl,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String chatId;
  final currentUser = FirebaseAuth.instance.currentUser;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    final ids = [currentUser!.uid, widget.peerId]..sort();
    chatId = ids.join('_');
    // Reset unread count for current user when opening chat
    FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'unreadCount_${currentUser!.uid}': 0,
    }, SetOptions(merge: true));
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSending = true);
    _messageController.clear();
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': currentUser!.uid,
          'receiverId': widget.peerId,
          'text': text,
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'text',
        });
    await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'participants': [currentUser!.uid, widget.peerId],
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'isGroup': false,
      'unreadCount_${widget.peerId}': FieldValue.increment(1),
      'unreadCount_${currentUser!.uid}': 0,
    }, SetOptions(merge: true));
    setState(() => _isSending = false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onAttachPressed() async {
    // TODO: Implement image/file picker logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attach image/file feature coming soon!')),
    );
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _peerStatusStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.peerId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  widget.peerPhotoUrl.isNotEmpty
                      ? NetworkImage(widget.peerPhotoUrl)
                      : null,
              child:
                  widget.peerPhotoUrl.isEmpty ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.peerName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _peerStatusStream(),
                  builder: (context, snapshot) {
                    final isOnline =
                        snapshot.data?.data()?['isOnline'] ?? false;
                    return Text(
                      isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: isOnline ? Colors.greenAccent : Colors.grey[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFF111B21),
        elevation: 1,
      ),
      backgroundColor: const Color(0xFF181F25),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('chats')
                      .doc(chatId)
                      .collection('messages')
                      .orderBy('timestamp')
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data?.docs ?? [];
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollToBottom(),
                );
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data() as Map<String, dynamic>;
                    final isMe = msg['senderId'] == currentUser!.uid;
                    final showAvatar =
                        index == 0 ||
                        (messages[index - 1].data()
                                as Map<String, dynamic>)['senderId'] !=
                            msg['senderId'];
                    final time =
                        msg['timestamp'] != null &&
                                msg['timestamp'] is Timestamp
                            ? DateFormat(
                              'h:mm a',
                            ).format((msg['timestamp'] as Timestamp).toDate())
                            : '';
                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: showAvatar ? 8 : 2,
                          bottom: 2,
                          left: isMe ? 40 : 0,
                          right: isMe ? 0 : 40,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              isMe
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isMe && showAvatar)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundImage:
                                      widget.peerPhotoUrl.isNotEmpty
                                          ? NetworkImage(widget.peerPhotoUrl)
                                          : null,
                                  child:
                                      widget.peerPhotoUrl.isEmpty
                                          ? const Icon(Icons.person, size: 18)
                                          : null,
                                ),
                              ),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isMe
                                          ? Colors.green[400]
                                          : Colors.grey[850],
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(18),
                                    topRight: const Radius.circular(18),
                                    bottomLeft: Radius.circular(isMe ? 18 : 4),
                                    bottomRight: Radius.circular(isMe ? 4 : 18),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      msg['text'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      time,
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isMe && showAvatar) const SizedBox(width: 6),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            color: const Color(0xFF202C33),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.white70),
                    onPressed: _onAttachPressed,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF181F25),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Type a message',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        minLines: 1,
                        maxLines: 5,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  CircleAvatar(
                    backgroundColor: Colors.green[400],
                    radius: 22,
                    child: IconButton(
                      icon:
                          _isSending
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.send, color: Colors.white),
                      onPressed: _isSending ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
