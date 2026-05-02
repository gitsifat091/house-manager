// // // // import 'package:flutter/material.dart';
// // // // import 'package:provider/provider.dart';
// // // // import '../../services/auth_service.dart';
// // // // import '../../services/property_service.dart';
// // // // import '../../models/property_model.dart';
// // // // import 'chart_screen.dart';
// // // // import 'add_edit_property_screen.dart';
// // // // import 'room_list_screen.dart';
// // // // import 'tenant_list_screen.dart';
// // // // import 'payment_list_screen.dart';
// // // // import 'notice_screen.dart';
// // // // import 'maintenance_requests_screen.dart';
// // // // import 'utility_screen.dart';
// // // // import 'archive_screen.dart';
// // // // import 'settings_screen.dart';
// // // // import '../../../widgets/profile_avatar.dart';
// // // // import 'rules_screen.dart';
// // // // import 'chat_list_screen.dart';
// // // // import '../community/community_chat_screen.dart';

// // // // class LandlordDashboard extends StatefulWidget {
// // // //   const LandlordDashboard({super.key});

// // // //   @override
// // // //   State<LandlordDashboard> createState() => _LandlordDashboardState();
// // // // }

// // // // class _LandlordDashboardState extends State<LandlordDashboard> {
// // // //   int _currentIndex = 0;

// // // //   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

// // // //   final List<_NavItem> _bottomItems = const [
// // // //     _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart_rounded, label: 'রিপোর্ট'),
// // // //     _NavItem(icon: Icons.home_work_outlined, activeIcon: Icons.home_work_rounded, label: 'Properties'),
// // // //     _NavItem(icon: Icons.people_outline, activeIcon: Icons.people_rounded, label: 'ভাড়াটিয়া'),
// // // //     _NavItem(icon: Icons.payments_outlined, activeIcon: Icons.payments_rounded, label: 'ভাড়া'),
// // // //     _NavItem(icon: Icons.campaign_outlined, activeIcon: Icons.campaign_rounded, label: 'নোটিশ'),
// // // //   ];

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final user = context.read<AuthService>().currentUser!;

// // // //     final List<Widget> pages = [
// // // //       ChartScreen(scaffoldKey: _scaffoldKey),
// // // //       _PropertyPage(landlordId: user.uid, scaffoldKey: _scaffoldKey),
// // // //       TenantListScreen(scaffoldKey: _scaffoldKey),
// // // //       PaymentListScreen(scaffoldKey: _scaffoldKey),
// // // //       NoticeScreen(scaffoldKey: _scaffoldKey),
// // // //     ];

// // // //     return Scaffold(
// // // //       key: _scaffoldKey,
// // // //       drawer: _AppDrawer(user: user),
// // // //       body: pages[_currentIndex],
// // // //       bottomNavigationBar: NavigationBar(
// // // //         selectedIndex: _currentIndex,
// // // //         onDestinationSelected: (i) => setState(() => _currentIndex = i),
// // // //         destinations: _bottomItems.map((item) => NavigationDestination(
// // // //           icon: Icon(item.icon),
// // // //           selectedIcon: Icon(item.activeIcon),
// // // //           label: item.label,
// // // //         )).toList(),
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // class _NavItem {
// // // //   final IconData icon;
// // // //   final IconData activeIcon;
// // // //   final String label;
// // // //   const _NavItem({required this.icon, required this.activeIcon, required this.label});
// // // // }

// // // // // ── Drawer ──────────────────────────────────────────────────────────────────

// // // // class _AppDrawer extends StatelessWidget {
// // // //   final dynamic user;
// // // //   const _AppDrawer({required this.user});

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final color = Theme.of(context).colorScheme;

// // // //     return Drawer(
// // // //       child: SafeArea(
// // // //         child: Column(
// // // //           children: [
// // // //             // Profile header
// // // //             Container(
// // // //               width: double.infinity,
// // // //               padding: const EdgeInsets.all(20),
// // // //               decoration: BoxDecoration(color: color.primary),
// // // //               child: Column(
// // // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // // //                 children: [
                  
// // // //                   Consumer<AuthService>(
// // // //                     builder: (context, auth, _) => ProfileAvatar(
// // // //                       name: auth.currentUser?.name ?? user.name,
// // // //                       photoUrl: auth.currentUser?.photoUrl,
// // // //                       userId: user.uid,
// // // //                       radius: 52,
// // // //                       editable: true,
// // // //                     ),
// // // //                   ),
// // // //                   const SizedBox(height: 12),
// // // //                   Text(user.name,
// // // //                       style: const TextStyle(
// // // //                           fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
// // // //                   Text(user.email,
// // // //                       style: const TextStyle(fontSize: 13, color: Colors.white70)),
// // // //                   const SizedBox(height: 4),
// // // //                   Container(
// // // //                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
// // // //                     decoration: BoxDecoration(
// // // //                       color: Colors.white24,
// // // //                       borderRadius: BorderRadius.circular(20),
// // // //                     ),
// // // //                     child: const Text('বাড়ীওয়ালা',
// // // //                         style: TextStyle(fontSize: 12, color: Colors.white)),
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //             ),

// // // //             Expanded(
// // // //               child: ListView(
// // // //                 padding: const EdgeInsets.symmetric(vertical: 8),
// // // //                 children: [
// // // //                   // My Profile
// // // //                   _DrawerItem(
// // // //                     icon: Icons.person_outline_rounded,
// // // //                     label: 'আমার প্রোফাইল',
// // // //                     onTap: () {
// // // //                       Navigator.pop(context);
// // // //                       Navigator.push(context, MaterialPageRoute(
// // // //                         builder: (_) => _LandlordProfileScreen(user: user),
// // // //                       ));
// // // //                     },
// // // //                   ),

// // // //                   const _DrawerDivider(label: 'অতিরিক্ত'),

// // // //                   _DrawerItem(
// // // //                     icon: Icons.build_outlined,
// // // //                     label: 'মেরামতের অনুরোধ',
// // // //                     onTap: () {
// // // //                       Navigator.pop(context);
// // // //                       Navigator.push(context, MaterialPageRoute(
// // // //                         builder: (_) => const MaintenanceRequestsScreen(),
// // // //                       ));
// // // //                     },
// // // //                   ),
// // // //                   _DrawerItem(
// // // //                     icon: Icons.electric_bolt_outlined,
// // // //                     label: 'ইউটিলিটি বিল',
// // // //                     onTap: () {
// // // //                       Navigator.pop(context);
// // // //                       Navigator.push(context, MaterialPageRoute(
// // // //                         builder: (_) => const UtilityScreen(),
// // // //                       ));
// // // //                     },
// // // //                   ),
// // // //                   _DrawerItem(
// // // //                     icon: Icons.archive_outlined,
// // // //                     label: 'আর্কাইভ',
// // // //                     onTap: () {
// // // //                       Navigator.pop(context);
// // // //                       Navigator.push(context, MaterialPageRoute(
// // // //                         builder: (_) => const ArchiveScreen(),
// // // //                       ));
// // // //                     },
// // // //                   ),

// // // //                   const _DrawerDivider(label: 'অ্যাপ'),

// // // //                   // Chat or Message
// // // //                   _DrawerItem(
// // // //                     icon: Icons.chat_outlined,
// // // //                     label: 'Messages',
// // // //                     onTap: () {
// // // //                       Navigator.pop(context);
// // // //                       Navigator.push(context, MaterialPageRoute(
// // // //                         builder: (_) => const ChatListScreen(),
// // // //                       ));
// // // //                     },
// // // //                   ),

// // // //                   // Rules
// // // //                   _DrawerItem(
// // // //                     icon: Icons.gavel_rounded,
// // // //                     label: 'নিয়মাবলী',
// // // //                     onTap: () {
// // // //                       Navigator.pop(context);
// // // //                       Navigator.push(context, MaterialPageRoute(
// // // //                         builder: (_) => const RulesScreen(),
// // // //                       ));
// // // //                     },
// // // //                   ),

// // // //                   _DrawerItem(
// // // //                     icon: Icons.settings_outlined,
// // // //                     label: 'Settings',
// // // //                     onTap: () {
// // // //                       Navigator.pop(context);
// // // //                       Navigator.push(context, MaterialPageRoute(
// // // //                         builder: (_) => const SettingsScreen(),
// // // //                       ));
// // // //                     },
// // // //                   ),

// // // //                   const SizedBox(height: 8),

// // // //                   // Logout
// // // //                   _DrawerItem(
// // // //                     icon: Icons.logout_rounded,
// // // //                     label: 'Logout',
// // // //                     color: Colors.red,
// // // //                     onTap: () {
// // // //                       Navigator.pop(context);
// // // //                       _confirmLogout(context);
// // // //                     },
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //             ),

// // // //             // App version
// // // //             Padding(
// // // //               padding: const EdgeInsets.all(16),
// // // //               child: Text('House Manager v1.0',
// // // //                   style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   void _confirmLogout(BuildContext context) {
// // // //     showDialog(
// // // //       context: context,
// // // //       builder: (_) => AlertDialog(
// // // //         title: const Text('Logout'),
// // // //         content: const Text('আপনি কি logout করতে চান?'),
// // // //         actions: [
// // // //           TextButton(
// // // //               onPressed: () => Navigator.pop(context),
// // // //               child: const Text('না')),
// // // //           FilledButton(
// // // //             onPressed: () {
// // // //               Navigator.pop(context);
// // // //               context.read<AuthService>().logout();
// // // //             },
// // // //             child: const Text('হ্যাঁ'),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // class _DrawerItem extends StatelessWidget {
// // // //   final IconData icon;
// // // //   final String label;
// // // //   final VoidCallback onTap;
// // // //   final Color? color;
// // // //   const _DrawerItem({
// // // //     required this.icon,
// // // //     required this.label,
// // // //     required this.onTap,
// // // //     this.color,
// // // //   });

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final c = color ?? Theme.of(context).colorScheme.onSurface;
// // // //     return ListTile(
// // // //       leading: Icon(icon, color: c, size: 22),
// // // //       title: Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w500)),
// // // //       onTap: onTap,
// // // //       horizontalTitleGap: 8,
// // // //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // // //       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
// // // //     );
// // // //   }
// // // // }

