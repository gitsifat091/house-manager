import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'tenant_home_screen.dart';
import 'tenant_payment_screen.dart';
import 'tenant_notice_screen.dart';
import 'tenant_maintenance_screen.dart';
import 'tenant_utility_screen.dart';
import '../landlord/settings_screen.dart';
import '../../../widgets/profile_avatar.dart';
import '../tenant/tenant_rules_screen.dart';
import '../tenant/tenant_chat_screen.dart';
import 'tenant_community_screen.dart';

class TenantDashboard extends StatefulWidget {
  const TenantDashboard({super.key});

  @override
  State<TenantDashboard> createState() => _TenantDashboardState();
}

class _TenantDashboardState extends State<TenantDashboard> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser!;

    final pages = [
      TenantHomeScreen(user: user, scaffoldKey: _scaffoldKey),
      TenantPaymentScreen(user: user, scaffoldKey: _scaffoldKey),
      TenantNoticeScreen(user: user, scaffoldKey: _scaffoldKey),
      TenantMaintenanceScreen(user: user, scaffoldKey: _scaffoldKey),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: _TenantDrawer(user: user),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'হোম',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'ভাড়া',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign_rounded),
            label: 'নোটিশ',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build_rounded),
            label: 'মেরামত',
          ),
        ],
      ),
    );
  }
}

// ── Tenant Drawer ─────────────────────────────────────────────────────────

class _TenantDrawer extends StatelessWidget {
  final dynamic user;
  const _TenantDrawer({required this.user});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: color.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Consumer<AuthService>(
                    builder: (context, auth, _) => ProfileAvatar(
                      name: auth.currentUser?.name ?? user.name,
                      photoUrl: auth.currentUser?.photoUrl,
                      userId: user.uid,
                      radius: 52,
                      editable: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(user.name,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text(user.email,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.white70)),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('ভাড়াটিয়া',
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // My Profile
                  _TenantDrawerItem(
                    icon: Icons.person_outline_rounded,
                    label: 'আমার প্রোফাইল',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _TenantProfileScreen(user: user),
                          ));
                    },
                  ),

                  const _DrawerDivider(label: 'বিলসমূহ'),

                  // Utility bills
                  _TenantDrawerItem(
                    icon: Icons.electric_bolt_outlined,
                    label: 'আমার বিলসমূহ',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TenantUtilityScreen(user: user),
                          ));
                    },
                  ),

                  const _DrawerDivider(label: 'অ্যাপ'),

                  // Chat or Message
                  _TenantDrawerItem(
                    icon: Icons.chat_outlined,
                    label: 'Messages',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TenantChatScreen(user: user),
                          ));
                    },
                  ),

                  _TenantDrawerItem(
                    icon: Icons.forum_outlined,
                    label: 'Community Chat',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TenantCommunityChatScreen(user: user),
                          ));
                    },
                  ),

                  // Rules
                  _TenantDrawerItem(
                    icon: Icons.gavel_rounded,
                    label: 'নিয়মাবলী',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TenantRulesScreen(user: user),
                          ));
                    },
                  ),

                  _TenantDrawerItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ));
                    },
                  ),

                  const SizedBox(height: 8),

                  _TenantDrawerItem(
                    icon: Icons.logout_rounded,
                    label: 'Logout',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _confirmLogout(context);
                    },
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('House Manager v1.0',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('আপনি কি logout করতে চান?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('না')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthService>().logout();
            },
            child: const Text('হ্যাঁ'),
          ),
        ],
      ),
    );
  }
}

// ── Tenant Profile Screen ─────────────────────────────────────────────────

class _TenantProfileScreen extends StatelessWidget {
  final dynamic user;
  const _TenantProfileScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('আমার প্রোফাইল'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 52,
              backgroundColor: color.primaryContainer,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'T',
                style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: color.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(user.name,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('ভাড়াটিয়া',
                  style: TextStyle(
                      color: color.primary, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 32),
            _profileRow(context, Icons.email_outlined, 'Email', user.email),
            _profileRow(context, Icons.phone_outlined, 'Phone', user.phone),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AuthService>().logout();
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.red),
                label:
                    const Text('Logout', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileRow(
      BuildContext context, IconData icon, String label, String value) {
    final color = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.primary, size: 22),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 12, color: color.onSurface.withOpacity(0.5))),
              Text(value,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shared Drawer Widgets ─────────────────────────────────────────────────

class _TenantDrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _TenantDrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurface;
    return ListTile(
      leading: Icon(icon, color: c, size: 22),
      title:
          Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w500)),
      onTap: onTap,
      horizontalTitleGap: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

class _DrawerDivider extends StatelessWidget {
  final String label;
  const _DrawerDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
            letterSpacing: 1),
      ),
    );
  }
}
