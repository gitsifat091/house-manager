import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/property_service.dart';
import '../../models/property_model.dart';
import 'chart_screen.dart';
import 'add_edit_property_screen.dart';
import 'room_list_screen.dart';
import 'tenant_list_screen.dart';
import 'payment_list_screen.dart';
import 'notice_screen.dart';
import 'maintenance_requests_screen.dart';
import 'utility_screen.dart';
import 'archive_screen.dart';
import 'settings_screen.dart';
import '../../../widgets/profile_avatar.dart';
import 'rules_screen.dart';
import 'chat_list_screen.dart';

class LandlordDashboard extends StatefulWidget {
  const LandlordDashboard({super.key});

  @override
  State<LandlordDashboard> createState() => _LandlordDashboardState();
}

class _LandlordDashboardState extends State<LandlordDashboard> {
  int _currentIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<_NavItem> _bottomItems = const [
    _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart_rounded, label: 'রিপোর্ট'),
    _NavItem(icon: Icons.home_work_outlined, activeIcon: Icons.home_work_rounded, label: 'Properties'),
    _NavItem(icon: Icons.people_outline, activeIcon: Icons.people_rounded, label: 'ভাড়াটিয়া'),
    _NavItem(icon: Icons.payments_outlined, activeIcon: Icons.payments_rounded, label: 'ভাড়া'),
    _NavItem(icon: Icons.campaign_outlined, activeIcon: Icons.campaign_rounded, label: 'নোটিশ'),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser!;

    final List<Widget> pages = [
      ChartScreen(scaffoldKey: _scaffoldKey),
      _PropertyPage(landlordId: user.uid, scaffoldKey: _scaffoldKey),
      TenantListScreen(scaffoldKey: _scaffoldKey),
      PaymentListScreen(scaffoldKey: _scaffoldKey),
      NoticeScreen(scaffoldKey: _scaffoldKey),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: _AppDrawer(user: user),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: _bottomItems.map((item) => NavigationDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.activeIcon),
          label: item.label,
        )).toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

// ── Drawer ──────────────────────────────────────────────────────────────────

class _AppDrawer extends StatelessWidget {
  final dynamic user;
  const _AppDrawer({required this.user});

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
                  // CircleAvatar(
                  //   radius: 32,
                  //   backgroundColor: Colors.white24,
                  //   child: Text(
                  //     user.name.isNotEmpty ? user.name[0].toUpperCase() : 'L',
                  //     style: const TextStyle(
                  //         fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  //   ),
                  // ),
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
                          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(user.email,
                      style: const TextStyle(fontSize: 13, color: Colors.white70)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('বাড়ীওয়ালা',
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
                  _DrawerItem(
                    icon: Icons.person_outline_rounded,
                    label: 'আমার প্রোফাইল',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => _LandlordProfileScreen(user: user),
                      ));
                    },
                  ),

                  const _DrawerDivider(label: 'অতিরিক্ত'),

                  _DrawerItem(
                    icon: Icons.build_outlined,
                    label: 'মেরামতের অনুরোধ',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const MaintenanceRequestsScreen(),
                      ));
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.electric_bolt_outlined,
                    label: 'ইউটিলিটি বিল',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const UtilityScreen(),
                      ));
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.archive_outlined,
                    label: 'আর্কাইভ',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const ArchiveScreen(),
                      ));
                    },
                  ),

                  const _DrawerDivider(label: 'অ্যাপ'),

                  // Chat or Message
                  _DrawerItem(
                    icon: Icons.chat_outlined,
                    label: 'Messages',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const ChatListScreen(),
                      ));
                    },
                  ),

                  // Rules
                  _DrawerItem(
                    icon: Icons.gavel_rounded,
                    label: 'নিয়মাবলী',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const RulesScreen(),
                      ));
                    },
                  ),

                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ));
                    },
                  ),

                  const SizedBox(height: 8),

                  // Logout
                  _DrawerItem(
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

            // App version
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
              onPressed: () => Navigator.pop(context),
              child: const Text('না')),
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

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _DrawerItem({
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
      title: Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w500)),
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
      child: Text(label.toUpperCase(),
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
              letterSpacing: 1)),
    );
  }
}

