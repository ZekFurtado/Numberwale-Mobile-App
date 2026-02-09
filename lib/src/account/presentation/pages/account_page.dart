import 'package:flutter/material.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/src/account/presentation/widgets/account_menu_item.dart';
import 'package:numberwale/src/account/presentation/widgets/profile_header.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  // Mock user data - will be replaced with BLoC
  Map<String, dynamic> _getUserData() {
    return {
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'phoneNumber': '+91 98765 43210',
    };
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Perform logout - will be implemented with BLoC
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.login,
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _getUserData();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with profile header
          SliverToBoxAdapter(
            child: ProfileHeader(
              name: user['name'],
              email: user['email'],
              phoneNumber: user['phoneNumber'],
              onEditTap: () {
                Navigator.pushNamed(context, Routes.editProfile);
              },
            ),
          ),

          // Menu sections
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // Quick Actions Section
                _SectionHeader('Quick Actions', theme),
                const SizedBox(height: 8),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      AccountMenuItem(
                        icon: Icons.receipt_long,
                        title: 'My Orders',
                        subtitle: 'View order history',
                        onTap: () {
                          Navigator.pushNamed(context, Routes.orders);
                        },
                      ),
                      AccountMenuItem(
                        icon: Icons.location_on,
                        title: 'Saved Addresses',
                        subtitle: 'Manage delivery addresses',
                        onTap: () {
                          Navigator.pushNamed(context, Routes.addresses);
                        },
                      ),
                      AccountMenuItem(
                        icon: Icons.shopping_cart,
                        title: 'My Cart',
                        subtitle: 'View items in cart',
                        onTap: () {
                          Navigator.pushNamed(context, Routes.cart);
                        },
                        showDivider: false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Account Settings Section
                _SectionHeader('Account Settings', theme),
                const SizedBox(height: 8),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      AccountMenuItem(
                        icon: Icons.person,
                        title: 'Edit Profile',
                        subtitle: 'Update your information',
                        onTap: () {
                          Navigator.pushNamed(context, Routes.editProfile);
                        },
                      ),
                      AccountMenuItem(
                        icon: Icons.lock,
                        title: 'Change Password',
                        subtitle: 'Update your password',
                        onTap: () {
                          Navigator.pushNamed(context, Routes.changePassword);
                        },
                        showDivider: false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Services Section
                _SectionHeader('Services', theme),
                const SizedBox(height: 8),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      AccountMenuItem(
                        icon: Icons.search,
                        title: 'Custom Number Request',
                        subtitle: 'Find your perfect number',
                        iconColor: theme.colorScheme.secondary,
                        onTap: () {
                          Navigator.pushNamed(context, Routes.customRequest);
                        },
                      ),
                      AccountMenuItem(
                        icon: Icons.auto_awesome,
                        title: 'Numerology Consultation',
                        subtitle: 'Get expert guidance',
                        iconColor: theme.colorScheme.tertiary,
                        onTap: () {
                          Navigator.pushNamed(context, Routes.numerologyConsultation);
                        },
                        showDivider: false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Support Section
                _SectionHeader('Support & Info', theme),
                const SizedBox(height: 8),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      AccountMenuItem(
                        icon: Icons.support_agent,
                        title: 'Contact Us',
                        subtitle: 'Get help and support',
                        onTap: () {
                          Navigator.pushNamed(context, Routes.contactUs);
                        },
                      ),
                      AccountMenuItem(
                        icon: Icons.help_outline,
                        title: 'FAQs',
                        subtitle: 'Frequently asked questions',
                        onTap: () {
                          Navigator.pushNamed(context, Routes.faq);
                        },
                      ),
                      AccountMenuItem(
                        icon: Icons.info_outline,
                        title: 'About Us',
                        subtitle: 'Learn more about Numberwale',
                        onTap: () {
                          Navigator.pushNamed(context, Routes.about);
                        },
                      ),
                      AccountMenuItem(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        onTap: () {
                          Navigator.pushNamed(context, Routes.privacyPolicy);
                        },
                      ),
                      AccountMenuItem(
                        icon: Icons.description_outlined,
                        title: 'Terms & Conditions',
                        onTap: () {
                          Navigator.pushNamed(context, Routes.termsAndConditions);
                        },
                        showDivider: false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Logout button
                Card(
                  elevation: 1,
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AccountMenuItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    iconColor: theme.colorScheme.error,
                    onTap: () => _showLogoutDialog(context),
                    showDivider: false,
                  ),
                ),

                const SizedBox(height: 16),

                // App version
                Center(
                  child: Text(
                    'Version 1.0.0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, this.theme);

  final String title;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
