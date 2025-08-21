import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/auth/presentation/screens/payments_screen.dart';
import 'package:park_chatapp/features/marketplace/presentation/screens/favorites_screen.dart';
import 'package:park_chatapp/features/property/presentation/screens/property_explore_screen.dart';
import 'package:park_chatapp/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:park_chatapp/features/security/presentation/screens/security_screen.dart';
import 'package:park_chatapp/features/complaints/presentation/screens/complaints_screen.dart';
import 'package:park_chatapp/features/lost_found/presentation/screens/lost_found_screen.dart';
import 'package:park_chatapp/features/marketplace/presentation/screens/marketplace_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.primaryRed,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DrawerHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerTile(
                    context,
                    icon: Icons.home_outlined,
                    label: 'Home',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.explore,
                    label: 'Explore Properties',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PropertyExploreScreen(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.chat,
                    label: 'Chat',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ChatListScreen(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.payment,
                    label: 'Payments',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PaymentsScreen(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.security,
                    label: 'Security',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SecurityScreen(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.feedback,
                    label: 'Complaints',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ComplaintsScreen(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.find_in_page,
                    label: 'Lost & Found',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LostFoundScreen(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.shopping_cart,
                    label: 'Marketplace',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MarketplaceScreen(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.favorite,
                    label: 'Favorites',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FavoritesScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(color: Colors.white24),
                  _drawerTile(
                    context,
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      _showSnack(context, 'Settings coming soon');
                    },
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.help_outline,
                    label: 'Help & Support',
                    onTap: () {
                      Navigator.pop(context);
                      _showSnack(context, 'Support coming soon');
                    },
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.logout,
                    label: 'Logout',
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Text(
                'Version 1.0.0',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: const Icon(Icons.circle, color: Colors.transparent),
      title: Row(
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      onTap: onTap,
      horizontalTitleGap: 0,
      trailing: const Icon(Icons.chevron_right, color: Colors.white70),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Logout'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                  _showSnack(context, 'Logged out');
                },
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryRed.withOpacity(0.9),
            AppColors.primaryRed.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.w,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: AppColors.primaryRed, size: 28.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Guest User',
                  style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
                ),
                SizedBox(height: 4.h),
                Text(
                  'guest@example.com',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
