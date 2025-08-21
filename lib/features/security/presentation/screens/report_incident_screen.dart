import 'package:flutter/material.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  final List<_IncidentReport> _reports = <_IncidentReport>[
    _IncidentReport(
      title: 'Suspicious vehicle near Gate 3',
      details:
          'White sedan parked for over an hour, license partially covered.',
      author: 'Ali',
      timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
    ),
    _IncidentReport(
      title: 'Street light not working',
      details: 'Dark area near Block A park, please check the light pole #12.',
      author: 'Sara',
      timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 5)),
    ),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: Text(
          'Report & Feed',
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReportCTA(context),
          const SizedBox(height: 16),
          ..._reports.map((r) => _ReportCard(report: r)).toList(),
        ],
      ),
    );
  }

  Widget _buildReportCTA(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.report, color: AppColors.primaryRed),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Report something', style: AppTextStyles.bodyMediumBold),
                  const SizedBox(height: 4),
                  Text(
                    'See something? Create a quick report to alert others.',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              onPressed: _openReportSheet,
              child: const Text(
                'Report',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openReportSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New report', style: AppTextStyles.headlineLarge),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Short summary',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _detailsController,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Details',
                  hintText: 'Describe what happened',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: _submit,
                  child: const Text(
                    'Submit report',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit() {
    final String title = _titleController.text.trim();
    final String details = _detailsController.text.trim();
    if (title.isEmpty || details.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final _IncidentReport newReport = _IncidentReport(
      title: title,
      details: details,
      author: 'You',
      timestamp: DateTime.now(),
    );

    setState(() {
      _reports.insert(0, newReport);
    });

    _titleController.clear();
    _detailsController.clear();

    Navigator.of(context).maybePop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Incident reported')));
  }
}

class _IncidentReport {
  final String title;
  final String details;
  final String author;
  final DateTime timestamp;

  _IncidentReport({
    required this.title,
    required this.details,
    required this.author,
    required this.timestamp,
  });
}

class _ReportCard extends StatelessWidget {
  final _IncidentReport report;

  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryRed.withOpacity(0.15),
                  child: const Icon(Icons.person, color: AppColors.primaryRed),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report.author, style: AppTextStyles.bodyMediumBold),
                      Text(
                        _formatTime(report.timestamp),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(report.title, style: AppTextStyles.bodyMediumBold),
            const SizedBox(height: 6),
            Text(report.details, style: AppTextStyles.bodySmall),
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
