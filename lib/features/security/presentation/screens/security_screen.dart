import 'package:flutter/material.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

import 'report_incident_screen.dart';
import 'emergency_alerts_screen.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  static const String _securityPhoneNumber = '+923001234567';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: Text(
          'Security & Emergency',
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _QuickActionsRow(
            onCall: () => _callSecurity(),
            onPanic: () => _showPanicSheet(context),
          ),
          const SizedBox(height: 16),
          _FeatureCard(
            icon: Icons.report,
            title: 'Report incidents or suspicious activity',
            subtitle: 'Describe what happened and optionally add a photo',
            actionText: 'Report',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportIncidentScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.notifications_active,
            title: 'Emergency alerts',
            subtitle: 'View and manage alerts from the community/security',
            actionText: 'Open alerts',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EmergencyAlertsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _callSecurity() async {
    final Uri uri = Uri(scheme: 'tel', path: _securityPhoneNumber);
    await launchUrl(uri);
  }

  void _showPanicSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Panic button', style: AppTextStyles.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Press and hold to send an immediate SOS alert to security. This will also initiate a call to the security office.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onLongPress: () async {
                    Navigator.pop(ctx);
                    await _callSecurity();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('SOS sent and calling security...'),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'HOLD TO SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Center(child: Text('Hold for 2 seconds to trigger')),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  final VoidCallback onCall;
  final VoidCallback onPanic;

  const _QuickActionsRow({required this.onCall, required this.onPanic});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            color: AppColors.primaryRed,
            icon: Icons.call,
            title: 'Call Security',
            subtitle: 'Single tap to dial',
            onPressed: onCall,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            color: Colors.red,
            icon: Icons.warning_amber_rounded,
            title: 'Panic Button',
            subtitle: 'Hold to send SOS',
            onPressed: onPanic,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMediumBold),
                  const SizedBox(height: 2),
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

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback onPressed;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.1),
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
                  const SizedBox(height: 6),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: onPressed,
                      child: Text(
                        actionText,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