// // // // class _DrawerDivider extends StatelessWidget {
// // // //   final String label;
// // // //   const _DrawerDivider({required this.label});

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Padding(
// // // //       padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
// // // //       child: Text(label.toUpperCase(),
// // // //           style: TextStyle(
// // // //               fontSize: 11,
// // // //               fontWeight: FontWeight.bold,
// // // //               color: Colors.grey.shade500,
// // // //               letterSpacing: 1)),
// // // //     );
// // // //   }
// // // // }

// // // // // ── Landlord Profile Screen ─────────────────────────────────────────────────

// // // // class _InfoTile extends StatelessWidget {
// // // //   final IconData icon;
// // // //   final String label;
// // // //   final String value;
// // // //   final ColorScheme color;
// // // //   const _InfoTile({
// // // //     required this.icon,
// // // //     required this.label,
// // // //     required this.value,
// // // //     required this.color,
// // // //   });

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Container(
// // // //       padding: const EdgeInsets.all(16),
// // // //       decoration: BoxDecoration(
// // // //         color: color.surface,
// // // //         borderRadius: BorderRadius.circular(14),
// // // //         border: Border.all(color: color.outlineVariant.withOpacity(0.5)),
// // // //         boxShadow: [
// // // //           BoxShadow(
// // // //             color: Colors.black.withOpacity(0.03),
// // // //             blurRadius: 6,
// // // //             offset: const Offset(0, 2),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //       child: Row(
// // // //         children: [
// // // //           Container(
// // // //             padding: const EdgeInsets.all(10),
// // // //             decoration: BoxDecoration(
// // // //               color: color.primary.withOpacity(0.08),
// // // //               borderRadius: BorderRadius.circular(10),
// // // //             ),
// // // //             child: Icon(icon, color: color.primary, size: 20),
// // // //           ),
// // // //           const SizedBox(width: 14),
// // // //           Column(
// // // //             crossAxisAlignment: CrossAxisAlignment.start,
// // // //             children: [
// // // //               Text(label,
// // // //                   style: TextStyle(
// // // //                       fontSize: 11,
// // // //                       color: color.onSurface.withOpacity(0.5))),
// // // //               const SizedBox(height: 2),
// // // //               Text(value,
// // // //                   style: const TextStyle(
// // // //                       fontSize: 15, fontWeight: FontWeight.w600)),
// // // //             ],
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // class _LandlordProfileScreen extends StatelessWidget {
// // // //   final dynamic user;
// // // //   const _LandlordProfileScreen({required this.user});

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final color = Theme.of(context).colorScheme;
// // // //     return Scaffold(
// // // //       body: CustomScrollView(
// // // //         slivers: [
// // // //           SliverAppBar(
// // // //             expandedHeight: 220,
// // // //             pinned: true,
// // // //             backgroundColor: color.primary,
// // // //             iconTheme: const IconThemeData(color: Colors.white),
// // // //             title: const Text('আমার প্রোফাইল',
// // // //                 style: TextStyle(color: Colors.white, fontSize: 16)),
// // // //             flexibleSpace: FlexibleSpaceBar(
// // // //               background: Container(
// // // //                 decoration: BoxDecoration(
// // // //                   gradient: LinearGradient(
// // // //                     begin: Alignment.topLeft,
// // // //                     end: Alignment.bottomRight,
// // // //                     colors: [color.primary, color.primary.withOpacity(0.75)],
// // // //                   ),
// // // //                 ),
// // // //                 child: SafeArea(
// // // //                   child: Column(
// // // //                     mainAxisAlignment: MainAxisAlignment.center,
// // // //                     children: [
// // // //                       const SizedBox(height: 32),
// // // //                       Container(
// // // //                         padding: const EdgeInsets.all(3),
// // // //                         decoration: BoxDecoration(
// // // //                           shape: BoxShape.circle,
// // // //                           border: Border.all(color: Colors.white, width: 2.5),
// // // //                         ),
// // // //                         child: CircleAvatar(
// // // //                           radius: 44,
// // // //                           backgroundColor: Colors.white24,
// // // //                           child: Text(
// // // //                             user.name.isNotEmpty
// // // //                                 ? user.name[0].toUpperCase()
// // // //                                 : 'L',
// // // //                             style: const TextStyle(
// // // //                                 fontSize: 38,
// // // //                                 fontWeight: FontWeight.bold,
// // // //                                 color: Colors.white),
// // // //                           ),
// // // //                         ),
// // // //                       ),
// // // //                       const SizedBox(height: 10),
// // // //                       Text(user.name,
// // // //                           style: const TextStyle(
// // // //                               fontSize: 18,
// // // //                               fontWeight: FontWeight.bold,
// // // //                               color: Colors.white)),
// // // //                       const SizedBox(height: 5),
// // // //                       Container(
// // // //                         padding: const EdgeInsets.symmetric(
// // // //                             horizontal: 14, vertical: 4),
// // // //                         decoration: BoxDecoration(
// // // //                           color: Colors.white24,
// // // //                           borderRadius: BorderRadius.circular(20),
// // // //                         ),
// // // //                         child: const Text('বাড়ীওয়ালা',
// // // //                             style:
// // // //                                 TextStyle(fontSize: 12, color: Colors.white)),
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //           ),
// // // //           SliverToBoxAdapter(
// // // //             child: Padding(
// // // //               padding: const EdgeInsets.all(20),
// // // //               child: Column(
// // // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // // //                 children: [
// // // //                   Text('যোগাযোগের তথ্য',
// // // //                       style: TextStyle(
// // // //                           fontSize: 12,
// // // //                           fontWeight: FontWeight.bold,
// // // //                           color: color.primary,
// // // //                           letterSpacing: 0.5)),
// // // //                   const SizedBox(height: 10),
// // // //                   _InfoTile(
// // // //                     icon: Icons.email_outlined,
// // // //                     label: 'Email',
// // // //                     value: user.email,
// // // //                     color: color,
// // // //                   ),
// // // //                   const SizedBox(height: 10),
// // // //                   _InfoTile(
// // // //                     icon: Icons.phone_outlined,
// // // //                     label: 'Phone',
// // // //                     value: user.phone,
// // // //                     color: color,
// // // //                   ),
// // // //                   const SizedBox(height: 10),
// // // //                   _InfoTile(
// // // //                     icon: Icons.home_rounded,
// // // //                     label: 'Role',
// // // //                     value: 'Landlord',
// // // //                     color: color,
// // // //                   ),
// // // //                   const SizedBox(height: 32),
// // // //                   SizedBox(
// // // //                     width: double.infinity,
// // // //                     height: 50,
// // // //                     child: OutlinedButton.icon(
// // // //                       onPressed: () {
// // // //                         Navigator.pop(context);
// // // //                         context.read<AuthService>().logout();
// // // //                       },
// // // //                       icon: const Icon(Icons.logout_rounded,
// // // //                           color: Colors.red),
// // // //                       label: const Text('Logout',
// // // //                           style: TextStyle(
// // // //                               color: Colors.red,
// // // //                               fontWeight: FontWeight.w600)),
// // // //                       style: OutlinedButton.styleFrom(
// // // //                         side: const BorderSide(color: Colors.red),
// // // //                         shape: RoundedRectangleBorder(
// // // //                             borderRadius: BorderRadius.circular(14)),
// // // //                       ),
// // // //                     ),
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // // class _LandlordProfileScreen extends StatelessWidget {
// // // // //   final dynamic user;
// // // // //   const _LandlordProfileScreen({required this.user});

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     final color = Theme.of(context).colorScheme;
// // // // //     return Scaffold(
// // // // //       appBar: AppBar(title: const Text('আমার প্রোফাইল'), centerTitle: true),
// // // // //       body: SingleChildScrollView(
// // // // //         padding: const EdgeInsets.all(24),
// // // // //         child: Column(
// // // // //           children: [
// // // // //             const SizedBox(height: 16),
// // // // //             CircleAvatar(
// // // // //               radius: 52,
// // // // //               backgroundColor: color.primaryContainer,
// // // // //               child: Text(
// // // // //                 user.name.isNotEmpty ? user.name[0].toUpperCase() : 'L',
// // // // //                 style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: color.primary),
// // // // //               ),
// // // // //             ),
// // // // //             const SizedBox(height: 16),
// // // // //             Text(user.name,
// // // // //                 style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
// // // // //             const SizedBox(height: 4),
// // // // //             Container(
// // // // //               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
// // // // //               decoration: BoxDecoration(
// // // // //                 color: color.primaryContainer,
// // // // //                 borderRadius: BorderRadius.circular(20),
// // // // //               ),
// // // // //               child: Text('বাড়ীওয়ালা',
// // // // //                   style: TextStyle(color: color.primary, fontWeight: FontWeight.w500)),
// // // // //             ),
// // // // //             const SizedBox(height: 32),

// // // // //             // Info cards
// // // // //             _profileRow(context, Icons.email_outlined, 'Email', user.email),
// // // // //             _profileRow(context, Icons.phone_outlined, 'Phone', user.phone),
// // // // //             _profileRow(context, Icons.home_rounded, 'Role', 'Landlord'),

// // // // //             const SizedBox(height: 32),

// // // // //             // Logout button
// // // // //             SizedBox(
// // // // //               width: double.infinity,
// // // // //               height: 50,
// // // // //               child: OutlinedButton.icon(
// // // // //                 onPressed: () {
// // // // //                   Navigator.pop(context);
// // // // //                   context.read<AuthService>().logout();
// // // // //                 },
// // // // //                 icon: const Icon(Icons.logout_rounded, color: Colors.red),
// // // // //                 label: const Text('Logout', style: TextStyle(color: Colors.red)),
// // // // //                 style: OutlinedButton.styleFrom(
// // // // //                   side: const BorderSide(color: Colors.red),
// // // // //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
// // // // //                 ),
// // // // //               ),
// // // // //             ),
// // // // //           ],
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   Widget _profileRow(BuildContext context, IconData icon, String label, String value) {
// // // // //     final color = Theme.of(context).colorScheme;
// // // // //     return Container(
// // // // //       margin: const EdgeInsets.only(bottom: 12),
// // // // //       padding: const EdgeInsets.all(16),
// // // // //       decoration: BoxDecoration(
// // // // //         color: color.surface,
// // // // //         borderRadius: BorderRadius.circular(14),
// // // // //         border: Border.all(color: color.outlineVariant),
// // // // //       ),
// // // // //       child: Row(
// // // // //         children: [
// // // // //           Icon(icon, color: color.primary, size: 22),
// // // // //           const SizedBox(width: 14),
// // // // //           Column(
// // // // //             crossAxisAlignment: CrossAxisAlignment.start,
// // // // //             children: [
// // // // //               Text(label,
// // // // //                   style: TextStyle(fontSize: 12, color: color.onSurface.withOpacity(0.5))),
// // // // //               Text(value,
// // // // //                   style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
// // // // //             ],
// // // // //           ),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // // ── Property Page ────────────────────────────────────────────────────────────

// // // // class _PropertyPage extends StatelessWidget {
// // // //   final String landlordId;
// // // //   final GlobalKey<ScaffoldState>? scaffoldKey;
// // // //   const _PropertyPage({required this.landlordId, this.scaffoldKey});

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final service = PropertyService();
// // // //     final user = context.read<AuthService>().currentUser!;

// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         leading: IconButton(
// // // //           icon: const Icon(Icons.menu_rounded),
// // // //           onPressed: () => scaffoldKey?.currentState?.openDrawer(),
// // // //         ),
// // // //         title: Column(
// // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // //           children: [
// // // //             Text('স্বাগতম, ${user.name.split(' ')[0]}!',
// // // //                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
// // // //             const Text('আপনার properties', style: TextStyle(fontSize: 11)),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //       body: Column(
// // // //         children: [
// // // //           _SummarySection(landlordId: landlordId, service: service),
// // // //           Padding(
// // // //             padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
// // // //             child: Row(
// // // //               children: [
// // // //                 const Text('আমার Properties',
// // // //                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
// // // //                 const Spacer(),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //           Expanded(
// // // //             child: StreamBuilder<List<PropertyModel>>(
// // // //               stream: service.getProperties(landlordId),
// // // //               builder: (context, snap) {
// // // //                 if (snap.connectionState == ConnectionState.waiting) {
// // // //                   return const Center(child: CircularProgressIndicator());
// // // //                 }
// // // //                 final properties = snap.data ?? [];
// // // //                 if (properties.isEmpty) {
// // // //                   return Center(
// // // //                     child: Column(
// // // //                       mainAxisSize: MainAxisSize.min,
// // // //                       children: [
// // // //                         Icon(Icons.home_work_outlined, size: 80,
// // // //                             color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
// // // //                         const SizedBox(height: 16),
// // // //                         const Text('কোনো property নেই',
// // // //                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // //                         const SizedBox(height: 8),
// // // //                         const Text('নিচের বাটন দিয়ে property যোগ করুন'),
// // // //                         const SizedBox(height: 20),
// // // //                         FilledButton.icon(
// // // //                           onPressed: () => Navigator.push(context, MaterialPageRoute(
// // // //                             builder: (_) => AddEditPropertyScreen(landlordId: landlordId),
// // // //                           )),
// // // //                           icon: const Icon(Icons.add),
// // // //                           label: const Text('Property যোগ করুন'),
// // // //                         ),
// // // //                       ],
// // // //                     ),
// // // //                   );
// // // //                 }
// // // //                 return ListView.builder(
// // // //                   padding: const EdgeInsets.symmetric(horizontal: 16),
// // // //                   itemCount: properties.length,
// // // //                   itemBuilder: (ctx, i) => _PropertyCard(
// // // //                     property: properties[i],
// // // //                     service: service,
// // // //                     onTap: () => Navigator.push(context, MaterialPageRoute(
// // // //                       builder: (_) => RoomListScreen(property: properties[i]),
// // // //                     )),
// // // //                     onEdit: () => Navigator.push(context, MaterialPageRoute(
// // // //                       builder: (_) => AddEditPropertyScreen(
// // // //                           landlordId: landlordId, property: properties[i]),
// // // //                     )),
// // // //                   ),
// // // //                 );
// // // //               },
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //       floatingActionButton: FloatingActionButton.extended(
// // // //         onPressed: () => Navigator.push(context, MaterialPageRoute(
// // // //           builder: (_) => AddEditPropertyScreen(landlordId: landlordId),
// // // //         )),
// // // //         icon: const Icon(Icons.add),
// // // //         label: const Text('Property যোগ করুন'),
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // class _SummarySection extends StatelessWidget {
// // // //   final String landlordId;
// // // //   final PropertyService service;
// // // //   const _SummarySection({required this.landlordId, required this.service});

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return FutureBuilder<Map<String, int>>(
// // // //       future: service.getPropertySummary(landlordId),
// // // //       builder: (context, snap) {
// // // //         final data = snap.data ?? {};
// // // //         return Container(
// // // //           margin: const EdgeInsets.all(16),
// // // //           padding: const EdgeInsets.all(16),
// // // //           decoration: BoxDecoration(
// // // //             color: Theme.of(context).colorScheme.primary,
// // // //             borderRadius: BorderRadius.circular(20),
// // // //           ),
// // // //           child: Row(
// // // //             children: [
// // // //               _SummaryItem(icon: Icons.home_work_rounded, label: 'Properties', value: '${data['totalProperties'] ?? 0}'),
// // // //               _divider(),
// // // //               _SummaryItem(icon: Icons.door_front_door_rounded, label: 'মোট রুম', value: '${data['totalRooms'] ?? 0}'),
// // // //               _divider(),
// // // //               _SummaryItem(icon: Icons.people_rounded, label: 'ভাড়া দেওয়া', value: '${data['occupiedRooms'] ?? 0}'),
// // // //               _divider(),
// // // //               _SummaryItem(icon: Icons.door_back_door_outlined, label: 'খালি', value: '${data['vacantRooms'] ?? 0}'),
// // // //             ],
// // // //           ),
// // // //         );
// // // //       },
// // // //     );
// // // //   }

// // // //   Widget _divider() => Container(
// // // //     width: 1, height: 40, color: Colors.white24,
// // // //     margin: const EdgeInsets.symmetric(horizontal: 8),
// // // //   );
// // // // }

// // // // class _SummaryItem extends StatelessWidget {
// // // //   final IconData icon;
// // // //   final String label;
// // // //   final String value;
// // // //   const _SummaryItem({required this.icon, required this.label, required this.value});

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Expanded(
// // // //       child: Column(
// // // //         children: [
// // // //           Icon(icon, color: Colors.white, size: 22),
// // // //           const SizedBox(height: 4),
// // // //           Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
// // // //           Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // class _PropertyCard extends StatelessWidget {
// // // //   final PropertyModel property;
// // // //   final PropertyService service;
// // // //   final VoidCallback onTap;
// // // //   final VoidCallback onEdit;
// // // //   const _PropertyCard({required this.property, required this.service, required this.onTap, required this.onEdit});

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Card(
// // // //       margin: const EdgeInsets.only(bottom: 12),
// // // //       child: InkWell(
// // // //         onTap: onTap,
// // // //         borderRadius: BorderRadius.circular(16),
// // // //         child: Padding(
// // // //           padding: const EdgeInsets.all(16),
// // // //           child: Row(
// // // //             children: [
// // // //               Container(
// // // //                 width: 52, height: 52,
// // // //                 decoration: BoxDecoration(
// // // //                   color: Theme.of(context).colorScheme.primaryContainer,
// // // //                   borderRadius: BorderRadius.circular(14),
// // // //                 ),
// // // //                 child: Icon(Icons.home_work_rounded, color: Theme.of(context).colorScheme.primary),
// // // //               ),
// // // //               const SizedBox(width: 14),
// // // //               Expanded(
// // // //                 child: Column(
// // // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // // //                   children: [
// // // //                     Text(property.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
// // // //                     Text(property.address,
// // // //                         style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
// // // //                     const SizedBox(height: 6),
// // // //                     Container(
// // // //                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
// // // //                       decoration: BoxDecoration(
// // // //                         color: Theme.of(context).colorScheme.primaryContainer,
// // // //                         borderRadius: BorderRadius.circular(20),
// // // //                       ),
// // // //                       child: Text('${property.totalRooms} টি রুম',
// // // //                           style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500)),
// // // //                     ),
// // // //                   ],
// // // //                 ),
// // // //               ),

// // // //               // Row এর children এ, PopupMenuButton এর আগে:
// // // //               IconButton(
// // // //                 icon: const Icon(Icons.forum_outlined, color: Colors.indigo),
// // // //                 tooltip: 'Community Chat',
// // // //                 onPressed: () => Navigator.push(
// // // //                   context,
// // // //                   MaterialPageRoute(
// // // //                     builder: (_) => CommunityChatScreen(
// // // //                       propertyId: property.id,
// // // //                       propertyName: property.name,
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //               ),

// // // //               PopupMenuButton(
// // // //                 itemBuilder: (_) => [
// // // //                   const PopupMenuItem(value: 'edit', child: Text('Edit')),
// // // //                   const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
// // // //                 ],
// // // //                 onSelected: (val) async {
// // // //                   if (val == 'edit') onEdit();
// // // //                   if (val == 'delete') await service.deleteProperty(property.id);
// // // //                 },
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }







// // // import 'package:flutter/material.dart';
// // // import 'package:provider/provider.dart';
// // // import '../../services/auth_service.dart';
// // // import '../../services/property_service.dart';
// // // import '../../models/property_model.dart';
// // // import 'chart_screen.dart';
// // // import 'add_edit_property_screen.dart';
// // // import 'room_list_screen.dart';
// // // import 'tenant_list_screen.dart';
// // // import 'payment_list_screen.dart';
// // // import 'notice_screen.dart';
// // // import 'maintenance_requests_screen.dart';
// // // import 'utility_screen.dart';
// // // import 'archive_screen.dart';
// // // import 'settings_screen.dart';
// // // import '../../../widgets/profile_avatar.dart';
// // // import 'rules_screen.dart';
// // // import 'chat_list_screen.dart';
// // // import '../community/community_chat_screen.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';

// // // class LandlordDashboard extends StatefulWidget {
// // //   const LandlordDashboard({super.key});

// // //   @override
// // //   State<LandlordDashboard> createState() => _LandlordDashboardState();
// // // }

// // // class _LandlordDashboardState extends State<LandlordDashboard> {
// // //   int _currentIndex = 0;
// // //   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

// // //   // Landlord Dashboard - Tab
// // //   final List<_NavItem> _bottomItems = const [
// // //     _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart_rounded, label: 'রিপোর্ট'),
// // //     _NavItem(icon: Icons.home_work_outlined, activeIcon: Icons.home_work_rounded, label: 'Properties'),
// // //     _NavItem(icon: Icons.people_outline, activeIcon: Icons.people_rounded, label: 'ভাড়াটিয়া'),
// // //     _NavItem(icon: Icons.payments_outlined, activeIcon: Icons.payments_rounded, label: 'ভাড়া'),
// // //     // _NavItem(icon: Icons.campaign_outlined, activeIcon: Icons.campaign_rounded, label: 'নোটিশ'),
// // //     _NavItem(icon: Icons.electric_bolt_outlined, activeIcon: Icons.electric_bolt_rounded, label: 'ইউটিলিটি'),
// // //   ];

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final user = context.read<AuthService>().currentUser!;

// // //     // Page List
// // //     final List<Widget> pages = [
// // //       ChartScreen(scaffoldKey: _scaffoldKey),
// // //       _PropertyPage(landlordId: user.uid, scaffoldKey: _scaffoldKey),
// // //       TenantListScreen(scaffoldKey: _scaffoldKey),
// // //       PaymentListScreen(scaffoldKey: _scaffoldKey),
// // //       // NoticeScreen(scaffoldKey: _scaffoldKey),
// // //       // UtilityScreen(scaffoldKey: _scaffoldKey),
// // //       // const UtilityScreen()
// // //       UtilityScreen(scaffoldKey: _scaffoldKey)
// // //     ];

// // //     return Scaffold(
// // //       key: _scaffoldKey,
// // //       drawer: _AppDrawer(user: user),
// // //       body: pages[_currentIndex],
// // //       bottomNavigationBar: NavigationBar(
// // //         selectedIndex: _currentIndex,
// // //         onDestinationSelected: (i) => setState(() => _currentIndex = i),
// // //         destinations: _bottomItems.map((item) => NavigationDestination(
// // //           icon: Icon(item.icon),
// // //           selectedIcon: Icon(item.activeIcon),
// // //           label: item.label,
// // //         )).toList(),
// // //       ),
// // //     );
// // //   }
// // // }

// // // class _NavItem {
// // //   final IconData icon;
// // //   final IconData activeIcon;
// // //   final String label;
// // //   const _NavItem({required this.icon, required this.activeIcon, required this.label});
// // // }

// // // // ── Drawer ───────────────────────────────────────────────────────────────────

// // // class _AppDrawer extends StatelessWidget {
// // //   final dynamic user;
// // //   const _AppDrawer({required this.user});

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final primary = Theme.of(context).colorScheme.primary;
// // //     final isDark = Theme.of(context).brightness == Brightness.dark;
// // //     final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
// // //     final textSecondary = isDark ? Colors.white38 : const Color(0xFF9CA3AF);

// // //     return Drawer(
// // //       backgroundColor: bg,
// // //       child: Column(
// // //         children: [
// // //           // ── Profile Header ──────────────────────────
// // //           _DrawerHeader(user: user, primary: primary, isDark: isDark),

// // //           // ── Menu Items ──────────────────────────────
// // //           Expanded(
// // //             child: ListView(
// // //               padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
// // //               children: [
// // //                 _DrawerTile(
// // //                   icon: Icons.person_outline_rounded,
// // //                   iconBg: primary,
// // //                   label: 'আমার প্রোফাইল',
// // //                   onTap: () {
// // //                     Navigator.pop(context);
// // //                     Navigator.push(context, MaterialPageRoute(
// // //                       builder: (_) => _LandlordProfileScreen(user: user),
// // //                     ));
// // //                   },
// // //                 ),

// // //                 _DrawerSectionLabel('অতিরিক্ত', textSecondary),

// // //                 _DrawerTile(
// // //                   icon: Icons.build_outlined,
// // //                   iconBg: const Color(0xFFD97706),
// // //                   label: 'মেরামতের অনুরোধ',
// // //                   onTap: () {
// // //                     Navigator.pop(context);
// // //                     Navigator.push(context, MaterialPageRoute(
// // //                       builder: (_) => const MaintenanceRequestsScreen(),
// // //                     ));
// // //                   },
// // //                 ),

// // //                 // _DrawerTile(
// // //                 //   icon: Icons.electric_bolt_outlined,
// // //                 //   iconBg: const Color(0xFF0891B2),
// // //                 //   label: 'ইউটিলিটি বিল',
// // //                 //   onTap: () {
// // //                 //     Navigator.pop(context);
// // //                 //     Navigator.push(context, MaterialPageRoute(
// // //                 //       builder: (_) => const UtilityScreen(),
// // //                 //     ));
// // //                 //   },
// // //                 // ),

// // //                 // App Drawer e Notice board
// // //                 _DrawerTile(
// // //                   icon: Icons.campaign_outlined,
// // //                   iconBg: const Color(0xFF059669),
// // //                   label: 'নোটিশ বোর্ড',
// // //                   onTap: () {
// // //                     Navigator.pop(context);
// // //                     Navigator.push(context, MaterialPageRoute(
// // //                       builder: (_) => const NoticeScreen(),
// // //                     ));
// // //                   },
// // //                 ),

// // //                 _DrawerTile(
// // //                   icon: Icons.archive_outlined,
// // //                   iconBg: const Color(0xFF6B7280),
// // //                   label: 'আর্কাইভ',
// // //                   onTap: () {
// // //                     Navigator.pop(context);
// // //                     Navigator.push(context, MaterialPageRoute(
// // //                       builder: (_) => const ArchiveScreen(),
// // //                     ));
// // //                   },
// // //                 ),

// // //                 _DrawerSectionLabel('অ্যাপ', textSecondary),

// // //                 _DrawerTile(
// // //                   icon: Icons.chat_bubble_outline_rounded,
// // //                   iconBg: const Color(0xFF7C3AED),
// // //                   label: 'Messages',
// // //                   onTap: () {
// // //                     Navigator.pop(context);
// // //                     Navigator.push(context, MaterialPageRoute(
// // //                       builder: (_) => const ChatListScreen(),
// // //                     ));
// // //                   },
// // //                 ),
// // //                 _DrawerTile(
// // //                   icon: Icons.gavel_rounded,
// // //                   iconBg: const Color(0xFF059669),
// // //                   label: 'নিয়মাবলী',
// // //                   onTap: () {
// // //                     Navigator.pop(context);
// // //                     Navigator.push(context, MaterialPageRoute(
// // //                       builder: (_) => const RulesScreen(),
// // //                     ));
// // //                   },
// // //                 ),
// // //                 _DrawerTile(
// // //                   icon: Icons.settings_outlined,
// // //                   iconBg: const Color(0xFF374151),
// // //                   label: 'Settings',
// // //                   onTap: () {
// // //                     Navigator.pop(context);
// // //                     Navigator.push(context, MaterialPageRoute(
// // //                       builder: (_) => const SettingsScreen(),
// // //                     ));
// // //                   },
// // //                 ),
// // //               ],
// // //             ),
// // //           ),

// // //           // ── Logout + Version ────────────────────────
// // //           _DrawerFooter(onLogout: () {
// // //             // Navigator.pop(context);
// // //             _confirmLogout(context);
// // //           }),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   // void _confirmLogout(BuildContext context) {
// // //   //   showDialog(
// // //   //     context: context,
// // //   //     builder: (_) => AlertDialog(
// // //   //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// // //   //       title: const Text('Logout করবেন?',
// // //   //           style: TextStyle(fontWeight: FontWeight.w700)),
// // //   //       content: const Text('আপনি কি নিশ্চিতভাবে logout করতে চান?'),
// // //   //       actions: [
// // //   //         TextButton(
// // //   //             onPressed: () => Navigator.pop(context),
// // //   //             child: const Text('না')),
// // //   //         FilledButton(
// // //   //           onPressed: () {
// // //   //             Navigator.pop(context);
// // //   //             context.read<AuthService>().logout();
// // //   //           },
// // //   //           child: const Text('হ্যাঁ, Logout'),
// // //   //         ),
// // //   //       ],
// // //   //     ),
// // //   //   );
// // //   // }

// // //   // _confirmLogout method:
// // //   void _confirmLogout(BuildContext context) {
// // //     showDialog(
// // //       context: context,
// // //       builder: (_) => AlertDialog(
// // //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// // //         title: const Text('Logout করবেন?',
// // //             style: TextStyle(fontWeight: FontWeight.w700)),
// // //         content: const Text('আপনি কি নিশ্চিতভাবে logout করতে চান?'),
// // //         actions: [
// // //           TextButton(
// // //               onPressed: () => Navigator.pop(context),
// // //               child: const Text('না')),
// // //           FilledButton(
// // //             onPressed: () {
// // //               Navigator.pop(context); // dialog বন্ধ
// // //               Navigator.pop(context); // drawer বন্ধ
// // //               context.read<AuthService>().logout();
// // //             },
// // //             child: const Text('হ্যাঁ, Logout'),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }

// // // // ── Shared Drawer Widgets ─────────────────────────────────────────────────────

// // // class _DrawerHeader extends StatelessWidget {
// // //   final dynamic user;
// // //   final Color primary;
// // //   final bool isDark;
// // //   const _DrawerHeader({required this.user, required this.primary, required this.isDark});

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Container(
// // //       width: double.infinity,
// // //       decoration: BoxDecoration(
// // //         gradient: LinearGradient(
// // //           begin: Alignment.topLeft,
// // //           end: Alignment.bottomRight,
// // //           colors: isDark
// // //               ? [const Color(0xFF1A3328), const Color(0xFF0F2018)]
// // //               : [primary, primary.withOpacity(0.8)],
// // //         ),
// // //       ),
// // //       child: SafeArea(
// // //         bottom: false,
// // //         child: Padding(
// // //           padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
// // //           child: Column(
// // //             crossAxisAlignment: CrossAxisAlignment.start,
// // //             children: [
// // //               // Avatar with camera icon
// // //               Consumer<AuthService>(
// // //                 builder: (context, auth, _) => ProfileAvatar(
// // //                   name: auth.currentUser?.name ?? user.name,
// // //                   photoUrl: auth.currentUser?.photoUrl,
// // //                   userId: user.uid,
// // //                   radius: 36,
// // //                   editable: true,
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 14),
// // //               Text(
// // //                 user.name,
// // //                 style: const TextStyle(
// // //                   fontSize: 18,
// // //                   fontWeight: FontWeight.w700,
// // //                   color: Colors.white,
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 3),
// // //               Text(
// // //                 user.email,
// // //                 style: const TextStyle(fontSize: 12, color: Colors.white60),
// // //                 maxLines: 1,
// // //                 overflow: TextOverflow.ellipsis,
// // //               ),
// // //               const SizedBox(height: 10),
// // //               Container(
// // //                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
// // //                 decoration: BoxDecoration(
// // //                   color: Colors.white.withOpacity(0.2),
// // //                   borderRadius: BorderRadius.circular(20),
// // //                   border: Border.all(color: Colors.white30, width: 1),
// // //                 ),
// // //                 child: const Text(
// // //                   'বাড়ীওয়ালা',
// // //                   style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }

// // // class _DrawerTile extends StatelessWidget {
// // //   final IconData icon;
// // //   final Color iconBg;
// // //   final String label;
// // //   final VoidCallback onTap;
// // //   const _DrawerTile({
// // //     required this.icon,
// // //     required this.iconBg,
// // //     required this.label,
// // //     required this.onTap,
// // //   });

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final isDark = Theme.of(context).brightness == Brightness.dark;
// // //     final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

// // //     return Padding(
// // //       padding: const EdgeInsets.only(bottom: 2),
// // //       child: Material(
// // //         color: Colors.transparent,
// // //         borderRadius: BorderRadius.circular(12),
// // //         child: InkWell(
// // //           onTap: onTap,
// // //           borderRadius: BorderRadius.circular(12),
// // //           child: Padding(
// // //             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// // //             child: Row(
// // //               children: [
// // //                 Container(
// // //                   width: 38,
// // //                   height: 38,
// // //                   decoration: BoxDecoration(
// // //                     color: iconBg,
// // //                     borderRadius: BorderRadius.circular(10),
// // //                   ),
// // //                   child: Icon(icon, color: Colors.white, size: 19),
// // //                 ),
// // //                 const SizedBox(width: 14),
// // //                 Text(
// // //                   label,
// // //                   style: TextStyle(
// // //                     color: textColor,
// // //                     fontSize: 14,
// // //                     fontWeight: FontWeight.w500,
// // //                   ),
// // //                 ),
// // //                 const Spacer(),
// // //                 Icon(Icons.chevron_right_rounded,
// // //                     color: isDark ? Colors.white24 : Colors.black12, size: 18),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }

// // // class _DrawerSectionLabel extends StatelessWidget {
// // //   final String label;
// // //   final Color color;
// // //   const _DrawerSectionLabel(this.label, this.color);

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Padding(
// // //       padding: const EdgeInsets.fromLTRB(12, 16, 12, 6),
// // //       child: Text(
// // //         label.toUpperCase(),
// // //         style: TextStyle(
// // //           fontSize: 10,
// // //           fontWeight: FontWeight.w700,
// // //           color: color,
// // //           letterSpacing: 1.2,
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }

// // // class _DrawerFooter extends StatelessWidget {
// // //   final VoidCallback onLogout;
// // //   const _DrawerFooter({required this.onLogout});

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final isDark = Theme.of(context).brightness == Brightness.dark;
// // //     return Container(
// // //       padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
// // //       decoration: BoxDecoration(
// // //         border: Border(
// // //           top: BorderSide(
// // //             color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
// // //             width: 1,
// // //           ),
// // //         ),
// // //       ),
// // //       child: Column(
// // //         children: [
// // //           Material(
// // //             color: Colors.transparent,
// // //             borderRadius: BorderRadius.circular(12),
// // //             child: InkWell(
// // //               onTap: onLogout,
// // //               borderRadius: BorderRadius.circular(12),
// // //               child: Padding(
// // //                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// // //                 child: Row(
// // //                   children: [
// // //                     Container(
// // //                       width: 38,
// // //                       height: 38,
// // //                       decoration: BoxDecoration(
// // //                         color: Colors.red.withOpacity(0.1),
// // //                         borderRadius: BorderRadius.circular(10),
// // //                         border: Border.all(color: Colors.red.withOpacity(0.2)),
// // //                       ),
// // //                       child: const Icon(Icons.logout_rounded, color: Colors.red, size: 19),
// // //                     ),
// // //                     const SizedBox(width: 14),
// // //                     const Text(
// // //                       'Logout',
// // //                       style: TextStyle(
// // //                         color: Colors.red,
// // //                         fontSize: 14,
// // //                         fontWeight: FontWeight.w600,
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),
// // //             ),
// // //           ),
// // //           const SizedBox(height: 8),
// // //           Text(
// // //             'House Manager v1.0.0',
// // //             style: TextStyle(
// // //               fontSize: 11,
// // //               color: isDark ? Colors.white24 : Colors.grey.shade400,
// // //             ),
// // //           ),
// // //           const SizedBox(height: 4),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }

// // // // ── Landlord Profile Screen ───────────────────────────────────────────────────

// // // class _InfoTile extends StatelessWidget {
// // //   final IconData icon;
// // //   final String label;
// // //   final String value;
// // //   final ColorScheme color;
// // //   const _InfoTile({
// // //     required this.icon,
// // //     required this.label,
// // //     required this.value,
// // //     required this.color,
// // //   });

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Container(
// // //       padding: const EdgeInsets.all(16),
// // //       decoration: BoxDecoration(
// // //         color: color.surface,
// // //         borderRadius: BorderRadius.circular(14),
// // //         border: Border.all(color: color.outlineVariant.withOpacity(0.5)),
// // //         boxShadow: [
// // //           BoxShadow(
// // //             color: Colors.black.withOpacity(0.03),
// // //             blurRadius: 6,
// // //             offset: const Offset(0, 2),
// // //           ),
// // //         ],
// // //       ),
// // //       child: Row(
// // //         children: [
// // //           Container(
// // //             padding: const EdgeInsets.all(10),
// // //             decoration: BoxDecoration(
// // //               color: color.primary.withOpacity(0.08),
// // //               borderRadius: BorderRadius.circular(10),
// // //             ),
// // //             child: Icon(icon, color: color.primary, size: 20),
// // //           ),
// // //           const SizedBox(width: 14),
// // //           Column(
// // //             crossAxisAlignment: CrossAxisAlignment.start,
// // //             children: [
// // //               Text(label,
// // //                   style: TextStyle(fontSize: 11, color: color.onSurface.withOpacity(0.5))),
// // //               const SizedBox(height: 2),
// // //               Text(value,
// // //                   style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
// // //             ],
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }

// // // class _LandlordProfileScreen extends StatelessWidget {
// // //   final dynamic user;
// // //   const _LandlordProfileScreen({required this.user});

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final color = Theme.of(context).colorScheme;
// // //     return Scaffold(
// // //       body: CustomScrollView(
// // //         slivers: [
// // //           SliverAppBar(
// // //             expandedHeight: 220,
// // //             pinned: true,
// // //             backgroundColor: color.primary,
// // //             iconTheme: const IconThemeData(color: Colors.white),
// // //             title: const Text('আমার প্রোফাইল',
// // //                 style: TextStyle(color: Colors.white, fontSize: 16)),
// // //             flexibleSpace: FlexibleSpaceBar(
// // //               background: Container(
// // //                 decoration: BoxDecoration(
// // //                   gradient: LinearGradient(
// // //                     begin: Alignment.topLeft,
// // //                     end: Alignment.bottomRight,
// // //                     colors: [color.primary, color.primary.withOpacity(0.75)],
// // //                   ),
// // //                 ),
// // //                 child: SafeArea(
// // //                   child: Column(
// // //                     mainAxisAlignment: MainAxisAlignment.center,
// // //                     children: [
// // //                       const SizedBox(height: 32),
// // //                       Container(
// // //                         padding: const EdgeInsets.all(3),
// // //                         decoration: BoxDecoration(
// // //                           shape: BoxShape.circle,
// // //                           border: Border.all(color: Colors.white, width: 2.5),
// // //                         ),
// // //                         child: CircleAvatar(
// // //                           radius: 44,
// // //                           backgroundColor: Colors.white24,
// // //                           child: Text(
// // //                             user.name.isNotEmpty ? user.name[0].toUpperCase() : 'L',
// // //                             style: const TextStyle(
// // //                                 fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white),
// // //                           ),
// // //                         ),
// // //                       ),
// // //                       const SizedBox(height: 10),
// // //                       Text(user.name,
// // //                           style: const TextStyle(
// // //                               fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
// // //                       const SizedBox(height: 5),
// // //                       Container(
// // //                         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
// // //                         decoration: BoxDecoration(
// // //                           color: Colors.white24,
// // //                           borderRadius: BorderRadius.circular(20),
// // //                         ),
// // //                         child: const Text('বাড়ীওয়ালা',
// // //                             style: TextStyle(fontSize: 12, color: Colors.white)),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //               ),
// // //             ),
// // //           ),
// // //           SliverToBoxAdapter(
// // //             child: Padding(
// // //               padding: const EdgeInsets.all(20),
// // //               child: Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                 children: [
// // //                   Text('যোগাযোগের তথ্য',
// // //                       style: TextStyle(
// // //                           fontSize: 12,
// // //                           fontWeight: FontWeight.bold,
// // //                           color: color.primary,
// // //                           letterSpacing: 0.5)),
// // //                   const SizedBox(height: 10),
// // //                   _InfoTile(icon: Icons.email_outlined, label: 'Email', value: user.email, color: color),
// // //                   const SizedBox(height: 10),
// // //                   _InfoTile(icon: Icons.phone_outlined, label: 'Phone', value: user.phone, color: color),
// // //                   const SizedBox(height: 10),
// // //                   _InfoTile(icon: Icons.home_rounded, label: 'Role', value: 'Landlord', color: color),
// // //                   const SizedBox(height: 32),
// // //                   SizedBox(
// // //                     width: double.infinity,
// // //                     height: 50,
// // //                     child: OutlinedButton.icon(
// // //                       onPressed: () {
// // //                         Navigator.pop(context);
// // //                         context.read<AuthService>().logout();
// // //                       },
// // //                       icon: const Icon(Icons.logout_rounded, color: Colors.red),
// // //                       label: const Text('Logout',
// // //                           style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
// // //                       style: OutlinedButton.styleFrom(
// // //                         side: const BorderSide(color: Colors.red),
// // //                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }


// // // // ── Property Page ─────────────────────────────────────────────────────────────

// // // class _PropertyPage extends StatelessWidget {
// // //   final String landlordId;
// // //   final GlobalKey<ScaffoldState>? scaffoldKey;
// // //   const _PropertyPage({required this.landlordId, this.scaffoldKey});

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final service = PropertyService();
// // //     final user = context.read<AuthService>().currentUser!;
// // //     final isDark = Theme.of(context).brightness == Brightness.dark;
// // //     final primary = Theme.of(context).colorScheme.primary;
// // //     final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
// // //     final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
// // //     final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);

// // //     return Scaffold(
// // //       backgroundColor: bg,
// // //       body: FutureBuilder<Map<String, int>>(
// // //         future: service.getPropertySummary(landlordId),
// // //         builder: (context, summarySnap) {
// // //           final data = summarySnap.data ?? {};
// // //           return CustomScrollView(
// // //             physics: const BouncingScrollPhysics(),
// // //             slivers: [
// // //               // ── SliverAppBar with gradient header ──
// // //               SliverAppBar(
// // //                 expandedHeight: 200,
// // //                 collapsedHeight: 60,
// // //                 pinned: true,
// // //                 backgroundColor: bg,
// // //                 elevation: 0,
// // //                 leading: IconButton(
// // //                   icon: Icon(Icons.menu_rounded, color: textPrimary),
// // //                   onPressed: () =>
// // //                       scaffoldKey?.currentState?.openDrawer(),
// // //                 ),
// // //                 title: Text(
// // //                   'স্বাগতম, ${user.name.split(' ')[0]}!',
// // //                   style: TextStyle(
// // //                     color: textPrimary,
// // //                     fontSize: 18,
// // //                     fontWeight: FontWeight.w700,
// // //                   ),
// // //                 ),
// // //                 centerTitle: true,
// // //                 flexibleSpace: FlexibleSpaceBar(
// // //                   background: _buildHeader(
// // //                     context: context,
// // //                     primary: primary,
// // //                     isDark: isDark,
// // //                     textPrimary: textPrimary,
// // //                     userName: user.name.split(' ')[0],
// // //                     data: data,
// // //                   ),
// // //                 ),
// // //               ),

// // //               // ── Section title ──
// // //               SliverToBoxAdapter(
// // //                 child: Padding(
// // //                   padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
// // //                   child: Row(
// // //                     children: [
// // //                       Container(
// // //                         width: 4,
// // //                         height: 20,
// // //                         decoration: BoxDecoration(
// // //                           color: primary,
// // //                           borderRadius: BorderRadius.circular(2),
// // //                         ),
// // //                       ),
// // //                       const SizedBox(width: 10),
// // //                       Text(
// // //                         'আমার Properties',
// // //                         style: TextStyle(
// // //                           fontSize: 16,
// // //                           fontWeight: FontWeight.w700,
// // //                           color: textPrimary,
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //               ),

// // //               // ── Property List ──
// // //               StreamBuilder<List<PropertyModel>>(
// // //                 stream: service.getProperties(landlordId),
// // //                 builder: (context, snap) {
// // //                   if (snap.connectionState == ConnectionState.waiting) {
// // //                     return SliverFillRemaining(
// // //                       child: Center(
// // //                           child: CircularProgressIndicator(color: primary)),
// // //                     );
// // //                   }
// // //                   final properties = snap.data ?? [];
// // //                   if (properties.isEmpty) {
// // //                     return SliverFillRemaining(
// // //                       child: _buildEmptyState(
// // //                           context, landlordId, primary, textSecondary),
// // //                     );
// // //                   }
// // //                   return SliverPadding(
// // //                     padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
// // //                     sliver: SliverList(
// // //                       delegate: SliverChildBuilderDelegate(
// // //                         (ctx, i) => _PropertyCard(
// // //                           property: properties[i],
// // //                           service: service,
// // //                           isDark: isDark,
// // //                           primary: primary,
// // //                           textPrimary: textPrimary,
// // //                           textSecondary: textSecondary,
// // //                           index: i,
// // //                           onTap: () => Navigator.push(
// // //                               context,
// // //                               MaterialPageRoute(
// // //                                   builder: (_) =>
// // //                                       RoomListScreen(property: properties[i]))),
// // //                           onEdit: () => Navigator.push(
// // //                               context,
// // //                               MaterialPageRoute(
// // //                                   builder: (_) => AddEditPropertyScreen(
// // //                                       landlordId: landlordId,
// // //                                       property: properties[i]))),
// // //                         ),
// // //                         childCount: properties.length,
// // //                       ),
// // //                     ),
// // //                   );
// // //                 },
// // //               ),
// // //             ],
// // //           );
// // //         },
// // //       ),
// // //       floatingActionButton: Container(
// // //         decoration: BoxDecoration(
// // //           borderRadius: BorderRadius.circular(16),
// // //           boxShadow: [
// // //             BoxShadow(
// // //               color: primary.withOpacity(0.4),
// // //               blurRadius: 16,
// // //               offset: const Offset(0, 6),
// // //             ),
// // //           ],
// // //         ),
// // //         child: FloatingActionButton.extended(
// // //           onPressed: () => Navigator.push(
// // //             context,
// // //             MaterialPageRoute(
// // //                 builder: (_) =>
// // //                     AddEditPropertyScreen(landlordId: landlordId)),
// // //           ),
// // //           icon: const Icon(Icons.add_rounded),
// // //           label: const Text('Property যোগ করুন',
// // //               style: TextStyle(fontWeight: FontWeight.w700)),
// // //           shape:
// // //               RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Gradient Header with Stats ──
// // //   Widget _buildHeader({
// // //     required BuildContext context,
// // //     required Color primary,
// // //     required bool isDark,
// // //     required Color textPrimary,
// // //     required String userName,
// // //     required Map<String, int> data,
// // //   }) {
// // //     return Container(
// // //       decoration: BoxDecoration(
// // //         gradient: LinearGradient(
// // //           begin: Alignment.topLeft,
// // //           end: Alignment.bottomRight,
// // //           colors: isDark
// // //               ? [const Color(0xFF1A3328), const Color(0xFF0F1A14)]
// // //               : [const Color(0xFFE8F5EE), const Color(0xFFF5FAF7)],
// // //         ),
// // //       ),
// // //       child: SafeArea(
// // //         child: Padding(
// // //           padding: const EdgeInsets.fromLTRB(16, 64, 16, 12),
// // //           child: Row(
// // //             children: [
// // //               _statCard(
// // //                 icon: Icons.home_work_rounded,
// // //                 label: 'Properties',
// // //                 value: '${data['totalProperties'] ?? 0}',
// // //                 color: primary,
// // //                 isDark: isDark,
// // //               ),
// // //               const SizedBox(width: 10),
// // //               _statCard(
// // //                 icon: Icons.door_front_door_rounded,
// // //                 label: 'মোট রুম',
// // //                 value: '${data['totalRooms'] ?? 0}',
// // //                 color: const Color(0xFF0891B2),
// // //                 isDark: isDark,
// // //               ),
// // //               const SizedBox(width: 10),
// // //               _statCard(
// // //                 icon: Icons.people_rounded,
// // //                 label: 'ভাড়া দেওয়া',
// // //                 value: '${data['occupiedRooms'] ?? 0}',
// // //                 color: const Color(0xFF059669),
// // //                 isDark: isDark,
// // //               ),
// // //               const SizedBox(width: 10),
// // //               _statCard(
// // //                 icon: Icons.door_back_door_outlined,
// // //                 label: 'খালি রুম',
// // //                 value: '${data['vacantRooms'] ?? 0}',
// // //                 color: const Color(0xFFD97706),
// // //                 isDark: isDark,
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _statCard({
// // //     required IconData icon,
// // //     required String label,
// // //     required String value,
// // //     required Color color,
// // //     required bool isDark,
// // //   }) {
// // //     return Expanded(
// // //       child: Container(
// // //         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
// // //         decoration: BoxDecoration(
// // //           color: color.withOpacity(isDark ? 0.15 : 0.1),
// // //           borderRadius: BorderRadius.circular(14),
// // //           border: Border.all(color: color.withOpacity(0.3)),
// // //         ),
// // //         child: Column(
// // //           mainAxisSize: MainAxisSize.min,
// // //           children: [
// // //             Icon(icon, color: color, size: 20),
// // //             const SizedBox(height: 4),
// // //             Text(
// // //               value,
// // //               style: TextStyle(
// // //                   fontSize: 18, fontWeight: FontWeight.bold, color: color),
// // //             ),
// // //             Text(
// // //               label,
// // //               style: TextStyle(fontSize: 9, color: color.withOpacity(0.8)),
// // //               overflow: TextOverflow.ellipsis,
// // //               textAlign: TextAlign.center,
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildEmptyState(BuildContext context, String landlordId,
// // //       Color primary, Color textSecondary) {
// // //     return Center(
// // //       child: Column(
// // //         mainAxisSize: MainAxisSize.min,
// // //         children: [
// // //           Container(
// // //             width: 100,
// // //             height: 100,
// // //             decoration: BoxDecoration(
// // //               color: primary.withOpacity(0.1),
// // //               shape: BoxShape.circle,
// // //             ),
// // //             child: Icon(Icons.home_work_outlined,
// // //                 size: 50, color: primary.withOpacity(0.5)),
// // //           ),
// // //           const SizedBox(height: 20),
// // //           const Text(
// // //             'কোনো Property নেই',
// // //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// // //           ),
// // //           const SizedBox(height: 8),
// // //           Text(
// // //             'নিচের বাটন দিয়ে property যোগ করুন',
// // //             style: TextStyle(fontSize: 14, color: textSecondary),
// // //           ),
// // //           const SizedBox(height: 24),
// // //           FilledButton.icon(
// // //             onPressed: () => Navigator.push(
// // //               context,
// // //               MaterialPageRoute(
// // //                   builder: (_) =>
// // //                       AddEditPropertyScreen(landlordId: landlordId)),
// // //             ),
// // //             icon: const Icon(Icons.add_rounded),
// // //             label: const Text('Property যোগ করুন'),
// // //             style: FilledButton.styleFrom(
// // //               padding:
// // //                   const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
// // //               shape: RoundedRectangleBorder(
// // //                   borderRadius: BorderRadius.circular(14)),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }

// // // // ── Property Card ─────────────────────────────────────────────────────────────

// // // class _PropertyCard extends StatelessWidget {
// // //   final PropertyModel property;
// // //   final PropertyService service;
// // //   final bool isDark;
// // //   final Color primary;
// // //   final Color textPrimary;
// // //   final Color textSecondary;
// // //   final int index;
// // //   final VoidCallback onTap;
// // //   final VoidCallback onEdit;

// // //   const _PropertyCard({
// // //     required this.property,
// // //     required this.service,
// // //     required this.isDark,
// // //     required this.primary,
// // //     required this.textPrimary,
// // //     required this.textSecondary,
// // //     required this.index,
// // //     required this.onTap,
// // //     required this.onEdit,
// // //   });

// // //   // Settings screen এর মত cycling colors
// // //   static const List<Color> _iconColors = [
// // //     Color(0xFF2D7A4F),
// // //     Color(0xFF0891B2),
// // //     Color(0xFFD97706),
// // //     Color(0xFF5B4FBF),
// // //     Color(0xFF059669),
// // //   ];

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
// // //     final iconBg = _iconColors[index % _iconColors.length];

// // //     return Container(
// // //       margin: const EdgeInsets.only(bottom: 12),
// // //       decoration: BoxDecoration(
// // //         color: cardBg,
// // //         borderRadius: BorderRadius.circular(18),
// // //         boxShadow: [
// // //           BoxShadow(
// // //             color: Colors.black.withOpacity(0.06),
// // //             blurRadius: 12,
// // //             offset: const Offset(0, 4),
// // //           ),
// // //         ],
// // //       ),
// // //       child: Material(
// // //         color: Colors.transparent,
// // //         borderRadius: BorderRadius.circular(18),
// // //         child: InkWell(
// // //           onTap: onTap,
// // //           borderRadius: BorderRadius.circular(18),
// // //           child: Padding(
// // //             padding: const EdgeInsets.all(16),
// // //             child: Column(
// // //               children: [
// // //                 // ── Header row ──
// // //                 Row(
// // //                   children: [
// // //                     // Icon
// // //                     Container(
// // //                       width: 50,
// // //                       height: 50,
// // //                       decoration: BoxDecoration(
// // //                         color: iconBg,
// // //                         borderRadius: BorderRadius.circular(14),
// // //                         boxShadow: [
// // //                           BoxShadow(
// // //                             color: iconBg.withOpacity(0.35),
// // //                             blurRadius: 8,
// // //                             offset: const Offset(0, 3),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       child: const Icon(Icons.home_work_rounded,
// // //                           color: Colors.white, size: 24),
// // //                     ),
// // //                     const SizedBox(width: 14),

// // //                     // Name + Address
// // //                     Expanded(
// // //                       child: Column(
// // //                         crossAxisAlignment: CrossAxisAlignment.start,
// // //                         children: [
// // //                           Text(
// // //                             property.name,
// // //                             style: TextStyle(
// // //                               fontSize: 16,
// // //                               fontWeight: FontWeight.bold,
// // //                               color: textPrimary,
// // //                             ),
// // //                           ),
// // //                           const SizedBox(height: 3),
// // //                           Row(
// // //                             children: [
// // //                               Icon(Icons.location_on_rounded,
// // //                                   size: 12,
// // //                                   color: textSecondary.withOpacity(0.7)),
// // //                               const SizedBox(width: 3),
// // //                               Expanded(
// // //                                 child: Text(
// // //                                   property.address,
// // //                                   style: TextStyle(
// // //                                       fontSize: 12, color: textSecondary),
// // //                                   overflow: TextOverflow.ellipsis,
// // //                                 ),
// // //                               ),
// // //                             ],
// // //                           ),
// // //                         ],
// // //                       ),
// // //                     ),

// // //                     // Actions
// // //                     IconButton(
// // //                       icon: const Icon(Icons.forum_outlined,
// // //                           color: Colors.indigo, size: 20),
// // //                       tooltip: 'Community Chat',
// // //                       onPressed: () => Navigator.push(
// // //                         context,
// // //                         MaterialPageRoute(
// // //                           builder: (_) => CommunityChatScreen(
// // //                             propertyId: property.id,
// // //                             propertyName: property.name,
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                     PopupMenuButton(
// // //                       icon: Icon(Icons.more_vert_rounded,
// // //                           color: textSecondary, size: 20),
// // //                       shape: RoundedRectangleBorder(
// // //                           borderRadius: BorderRadius.circular(12)),
// // //                       itemBuilder: (_) => [
// // //                         PopupMenuItem(
// // //                           value: 'edit',
// // //                           child: Row(
// // //                             children: [
// // //                               Icon(Icons.edit_outlined,
// // //                                   size: 18, color: primary),
// // //                               const SizedBox(width: 10),
// // //                               const Text('Edit'),
// // //                             ],
// // //                           ),
// // //                         ),
// // //                         PopupMenuItem(
// // //                           value: 'delete',
// // //                           child: Row(
// // //                             children: const [
// // //                               Icon(Icons.delete_outline_rounded,
// // //                                   size: 18, color: Colors.red),
// // //                               SizedBox(width: 10),
// // //                               Text('Delete',
// // //                                   style: TextStyle(color: Colors.red)),
// // //                             ],
// // //                           ),
// // //                         ),
// // //                       ],
// // //                       onSelected: (val) async {
// // //                         if (val == 'edit') onEdit();
// // //                         if (val == 'delete') {
// // //                           await service.deleteProperty(property.id);
// // //                         }
// // //                       },
// // //                     ),
// // //                   ],
// // //                 ),

// // //                 const SizedBox(height: 12),

// // //                 // ── Divider ──
// // //                 Divider(
// // //                   height: 1,
// // //                   color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
// // //                 ),

// // //                 const SizedBox(height: 12),

// // //                 // ── Stats row ──
// // //                 // Row(
// // //                 //   children: [
// // //                 //     _miniStat(
// // //                 //       icon: Icons.door_front_door_rounded,
// // //                 //       label: 'মোট রুম',
// // //                 //       value: '${property.totalRooms}',
// // //                 //       color: primary,
// // //                 //     ),
// // //                 //     _verticalDivider(),
// // //                 //     _miniStat(
// // //                 //       icon: Icons.people_rounded,
// // //                 //       label: 'ভাড়া দেওয়া',
// // //                 //       value: '${property.occupiedRooms ?? 0}',
// // //                 //       color: const Color(0xFF059669),
// // //                 //     ),
// // //                 //     _verticalDivider(),
// // //                 //     _miniStat(
// // //                 //       icon: Icons.door_back_door_outlined,
// // //                 //       label: 'খালি',
// // //                 //       value:
// // //                 //           '${(property.totalRooms) - (property.occupiedRooms ?? 0)}',
// // //                 //       color: const Color(0xFFD97706),
// // //                 //     ),
// // //                 //   ],
// // //                 // ),

// // //                 // ── Stats row — Firestore থেকে real data ──
// // //                 FutureBuilder<QuerySnapshot>(
// // //                   future: FirebaseFirestore.instance
// // //                       .collection('rooms')
// // //                       .where('propertyId', isEqualTo: property.id)
// // //                       .get(),
// // //                   builder: (context, snap) {
// // //                     int total = 0;
// // //                     int occupied = 0;
// // //                     int vacant = 0;

// // //                     if (snap.hasData) {
// // //                       final rooms = snap.data!.docs;
// // //                       total = rooms.length;
// // //                       occupied = rooms
// // //                           .where((r) =>
// // //                               (r.data() as Map<String, dynamic>)['status'] ==
// // //                               'occupied')
// // //                           .length;
// // //                       vacant = total - occupied;
// // //                     }

// // //                     return Row(
// // //                       children: [
// // //                         _miniStat(
// // //                           icon: Icons.door_front_door_rounded,
// // //                           label: 'মোট রুম',
// // //                           value: snap.hasData ? '$total' : '${property.totalRooms}',
// // //                           color: primary,
// // //                         ),
// // //                         _verticalDivider(),
// // //                         _miniStat(
// // //                           icon: Icons.people_rounded,
// // //                           label: 'ভাড়া দেওয়া',
// // //                           value: snap.hasData ? '$occupied' : '-',
// // //                           color: const Color(0xFF059669),
// // //                         ),
// // //                         _verticalDivider(),
// // //                         _miniStat(
// // //                           icon: Icons.door_back_door_outlined,
// // //                           label: 'খালি',
// // //                           value: snap.hasData ? '$vacant' : '-',
// // //                           color: const Color(0xFFD97706),
// // //                         ),
// // //                       ],
// // //                     );
// // //                   },
// // //                 ),

// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _miniStat({
// // //     required IconData icon,
// // //     required String label,
// // //     required String value,
// // //     required Color color,
// // //   }) {
// // //     return Expanded(
// // //       child: Row(
// // //         mainAxisAlignment: MainAxisAlignment.center,
// // //         children: [
// // //           Container(
// // //             width: 30,
// // //             height: 30,
// // //             decoration: BoxDecoration(
// // //               color: color.withOpacity(0.1),
// // //               borderRadius: BorderRadius.circular(8),
// // //             ),
// // //             child: Icon(icon, size: 16, color: color),
// // //           ),
// // //           const SizedBox(width: 8),
// // //           Column(
// // //             crossAxisAlignment: CrossAxisAlignment.start,
// // //             children: [
// // //               Text(
// // //                 value,
// // //                 style: TextStyle(
// // //                     fontSize: 15,
// // //                     fontWeight: FontWeight.bold,
// // //                     color: color),
// // //               ),
// // //               Text(
// // //                 label,
// // //                 style: TextStyle(fontSize: 10, color: textSecondary),
// // //               ),
// // //             ],
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   Widget _verticalDivider() => Container(
// // //         width: 1,
// // //         height: 36,
// // //         color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
// // //       );
// // // }

// // // // // ── Property Page ─────────────────────────────────────────────────────────────

// // // // class _PropertyPage extends StatelessWidget {
// // // //   final String landlordId;
// // // //   final GlobalKey<ScaffoldState>? scaffoldKey;
// // // //   const _PropertyPage({required this.landlordId, this.scaffoldKey});

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final service = PropertyService();
// // // //     final user = context.read<AuthService>().currentUser!;

// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         leading: IconButton(
// // // //           icon: const Icon(Icons.menu_rounded),
// // // //           onPressed: () => scaffoldKey?.currentState?.openDrawer(),
// // // //         ),
// // // //         title: Column(
// // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // //           children: [
// // // //             Text('স্বাগতম, ${user.name.split(' ')[0]}!',
// // // //                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
// // // //             const Text('আপনার properties', style: TextStyle(fontSize: 11)),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //       body: Column(
// // // //         children: [
// // // //           _SummarySection(landlordId: landlordId, service: service),
// // // //           Padding(
// // // //             padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
// // // //             child: Row(
// // // //               children: [
// // // //                 const Text('আমার Properties',
// // // //                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
// // // //                 const Spacer(),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //           Expanded(
// // // //             child: StreamBuilder<List<PropertyModel>>(
// // // //               stream: service.getProperties(landlordId),
// // // //               builder: (context, snap) {
// // // //                 if (snap.connectionState == ConnectionState.waiting) {
// // // //                   return const Center(child: CircularProgressIndicator());
// // // //                 }
// // // //                 final properties = snap.data ?? [];
// // // //                 if (properties.isEmpty) {
// // // //                   return Center(
// // // //                     child: Column(
// // // //                       mainAxisSize: MainAxisSize.min,
// // // //                       children: [
// // // //                         Icon(Icons.home_work_outlined, size: 80,
// // // //                             color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
// // // //                         const SizedBox(height: 16),
// // // //                         const Text('কোনো property নেই',
// // // //                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // //                         const SizedBox(height: 8),
// // // //                         const Text('নিচের বাটন দিয়ে property যোগ করুন'),
// // // //                         const SizedBox(height: 20),
// // // //                         FilledButton.icon(
// // // //                           onPressed: () => Navigator.push(context, MaterialPageRoute(
// // // //                             builder: (_) => AddEditPropertyScreen(landlordId: landlordId),
// // // //                           )),
// // // //                           icon: const Icon(Icons.add),
// // // //                           label: const Text('Property যোগ করুন'),
// // // //                         ),
// // // //                       ],
// // // //                     ),
// // // //                   );
// // // //                 }
// // // //                 return ListView.builder(
// // // //                   padding: const EdgeInsets.symmetric(horizontal: 16),
// // // //                   itemCount: properties.length,
// // // //                   itemBuilder: (ctx, i) => _PropertyCard(
// // // //                     property: properties[i],
// // // //                     service: service,
// // // //                     onTap: () => Navigator.push(context, MaterialPageRoute(
// // // //                       builder: (_) => RoomListScreen(property: properties[i]),
// // // //                     )),
// // // //                     onEdit: () => Navigator.push(context, MaterialPageRoute(
// // // //                       builder: (_) => AddEditPropertyScreen(
// // // //                           landlordId: landlordId, property: properties[i]),
// // // //                     )),
// // // //                   ),
// // // //                 );
// // // //               },
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //       floatingActionButton: FloatingActionButton.extended(
// // // //         onPressed: () => Navigator.push(context, MaterialPageRoute(
// // // //           builder: (_) => AddEditPropertyScreen(landlordId: landlordId),
// // // //         )),
// // // //         icon: const Icon(Icons.add),
// // // //         label: const Text('Property যোগ করুন'),
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // class _SummarySection extends StatelessWidget {
// // // //   final String landlordId;
// // // //   final PropertyService service;
// // // //   const _SummarySection({required this.landlordId, required this.service});

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return FutureBuilder<Map<String, int>>(
// // // //       future: service.getPropertySummary(landlordId),
// // // //       builder: (context, snap) {
// // // //         final data = snap.data ?? {};
// // // //         return Container(
// // // //           margin: const EdgeInsets.all(16),
// // // //           padding: const EdgeInsets.all(16),
// // // //           decoration: BoxDecoration(
// // // //             color: Theme.of(context).colorScheme.primary,
// // // //             borderRadius: BorderRadius.circular(20),
// // // //           ),
// // // //           child: Row(
// // // //             children: [
// // // //               _SummaryItem(icon: Icons.home_work_rounded, label: 'Properties', value: '${data['totalProperties'] ?? 0}'),
// // // //               _divider(),
// // // //               _SummaryItem(icon: Icons.door_front_door_rounded, label: 'মোট রুম', value: '${data['totalRooms'] ?? 0}'),
// // // //               _divider(),
// // // //               _SummaryItem(icon: Icons.people_rounded, label: 'ভাড়া দেওয়া', value: '${data['occupiedRooms'] ?? 0}'),
// // // //               _divider(),
// // // //               _SummaryItem(icon: Icons.door_back_door_outlined, label: 'খালি', value: '${data['vacantRooms'] ?? 0}'),
// // // //             ],
// // // //           ),
// // // //         );
// // // //       },
// // // //     );
// // // //   }

// // // //   Widget _divider() => Container(
// // // //     width: 1, height: 40, color: Colors.white24,
// // // //     margin: const EdgeInsets.symmetric(horizontal: 8),
// // // //   );
// // // // }

// // // // class _SummaryItem extends StatelessWidget {
// // // //   final IconData icon;
// // // //   final String label;
// // // //   final String value;
// // // //   const _SummaryItem({required this.icon, required this.label, required this.value});

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Expanded(
// // // //       child: Column(
// // // //         children: [
// // // //           Icon(icon, color: Colors.white, size: 22),
// // // //           const SizedBox(height: 4),
// // // //           Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
// // // //           Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // class _PropertyCard extends StatelessWidget {
// // // //   final PropertyModel property;
// // // //   final PropertyService service;
// // // //   final VoidCallback onTap;
// // // //   final VoidCallback onEdit;
// // // //   const _PropertyCard({required this.property, required this.service, required this.onTap, required this.onEdit});

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Card(
// // // //       margin: const EdgeInsets.only(bottom: 12),
// // // //       child: InkWell(
// // // //         onTap: onTap,
// // // //         borderRadius: BorderRadius.circular(16),
// // // //         child: Padding(
// // // //           padding: const EdgeInsets.all(16),
// // // //           child: Row(
// // // //             children: [
// // // //               Container(
// // // //                 width: 52, height: 52,
// // // //                 decoration: BoxDecoration(
// // // //                   color: Theme.of(context).colorScheme.primaryContainer,
// // // //                   borderRadius: BorderRadius.circular(14),
// // // //                 ),
// // // //                 child: Icon(Icons.home_work_rounded, color: Theme.of(context).colorScheme.primary),
// // // //               ),
// // // //               const SizedBox(width: 14),
// // // //               Expanded(
// // // //                 child: Column(
// // // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // // //                   children: [
// // // //                     Text(property.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
// // // //                     Text(property.address,
// // // //                         style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
// // // //                     const SizedBox(height: 6),
// // // //                     Container(
// // // //                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
// // // //                       decoration: BoxDecoration(
// // // //                         color: Theme.of(context).colorScheme.primaryContainer,
// // // //                         borderRadius: BorderRadius.circular(20),
// // // //                       ),
// // // //                       child: Text('${property.totalRooms} টি রুম',
// // // //                           style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500)),
// // // //                     ),
// // // //                   ],
// // // //                 ),
// // // //               ),
// // // //               IconButton(
// // // //                 icon: const Icon(Icons.forum_outlined, color: Colors.indigo),
// // // //                 tooltip: 'Community Chat',
// // // //                 onPressed: () => Navigator.push(
// // // //                   context,
// // // //                   MaterialPageRoute(
// // // //                     builder: (_) => CommunityChatScreen(
// // // //                       propertyId: property.id,
// // // //                       propertyName: property.name,
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //               ),
// // // //               PopupMenuButton(
// // // //                 itemBuilder: (_) => [
// // // //                   const PopupMenuItem(value: 'edit', child: Text('Edit')),
// // // //                   const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
// // // //                 ],
// // // //                 onSelected: (val) async {
// // // //                   if (val == 'edit') onEdit();
// // // //                   if (val == 'delete') await service.deleteProperty(property.id);
// // // //                 },
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }








// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import '../../services/auth_service.dart';
// // import '../../services/property_service.dart';
// // import '../../models/property_model.dart';
// // import 'chart_screen.dart';
// // import 'add_edit_property_screen.dart';
// // import 'room_list_screen.dart';
// // import 'tenant_list_screen.dart';
// // import 'payment_list_screen.dart';
// // import 'notice_screen.dart';
// // import 'maintenance_requests_screen.dart';
// // import 'utility_screen.dart';
// // import 'archive_screen.dart';
// // import 'settings_screen.dart';
// // import '../../../widgets/profile_avatar.dart';
// // import 'rules_screen.dart';
// // import 'chat_list_screen.dart';
// // import '../community/community_chat_screen.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';

// // class LandlordDashboard extends StatefulWidget {
// //   const LandlordDashboard({super.key});

// //   @override
// //   State<LandlordDashboard> createState() => _LandlordDashboardState();
// // }

// // class _LandlordDashboardState extends State<LandlordDashboard> {
// //   int _currentIndex = 0;
// //   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

// //   final List<_NavItem> _bottomItems = const [
// //     _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart_rounded, label: 'রিপোর্ট'),
// //     _NavItem(icon: Icons.home_work_outlined, activeIcon: Icons.home_work_rounded, label: 'Properties'),
// //     _NavItem(icon: Icons.people_outline, activeIcon: Icons.people_rounded, label: 'ভাড়াটিয়া'),
// //     _NavItem(icon: Icons.payments_outlined, activeIcon: Icons.payments_rounded, label: 'ভাড়া'),
// //     _NavItem(icon: Icons.electric_bolt_outlined, activeIcon: Icons.electric_bolt_rounded, label: 'ইউটিলিটি'),
// //   ];

// //   @override
// //   Widget build(BuildContext context) {
// //     final user = context.read<AuthService>().currentUser!;

// //     final List<Widget> pages = [
// //       ChartScreen(scaffoldKey: _scaffoldKey),
// //       _PropertyPage(landlordId: user.uid, scaffoldKey: _scaffoldKey),
// //       TenantListScreen(scaffoldKey: _scaffoldKey),
// //       PaymentListScreen(scaffoldKey: _scaffoldKey),
// //       UtilityScreen(scaffoldKey: _scaffoldKey),
// //     ];

// //     return Scaffold(
// //       key: _scaffoldKey,
// //       drawer: _AppDrawer(user: user),
// //       body: pages[_currentIndex],
// //       bottomNavigationBar: NavigationBar(
// //         selectedIndex: _currentIndex,
// //         onDestinationSelected: (i) => setState(() => _currentIndex = i),
// //         destinations: _bottomItems.map((item) => NavigationDestination(
// //           icon: Icon(item.icon),
// //           selectedIcon: Icon(item.activeIcon),
// //           label: item.label,
// //         )).toList(),
// //       ),
// //     );
// //   }
// // }

// // class _NavItem {
// //   final IconData icon;
// //   final IconData activeIcon;
// //   final String label;
// //   const _NavItem({required this.icon, required this.activeIcon, required this.label});
// // }

// // // ── Drawer ────────────────────────────────────────────────────────────────────

// // class _AppDrawer extends StatelessWidget {
// //   final dynamic user;
// //   const _AppDrawer({required this.user});

// //   @override
// //   Widget build(BuildContext context) {
// //     final primary = Theme.of(context).colorScheme.primary;
// //     final isDark = Theme.of(context).brightness == Brightness.dark;
// //     final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
// //     final textSecondary = isDark ? Colors.white38 : const Color(0xFF9CA3AF);

// //     return Drawer(
// //       backgroundColor: bg,
// //       child: Column(
// //         children: [
// //           _DrawerHeader(user: user, primary: primary, isDark: isDark),
// //           Expanded(
// //             child: ListView(
// //               padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
// //               children: [
// //                 _DrawerTile(
// //                   icon: Icons.person_outline_rounded,
// //                   iconBg: primary,
// //                   label: 'আমার প্রোফাইল',
// //                   onTap: () {
// //                     Navigator.pop(context);
// //                     Navigator.push(context, MaterialPageRoute(
// //                       builder: (_) => _LandlordProfileScreen(user: user),
// //                     ));
// //                   },
// //                 ),
// //                 _DrawerSectionLabel('অতিরিক্ত', textSecondary),
// //                 _DrawerTile(
// //                   icon: Icons.build_outlined,
// //                   iconBg: const Color(0xFFD97706),
// //                   label: 'মেরামতের অনুরোধ',
// //                   onTap: () {
// //                     Navigator.pop(context);
// //                     Navigator.push(context, MaterialPageRoute(
// //                       builder: (_) => const MaintenanceRequestsScreen(),
// //                     ));
// //                   },
// //                 ),
// //                 _DrawerTile(
// //                   icon: Icons.campaign_outlined,
// //                   iconBg: const Color(0xFF059669),
// //                   label: 'নোটিশ বোর্ড',
// //                   onTap: () {
// //                     Navigator.pop(context);
// //                     Navigator.push(context, MaterialPageRoute(
// //                       builder: (_) => const NoticeScreen(),
// //                     ));
// //                   },
// //                 ),
// //                 _DrawerTile(
// //                   icon: Icons.archive_outlined,
// //                   iconBg: const Color(0xFF6B7280),
// //                   label: 'আর্কাইভ',
// //                   onTap: () {
// //                     Navigator.pop(context);
// //                     Navigator.push(context, MaterialPageRoute(
// //                       builder: (_) => const ArchiveScreen(),
// //                     ));
// //                   },
// //                 ),
// //                 _DrawerSectionLabel('অ্যাপ', textSecondary),
// //                 _DrawerTile(
// //                   icon: Icons.chat_bubble_outline_rounded,
// //                   iconBg: const Color(0xFF7C3AED),
// //                   label: 'Messages',
// //                   onTap: () {
// //                     Navigator.pop(context);
// //                     Navigator.push(context, MaterialPageRoute(
// //                       builder: (_) => const ChatListScreen(),
// //                     ));
// //                   },
// //                 ),
// //                 _DrawerTile(
// //                   icon: Icons.gavel_rounded,
// //                   iconBg: const Color(0xFF059669),
// //                   label: 'নিয়মাবলী',
// //                   onTap: () {
// //                     Navigator.pop(context);
// //                     Navigator.push(context, MaterialPageRoute(
// //                       builder: (_) => const RulesScreen(),
// //                     ));
// //                   },
// //                 ),
// //                 _DrawerTile(
// //                   icon: Icons.settings_outlined,
// //                   iconBg: const Color(0xFF374151),
// //                   label: 'Settings',
// //                   onTap: () {
// //                     Navigator.pop(context);
// //                     Navigator.push(context, MaterialPageRoute(
// //                       builder: (_) => const SettingsScreen(),
// //                     ));
// //                   },
// //                 ),
// //               ],
// //             ),
// //           ),
// //           _DrawerFooter(onLogout: () => _confirmLogout(context)),
// //         ],
// //       ),
// //     );
// //   }

// //   void _confirmLogout(BuildContext context) {
// //     showDialog(
// //       context: context,
// //       builder: (_) => AlertDialog(
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //         title: const Text('Logout করবেন?',
// //             style: TextStyle(fontWeight: FontWeight.w700)),
// //         content: const Text('আপনি কি নিশ্চিতভাবে logout করতে চান?'),
// //         actions: [
// //           TextButton(
// //               onPressed: () => Navigator.pop(context),
// //               child: const Text('না')),
// //           FilledButton(
// //             onPressed: () {
// //               Navigator.pop(context); // dialog বন্ধ
// //               Navigator.pop(context); // drawer বন্ধ
// //               context.read<AuthService>().logout();
// //             },
// //             child: const Text('হ্যাঁ, Logout'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // ── Shared Drawer Widgets ─────────────────────────────────────────────────────

// // class _DrawerHeader extends StatelessWidget {
// //   final dynamic user;
// //   final Color primary;
// //   final bool isDark;
// //   const _DrawerHeader({required this.user, required this.primary, required this.isDark});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       width: double.infinity,
// //       decoration: BoxDecoration(
// //         gradient: LinearGradient(
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //           colors: isDark
// //               ? [const Color(0xFF1A3328), const Color(0xFF0F2018)]
// //               : [primary, primary.withOpacity(0.8)],
// //         ),
// //       ),
// //       child: SafeArea(
// //         bottom: false,
// //         child: Padding(
// //           padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Consumer<AuthService>(
// //                 builder: (context, auth, _) => ProfileAvatar(
// //                   name: auth.currentUser?.name ?? user.name,
// //                   photoUrl: auth.currentUser?.photoUrl,
// //                   userId: user.uid,
// //                   radius: 36,
// //                   editable: true,
// //                 ),
// //               ),
// //               const SizedBox(height: 14),
// //               Text(
// //                 user.name,
// //                 style: const TextStyle(
// //                     fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
// //               ),
// //               const SizedBox(height: 3),
// //               Text(
// //                 user.email,
// //                 style: const TextStyle(fontSize: 12, color: Colors.white60),
// //                 maxLines: 1,
// //                 overflow: TextOverflow.ellipsis,
// //               ),
// //               const SizedBox(height: 10),
// //               Container(
// //                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white.withOpacity(0.2),
// //                   borderRadius: BorderRadius.circular(20),
// //                   border: Border.all(color: Colors.white30, width: 1),
// //                 ),
// //                 child: const Text(
// //                   'বাড়ীওয়ালা',
// //                   style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class _DrawerTile extends StatelessWidget {
// //   final IconData icon;
// //   final Color iconBg;
// //   final String label;
// //   final VoidCallback onTap;
// //   const _DrawerTile({required this.icon, required this.iconBg, required this.label, required this.onTap});

// //   @override
// //   Widget build(BuildContext context) {
// //     final isDark = Theme.of(context).brightness == Brightness.dark;
// //     final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 2),
// //       child: Material(
// //         color: Colors.transparent,
// //         borderRadius: BorderRadius.circular(12),
// //         child: InkWell(
// //           onTap: onTap,
// //           borderRadius: BorderRadius.circular(12),
// //           child: Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// //             child: Row(
// //               children: [
// //                 Container(
// //                   width: 38,
// //                   height: 38,
// //                   decoration: BoxDecoration(
// //                     color: iconBg,
// //                     borderRadius: BorderRadius.circular(10),
// //                   ),
// //                   child: Icon(icon, color: Colors.white, size: 19),
// //                 ),
// //                 const SizedBox(width: 14),
// //                 Text(label, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500)),
// //                 const Spacer(),
// //                 Icon(Icons.chevron_right_rounded,
// //                     color: isDark ? Colors.white24 : Colors.black12, size: 18),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class _DrawerSectionLabel extends StatelessWidget {
// //   final String label;
// //   final Color color;
// //   const _DrawerSectionLabel(this.label, this.color);

// //   @override
// //   Widget build(BuildContext context) {
// //     return Padding(
// //       padding: const EdgeInsets.fromLTRB(12, 16, 12, 6),
// //       child: Text(
// //         label.toUpperCase(),
// //         style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 1.2),
// //       ),
// //     );
// //   }
// // }

// // class _DrawerFooter extends StatelessWidget {
// //   final VoidCallback onLogout;
// //   const _DrawerFooter({required this.onLogout});

// //   @override
// //   Widget build(BuildContext context) {
// //     final isDark = Theme.of(context).brightness == Brightness.dark;
// //     return Container(
// //       padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
// //       decoration: BoxDecoration(
// //         border: Border(
// //           top: BorderSide(
// //             color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
// //             width: 1,
// //           ),
// //         ),
// //       ),
// //       child: Column(
// //         children: [
// //           Material(
// //             color: Colors.transparent,
// //             borderRadius: BorderRadius.circular(12),
// //             child: InkWell(
// //               onTap: onLogout,
// //               borderRadius: BorderRadius.circular(12),
// //               child: Padding(
// //                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// //                 child: Row(
// //                   children: [
// //                     Container(
// //                       width: 38,
// //                       height: 38,
// //                       decoration: BoxDecoration(
// //                         color: Colors.red.withOpacity(0.1),
// //                         borderRadius: BorderRadius.circular(10),
// //                         border: Border.all(color: Colors.red.withOpacity(0.2)),
// //                       ),
// //                       child: const Icon(Icons.logout_rounded, color: Colors.red, size: 19),
// //                     ),
// //                     const SizedBox(width: 14),
// //                     const Text('Logout',
// //                         style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w600)),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //           const SizedBox(height: 8),
// //           Text(
// //             'House Manager v1.0.0',
// //             style: TextStyle(fontSize: 11, color: isDark ? Colors.white24 : Colors.grey.shade400),
// //           ),
// //           const SizedBox(height: 4),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // ── Landlord Profile Screen ───────────────────────────────────────────────────

// // class _InfoTile extends StatelessWidget {
// //   final IconData icon;
// //   final String label;
// //   final String value;
// //   final ColorScheme color;
// //   const _InfoTile({required this.icon, required this.label, required this.value, required this.color});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: color.surface,
// //         borderRadius: BorderRadius.circular(14),
// //         border: Border.all(color: color.outlineVariant.withOpacity(0.5)),
// //         boxShadow: [
// //           BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
// //         ],
// //       ),
// //       child: Row(
// //         children: [
// //           Container(
// //             padding: const EdgeInsets.all(10),
// //             decoration: BoxDecoration(
// //               color: color.primary.withOpacity(0.08),
// //               borderRadius: BorderRadius.circular(10),
// //             ),
// //             child: Icon(icon, color: color.primary, size: 20),
// //           ),
// //           const SizedBox(width: 14),
// //           Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text(label, style: TextStyle(fontSize: 11, color: color.onSurface.withOpacity(0.5))),
// //               const SizedBox(height: 2),
// //               Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class _LandlordProfileScreen extends StatelessWidget {
// //   final dynamic user;
// //   const _LandlordProfileScreen({required this.user});

// //   @override
// //   Widget build(BuildContext context) {
// //     final color = Theme.of(context).colorScheme;
// //     return Scaffold(
// //       body: CustomScrollView(
// //         slivers: [
// //           SliverAppBar(
// //             expandedHeight: 220,
// //             pinned: true,
// //             backgroundColor: color.primary,
// //             iconTheme: const IconThemeData(color: Colors.white),
// //             title: const Text('আমার প্রোফাইল',
// //                 style: TextStyle(color: Colors.white, fontSize: 16)),
// //             flexibleSpace: FlexibleSpaceBar(
// //               background: Container(
// //                 decoration: BoxDecoration(
// //                   gradient: LinearGradient(
// //                     begin: Alignment.topLeft,
// //                     end: Alignment.bottomRight,
// //                     colors: [color.primary, color.primary.withOpacity(0.75)],
// //                   ),
// //                 ),
// //                 child: SafeArea(
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       const SizedBox(height: 32),
// //                       Container(
// //                         padding: const EdgeInsets.all(3),
// //                         decoration: BoxDecoration(
// //                           shape: BoxShape.circle,
// //                           border: Border.all(color: Colors.white, width: 2.5),
// //                         ),
// //                         child: CircleAvatar(
// //                           radius: 44,
// //                           backgroundColor: Colors.white24,
// //                           child: Text(
// //                             user.name.isNotEmpty ? user.name[0].toUpperCase() : 'L',
// //                             style: const TextStyle(
// //                                 fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white),
// //                           ),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 10),
// //                       Text(user.name,
// //                           style: const TextStyle(
// //                               fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
// //                       const SizedBox(height: 5),
// //                       Container(
// //                         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
// //                         decoration: BoxDecoration(
// //                           color: Colors.white24,
// //                           borderRadius: BorderRadius.circular(20),
// //                         ),
// //                         child: const Text('বাড়ীওয়ালা',
// //                             style: TextStyle(fontSize: 12, color: Colors.white)),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),
// //           SliverToBoxAdapter(
// //             child: Padding(
// //               padding: const EdgeInsets.all(20),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text('যোগাযোগের তথ্য',
// //                       style: TextStyle(
// //                           fontSize: 12,
// //                           fontWeight: FontWeight.bold,
// //                           color: color.primary,
// //                           letterSpacing: 0.5)),
// //                   const SizedBox(height: 10),
// //                   _InfoTile(icon: Icons.email_outlined, label: 'Email', value: user.email, color: color),
// //                   const SizedBox(height: 10),
// //                   _InfoTile(icon: Icons.phone_outlined, label: 'Phone', value: user.phone, color: color),
// //                   const SizedBox(height: 10),
// //                   _InfoTile(icon: Icons.home_rounded, label: 'Role', value: 'Landlord', color: color),
// //                   const SizedBox(height: 32),
// //                   SizedBox(
// //                     width: double.infinity,
// //                     height: 50,
// //                     child: OutlinedButton.icon(
// //                       onPressed: () {
// //                         Navigator.pop(context);
// //                         context.read<AuthService>().logout();
// //                       },
// //                       icon: const Icon(Icons.logout_rounded, color: Colors.red),
// //                       label: const Text('Logout',
// //                           style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
// //                       style: OutlinedButton.styleFrom(
// //                         side: const BorderSide(color: Colors.red),
// //                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // ── Property Page ─────────────────────────────────────────────────────────────
// // // FIX 1: FutureBuilder পুরো page wrap করা থেকে সরানো হয়েছে।
// // // Summary stats এখন আলাদা StreamBuilder দিয়ে header এর ভেতরে render হয়।
// // // এতে page open হওয়ার সময় glitch বন্ধ হবে।

// // class _PropertyPage extends StatelessWidget {
// //   final String landlordId;
// //   final GlobalKey<ScaffoldState>? scaffoldKey;
// //   const _PropertyPage({required this.landlordId, this.scaffoldKey});

// //   @override
// //   Widget build(BuildContext context) {
// //     final service = PropertyService();
// //     final user = context.read<AuthService>().currentUser!;
// //     final isDark = Theme.of(context).brightness == Brightness.dark;
// //     final primary = Theme.of(context).colorScheme.primary;
// //     final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
// //     final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
// //     final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);

// //     return Scaffold(
// //       backgroundColor: bg,
// //       // FIX 1: FutureBuilder সরিয়ে সরাসরি CustomScrollView রেন্ডার করা হচ্ছে।
// //       // Summary stats এখন header এর ভেতরে StreamBuilder ব্যবহার করে।
// //       body: CustomScrollView(
// //         physics: const BouncingScrollPhysics(),
// //         slivers: [
// //           // ── SliverAppBar ──
// //           SliverAppBar(
// //             expandedHeight: 200,
// //             collapsedHeight: 60,
// //             pinned: true,
// //             backgroundColor: bg,
// //             elevation: 0,
// //             leading: IconButton(
// //               icon: Icon(Icons.menu_rounded, color: textPrimary),
// //               onPressed: () => scaffoldKey?.currentState?.openDrawer(),
// //             ),
// //             title: Text(
// //               'স্বাগতম, ${user.name.split(' ')[0]}!',
// //               style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
// //             ),
// //             centerTitle: true,
// //             flexibleSpace: FlexibleSpaceBar(
// //               background: _buildHeader(
// //                 context: context,
// //                 primary: primary,
// //                 isDark: isDark,
// //                 textPrimary: textPrimary,
// //                 landlordId: landlordId,
// //                 service: service,
// //               ),
// //             ),
// //           ),

// //           // ── Section Title ──
// //           SliverToBoxAdapter(
// //             child: Padding(
// //               padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
// //               child: Row(
// //                 children: [
// //                   Container(
// //                     width: 4,
// //                     height: 20,
// //                     decoration: BoxDecoration(
// //                         color: primary, borderRadius: BorderRadius.circular(2)),
// //                   ),
// //                   const SizedBox(width: 10),
// //                   Text('আমার Properties',
// //                       style: TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.w700,
// //                           color: textPrimary)),
// //                 ],
// //               ),
// //             ),
// //           ),

// //           // ── Property List ──
// //           StreamBuilder<List<PropertyModel>>(
// //             stream: service.getProperties(landlordId),
// //             builder: (context, snap) {
// //               if (snap.connectionState == ConnectionState.waiting) {
// //                 return SliverFillRemaining(
// //                   child: Center(child: CircularProgressIndicator(color: primary)),
// //                 );
// //               }
// //               final properties = snap.data ?? [];
// //               if (properties.isEmpty) {
// //                 return SliverFillRemaining(
// //                   child: _buildEmptyState(context, landlordId, primary, textSecondary),
// //                 );
// //               }
// //               return SliverPadding(
// //                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
// //                 sliver: SliverList(
// //                   delegate: SliverChildBuilderDelegate(
// //                     (ctx, i) => _PropertyCard(
// //                       property: properties[i],
// //                       service: service,
// //                       isDark: isDark,
// //                       primary: primary,
// //                       textPrimary: textPrimary,
// //                       textSecondary: textSecondary,
// //                       index: i,
// //                       onTap: () => Navigator.push(
// //                           context,
// //                           MaterialPageRoute(
// //                               builder: (_) => RoomListScreen(property: properties[i]))),
// //                       onEdit: () => Navigator.push(
// //                           context,
// //                           MaterialPageRoute(
// //                               builder: (_) => AddEditPropertyScreen(
// //                                   landlordId: landlordId, property: properties[i]))),
// //                     ),
// //                     childCount: properties.length,
// //                   ),
// //                 ),
// //               );
// //             },
// //           ),
// //         ],
// //       ),
// //       floatingActionButton: Container(
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(16),
// //           boxShadow: [
// //             BoxShadow(color: primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6)),
// //           ],
// //         ),
// //         child: FloatingActionButton.extended(
// //           onPressed: () => Navigator.push(
// //             context,
// //             MaterialPageRoute(builder: (_) => AddEditPropertyScreen(landlordId: landlordId)),
// //           ),
// //           icon: const Icon(Icons.add_rounded),
// //           label: const Text('Property যোগ করুন', style: TextStyle(fontWeight: FontWeight.w700)),
// //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Header: summary stats এখন StreamBuilder দিয়ে — glitch নেই ──
// //   Widget _buildHeader({
// //     required BuildContext context,
// //     required Color primary,
// //     required bool isDark,
// //     required Color textPrimary,
// //     required String landlordId,
// //     required PropertyService service,
// //   }) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         gradient: LinearGradient(
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //           colors: isDark
// //               ? [const Color(0xFF1A3328), const Color(0xFF0F1A14)]
// //               : [const Color(0xFFE8F5EE), const Color(0xFFF5FAF7)],
// //         ),
// //       ),
// //       child: SafeArea(
// //         child: Padding(
// //           padding: const EdgeInsets.fromLTRB(16, 64, 16, 12),
// //           // FIX 1: FutureBuilder → StreamBuilder তে পরিবর্তন করা হয়েছে।
// //           // এখন summary data আসার আগে skeleton/placeholder দেখাবে, পুরো page rebuild হবে না।
// //           child: StreamBuilder<List<PropertyModel>>(
// //             stream: service.getProperties(landlordId),
// //             builder: (context, snap) {
// //               // FIX 2: Room count সঠিকভাবে গোনার জন্য এখন Firestore stream ব্যবহার হচ্ছে।
// //               // property.totalRooms (পুরনো static value) এর উপর নির্ভর না করে
// //               // Firestore থেকে actual room data নেওয়া হচ্ছে।
// //               if (!snap.hasData) {
// //                 // Loading state — placeholder stats দেখাও, page glitch করবে না
// //                 return Row(
// //                   children: [
// //                     _statCard(icon: Icons.home_work_rounded, label: 'Properties', value: '—', color: primary, isDark: isDark),
// //                     const SizedBox(width: 10),
// //                     _statCard(icon: Icons.door_front_door_rounded, label: 'মোট রুম', value: '—', color: const Color(0xFF0891B2), isDark: isDark),
// //                     const SizedBox(width: 10),
// //                     _statCard(icon: Icons.people_rounded, label: 'ভাড়া দেওয়া', value: '—', color: const Color(0xFF059669), isDark: isDark),
// //                     const SizedBox(width: 10),
// //                     _statCard(icon: Icons.door_back_door_outlined, label: 'খালি রুম', value: '—', color: const Color(0xFFD97706), isDark: isDark),
// //                   ],
// //                 );
// //               }

// //               final properties = snap.data!;
// //               final totalProperties = properties.length;

// //               // properties ready — এবার room count Firestore থেকে আনো
// //               return FutureBuilder<QuerySnapshot>(
// //                 future: FirebaseFirestore.instance
// //                     .collection('rooms')
// //                     .where('propertyId', whereIn: totalProperties == 0
// //                         ? ['__none__'] // empty list এড়াতে
// //                         : properties.map((p) => p.id).toList())
// //                     .get(),
// //                 builder: (context, roomSnap) {
// //                   int totalRooms = 0;
// //                   int occupied = 0;

// //                   if (roomSnap.hasData) {
// //                     final rooms = roomSnap.data!.docs;
// //                     totalRooms = rooms.length;
// //                     occupied = rooms.where((r) {
// //                       final data = r.data() as Map<String, dynamic>;
// //                       return data['status'] == 'occupied';
// //                     }).length;
// //                   }

// //                   final vacant = totalRooms - occupied;

// //                   return Row(
// //                     children: [
// //                       _statCard(
// //                           icon: Icons.home_work_rounded,
// //                           label: 'Properties',
// //                           value: '$totalProperties',
// //                           color: primary,
// //                           isDark: isDark),
// //                       const SizedBox(width: 10),
// //                       _statCard(
// //                           icon: Icons.door_front_door_rounded,
// //                           label: 'মোট রুম',
// //                           value: roomSnap.hasData ? '$totalRooms' : '—',
// //                           color: const Color(0xFF0891B2),
// //                           isDark: isDark),
// //                       const SizedBox(width: 10),
// //                       _statCard(
// //                           icon: Icons.people_rounded,
// //                           label: 'ভাড়া দেওয়া',
// //                           value: roomSnap.hasData ? '$occupied' : '—',
// //                           color: const Color(0xFF059669),
// //                           isDark: isDark),
// //                       const SizedBox(width: 10),
// //                       _statCard(
// //                           icon: Icons.door_back_door_outlined,
// //                           label: 'খালি রুম',
// //                           value: roomSnap.hasData ? '$vacant' : '—',
// //                           color: const Color(0xFFD97706),
// //                           isDark: isDark),
// //                     ],
// //                   );
// //                 },
// //               );
// //             },
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _statCard({
// //     required IconData icon,
// //     required String label,
// //     required String value,
// //     required Color color,
// //     required bool isDark,
// //   }) {
// //     return Expanded(
// //       child: Container(
// //         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
// //         decoration: BoxDecoration(
// //           color: color.withOpacity(isDark ? 0.15 : 0.1),
// //           borderRadius: BorderRadius.circular(14),
// //           border: Border.all(color: color.withOpacity(0.3)),
// //         ),
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Icon(icon, color: color, size: 20),
// //             const SizedBox(height: 4),
// //             Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
// //             Text(label,
// //                 style: TextStyle(fontSize: 9, color: color.withOpacity(0.8)),
// //                 overflow: TextOverflow.ellipsis,
// //                 textAlign: TextAlign.center),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildEmptyState(BuildContext context, String landlordId, Color primary, Color textSecondary) {
// //     return Center(
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Container(
// //             width: 100,
// //             height: 100,
// //             decoration: BoxDecoration(color: primary.withOpacity(0.1), shape: BoxShape.circle),
// //             child: Icon(Icons.home_work_outlined, size: 50, color: primary.withOpacity(0.5)),
// //           ),
// //           const SizedBox(height: 20),
// //           const Text('কোনো Property নেই',
// //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //           const SizedBox(height: 8),
// //           Text('নিচের বাটন দিয়ে property যোগ করুন',
// //               style: TextStyle(fontSize: 14, color: textSecondary)),
// //           const SizedBox(height: 24),
// //           FilledButton.icon(
// //             onPressed: () => Navigator.push(
// //               context,
// //               MaterialPageRoute(builder: (_) => AddEditPropertyScreen(landlordId: landlordId)),
// //             ),
// //             icon: const Icon(Icons.add_rounded),
// //             label: const Text('Property যোগ করুন'),
// //             style: FilledButton.styleFrom(
// //               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
// //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // ── Property Card ─────────────────────────────────────────────────────────────
// // // FIX 2: property.totalRooms কে fallback হিসেবে আর ব্যবহার করা হচ্ছে না।
// // // সবসময় Firestore থেকে actual room count নেওয়া হচ্ছে।
// // // Loading এ '—' দেখাবে, data আসলে actual count দেখাবে। Flicker বন্ধ।

// // class _PropertyCard extends StatelessWidget {
// //   final PropertyModel property;
// //   final PropertyService service;
// //   final bool isDark;
// //   final Color primary;
// //   final Color textPrimary;
// //   final Color textSecondary;
// //   final int index;
// //   final VoidCallback onTap;
// //   final VoidCallback onEdit;

// //   const _PropertyCard({
// //     required this.property,
// //     required this.service,
// //     required this.isDark,
// //     required this.primary,
// //     required this.textPrimary,
// //     required this.textSecondary,
// //     required this.index,
// //     required this.onTap,
// //     required this.onEdit,
// //   });

// //   static const List<Color> _iconColors = [
// //     Color(0xFF2D7A4F),
// //     Color(0xFF0891B2),
// //     Color(0xFFD97706),
// //     Color(0xFF5B4FBF),
// //     Color(0xFF059669),
// //   ];

// //   @override
// //   Widget build(BuildContext context) {
// //     final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
// //     final iconBg = _iconColors[index % _iconColors.length];

// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 12),
// //       decoration: BoxDecoration(
// //         color: cardBg,
// //         borderRadius: BorderRadius.circular(18),
// //         boxShadow: [
// //           BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
// //         ],
// //       ),
// //       child: Material(
// //         color: Colors.transparent,
// //         borderRadius: BorderRadius.circular(18),
// //         child: InkWell(
// //           onTap: onTap,
// //           borderRadius: BorderRadius.circular(18),
// //           child: Padding(
// //             padding: const EdgeInsets.all(16),
// //             child: Column(
// //               children: [
// //                 // ── Header row ──
// //                 Row(
// //                   children: [
// //                     Container(
// //                       width: 50,
// //                       height: 50,
// //                       decoration: BoxDecoration(
// //                         color: iconBg,
// //                         borderRadius: BorderRadius.circular(14),
// //                         boxShadow: [
// //                           BoxShadow(
// //                               color: iconBg.withOpacity(0.35),
// //                               blurRadius: 8,
// //                               offset: const Offset(0, 3)),
// //                         ],
// //                       ),
// //                       child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 24),
// //                     ),
// //                     const SizedBox(width: 14),
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(property.name,
// //                               style: TextStyle(
// //                                   fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
// //                           const SizedBox(height: 3),
// //                           Row(
// //                             children: [
// //                               Icon(Icons.location_on_rounded,
// //                                   size: 12, color: textSecondary.withOpacity(0.7)),
// //                               const SizedBox(width: 3),
// //                               Expanded(
// //                                 child: Text(property.address,
// //                                     style: TextStyle(fontSize: 12, color: textSecondary),
// //                                     overflow: TextOverflow.ellipsis),
// //                               ),
// //                             ],
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                     IconButton(
// //                       icon: const Icon(Icons.forum_outlined, color: Colors.indigo, size: 20),
// //                       tooltip: 'Community Chat',
// //                       onPressed: () => Navigator.push(
// //                         context,
// //                         MaterialPageRoute(
// //                           builder: (_) => CommunityChatScreen(
// //                             propertyId: property.id,
// //                             propertyName: property.name,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                     PopupMenuButton(
// //                       icon: Icon(Icons.more_vert_rounded, color: textSecondary, size: 20),
// //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //                       itemBuilder: (_) => [
// //                         PopupMenuItem(
// //                           value: 'edit',
// //                           child: Row(children: [
// //                             Icon(Icons.edit_outlined, size: 18, color: primary),
// //                             const SizedBox(width: 10),
// //                             const Text('Edit'),
// //                           ]),
// //                         ),
// //                         const PopupMenuItem(
// //                           value: 'delete',
// //                           child: Row(children: [
// //                             Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
// //                             SizedBox(width: 10),
// //                             Text('Delete', style: TextStyle(color: Colors.red)),
// //                           ]),
// //                         ),
// //                       ],
// //                       onSelected: (val) async {
// //                         if (val == 'edit') onEdit();
// //                         if (val == 'delete') await service.deleteProperty(property.id);
// //                       },
// //                     ),
// //                   ],
// //                 ),

// //                 const SizedBox(height: 12),
// //                 Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
// //                 const SizedBox(height: 12),

// //                 // ── Stats row — সবসময় Firestore থেকে real data ──
// //                 // FIX 2: property.totalRooms এর উপর নির্ভর করা বন্ধ।
// //                 // Loading এ '—' placeholder, data আসলে actual count।
// //                 StreamBuilder<QuerySnapshot>(
// //                   stream: FirebaseFirestore.instance
// //                       .collection('rooms')
// //                       .where('propertyId', isEqualTo: property.id)
// //                       .snapshots(),
// //                   builder: (context, snap) {
// //                     // Loading state — '—' দেখাও, flicker হবে না
// //                     if (!snap.hasData) {
// //                       return Row(
// //                         children: [
// //                           _miniStat(icon: Icons.door_front_door_rounded, label: 'মোট রুম', value: '—', color: primary),
// //                           _verticalDivider(),
// //                           _miniStat(icon: Icons.people_rounded, label: 'ভাড়া দেওয়া', value: '—', color: const Color(0xFF059669)),
// //                           _verticalDivider(),
// //                           _miniStat(icon: Icons.door_back_door_outlined, label: 'খালি', value: '—', color: const Color(0xFFD97706)),
// //                         ],
// //                       );
// //                     }

// //                     final rooms = snap.data!.docs;
// //                     final total = rooms.length;
// //                     final occupied = rooms.where((r) {
// //                       final data = r.data() as Map<String, dynamic>;
// //                       return data['status'] == 'occupied';
// //                     }).length;
// //                     final vacant = total - occupied;

// //                     return Row(
// //                       children: [
// //                         _miniStat(icon: Icons.door_front_door_rounded, label: 'মোট রুম', value: '$total', color: primary),
// //                         _verticalDivider(),
// //                         _miniStat(icon: Icons.people_rounded, label: 'ভাড়া দেওয়া', value: '$occupied', color: const Color(0xFF059669)),
// //                         _verticalDivider(),
// //                         _miniStat(icon: Icons.door_back_door_outlined, label: 'খালি', value: '$vacant', color: const Color(0xFFD97706)),
// //                       ],
// //                     );
// //                   },
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _miniStat({
// //     required IconData icon,
// //     required String label,
// //     required String value,
// //     required Color color,
// //   }) {
// //     return Expanded(
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Container(
// //             width: 30,
// //             height: 30,
// //             decoration: BoxDecoration(
// //                 color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
// //             child: Icon(icon, size: 16, color: color),
// //           ),
// //           const SizedBox(width: 8),
// //           Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text(value,
// //                   style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
// //               Text(label, style: TextStyle(fontSize: 10, color: textSecondary)),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _verticalDivider() => Container(
// //         width: 1,
// //         height: 36,
// //         color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
// //       );
// // }







// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../services/auth_service.dart';
// import '../../services/property_service.dart';
// import '../../models/property_model.dart';
// import 'chart_screen.dart';
// import 'add_edit_property_screen.dart';
// import 'room_list_screen.dart';
// import 'tenant_list_screen.dart';
// import 'payment_list_screen.dart';
// import 'notice_screen.dart';
// import 'maintenance_requests_screen.dart';
// import 'utility_screen.dart';
// import 'archive_screen.dart';
// import 'settings_screen.dart';
// import '../../../widgets/profile_avatar.dart';
// import 'rules_screen.dart';
// import 'chat_list_screen.dart';
// import '../community/community_chat_screen.dart';
// import 'to_let_screen.dart';
// import 'rental_requests_screen.dart';

// class LandlordDashboard extends StatefulWidget {
//   const LandlordDashboard({super.key});

//   @override
//   State<LandlordDashboard> createState() => _LandlordDashboardState();
// }

// class _LandlordDashboardState extends State<LandlordDashboard> {
//   int _currentIndex = 0;
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   final List<_NavItem> _bottomItems = const [
//     _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart_rounded, label: 'রিপোর্ট'),
//     _NavItem(icon: Icons.home_work_outlined, activeIcon: Icons.home_work_rounded, label: 'Properties'),
//     _NavItem(icon: Icons.people_outline, activeIcon: Icons.people_rounded, label: 'ভাড়াটিয়া'),
//     _NavItem(icon: Icons.payments_outlined, activeIcon: Icons.payments_rounded, label: 'ভাড়া'),
//     _NavItem(icon: Icons.electric_bolt_outlined, activeIcon: Icons.electric_bolt_rounded, label: 'ইউটিলিটি'),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final user = context.read<AuthService>().currentUser!;
//     final List<Widget> pages = [
//       ChartScreen(scaffoldKey: _scaffoldKey),
//       _PropertyPage(landlordId: user.uid, scaffoldKey: _scaffoldKey),
//       TenantListScreen(scaffoldKey: _scaffoldKey),
//       PaymentListScreen(scaffoldKey: _scaffoldKey),
//       UtilityScreen(scaffoldKey: _scaffoldKey),
//     ];

//     return Scaffold(
//       key: _scaffoldKey,
//       drawer: _AppDrawer(user: user),
//       body: pages[_currentIndex],
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: _currentIndex,
//         onDestinationSelected: (i) => setState(() => _currentIndex = i),
//         destinations: _bottomItems.map((item) => NavigationDestination(
//           icon: Icon(item.icon),
//           selectedIcon: Icon(item.activeIcon),
//           label: item.label,
//         )).toList(),
//       ),
//     );
//   }
// }

// class _NavItem {
//   final IconData icon;
//   final IconData activeIcon;
//   final String label;
//   const _NavItem({required this.icon, required this.activeIcon, required this.label});
// }

// // ── Drawer ────────────────────────────────────────────────────────────────────

// class _AppDrawer extends StatelessWidget {
//   final dynamic user;
//   const _AppDrawer({required this.user});

//   @override
//   Widget build(BuildContext context) {
//     final primary = Theme.of(context).colorScheme.primary;
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
//     final textSecondary = isDark ? Colors.white38 : const Color(0xFF9CA3AF);

//     return Drawer(
//       backgroundColor: bg,
//       child: Column(
//         children: [
//           _DrawerHeader(user: user, primary: primary, isDark: isDark),
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
//               children: [
//                 _DrawerTile(
//                   icon: Icons.person_outline_rounded, iconBg: primary, label: 'আমার প্রোফাইল',
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(context, MaterialPageRoute(
//                       builder: (_) => LandlordProfileScreen(user: user),
//                     ));
//                   },
//                 ),
//                 _DrawerSectionLabel('ভাড়া ব্যবস্থাপনা', textSecondary),
//                 _DrawerTile(
//                   icon: Icons.home_outlined, iconBg: const Color(0xFF059669), label: 'ভাড়া দিন (To-Let)',
//                   onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ToLetScreen())); },
//                 ),
//                 _DrawerTile(
//                   icon: Icons.inbox_rounded, iconBg: const Color(0xFF0891B2), label: 'ভাড়ার আবেদন',
//                   onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => RentalRequestsScreen(landlordId: user.uid))); },
//                 ),
//                 _DrawerSectionLabel('অতিরিক্ত', textSecondary),
//                 _DrawerTile(
//                   icon: Icons.build_outlined, iconBg: const Color(0xFFD97706), label: 'মেরামতের অনুরোধ',
//                   onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const MaintenanceRequestsScreen())); },
//                 ),
//                 _DrawerTile(
//                   icon: Icons.campaign_outlined, iconBg: const Color(0xFF059669), label: 'নোটিশ বোর্ড',
//                   onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const NoticeScreen())); },
//                 ),
//                 _DrawerTile(
//                   icon: Icons.archive_outlined, iconBg: const Color(0xFF6B7280), label: 'আর্কাইভ',
//                   onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ArchiveScreen())); },
//                 ),
//                 _DrawerSectionLabel('অ্যাপ', textSecondary),
//                 _DrawerTile(
//                   icon: Icons.chat_bubble_outline_rounded, iconBg: const Color(0xFF7C3AED), label: 'Messages',
//                   onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListScreen())); },
//                 ),
//                 _DrawerTile(
//                   icon: Icons.gavel_rounded, iconBg: const Color(0xFF059669), label: 'নিয়মাবলী',
//                   onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const RulesScreen())); },
//                 ),
//                 _DrawerTile(
//                   icon: Icons.settings_outlined, iconBg: const Color(0xFF374151), label: 'Settings',
//                   onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())); },
//                 ),
//               ],
//             ),
//           ),
//           _DrawerFooter(onLogout: () => _confirmLogout(context)),
//         ],
//       ),
//     );
//   }

//   void _confirmLogout(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Logout করবেন?', style: TextStyle(fontWeight: FontWeight.w700)),
//         content: const Text('আপনি কি নিশ্চিতভাবে logout করতে চান?'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('না')),
//           FilledButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pop(context);
//               context.read<AuthService>().logout();
//             },
//             child: const Text('হ্যাঁ, Logout'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _DrawerHeader extends StatelessWidget {
//   final dynamic user;
//   final Color primary;
//   final bool isDark;
//   const _DrawerHeader({required this.user, required this.primary, required this.isDark});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft, end: Alignment.bottomRight,
//           colors: isDark
//               ? [const Color(0xFF1A3328), const Color(0xFF0F2018)]
//               : [primary, primary.withOpacity(0.8)],
//         ),
//       ),
//       child: SafeArea(
//         bottom: false,
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Consumer<AuthService>(
//                 builder: (context, auth, _) => ProfileAvatar(
//                   name: auth.currentUser?.name ?? user.name,
//                   photoUrl: auth.currentUser?.photoUrl,
//                   userId: user.uid,
//                   radius: 36,
//                   editable: true,
//                 ),
//               ),
//               const SizedBox(height: 14),
//               Text(user.name,
//                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
//               const SizedBox(height: 3),
//               Text(user.email,
//                   style: const TextStyle(fontSize: 12, color: Colors.white60),
//                   maxLines: 1, overflow: TextOverflow.ellipsis),
//               const SizedBox(height: 10),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: Colors.white30),
//                 ),
//                 child: const Text('বাড়ীওয়ালা',
//                     style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _DrawerTile extends StatelessWidget {
//   final IconData icon;
//   final Color iconBg;
//   final String label;
//   final VoidCallback onTap;
//   const _DrawerTile({required this.icon, required this.iconBg, required this.label, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 2),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(12),
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(12),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//             child: Row(
//               children: [
//                 Container(
//                   width: 38, height: 38,
//                   decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
//                   child: Icon(icon, color: Colors.white, size: 19),
//                 ),
//                 const SizedBox(width: 14),
//                 Text(label, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500)),
//                 const Spacer(),
//                 Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white24 : Colors.black12, size: 18),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _DrawerSectionLabel extends StatelessWidget {
//   final String label;
//   final Color color;
//   const _DrawerSectionLabel(this.label, this.color);
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(12, 16, 12, 6),
//       child: Text(label.toUpperCase(),
//           style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 1.2)),
//     );
//   }
// }

// class _DrawerFooter extends StatelessWidget {
//   final VoidCallback onLogout;
//   const _DrawerFooter({required this.onLogout});

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Container(
//       padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
//       decoration: BoxDecoration(
//         border: Border(top: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB))),
//       ),
//       child: Column(
//         children: [
//           Material(
//             color: Colors.transparent,
//             borderRadius: BorderRadius.circular(12),
//             child: InkWell(
//               onTap: onLogout,
//               borderRadius: BorderRadius.circular(12),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 38, height: 38,
//                       decoration: BoxDecoration(
//                         color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: Colors.red.withOpacity(0.2)),
//                       ),
//                       child: const Icon(Icons.logout_rounded, color: Colors.red, size: 19),
//                     ),
//                     const SizedBox(width: 14),
//                     const Text('Logout', style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w600)),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text('House Manager v1.0.0',
//               style: TextStyle(fontSize: 11, color: isDark ? Colors.white24 : Colors.grey.shade400)),
//           const SizedBox(height: 4),
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════════════════════
// // ── Landlord Profile Screen — settings_screen style, tenant profile এর মতো info
// // ═══════════════════════════════════════════════════════════════════════════════

// class LandlordProfileScreen extends StatelessWidget {
//   final dynamic user;
//   const LandlordProfileScreen({super.key, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     final primary = Theme.of(context).colorScheme.primary;
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
//     final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
//     final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
//     final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);
//     final divider = isDark ? Colors.white10 : const Color(0xFFE5E7EB);

//     return Scaffold(
//       backgroundColor: bg,
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           // ── Collapsing Header — tenant profile এর মতো green gradient ──
//           SliverAppBar(
//             expandedHeight: 240,
//             collapsedHeight: 60,
//             pinned: true,
//             backgroundColor: bg,
//             elevation: 0,
//             leading: IconButton(
//               icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textPrimary),
//               onPressed: () => Navigator.pop(context),
//             ),
//             title: Text('আমার প্রোফাইল',
//                 style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
//             centerTitle: true,
//             flexibleSpace: FlexibleSpaceBar(
//               background: _buildProfileHeader(primary: primary, isDark: isDark),
//             ),
//           ),

//           SliverPadding(
//             padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
//             sliver: SliverList(
//               delegate: SliverChildListDelegate([

//                 // ── Stats Cards — tenant এর মতো ──
//                 _LandlordStatsSection(landlordId: user.uid, primary: primary, isDark: isDark),
//                 const SizedBox(height: 16),

//                 // ── ব্যক্তিগত তথ্য ──
//                 _sectionHeader('ব্যক্তিগত তথ্য', textSecondary),
//                 _card(cardBg, [
//                   _tile(Icons.person_outline_rounded, 'নাম', user.name,
//                       primary, textPrimary, textSecondary, divider, last: false),
//                   _tile(Icons.email_outlined, 'Email', user.email,
//                       const Color(0xFF0891B2), textPrimary, textSecondary, divider, last: false),
//                   _tile(Icons.phone_outlined, 'Phone', user.phone,
//                       const Color(0xFF059669), textPrimary, textSecondary, divider, last: true),
//                 ]),
//                 const SizedBox(height: 12),

//                 // ── অ্যাকাউন্ট তথ্য ──
//                 _sectionHeader('অ্যাকাউন্ট তথ্য', textSecondary),
//                 _card(cardBg, [
//                   _tile(Icons.shield_outlined, 'ভূমিকা', 'বাড়ীওয়ালা',
//                       const Color(0xFF5B4FBF), textPrimary, textSecondary, divider, last: false),
//                   _tile(Icons.verified_user_outlined, 'অ্যাকাউন্ট স্ট্যাটাস', 'সক্রিয়',
//                       const Color(0xFF059669), textPrimary, textSecondary, divider, last: true),
//                 ]),
//                 const SizedBox(height: 24),

//                 // ── Logout — settings_screen এর মতো ──
//                 GestureDetector(
//                   onTap: () => _confirmLogout(context),
//                   child: Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(14),
//                       border: Border.all(color: Colors.red.withOpacity(0.5), width: 1.5),
//                       color: Colors.red.withOpacity(isDark ? 0.08 : 0.04),
//                     ),
//                     child: const Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.logout_rounded, color: Colors.red, size: 20),
//                         SizedBox(width: 10),
//                         Text('Logout',
//                             style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w700)),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//               ]),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Profile header: tenant profile এর মতো centered avatar + name + badge ──
//   // Widget _buildProfileHeader({required Color primary, required bool isDark}) {
//   //   return Container(
//   //     decoration: BoxDecoration(
//   //       gradient: LinearGradient(
//   //         begin: Alignment.topLeft, end: Alignment.bottomRight,
//   //         colors: isDark
//   //             ? [const Color(0xFF1A3328), const Color(0xFF0F1A14)]
//   //             : [primary, primary.withOpacity(0.75)],
//   //       ),
//   //     ),
//   //     child: SafeArea(
//   //       child: Padding(
//   //         // padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
//   //         padding: const EdgeInsets.fromLTRB(20, 50, 20, 12),
//   //         child: Column(
//   //           mainAxisAlignment: MainAxisAlignment.center,
//   //           children: [
//   //             // ✅ Editable avatar — profile pic upload support
//   //             Consumer<AuthService>(
//   //               builder: (context, auth, _) => ProfileAvatar(
//   //                 name: auth.currentUser?.name ?? user.name,
//   //                 photoUrl: auth.currentUser?.photoUrl,
//   //                 userId: user.uid,
//   //                 radius: 46,
//   //                 editable: true,
//   //               ),
//   //             ),
//   //             // const SizedBox(height: 12),
//   //             const SizedBox(height: 8),
//   //             Text(user.name,
//   //                 style: const TextStyle(
//   //                     color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
//   //             // const SizedBox(height: 8),
//   //             const SizedBox(height: 6),
//   //             Container(
//   //               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
//   //               decoration: BoxDecoration(
//   //                 color: Colors.white.withOpacity(0.2),
//   //                 borderRadius: BorderRadius.circular(20),
//   //                 border: Border.all(color: Colors.white30),
//   //               ),
//   //               child: const Row(
//   //                 mainAxisSize: MainAxisSize.min,
//   //                 children: [
//   //                   Icon(Icons.home_work_rounded, size: 13, color: Colors.white),
//   //                   SizedBox(width: 5),
//   //                   Text('বাড়ীওয়ালা',
//   //                       style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
//   //                 ],
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }

//   Widget _buildProfileHeader({required Color primary, required bool isDark}) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft, end: Alignment.bottomRight,
//           colors: isDark
//               ? [const Color(0xFF1A3328), const Color(0xFF0F1A14)]
//               : [primary, primary.withOpacity(0.75)],
//         ),
//       ),
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 50, 20, 12), // ← top 60→50, bottom 20→12
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             mainAxisSize: MainAxisSize.min, // ← এটা add করো
//             children: [
//               Consumer<AuthService>(
//                 builder: (context, auth, _) => ProfileAvatar(
//                   name: auth.currentUser?.name ?? user.name,
//                   photoUrl: auth.currentUser?.photoUrl,
//                   userId: user.uid,
//                   radius: 44, // ← 46→44 (2px কম)
//                   editable: true,
//                 ),
//               ),
//               const SizedBox(height: 8), // ← 12→8
//               Text(user.name,
//                   style: const TextStyle(
//                       color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
//               const SizedBox(height: 6), // ← 8→6
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: Colors.white30),
//                 ),
//                 child: const Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.home_work_rounded, size: 13, color: Colors.white),
//                     SizedBox(width: 5),
//                     Text('বাড়ীওয়ালা',
//                         style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _sectionHeader(String title, Color color) => Padding(
//         padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
//         child: Text(title,
//             style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5)),
//       );

//   Widget _card(Color bg, List<Widget> children) => Container(
//         decoration: BoxDecoration(
//           color: bg,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
//         ),
//         child: Column(children: children),
//       );

//   Widget _tile(
//     IconData icon, String label, String value, Color iconColor,
//     Color textPrimary, Color textSecondary, Color dividerColor, {required bool last}
//   ) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
//           child: Row(
//             children: [
//               Container(
//                 width: 40, height: 40,
//                 decoration: BoxDecoration(
//                   color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
//                 child: Icon(icon, color: iconColor, size: 20),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(label, style: TextStyle(fontSize: 11, color: textSecondary)),
//                     const SizedBox(height: 2),
//                     SelectableText(value,
//                         style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary)),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         if (!last)
//           Padding(
//             padding: const EdgeInsets.only(left: 70),
//             child: Divider(height: 1, color: dividerColor),
//           ),
//       ],
//     );
//   }

//   void _confirmLogout(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Logout করবেন?', style: TextStyle(fontWeight: FontWeight.w700)),
//         content: const Text('আপনি কি নিশ্চিতভাবে logout করতে চান?'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('না')),
//           FilledButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.of(context).popUntil((route) => route.isFirst);
//               context.read<AuthService>().logout();
//             },
//             child: const Text('হ্যাঁ, Logout'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Landlord Stats — Properties / Rooms / Tenants / Vacant ───────────────────

// class _LandlordStatsSection extends StatelessWidget {
//   final String landlordId;
//   final Color primary;
//   final bool isDark;
//   const _LandlordStatsSection({required this.landlordId, required this.primary, required this.isDark});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('properties')
//           .where('landlordId', isEqualTo: landlordId)
//           .snapshots(),
//       builder: (context, propSnap) {
//         final propIds = propSnap.data?.docs.map((d) => d.id).toList() ?? [];
//         final propCount = propIds.length;

//         return FutureBuilder<QuerySnapshot?>(
//           future: propIds.isEmpty
//               ? Future.value(null)
//               : FirebaseFirestore.instance
//                   .collection('rooms')
//                   .where('propertyId', whereIn: propIds)
//                   .get(),
//           builder: (context, roomSnap) {
//             final rooms = roomSnap.data?.docs ?? [];
//             final totalRooms = rooms.length;
//             final occupied = rooms.where((r) =>
//                 (r.data() as Map<String, dynamic>)['status'] == 'occupied').length;

//             return FutureBuilder<QuerySnapshot>(
//               future: FirebaseFirestore.instance
//                   .collection('tenants')
//                   .where('landlordId', isEqualTo: landlordId)
//                   .where('isActive', isEqualTo: true)
//                   .get(),
//               builder: (context, tenantSnap) {
//                 final tenantCount = tenantSnap.data?.docs.length ?? 0;
//                 return Row(
//                   children: [
//                     _stat('🏘️', '$propCount', 'Properties', primary),
//                     const SizedBox(width: 10),
//                     _stat('🚪', '$totalRooms', 'মোট রুম', const Color(0xFF0891B2)),
//                     const SizedBox(width: 10),
//                     _stat('👥', '$tenantCount', 'ভাড়াটিয়া', const Color(0xFF059669)),
//                     const SizedBox(width: 10),
//                     _stat('🔓', '${totalRooms - occupied}', 'খালি', const Color(0xFFD97706)),
//                   ],
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _stat(String emoji, String value, String label, Color color) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
//         decoration: BoxDecoration(
//           color: color.withOpacity(isDark ? 0.15 : 0.08),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: color.withOpacity(0.25)),
//         ),
//         child: Column(
//           children: [
//             Text(emoji, style: const TextStyle(fontSize: 20)),
//             const SizedBox(height: 4),
//             Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
//             const SizedBox(height: 2),
//             Text(label,
//                 style: TextStyle(fontSize: 9, color: color.withOpacity(0.8)),
//                 textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Property Page ─────────────────────────────────────────────────────────────

// class _PropertyPage extends StatelessWidget {
//   final String landlordId;
//   final GlobalKey<ScaffoldState>? scaffoldKey;
//   const _PropertyPage({required this.landlordId, this.scaffoldKey});

//   @override
//   Widget build(BuildContext context) {
//     final service = PropertyService();
//     final user = context.read<AuthService>().currentUser!;
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final primary = Theme.of(context).colorScheme.primary;
//     final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
//     final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
//     final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);

//     return Scaffold(
//       backgroundColor: bg,
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           SliverAppBar(
//             expandedHeight: 200,
//             collapsedHeight: 60,
//             pinned: true,
//             backgroundColor: bg,
//             elevation: 0,
//             leading: IconButton(
//               icon: Icon(Icons.menu_rounded, color: textPrimary),
//               onPressed: () => scaffoldKey?.currentState?.openDrawer(),
//             ),
//             title: Text('স্বাগতম, ${user.name.split(' ')[0]}!',
//                 style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
//             centerTitle: true,
//             flexibleSpace: FlexibleSpaceBar(
//               background: _buildHeader(
//                   context: context, primary: primary, isDark: isDark,
//                   textPrimary: textPrimary, landlordId: landlordId, service: service),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
//               child: Row(children: [
//                 Container(width: 4, height: 20,
//                     decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(2))),
//                 const SizedBox(width: 10),
//                 Text('আমার Properties',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary)),
//               ]),
//             ),
//           ),
//           StreamBuilder<List<PropertyModel>>(
//             stream: service.getProperties(landlordId),
//             builder: (context, snap) {
//               if (snap.connectionState == ConnectionState.waiting) {
//                 return SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: primary)));
//               }
//               final properties = snap.data ?? [];
//               if (properties.isEmpty) {
//                 return SliverFillRemaining(child: _buildEmptyState(context, landlordId, primary, textSecondary));
//               }
//               return SliverPadding(
//                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
//                 sliver: SliverList(
//                   delegate: SliverChildBuilderDelegate(
//                     (ctx, i) => _PropertyCard(
//                       property: properties[i], service: service,
//                       isDark: isDark, primary: primary,
//                       textPrimary: textPrimary, textSecondary: textSecondary, index: i,
//                       onTap: () => Navigator.push(context,
//                           MaterialPageRoute(builder: (_) => RoomListScreen(property: properties[i]))),
//                       onEdit: () => Navigator.push(context,
//                           MaterialPageRoute(builder: (_) => AddEditPropertyScreen(
//                               landlordId: landlordId, property: properties[i]))),
//                     ),
//                     childCount: properties.length,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       floatingActionButton: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [BoxShadow(color: primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
//         ),
//         child: FloatingActionButton.extended(
//           onPressed: () => Navigator.push(context,
//               MaterialPageRoute(builder: (_) => AddEditPropertyScreen(landlordId: landlordId))),
//           icon: const Icon(Icons.add_rounded),
//           label: const Text('Property যোগ করুন', style: TextStyle(fontWeight: FontWeight.w700)),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader({
//     required BuildContext context, required Color primary, required bool isDark,
//     required Color textPrimary, required String landlordId, required PropertyService service,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft, end: Alignment.bottomRight,
//           colors: isDark
//               ? [const Color(0xFF1A3328), const Color(0xFF0F1A14)]
//               : [const Color(0xFFE8F5EE), const Color(0xFFF5FAF7)],
//         ),
//       ),
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(16, 64, 16, 12),
//           child: StreamBuilder<List<PropertyModel>>(
//             stream: service.getProperties(landlordId),
//             builder: (context, snap) {
//               if (!snap.hasData) {
//                 return Row(children: [
//                   _statCard(icon: Icons.home_work_rounded, label: 'Properties', value: '—', color: primary, isDark: isDark),
//                   const SizedBox(width: 10),
//                   _statCard(icon: Icons.door_front_door_rounded, label: 'মোট রুম', value: '—', color: const Color(0xFF0891B2), isDark: isDark),
//                   const SizedBox(width: 10),
//                   _statCard(icon: Icons.people_rounded, label: 'ভাড়া দেওয়া', value: '—', color: const Color(0xFF059669), isDark: isDark),
//                   const SizedBox(width: 10),
//                   _statCard(icon: Icons.door_back_door_outlined, label: 'খালি রুম', value: '—', color: const Color(0xFFD97706), isDark: isDark),
//                 ]);
//               }
//               final properties = snap.data!;
//               final totalProperties = properties.length;
//               return FutureBuilder<QuerySnapshot?>(
//                 future: totalProperties == 0
//                     ? Future.value(null)
//                     : FirebaseFirestore.instance
//                         .collection('rooms')
//                         .where('propertyId', whereIn: properties.map((p) => p.id).toList())
//                         .get(),
//                 builder: (context, roomSnap) {
//                   int totalRooms = 0, occupied = 0;
//                   if (roomSnap.hasData && roomSnap.data != null) {
//                     final rooms = roomSnap.data!.docs;
//                     totalRooms = rooms.length;
//                     occupied = rooms.where((r) =>
//                         (r.data() as Map<String, dynamic>)['status'] == 'occupied').length;
//                   }
//                   return Row(children: [
//                     _statCard(icon: Icons.home_work_rounded, label: 'Properties', value: '$totalProperties', color: primary, isDark: isDark),
//                     const SizedBox(width: 10),
//                     _statCard(icon: Icons.door_front_door_rounded, label: 'মোট রুম', value: roomSnap.hasData ? '$totalRooms' : '—', color: const Color(0xFF0891B2), isDark: isDark),
//                     const SizedBox(width: 10),
//                     _statCard(icon: Icons.people_rounded, label: 'ভাড়া দেওয়া', value: roomSnap.hasData ? '$occupied' : '—', color: const Color(0xFF059669), isDark: isDark),
//                     const SizedBox(width: 10),
//                     _statCard(icon: Icons.door_back_door_outlined, label: 'খালি রুম', value: roomSnap.hasData ? '${totalRooms - occupied}' : '—', color: const Color(0xFFD97706), isDark: isDark),
//                   ]);
//                 },
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _statCard({required IconData icon, required String label, required String value, required Color color, required bool isDark}) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
//         decoration: BoxDecoration(
//           color: color.withOpacity(isDark ? 0.15 : 0.1),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: color.withOpacity(0.3)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, color: color, size: 20),
//             const SizedBox(height: 4),
//             Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
//             Text(label, style: TextStyle(fontSize: 9, color: color.withOpacity(0.8)),
//                 overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState(BuildContext context, String landlordId, Color primary, Color textSecondary) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 100, height: 100,
//             decoration: BoxDecoration(color: primary.withOpacity(0.1), shape: BoxShape.circle),
//             child: Icon(Icons.home_work_outlined, size: 50, color: primary.withOpacity(0.5)),
//           ),
//           const SizedBox(height: 20),
//           const Text('কোনো Property নেই', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           Text('নিচের বাটন দিয়ে property যোগ করুন', style: TextStyle(fontSize: 14, color: textSecondary)),
//           const SizedBox(height: 24),
//           FilledButton.icon(
//             onPressed: () => Navigator.push(context,
//                 MaterialPageRoute(builder: (_) => AddEditPropertyScreen(landlordId: landlordId))),
//             icon: const Icon(Icons.add_rounded),
//             label: const Text('Property যোগ করুন'),
//             style: FilledButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Property Card ─────────────────────────────────────────────────────────────

// class _PropertyCard extends StatelessWidget {
//   final PropertyModel property;
//   final PropertyService service;
//   final bool isDark;
//   final Color primary;
//   final Color textPrimary;
//   final Color textSecondary;
//   final int index;
//   final VoidCallback onTap;
//   final VoidCallback onEdit;

//   const _PropertyCard({
//     required this.property, required this.service, required this.isDark,
//     required this.primary, required this.textPrimary, required this.textSecondary,
//     required this.index, required this.onTap, required this.onEdit,
//   });

//   static const List<Color> _iconColors = [
//     Color(0xFF2D7A4F), Color(0xFF0891B2), Color(0xFFD97706),
//     Color(0xFF5B4FBF), Color(0xFF059669),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
//     final iconBg = _iconColors[index % _iconColors.length];

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: cardBg, borderRadius: BorderRadius.circular(18),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
//       ),
//       child: Material(
//         color: Colors.transparent, borderRadius: BorderRadius.circular(18),
//         child: InkWell(
//           onTap: onTap, borderRadius: BorderRadius.circular(18),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       width: 50, height: 50,
//                       decoration: BoxDecoration(
//                         color: iconBg, borderRadius: BorderRadius.circular(14),
//                         boxShadow: [BoxShadow(color: iconBg.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3))],
//                       ),
//                       child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 24),
//                     ),
//                     const SizedBox(width: 14),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(property.name,
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
//                           const SizedBox(height: 3),
//                           Row(children: [
//                             Icon(Icons.location_on_rounded, size: 12, color: textSecondary.withOpacity(0.7)),
//                             const SizedBox(width: 3),
//                             Expanded(child: Text(property.address,
//                                 style: TextStyle(fontSize: 12, color: textSecondary),
//                                 overflow: TextOverflow.ellipsis)),
//                           ]),
//                         ],
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.forum_outlined, color: Colors.indigo, size: 20),
//                       onPressed: () => Navigator.push(context, MaterialPageRoute(
//                           builder: (_) => CommunityChatScreen(propertyId: property.id, propertyName: property.name))),
//                     ),
//                     PopupMenuButton(
//                       icon: Icon(Icons.more_vert_rounded, color: textSecondary, size: 20),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       itemBuilder: (_) => [
//                         PopupMenuItem(value: 'edit', child: Row(children: [
//                           Icon(Icons.edit_outlined, size: 18, color: primary), const SizedBox(width: 10), const Text('Edit'),
//                         ])),
//                         const PopupMenuItem(value: 'delete', child: Row(children: [
//                           Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
//                           SizedBox(width: 10), Text('Delete', style: TextStyle(color: Colors.red)),
//                         ])),
//                       ],
//                       onSelected: (val) async {
//                         if (val == 'edit') onEdit();
//                         if (val == 'delete') await service.deleteProperty(property.id);
//                       },
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
//                 const SizedBox(height: 12),
//                 StreamBuilder<QuerySnapshot>(
//                   stream: FirebaseFirestore.instance
//                       .collection('rooms')
//                       .where('propertyId', isEqualTo: property.id)
//                       .snapshots(),
//                   builder: (context, snap) {
//                     if (!snap.hasData) {
//                       return Row(children: [
//                         _mini('—', 'মোট রুম', primary),
//                         _vDivider(),
//                         _mini('—', 'ভাড়া দেওয়া', const Color(0xFF059669)),
//                         _vDivider(),
//                         _mini('—', 'খালি', const Color(0xFFD97706)),
//                       ]);
//                     }
//                     final rooms = snap.data!.docs;
//                     final total = rooms.length;
//                     final occ = rooms.where((r) =>
//                         (r.data() as Map<String, dynamic>)['status'] == 'occupied').length;
//                     return Row(children: [
//                       _mini('$total', 'মোট রুম', primary),
//                       _vDivider(),
//                       _mini('$occ', 'ভাড়া দেওয়া', const Color(0xFF059669)),
//                       _vDivider(),
//                       _mini('${total - occ}', 'খালি', const Color(0xFFD97706)),
//                     ]);
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _mini(String value, String label, Color color) {
//     return Expanded(
//       child: Column(
//         children: [
//           Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
//           Text(label, style: TextStyle(fontSize: 10, color: textSecondary)),
//         ],
//       ),
//     );
//   }

//   Widget _vDivider() =>
//       Container(width: 1, height: 30, color: isDark ? Colors.white10 : const Color(0xFFE5E7EB));
// }








import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import '../community/community_chat_screen.dart';
import 'to_let_screen.dart';
import 'rental_requests_screen.dart';

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
    _NavItem(icon: Icons.electric_bolt_outlined, activeIcon: Icons.electric_bolt_rounded, label: 'ইউটিলিটি'),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser!;
    final List<Widget> pages = [
      ChartScreen(scaffoldKey: _scaffoldKey),
      _PropertyPage(landlordId: user.uid, scaffoldKey: _scaffoldKey),
      TenantListScreen(scaffoldKey: _scaffoldKey),
      PaymentListScreen(scaffoldKey: _scaffoldKey),
      UtilityScreen(scaffoldKey: _scaffoldKey),
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

// ── Drawer ────────────────────────────────────────────────────────────────────

class _AppDrawer extends StatelessWidget {
  final dynamic user;
  const _AppDrawer({required this.user});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
    final textSecondary = isDark ? Colors.white38 : const Color(0xFF9CA3AF);

    return Drawer(
      backgroundColor: bg,
      child: Column(
        children: [
          _DrawerHeader(user: user, primary: primary, isDark: isDark),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              children: [
                _DrawerTile(
                  icon: Icons.person_outline_rounded, iconBg: primary, label: 'আমার প্রোফাইল',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => LandlordProfileScreen(user: user),
                    ));
                  },
                ),
                _DrawerSectionLabel('ভাড়া ব্যবস্থাপনা', textSecondary),
                _DrawerTile(
                  icon: Icons.home_outlined, iconBg: const Color(0xFF059669), label: 'ভাড়া দিন (To-Let)',
                  onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ToLetScreen())); },
                ),
                _DrawerTile(
                  icon: Icons.inbox_rounded, iconBg: const Color(0xFF0891B2), label: 'ভাড়ার আবেদন',
                  onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => RentalRequestsScreen(landlordId: user.uid))); },
                ),
                _DrawerSectionLabel('অতিরিক্ত', textSecondary),
                _DrawerTile(
                  icon: Icons.build_outlined, iconBg: const Color(0xFFD97706), label: 'মেরামতের অনুরোধ',
                  onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const MaintenanceRequestsScreen())); },
                ),
                _DrawerTile(
                  icon: Icons.campaign_outlined, iconBg: const Color(0xFF059669), label: 'নোটিশ বোর্ড',
                  onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const NoticeScreen())); },
                ),
                _DrawerTile(
                  icon: Icons.archive_outlined, iconBg: const Color(0xFF6B7280), label: 'আর্কাইভ',
                  onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ArchiveScreen())); },
                ),
                _DrawerSectionLabel('অ্যাপ', textSecondary),
                _DrawerTile(
                  icon: Icons.chat_bubble_outline_rounded, iconBg: const Color(0xFF7C3AED), label: 'Messages',
                  onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListScreen())); },
                ),
                _DrawerTile(
                  icon: Icons.gavel_rounded, iconBg: const Color(0xFF059669), label: 'নিয়মাবলী',
                  onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const RulesScreen())); },
                ),
                _DrawerTile(
                  icon: Icons.settings_outlined, iconBg: const Color(0xFF374151), label: 'Settings',
                  onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())); },
                ),
              ],
            ),
          ),
          _DrawerFooter(onLogout: () => _confirmLogout(context)),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout করবেন?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('আপনি কি নিশ্চিতভাবে logout করতে চান?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('না')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              context.read<AuthService>().logout();
            },
            child: const Text('হ্যাঁ, Logout'),
          ),
        ],
      ),
    );
  }
}

