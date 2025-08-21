import 'package:flutter/material.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';

class LostFoundScreen extends StatefulWidget {
  const LostFoundScreen({super.key});

  @override
  State<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends State<LostFoundScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_LostFoundItem> _lostItems = <_LostFoundItem>[
    _LostFoundItem(
      id: 'l1',
      title: 'Wallet',
      description: 'Black leather wallet near Block A parking.',
      location: 'Block A Parking',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      isLost: true,
      contactName: 'Ali',
      contactPhone: '0300-0000000',
    ),
  ];

  final List<_LostFoundItem> _foundItems = <_LostFoundItem>[
    _LostFoundItem(
      id: 'f1',
      title: 'Keys',
      description: 'Set of car keys with a red keychain.',
      location: 'Community Center',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      isLost: false,
      contactName: 'Sara',
      contactPhone: '0321-1111111',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: Text(
          'Lost & Found',
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: AppTextStyles.bodyMediumBold.copyWith(fontSize: 16),
          unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(fontSize: 16),
          tabs: const [Tab(text: 'Lost Items'), Tab(text: 'Found Items')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildLostTab(context), _buildFoundTab(context)],
      ),
    );
  }

  Widget _buildLostTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ActionCard(
          icon: Icons.search,
          title: 'Report Lost Item',
          subtitle: 'Create a notice for a lost item',
          onTap: () => _showReportDialog(context, isLost: true),
        ),
        const SizedBox(height: 16),
        _buildSection('Recent Lost Reports', _lostItems),
      ],
    );
  }

  Widget _buildFoundTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ActionCard(
          icon: Icons.check_circle,
          title: 'Report Found Item',
          subtitle: 'Let others know you found something',
          onTap: () => _showReportDialog(context, isLost: false),
        ),
        const SizedBox(height: 16),
        _buildSection('Recently Found', _foundItems),
      ],
    );
  }

  Widget _buildSection(String heading, List<_LostFoundItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(heading, style: AppTextStyles.bodyMediumBold),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No entries yet.'),
            ),
          )
        else
          ...items.map((i) => _LostFoundCard(item: i)).toList(),
      ],
    );
  }

  Future<void> _showReportDialog(
    BuildContext context, {
    required bool isLost,
  }) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    final contactNameController = TextEditingController();
    final contactPhoneController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isLost ? 'Report Lost Item' : 'Report Found Item'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator:
                        (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  TextFormField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                  TextFormField(
                    controller: contactNameController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Name',
                    ),
                  ),
                  TextFormField(
                    controller: contactPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Phone',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final newItem = _LostFoundItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  location: locationController.text.trim(),
                  timestamp: DateTime.now(),
                  isLost: isLost,
                  contactName: contactNameController.text.trim(),
                  contactPhone: contactPhoneController.text.trim(),
                );
                setState(() {
                  if (isLost) {
                    _lostItems.insert(0, newItem);
                  } else {
                    _foundItems.insert(0, newItem);
                  }
                });
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
              ),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryRed.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryRed.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryRed),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMediumBold),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LostFoundItem {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime timestamp;
  final bool isLost;
  final String? contactName;
  final String? contactPhone;

  _LostFoundItem({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.timestamp,
    required this.isLost,
    this.contactName,
    this.contactPhone,
  });
}

class _LostFoundCard extends StatelessWidget {
  final _LostFoundItem item;

  const _LostFoundCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final Color chipColor = item.isLost ? Colors.orange : Colors.green;
    final String chipText = item.isLost ? 'Lost' : 'Found';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.title, style: AppTextStyles.bodyMediumBold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: chipColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    chipText,
                    style: TextStyle(
                      color: chipColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (item.description.isNotEmpty)
              Text(item.description, style: AppTextStyles.bodySmall),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.place, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.location,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _formatTime(item.timestamp),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            if ((item.contactName?.isNotEmpty ?? false) ||
                (item.contactPhone?.isNotEmpty ?? false)) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      [
                        item.contactName,
                        item.contactPhone,
                      ].where((e) => (e ?? '').isNotEmpty).join(' • '),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
