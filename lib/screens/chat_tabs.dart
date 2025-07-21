import 'package:flutter/material.dart';

class ChatTabs extends StatefulWidget {
  final int initialIndex;
  final ValueChanged<int> onTabSelected;
  const ChatTabs({
    super.key,
    this.initialIndex = 0,
    required this.onTabSelected,
  });

  @override
  State<ChatTabs> createState() => _ChatTabsState();
}

class _ChatTabsState extends State<ChatTabs> {
  int selectedIndex = 0;

  final List<String> tabTitles = ['All', 'Unread', 'Groups', 'Favourites'];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...List.generate(tabTitles.length, (index) {
            final isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() => selectedIndex = index);
                widget.onTabSelected(index);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color.fromARGB(90, 76, 175, 79) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.green : const Color.fromARGB(185, 65, 64, 64),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  tabTitles[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
              ),
            );
          }),
          // Plus button
          GestureDetector(
            onTap: () {
              // Handle plus button tap
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white54, width: 1.5),
              ),
              child: const Icon(Icons.add, color: Colors.white70, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