// class _DrawerHeader extends StatelessWidget {
//   final dynamic user;
//   final Color primary;
//   final bool isDark;
//   const _DrawerHeader({required this.user, required this.primary, required this.isDark});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft, end: Alignment.bottomRight,
//           colors: isDark
//               ? [const Color(0xFF1A3328), const Color(0xFF0F2018)]
//               : [primary, primary.withOpacity(0.8)],
//         ),
//       ),
//       child: SafeArea(
//         bottom: false,
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Consumer<AuthService>(
//                 builder: (context, auth, _) => ProfileAvatar(
//                   name: auth.currentUser?.name ?? user.name,
//                   photoUrl: auth.currentUser?.photoUrl,
//                   userId: user.uid,
//                   radius: 36,
//                   editable: true,
//                 ),
//               ),
//               const SizedBox(height: 14),
//               Text(user.name,
//                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
//               const SizedBox(height: 3),
//               Text(user.email,
//                   style: const TextStyle(fontSize: 12, color: Colors.white60),
//                   maxLines: 1, overflow: TextOverflow.ellipsis),
//               const SizedBox(height: 10),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: Colors.white30),
//                 ),
//                 child: const Text('বাড়ীওয়ালা',
//                     style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class _DrawerHeader extends StatelessWidget {
  final dynamic user;
  final Color primary;
  final bool isDark;
  const _DrawerHeader({required this.user, required this.primary, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A3328), const Color(0xFF0F2018)]
              : [primary, primary.withOpacity(0.85)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar + camera badge
              Consumer<AuthService>(
                builder: (context, auth, _) => ProfileAvatar(
                  name: auth.currentUser?.name ?? user.name,
                  photoUrl: auth.currentUser?.photoUrl,
                  userId: user.uid,
                  radius: 38,
                  editable: true,
                ),
              ),
              const SizedBox(height: 16),

              // Name
              Text(user.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: Colors.white, letterSpacing: 0.2)),
              const SizedBox(height: 4),

              // Email
              Text(user.email,
                  style: const TextStyle(fontSize: 12, color: Colors.white60),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 14),

              // Role badge + divider hint
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7, height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4ADE80),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('বাড়ীওয়ালা',
                            style: TextStyle(
                                fontSize: 12, color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// class _DrawerTile extends StatelessWidget {
//   final IconData icon;
//   final Color iconBg;
//   final String label;
//   final VoidCallback onTap;
//   const _DrawerTile({required this.icon, required this.iconBg, required this.label, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 2),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(12),
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(12),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//             child: Row(
//               children: [
//                 Container(
//                   width: 38, height: 38,
//                   decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
//                   child: Icon(icon, color: Colors.white, size: 19),
//                 ),
//                 const SizedBox(width: 14),
//                 Text(label, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500)),
//                 const Spacer(),
//                 Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white24 : Colors.black12, size: 18),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String label;
  final VoidCallback onTap;
  final String? badge; // optional notification badge
  const _DrawerTile({
    required this.icon, required this.iconBg,
    required this.label, required this.onTap, this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final hoverBg = isDark
        ? Colors.white.withOpacity(0.05)
        : const Color(0xFF1A1A1A).withOpacity(0.04);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: hoverBg,
          splashColor: iconBg.withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              children: [
                // Icon box
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: iconBg.withOpacity(0.30),
                        blurRadius: 6, offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 14),

                // Label
                Expanded(
                  child: Text(label,
                      style: TextStyle(
                          color: textColor, fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ),

                // Badge or chevron
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(badge!,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  )
                else
                  Icon(Icons.chevron_right_rounded,
                      color: isDark ? Colors.white24 : Colors.black12, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// class _DrawerSectionLabel extends StatelessWidget {
//   final String label;
//   final Color color;
//   const _DrawerSectionLabel(this.label, this.color);
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(12, 16, 12, 6),
//       child: Text(label.toUpperCase(),
//           style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 1.2)),
//     );
//   }
// }

class _DrawerSectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _DrawerSectionLabel(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 6),
      child: Row(
        children: [
          Container(
            width: 3, height: 12,
            decoration: BoxDecoration(
              color: color.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700,
                color: color, letterSpacing: 1.4),
          ),
        ],
      ),
    );
  }
}


// class _DrawerFooter extends StatelessWidget {
//   final VoidCallback onLogout;
//   const _DrawerFooter({required this.onLogout});

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Container(
//       padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
//       decoration: BoxDecoration(
//         border: Border(top: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB))),
//       ),
//       child: Column(
//         children: [
//           Material(
//             color: Colors.transparent,
//             borderRadius: BorderRadius.circular(12),
//             child: InkWell(
//               onTap: onLogout,
//               borderRadius: BorderRadius.circular(12),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 38, height: 38,
//                       decoration: BoxDecoration(
//                         color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: Colors.red.withOpacity(0.2)),
//                       ),
//                       child: const Icon(Icons.logout_rounded, color: Colors.red, size: 19),
//                     ),
//                     const SizedBox(width: 14),
//                     const Text('Logout', style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w600)),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text('House Manager v1.0.0',
//               style: TextStyle(fontSize: 11, color: isDark ? Colors.white24 : Colors.grey.shade400)),
//           const SizedBox(height: 4),
//         ],
//       ),
//     );
//   }
// }

class _DrawerFooter extends StatelessWidget {
  final VoidCallback onLogout;
  const _DrawerFooter({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(
                color: isDark ? Colors.white10 : const Color(0xFFE5E7EB))),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onLogout,
              borderRadius: BorderRadius.circular(12),
              splashColor: Colors.red.withOpacity(0.08),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(isDark ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.red.withOpacity(0.25)),
                      ),
                      child: const Icon(Icons.logout_rounded,
                          color: Colors.red, size: 18),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text('Logout',
                          style: TextStyle(
                              color: Colors.red, fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: Colors.red.withOpacity(0.4), size: 18),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Version
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_rounded,
                  size: 12,
                  color: isDark ? Colors.white24 : Colors.grey.shade400),
              const SizedBox(width: 4),
              Text('House Manager v1.0.0',
                  style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? Colors.white24
                          : Colors.grey.shade400)),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}


// ═══════════════════════════════════════════════════════════════════════════════
// ── Landlord Profile Screen
// ═══════════════════════════════════════════════════════════════════════════════

class LandlordProfileScreen extends StatelessWidget {
  final dynamic user;
  const LandlordProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final divider = isDark ? Colors.white10 : const Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            collapsedHeight: 60,
            pinned: true,
            backgroundColor: bg,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('আমার প্রোফাইল',
                style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProfileHeader(primary: primary, isDark: isDark),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _LandlordStatsSection(landlordId: user.uid, primary: primary, isDark: isDark),
                const SizedBox(height: 16),

                _sectionHeader('ব্যক্তিগত তথ্য', textSecondary),
                _card(cardBg, [
                  _tile(Icons.person_outline_rounded, 'নাম', user.name,
                      primary, textPrimary, textSecondary, divider, last: false),
                  _tile(Icons.email_outlined, 'Email', user.email,
                      const Color(0xFF0891B2), textPrimary, textSecondary, divider, last: false),
                  _tile(Icons.phone_outlined, 'Phone', user.phone,
                      const Color(0xFF059669), textPrimary, textSecondary, divider, last: true),
                ]),
                const SizedBox(height: 12),

                _sectionHeader('অ্যাকাউন্ট তথ্য', textSecondary),
                _card(cardBg, [
                  _tile(Icons.shield_outlined, 'ভূমিকা', 'বাড়ীওয়ালা',
                      const Color(0xFF5B4FBF), textPrimary, textSecondary, divider, last: false),
                  _tile(Icons.verified_user_outlined, 'অ্যাকাউন্ট স্ট্যাটাস', 'সক্রিয়',
                      const Color(0xFF059669), textPrimary, textSecondary, divider, last: true),
                ]),
                const SizedBox(height: 24),

                GestureDetector(
                  onTap: () => _confirmLogout(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.red.withOpacity(0.5), width: 1.5),
                      color: Colors.red.withOpacity(isDark ? 0.08 : 0.04),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                        SizedBox(width: 10),
                        Text('Logout',
                            style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w700)),
                      ],
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

  Widget _buildProfileHeader({required Color primary, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A3328), const Color(0xFF0F1A14)]
              : [primary, primary.withOpacity(0.75)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer<AuthService>(
                builder: (context, auth, _) => ProfileAvatar(
                  name: auth.currentUser?.name ?? user.name,
                  photoUrl: auth.currentUser?.photoUrl,
                  userId: user.uid,
                  radius: 44,
                  editable: true,
                ),
              ),
              const SizedBox(height: 8),
              Text(user.name,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.home_work_rounded, size: 13, color: Colors.white),
                    SizedBox(width: 5),
                    Text('বাড়ীওয়ালা',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
        child: Text(title,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5)),
      );

  Widget _card(Color bg, List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(children: children),
      );

  Widget _tile(
    IconData icon, String label, String value, Color iconColor,
    Color textPrimary, Color textSecondary, Color dividerColor, {required bool last}
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(fontSize: 11, color: textSecondary)),
                    const SizedBox(height: 2),
                    SelectableText(value,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!last)
          Padding(
            padding: const EdgeInsets.only(left: 70),
            child: Divider(height: 1, color: dividerColor),
          ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout করবেন?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('আপনি কি নিশ্চিতভাবে logout করতে চান?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('না')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).popUntil((route) => route.isFirst);
              context.read<AuthService>().logout();
            },
            child: const Text('হ্যাঁ, Logout'),
          ),
        ],
      ),
    );
  }
}