// ── Landlord Profile Screen ─────────────────────────────────────────────────

class _LandlordProfileScreen extends StatelessWidget {
  final dynamic user;
  const _LandlordProfileScreen({required this.user});

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
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'L',
                style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: color.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(user.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('বাড়ীওয়ালা',
                  style: TextStyle(color: color.primary, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 32),

            // Info cards
            _profileRow(context, Icons.email_outlined, 'Email', user.email),
            _profileRow(context, Icons.phone_outlined, 'Phone', user.phone),
            _profileRow(context, Icons.home_rounded, 'Role', 'Landlord'),

            const SizedBox(height: 32),

            // Logout button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AuthService>().logout();
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.red),
                label: const Text('Logout', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileRow(BuildContext context, IconData icon, String label, String value) {
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
                  style: TextStyle(fontSize: 12, color: color.onSurface.withOpacity(0.5))),
              Text(value,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Property Page ────────────────────────────────────────────────────────────

class _PropertyPage extends StatelessWidget {
  final String landlordId;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const _PropertyPage({required this.landlordId, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final service = PropertyService();
    final user = context.read<AuthService>().currentUser!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => scaffoldKey?.currentState?.openDrawer(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('স্বাগতম, ${user.name.split(' ')[0]}!',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Text('আপনার properties', style: TextStyle(fontSize: 11)),
          ],
        ),
      ),
      body: Column(
        children: [
          _SummarySection(landlordId: landlordId, service: service),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                const Text('আমার Properties',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<PropertyModel>>(
              stream: service.getProperties(landlordId),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final properties = snap.data ?? [];
                if (properties.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.home_work_outlined, size: 80,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        const Text('কোনো property নেই',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('নিচের বাটন দিয়ে property যোগ করুন'),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => AddEditPropertyScreen(landlordId: landlordId),
                          )),
                          icon: const Icon(Icons.add),
                          label: const Text('Property যোগ করুন'),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: properties.length,
                  itemBuilder: (ctx, i) => _PropertyCard(
                    property: properties[i],
                    service: service,
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => RoomListScreen(property: properties[i]),
                    )),
                    onEdit: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => AddEditPropertyScreen(
                          landlordId: landlordId, property: properties[i]),
                    )),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => AddEditPropertyScreen(landlordId: landlordId),
        )),
        icon: const Icon(Icons.add),
        label: const Text('Property যোগ করুন'),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final String landlordId;
  final PropertyService service;
  const _SummarySection({required this.landlordId, required this.service});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: service.getPropertySummary(landlordId),
      builder: (context, snap) {
        final data = snap.data ?? {};
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              _SummaryItem(icon: Icons.home_work_rounded, label: 'Properties', value: '${data['totalProperties'] ?? 0}'),
              _divider(),
              _SummaryItem(icon: Icons.door_front_door_rounded, label: 'মোট রুম', value: '${data['totalRooms'] ?? 0}'),
              _divider(),
              _SummaryItem(icon: Icons.people_rounded, label: 'ভাড়া দেওয়া', value: '${data['occupiedRooms'] ?? 0}'),
              _divider(),
              _SummaryItem(icon: Icons.door_back_door_outlined, label: 'খালি', value: '${data['vacantRooms'] ?? 0}'),
            ],
          ),
        );
      },
    );
  }

  Widget _divider() => Container(
    width: 1, height: 40, color: Colors.white24,
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _SummaryItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final PropertyModel property;
  final PropertyService service;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  const _PropertyCard({required this.property, required this.service, required this.onTap, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.home_work_rounded, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(property.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(property.address,
                        style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${property.totalRooms} টি রুম',
                          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                ],
                onSelected: (val) async {
                  if (val == 'edit') onEdit();
                  if (val == 'delete') await service.deleteProperty(property.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}