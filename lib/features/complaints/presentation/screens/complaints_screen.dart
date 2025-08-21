import 'package:flutter/material.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';

import 'register_complaint_screen.dart';
import 'feedback_screen.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_Complaint> _complaints = <_Complaint>[
    _Complaint(
      id: '1',
      title: 'Water leakage in Block B',
      category: 'Maintenance',
      description: 'Water dripping from ceiling in apartment 2B',
      status: ComplaintStatus.inProgress,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      priority: 'High',
    ),
    _Complaint(
      id: '2',
      title: 'Garbage not collected',
      category: 'Cleanliness',
      description: 'Garbage bins overflowing near Gate 1',
      status: ComplaintStatus.resolved,
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      priority: 'Medium',
    ),
  ];

  final List<_Feedback> _feedbacks = <_Feedback>[
    _Feedback(
      id: '1',
      overallRating: 4.0,
      maintenanceRating: 3.5,
      securityRating: 4.5,
      cleanlinessRating: 4.0,
      comments:
          'Overall good experience. Security services are excellent, but maintenance could be improved.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    _Feedback(
      id: '2',
      overallRating: 3.5,
      maintenanceRating: 4.0,
      securityRating: 3.0,
      cleanlinessRating: 4.5,
      comments:
          'Cleanliness is top-notch. Security response time needs improvement.',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
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
          'Complaints & Feedback',
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
          tabs: const [Tab(text: 'Complaints'), Tab(text: 'Feedback')],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [_buildComplaintsTab(context), _buildFeedbackTab(context)],
        ),
      ),
    );
  }

  Widget _buildComplaintsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildQuickActions(context),
        const SizedBox(height: 16),
        _buildComplaintsList(),
      ],
    );
  }

  Widget _buildFeedbackTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFeedbackActions(context),
        const SizedBox(height: 16),
        _buildFeedbackList(),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.report_problem,
            title: 'Register Complaint',
            subtitle: 'Report maintenance, cleanliness issues',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RegisterComplaintScreen(),
                ),
              );
              if (result is Map<String, dynamic>) {
                setState(() {
                  _complaints.insert(
                    0,
                    _Complaint(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: result['title'] ?? '',
                      category: result['category'] ?? '',
                      description: result['description'] ?? '',
                      status: ComplaintStatus.pending,
                      timestamp: DateTime.now(),
                      priority: result['priority'] ?? 'Medium',
                    ),
                  );
                });
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.rate_review,
            title: 'Submit Feedback',
            subtitle: 'Rate services or give suggestions',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FeedbackScreen()),
              );
              if (result is Map<String, dynamic>) {
                setState(() {
                  _feedbacks.insert(
                    0,
                    _Feedback(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      overallRating: result['overallRating'] ?? 3.0,
                      maintenanceRating: result['maintenanceRating'] ?? 3.0,
                      securityRating: result['securityRating'] ?? 3.0,
                      cleanlinessRating: result['cleanlinessRating'] ?? 3.0,
                      comments: result['comments'] ?? '',
                      timestamp: DateTime.now(),
                    ),
                  );
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackActions(BuildContext context) {
    return _ActionCard(
      icon: Icons.rate_review,
      title: 'Submit New Feedback',
      subtitle: 'Rate services or give suggestions',
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FeedbackScreen()),
        );
        if (result is Map<String, dynamic>) {
          setState(() {
            _feedbacks.insert(
              0,
              _Feedback(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                overallRating: result['overallRating'] ?? 3.0,
                maintenanceRating: result['maintenanceRating'] ?? 3.0,
                securityRating: result['securityRating'] ?? 3.0,
                cleanlinessRating: result['cleanlinessRating'] ?? 3.0,
                comments: result['comments'] ?? '',
                timestamp: DateTime.now(),
              ),
            );
          });
        }
      },
    );
  }

  Widget _buildFeedbackList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Feedback', style: AppTextStyles.bodyMediumBold),
        const SizedBox(height: 12),
        if (_feedbacks.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No feedback submitted yet. Tap "Submit New Feedback" to get started.',
              ),
            ),
          )
        else
          ..._feedbacks.map((f) => _FeedbackCard(feedback: f)).toList(),
      ],
    );
  }

  Widget _buildComplaintsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Complaints', style: AppTextStyles.bodyMediumBold),
        const SizedBox(height: 12),
        if (_complaints.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No complaints yet. Tap "Register Complaint" to get started.',
              ),
            ),
          )
        else
          ..._complaints.map((c) => _ComplaintCard(complaint: c)).toList(),
      ],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.bodyMediumBold),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final _Complaint complaint;

  const _ComplaintCard({required this.complaint});

  @override
  Widget build(BuildContext context) {
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
                  child: Text(
                    complaint.title,
                    style: AppTextStyles.bodyMediumBold,
                  ),
                ),
                _StatusChip(status: complaint.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    complaint.category,
                    style: TextStyle(
                      color: AppColors.primaryRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(
                      complaint.priority,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    complaint.priority,
                    style: TextStyle(
                      color: _getPriorityColor(complaint.priority),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(complaint.description, style: AppTextStyles.bodySmall),
            const SizedBox(height: 8),
            Text(
              'Submitted ${_formatTime(complaint.timestamp)}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
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

class _StatusChip extends StatelessWidget {
  final ComplaintStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case ComplaintStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case ComplaintStatus.inProgress:
        color = Colors.blue;
        text = 'In Progress';
        break;
      case ComplaintStatus.resolved:
        color = Colors.green;
        text = 'Resolved';
        break;
      case ComplaintStatus.closed:
        color = Colors.grey;
        text = 'Closed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _Complaint {
  final String id;
  final String title;
  final String category;
  final String description;
  final ComplaintStatus status;
  final DateTime timestamp;
  final String priority;

  _Complaint({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.status,
    required this.timestamp,
    required this.priority,
  });
}

enum ComplaintStatus { pending, inProgress, resolved, closed }

class _Feedback {
  final String id;
  final double overallRating;
  final double maintenanceRating;
  final double securityRating;
  final double cleanlinessRating;
  final String comments;
  final DateTime timestamp;

  _Feedback({
    required this.id,
    required this.overallRating,
    required this.maintenanceRating,
    required this.securityRating,
    required this.cleanlinessRating,
    required this.comments,
    required this.timestamp,
  });
}

class _FeedbackCard extends StatelessWidget {
  final _Feedback feedback;

  const _FeedbackCard({required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Feedback Submitted',
                    style: AppTextStyles.bodyMediumBold.copyWith(
                      color: AppColors.primaryRed,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${feedback.overallRating.toStringAsFixed(1)}/5',
                    style: TextStyle(
                      color: AppColors.primaryRed,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRatingRow('Overall', feedback.overallRating),
            _buildRatingRow('Maintenance', feedback.maintenanceRating),
            _buildRatingRow('Security', feedback.securityRating),
            _buildRatingRow('Cleanliness', feedback.cleanlinessRating),
            if (feedback.comments.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Comments:',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                feedback.comments,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Submitted ${_formatTime(feedback.timestamp)}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow(String label, double rating) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < rating.floor()
                      ? Icons.star
                      : (index < rating.ceil() && rating % 1 != 0)
                      ? Icons.star_half
                      : Icons.star_border,
                  size: 16,
                  color: AppColors.primaryRed,
                );
              }),
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              rating.toStringAsFixed(1),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