// ── Landlord Stats ────────────────────────────────────────────────────────────

class _LandlordStatsSection extends StatelessWidget {
  final String landlordId;
  final Color primary;
  final bool isDark;
  const _LandlordStatsSection({required this.landlordId, required this.primary, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('properties')
          .where('landlordId', isEqualTo: landlordId)
          .snapshots(),
      builder: (context, propSnap) {
        final propIds = propSnap.data?.docs.map((d) => d.id).toList() ?? [];
        final propCount = propIds.length;

        return FutureBuilder<QuerySnapshot?>(
          future: propIds.isEmpty
              ? Future.value(null)
              : FirebaseFirestore.instance
                  .collection('rooms')
                  .where('propertyId', whereIn: propIds)
                  .get(),
          builder: (context, roomSnap) {
            final rooms = roomSnap.data?.docs ?? [];
            final totalRooms = rooms.length;
            final occupied = rooms.where((r) =>
                (r.data() as Map<String, dynamic>)['status'] == 'occupied').length;

            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('tenants')
                  .where('landlordId', isEqualTo: landlordId)
                  .where('isActive', isEqualTo: true)
                  .get(),
              builder: (context, tenantSnap) {
                final tenantCount = tenantSnap.data?.docs.length ?? 0;
                return Row(
                  children: [
                    _stat('🏘️', '$propCount', 'Properties', primary),
                    const SizedBox(width: 10),
                    _stat('🚪', '$totalRooms', 'মোট রুম', const Color(0xFF0891B2)),
                    const SizedBox(width: 10),
                    _stat('👥', '$tenantCount', 'ভাড়াটিয়া', const Color(0xFF059669)),
                    const SizedBox(width: 10),
                    _stat('🔓', '${totalRooms - occupied}', 'খালি', const Color(0xFFD97706)),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _stat(String emoji, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 9, color: color.withOpacity(0.8)),
                textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ── Property Page ─────────────────────────────────────────────────────────────

class _PropertyPage extends StatelessWidget {
  final String landlordId;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const _PropertyPage({required this.landlordId, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final service = PropertyService();
    final user = context.read<AuthService>().currentUser!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            collapsedHeight: 60,
            pinned: true,
            backgroundColor: bg,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.menu_rounded, color: textPrimary),
              onPressed: () => scaffoldKey?.currentState?.openDrawer(),
            ),
            title: Text('স্বাগতম, ${user.name.split(' ')[0]}!',
                style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(
                  context: context, primary: primary, isDark: isDark,
                  textPrimary: textPrimary, landlordId: landlordId, service: service),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(children: [
                Container(width: 4, height: 20,
                    decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 10),
                Text('আমার Properties',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary)),
              ]),
            ),
          ),
          StreamBuilder<List<PropertyModel>>(
            stream: service.getProperties(landlordId),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: primary)));
              }
              final properties = snap.data ?? [];
              if (properties.isEmpty) {
                return SliverFillRemaining(child: _buildEmptyState(context, landlordId, primary, textSecondary));
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _PropertyCard(
                      property: properties[i], service: service,
                      isDark: isDark, primary: primary,
                      textPrimary: textPrimary, textSecondary: textSecondary, index: i,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => RoomListScreen(property: properties[i]))),
                      onEdit: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => AddEditPropertyScreen(
                              landlordId: landlordId, property: properties[i]))),
                    ),
                    childCount: properties.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => AddEditPropertyScreen(landlordId: landlordId))),
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Property যোগ করুন', style: TextStyle(fontWeight: FontWeight.w700)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required BuildContext context, required Color primary, required bool isDark,
    required Color textPrimary, required String landlordId, required PropertyService service,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A3328), const Color(0xFF0F1A14)]
              : [const Color(0xFFE8F5EE), const Color(0xFFF5FAF7)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 64, 16, 12),
          child: StreamBuilder<List<PropertyModel>>(
            stream: service.getProperties(landlordId),
            builder: (context, snap) {
              if (!snap.hasData) {
                return Row(children: [
                  _statCard(icon: Icons.home_work_rounded, label: 'Properties', value: '—', color: primary, isDark: isDark),
                  const SizedBox(width: 10),
                  _statCard(icon: Icons.door_front_door_rounded, label: 'মোট রুম', value: '—', color: const Color(0xFF0891B2), isDark: isDark),
                  const SizedBox(width: 10),
                  _statCard(icon: Icons.people_rounded, label: 'ভাড়া দেওয়া', value: '—', color: const Color(0xFF059669), isDark: isDark),
                  const SizedBox(width: 10),
                  _statCard(icon: Icons.door_back_door_outlined, label: 'খালি রুম', value: '—', color: const Color(0xFFD97706), isDark: isDark),
                ]);
              }
              final properties = snap.data!;
              final totalProperties = properties.length;
              return FutureBuilder<QuerySnapshot?>(
                future: totalProperties == 0
                    ? Future.value(null)
                    : FirebaseFirestore.instance
                        .collection('rooms')
                        .where('propertyId', whereIn: properties.map((p) => p.id).toList())
                        .get(),
                builder: (context, roomSnap) {
                  int totalRooms = 0, occupied = 0;
                  if (roomSnap.hasData && roomSnap.data != null) {
                    final rooms = roomSnap.data!.docs;
                    totalRooms = rooms.length;
                    occupied = rooms.where((r) =>
                        (r.data() as Map<String, dynamic>)['status'] == 'occupied').length;
                  }
                  return Row(children: [
                    _statCard(icon: Icons.home_work_rounded, label: 'Properties', value: '$totalProperties', color: primary, isDark: isDark),
                    const SizedBox(width: 10),
                    _statCard(icon: Icons.door_front_door_rounded, label: 'মোট রুম', value: roomSnap.hasData ? '$totalRooms' : '—', color: const Color(0xFF0891B2), isDark: isDark),
                    const SizedBox(width: 10),
                    _statCard(icon: Icons.people_rounded, label: 'ভাড়া দেওয়া', value: roomSnap.hasData ? '$occupied' : '—', color: const Color(0xFF059669), isDark: isDark),
                    const SizedBox(width: 10),
                    _statCard(icon: Icons.door_back_door_outlined, label: 'খালি রুম', value: roomSnap.hasData ? '${totalRooms - occupied}' : '—', color: const Color(0xFFD97706), isDark: isDark),
                  ]);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _statCard({required IconData icon, required String label, required String value, required Color color, required bool isDark}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 9, color: color.withOpacity(0.8)),
                overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String landlordId, Color primary, Color textSecondary) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(color: primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.home_work_outlined, size: 50, color: primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 20),
          const Text('কোনো Property নেই', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('নিচের বাটন দিয়ে property যোগ করুন', style: TextStyle(fontSize: 14, color: textSecondary)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => AddEditPropertyScreen(landlordId: landlordId))),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Property যোগ করুন'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Property Card ─────────────────────────────────────────────────────────────

class _PropertyCard extends StatelessWidget {
  final PropertyModel property;
  final PropertyService service;
  final bool isDark;
  final Color primary;
  final Color textPrimary;
  final Color textSecondary;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _PropertyCard({
    required this.property, required this.service, required this.isDark,
    required this.primary, required this.textPrimary, required this.textSecondary,
    required this.index, required this.onTap, required this.onEdit,
  });

  static const List<Color> _iconColors = [
    Color(0xFF2D7A4F), Color(0xFF0891B2), Color(0xFFD97706),
    Color(0xFF5B4FBF), Color(0xFF059669),
  ];

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final iconBg = _iconColors[index % _iconColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent, borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap, borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: iconBg, borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: iconBg.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(property.name,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
                          const SizedBox(height: 3),
                          Row(children: [
                            Icon(Icons.location_on_rounded, size: 12, color: textSecondary.withOpacity(0.7)),
                            const SizedBox(width: 3),
                            Expanded(child: Text(property.address,
                                style: TextStyle(fontSize: 12, color: textSecondary),
                                overflow: TextOverflow.ellipsis)),
                          ]),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.forum_outlined, color: Colors.indigo, size: 20),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => CommunityChatScreen(propertyId: property.id, propertyName: property.name))),
                    ),
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert_rounded, color: textSecondary, size: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      itemBuilder: (_) => [
                        PopupMenuItem(value: 'edit', child: Row(children: [
                          Icon(Icons.edit_outlined, size: 18, color: primary), const SizedBox(width: 10), const Text('Edit'),
                        ])),
                        const PopupMenuItem(value: 'delete', child: Row(children: [
                          Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                          SizedBox(width: 10), Text('Delete', style: TextStyle(color: Colors.red)),
                        ])),
                      ],
                      onSelected: (val) async {
                        if (val == 'edit') onEdit();
                        if (val == 'delete') await service.deleteProperty(property.id);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
                const SizedBox(height: 12),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('rooms')
                      .where('propertyId', isEqualTo: property.id)
                      .snapshots(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return Row(children: [
                        _mini('—', 'মোট রুম', primary),
                        _vDivider(),
                        _mini('—', 'ভাড়া দেওয়া', const Color(0xFF059669)),
                        _vDivider(),
                        _mini('—', 'খালি', const Color(0xFFD97706)),
                      ]);
                    }
                    final rooms = snap.data!.docs;
                    final total = rooms.length;
                    final occ = rooms.where((r) =>
                        (r.data() as Map<String, dynamic>)['status'] == 'occupied').length;
                    return Row(children: [
                      _mini('$total', 'মোট রুম', primary),
                      _vDivider(),
                      _mini('$occ', 'ভাড়া দেওয়া', const Color(0xFF059669)),
                      _vDivider(),
                      _mini('${total - occ}', 'খালি', const Color(0xFFD97706)),
                    ]);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mini(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 10, color: textSecondary)),
        ],
      ),
    );
  }

  Widget _vDivider() =>
      Container(width: 1, height: 30, color: isDark ? Colors.white10 : const Color(0xFFE5E7EB));
}