// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
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
//     _NavItem(icon: Icons.campaign_outlined, activeIcon: Icons.campaign_rounded, label: 'নোটিশ'),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final user = context.read<AuthService>().currentUser!;

//     final List<Widget> pages = [
//       ChartScreen(scaffoldKey: _scaffoldKey),
//       _PropertyPage(landlordId: user.uid, scaffoldKey: _scaffoldKey),
//       TenantListScreen(scaffoldKey: _scaffoldKey),
//       PaymentListScreen(scaffoldKey: _scaffoldKey),
//       NoticeScreen(scaffoldKey: _scaffoldKey),
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

// // ── Drawer ──────────────────────────────────────────────────────────────────

// class _AppDrawer extends StatelessWidget {
//   final dynamic user;
//   const _AppDrawer({required this.user});

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;

//     return Drawer(
//       child: SafeArea(
//         child: Column(
//           children: [
//             // Profile header
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(color: color.primary),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
                  
//                   Consumer<AuthService>(
//                     builder: (context, auth, _) => ProfileAvatar(
//                       name: auth.currentUser?.name ?? user.name,
//                       photoUrl: auth.currentUser?.photoUrl,
//                       userId: user.uid,
//                       radius: 52,
//                       editable: true,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(user.name,
//                       style: const TextStyle(
//                           fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
//                   Text(user.email,
//                       style: const TextStyle(fontSize: 13, color: Colors.white70)),
//                   const SizedBox(height: 4),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//                     decoration: BoxDecoration(
//                       color: Colors.white24,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: const Text('বাড়ীওয়ালা',
//                         style: TextStyle(fontSize: 12, color: Colors.white)),
//                   ),
//                 ],
//               ),
//             ),

//             Expanded(
//               child: ListView(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 children: [
//                   // My Profile
//                   _DrawerItem(
//                     icon: Icons.person_outline_rounded,
//                     label: 'আমার প্রোফাইল',
//                     onTap: () {
//                       Navigator.pop(context);
//                       Navigator.push(context, MaterialPageRoute(
//                         builder: (_) => _LandlordProfileScreen(user: user),
//                       ));
//                     },
//                   ),

//                   const _DrawerDivider(label: 'অতিরিক্ত'),

//                   _DrawerItem(
//                     icon: Icons.build_outlined,
//                     label: 'মেরামতের অনুরোধ',
//                     onTap: () {
//                       Navigator.pop(context);
//                       Navigator.push(context, MaterialPageRoute(
//                         builder: (_) => const MaintenanceRequestsScreen(),
//                       ));
//                     },
//                   ),
//                   _DrawerItem(
//                     icon: Icons.electric_bolt_outlined,
//                     label: 'ইউটিলিটি বিল',
//                     onTap: () {
//                       Navigator.pop(context);
//                       Navigator.push(context, MaterialPageRoute(
//                         builder: (_) => const UtilityScreen(),
//                       ));
//                     },
//                   ),
//                   _DrawerItem(
//                     icon: Icons.archive_outlined,
//                     label: 'আর্কাইভ',
//                     onTap: () {
//                       Navigator.pop(context);
//                       Navigator.push(context, MaterialPageRoute(
//                         builder: (_) => const ArchiveScreen(),
//                       ));
//                     },
//                   ),

//                   const _DrawerDivider(label: 'অ্যাপ'),

//                   // Chat or Message
//                   _DrawerItem(
//                     icon: Icons.chat_outlined,
//                     label: 'Messages',
//                     onTap: () {
//                       Navigator.pop(context);
//                       Navigator.push(context, MaterialPageRoute(
//                         builder: (_) => const ChatListScreen(),
//                       ));
//                     },
//                   ),

//                   // Rules
//                   _DrawerItem(
//                     icon: Icons.gavel_rounded,
//                     label: 'নিয়মাবলী',
//                     onTap: () {
//                       Navigator.pop(context);
//                       Navigator.push(context, MaterialPageRoute(
//                         builder: (_) => const RulesScreen(),
//                       ));
//                     },
//                   ),

//                   _DrawerItem(
//                     icon: Icons.settings_outlined,
//                     label: 'Settings',
//                     onTap: () {
//                       Navigator.pop(context);
//                       Navigator.push(context, MaterialPageRoute(
//                         builder: (_) => const SettingsScreen(),
//                       ));
//                     },
//                   ),

//                   const SizedBox(height: 8),

//                   // Logout
//                   _DrawerItem(
//                     icon: Icons.logout_rounded,
//                     label: 'Logout',
//                     color: Colors.red,
//                     onTap: () {
//                       Navigator.pop(context);
//                       _confirmLogout(context);
//                     },
//                   ),
//                 ],
//               ),
//             ),

//             // App version
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Text('House Manager v1.0',
//                   style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _confirmLogout(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Logout'),
//         content: const Text('আপনি কি logout করতে চান?'),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('না')),
//           FilledButton(
//             onPressed: () {
//               Navigator.pop(context);
//               context.read<AuthService>().logout();
//             },
//             child: const Text('হ্যাঁ'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _DrawerItem extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;
//   final Color? color;
//   const _DrawerItem({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//     this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final c = color ?? Theme.of(context).colorScheme.onSurface;
//     return ListTile(
//       leading: Icon(icon, color: c, size: 22),
//       title: Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w500)),
//       onTap: onTap,
//       horizontalTitleGap: 8,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
//     );
//   }
// }

// class _DrawerDivider extends StatelessWidget {
//   final String label;
//   const _DrawerDivider({required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
//       child: Text(label.toUpperCase(),
//           style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey.shade500,
//               letterSpacing: 1)),
//     );
//   }
// }

// // ── Landlord Profile Screen ─────────────────────────────────────────────────

// class _InfoTile extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final ColorScheme color;
//   const _InfoTile({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color.surface,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: color.outlineVariant.withOpacity(0.5)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: color.primary.withOpacity(0.08),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: color.primary, size: 20),
//           ),
//           const SizedBox(width: 14),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(label,
//                   style: TextStyle(
//                       fontSize: 11,
//                       color: color.onSurface.withOpacity(0.5))),
//               const SizedBox(height: 2),
//               Text(value,
//                   style: const TextStyle(
//                       fontSize: 15, fontWeight: FontWeight.w600)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _LandlordProfileScreen extends StatelessWidget {
//   final dynamic user;
//   const _LandlordProfileScreen({required this.user});

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;
//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             expandedHeight: 220,
//             pinned: true,
//             backgroundColor: color.primary,
//             iconTheme: const IconThemeData(color: Colors.white),
//             title: const Text('আমার প্রোফাইল',
//                 style: TextStyle(color: Colors.white, fontSize: 16)),
//             flexibleSpace: FlexibleSpaceBar(
//               background: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [color.primary, color.primary.withOpacity(0.75)],
//                   ),
//                 ),
//                 child: SafeArea(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const SizedBox(height: 32),
//                       Container(
//                         padding: const EdgeInsets.all(3),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(color: Colors.white, width: 2.5),
//                         ),
//                         child: CircleAvatar(
//                           radius: 44,
//                           backgroundColor: Colors.white24,
//                           child: Text(
//                             user.name.isNotEmpty
//                                 ? user.name[0].toUpperCase()
//                                 : 'L',
//                             style: const TextStyle(
//                                 fontSize: 38,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(user.name,
//                           style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white)),
//                       const SizedBox(height: 5),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 14, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.white24,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: const Text('বাড়ীওয়ালা',
//                             style:
//                                 TextStyle(fontSize: 12, color: Colors.white)),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('যোগাযোগের তথ্য',
//                       style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: color.primary,
//                           letterSpacing: 0.5)),
//                   const SizedBox(height: 10),
//                   _InfoTile(
//                     icon: Icons.email_outlined,
//                     label: 'Email',
//                     value: user.email,
//                     color: color,
//                   ),
//                   const SizedBox(height: 10),
//                   _InfoTile(
//                     icon: Icons.phone_outlined,
//                     label: 'Phone',
//                     value: user.phone,
//                     color: color,
//                   ),
//                   const SizedBox(height: 10),
//                   _InfoTile(
//                     icon: Icons.home_rounded,
//                     label: 'Role',
//                     value: 'Landlord',
//                     color: color,
//                   ),
//                   const SizedBox(height: 32),
//                   SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: OutlinedButton.icon(
//                       onPressed: () {
//                         Navigator.pop(context);
//                         context.read<AuthService>().logout();
//                       },
//                       icon: const Icon(Icons.logout_rounded,
//                           color: Colors.red),
//                       label: const Text('Logout',
//                           style: TextStyle(
//                               color: Colors.red,
//                               fontWeight: FontWeight.w600)),
//                       style: OutlinedButton.styleFrom(
//                         side: const BorderSide(color: Colors.red),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14)),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // class _LandlordProfileScreen extends StatelessWidget {
// //   final dynamic user;
// //   const _LandlordProfileScreen({required this.user});

// //   @override
// //   Widget build(BuildContext context) {
// //     final color = Theme.of(context).colorScheme;
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('আমার প্রোফাইল'), centerTitle: true),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(24),
// //         child: Column(
// //           children: [
// //             const SizedBox(height: 16),
// //             CircleAvatar(
// //               radius: 52,
// //               backgroundColor: color.primaryContainer,
// //               child: Text(
// //                 user.name.isNotEmpty ? user.name[0].toUpperCase() : 'L',
// //                 style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: color.primary),
// //               ),
// //             ),
// //             const SizedBox(height: 16),
// //             Text(user.name,
// //                 style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
// //             const SizedBox(height: 4),
// //             Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
// //               decoration: BoxDecoration(
// //                 color: color.primaryContainer,
// //                 borderRadius: BorderRadius.circular(20),
// //               ),
// //               child: Text('বাড়ীওয়ালা',
// //                   style: TextStyle(color: color.primary, fontWeight: FontWeight.w500)),
// //             ),
// //             const SizedBox(height: 32),

// //             // Info cards
// //             _profileRow(context, Icons.email_outlined, 'Email', user.email),
// //             _profileRow(context, Icons.phone_outlined, 'Phone', user.phone),
// //             _profileRow(context, Icons.home_rounded, 'Role', 'Landlord'),

// //             const SizedBox(height: 32),

// //             // Logout button
// //             SizedBox(
// //               width: double.infinity,
// //               height: 50,
// //               child: OutlinedButton.icon(
// //                 onPressed: () {
// //                   Navigator.pop(context);
// //                   context.read<AuthService>().logout();
// //                 },
// //                 icon: const Icon(Icons.logout_rounded, color: Colors.red),
// //                 label: const Text('Logout', style: TextStyle(color: Colors.red)),
// //                 style: OutlinedButton.styleFrom(
// //                   side: const BorderSide(color: Colors.red),
// //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _profileRow(BuildContext context, IconData icon, String label, String value) {
// //     final color = Theme.of(context).colorScheme;
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 12),
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: color.surface,
// //         borderRadius: BorderRadius.circular(14),
// //         border: Border.all(color: color.outlineVariant),
// //       ),
// //       child: Row(
// //         children: [
// //           Icon(icon, color: color.primary, size: 22),
// //           const SizedBox(width: 14),
// //           Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text(label,
// //                   style: TextStyle(fontSize: 12, color: color.onSurface.withOpacity(0.5))),
// //               Text(value,
// //                   style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // ── Property Page ────────────────────────────────────────────────────────────

// class _PropertyPage extends StatelessWidget {
//   final String landlordId;
//   final GlobalKey<ScaffoldState>? scaffoldKey;
//   const _PropertyPage({required this.landlordId, this.scaffoldKey});

//   @override
//   Widget build(BuildContext context) {
//     final service = PropertyService();
//     final user = context.read<AuthService>().currentUser!;

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.menu_rounded),
//           onPressed: () => scaffoldKey?.currentState?.openDrawer(),
//         ),
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('স্বাগতম, ${user.name.split(' ')[0]}!',
//                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             const Text('আপনার properties', style: TextStyle(fontSize: 11)),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           _SummarySection(landlordId: landlordId, service: service),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
//             child: Row(
//               children: [
//                 const Text('আমার Properties',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                 const Spacer(),
//               ],
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<List<PropertyModel>>(
//               stream: service.getProperties(landlordId),
//               builder: (context, snap) {
//                 if (snap.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 final properties = snap.data ?? [];
//                 if (properties.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(Icons.home_work_outlined, size: 80,
//                             color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
//                         const SizedBox(height: 16),
//                         const Text('কোনো property নেই',
//                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 8),
//                         const Text('নিচের বাটন দিয়ে property যোগ করুন'),
//                         const SizedBox(height: 20),
//                         FilledButton.icon(
//                           onPressed: () => Navigator.push(context, MaterialPageRoute(
//                             builder: (_) => AddEditPropertyScreen(landlordId: landlordId),
//                           )),
//                           icon: const Icon(Icons.add),
//                           label: const Text('Property যোগ করুন'),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//                 return ListView.builder(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   itemCount: properties.length,
//                   itemBuilder: (ctx, i) => _PropertyCard(
//                     property: properties[i],
//                     service: service,
//                     onTap: () => Navigator.push(context, MaterialPageRoute(
//                       builder: (_) => RoomListScreen(property: properties[i]),
//                     )),
//                     onEdit: () => Navigator.push(context, MaterialPageRoute(
//                       builder: (_) => AddEditPropertyScreen(
//                           landlordId: landlordId, property: properties[i]),
//                     )),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => Navigator.push(context, MaterialPageRoute(
//           builder: (_) => AddEditPropertyScreen(landlordId: landlordId),
//         )),
//         icon: const Icon(Icons.add),
//         label: const Text('Property যোগ করুন'),
//       ),
//     );
//   }
// }

// class _SummarySection extends StatelessWidget {
//   final String landlordId;
//   final PropertyService service;
//   const _SummarySection({required this.landlordId, required this.service});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, int>>(
//       future: service.getPropertySummary(landlordId),
//       builder: (context, snap) {
//         final data = snap.data ?? {};
//         return Container(
//           margin: const EdgeInsets.all(16),
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.primary,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Row(
//             children: [
//               _SummaryItem(icon: Icons.home_work_rounded, label: 'Properties', value: '${data['totalProperties'] ?? 0}'),
//               _divider(),
//               _SummaryItem(icon: Icons.door_front_door_rounded, label: 'মোট রুম', value: '${data['totalRooms'] ?? 0}'),
//               _divider(),
//               _SummaryItem(icon: Icons.people_rounded, label: 'ভাড়া দেওয়া', value: '${data['occupiedRooms'] ?? 0}'),
//               _divider(),
//               _SummaryItem(icon: Icons.door_back_door_outlined, label: 'খালি', value: '${data['vacantRooms'] ?? 0}'),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _divider() => Container(
//     width: 1, height: 40, color: Colors.white24,
//     margin: const EdgeInsets.symmetric(horizontal: 8),
//   );
// }

// class _SummaryItem extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   const _SummaryItem({required this.icon, required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Column(
//         children: [
//           Icon(icon, color: Colors.white, size: 22),
//           const SizedBox(height: 4),
//           Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//           Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
//         ],
//       ),
//     );
//   }
// }

// class _PropertyCard extends StatelessWidget {
//   final PropertyModel property;
//   final PropertyService service;
//   final VoidCallback onTap;
//   final VoidCallback onEdit;
//   const _PropertyCard({required this.property, required this.service, required this.onTap, required this.onEdit});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               Container(
//                 width: 52, height: 52,
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.primaryContainer,
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: Icon(Icons.home_work_rounded, color: Theme.of(context).colorScheme.primary),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(property.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                     Text(property.address,
//                         style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
//                     const SizedBox(height: 6),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                       decoration: BoxDecoration(
//                         color: Theme.of(context).colorScheme.primaryContainer,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text('${property.totalRooms} টি রুম',
//                           style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500)),
//                     ),
//                   ],
//                 ),
//               ),

//               // Row এর children এ, PopupMenuButton এর আগে:
//               IconButton(
//                 icon: const Icon(Icons.forum_outlined, color: Colors.indigo),
//                 tooltip: 'Community Chat',
//                 onPressed: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => CommunityChatScreen(
//                       propertyId: property.id,
//                       propertyName: property.name,
//                     ),
//                   ),
//                 ),
//               ),

//               PopupMenuButton(
//                 itemBuilder: (_) => [
//                   const PopupMenuItem(value: 'edit', child: Text('Edit')),
//                   const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
//                 ],
//                 onSelected: (val) async {
//                   if (val == 'edit') onEdit();
//                   if (val == 'delete') await service.deleteProperty(property.id);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }







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
import '../community/community_chat_screen.dart';

class LandlordDashboard extends StatefulWidget {
  const LandlordDashboard({super.key});

  @override
  State<LandlordDashboard> createState() => _LandlordDashboardState();
}

class _LandlordDashboardState extends State<LandlordDashboard> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Landlord Dashboard - Tab
  final List<_NavItem> _bottomItems = const [
    _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart_rounded, label: 'রিপোর্ট'),
    _NavItem(icon: Icons.home_work_outlined, activeIcon: Icons.home_work_rounded, label: 'Properties'),
    _NavItem(icon: Icons.people_outline, activeIcon: Icons.people_rounded, label: 'ভাড়াটিয়া'),
    _NavItem(icon: Icons.payments_outlined, activeIcon: Icons.payments_rounded, label: 'ভাড়া'),
    // _NavItem(icon: Icons.campaign_outlined, activeIcon: Icons.campaign_rounded, label: 'নোটিশ'),
    _NavItem(icon: Icons.electric_bolt_outlined, activeIcon: Icons.electric_bolt_rounded, label: 'ইউটিলিটি'),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser!;

    // Page List
    final List<Widget> pages = [
      ChartScreen(scaffoldKey: _scaffoldKey),
      _PropertyPage(landlordId: user.uid, scaffoldKey: _scaffoldKey),
      TenantListScreen(scaffoldKey: _scaffoldKey),
      PaymentListScreen(scaffoldKey: _scaffoldKey),
      // NoticeScreen(scaffoldKey: _scaffoldKey),
      // UtilityScreen(scaffoldKey: _scaffoldKey),
      const UtilityScreen()
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

// ── Drawer ───────────────────────────────────────────────────────────────────

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
          // ── Profile Header ──────────────────────────
          _DrawerHeader(user: user, primary: primary, isDark: isDark),

          // ── Menu Items ──────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              children: [
                _DrawerTile(
                  icon: Icons.person_outline_rounded,
                  iconBg: primary,
                  label: 'আমার প্রোফাইল',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => _LandlordProfileScreen(user: user),
                    ));
                  },
                ),

                _DrawerSectionLabel('অতিরিক্ত', textSecondary),

                _DrawerTile(
                  icon: Icons.build_outlined,
                  iconBg: const Color(0xFFD97706),
                  label: 'মেরামতের অনুরোধ',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const MaintenanceRequestsScreen(),
                    ));
                  },
                ),

                // _DrawerTile(
                //   icon: Icons.electric_bolt_outlined,
                //   iconBg: const Color(0xFF0891B2),
                //   label: 'ইউটিলিটি বিল',
                //   onTap: () {
                //     Navigator.pop(context);
                //     Navigator.push(context, MaterialPageRoute(
                //       builder: (_) => const UtilityScreen(),
                //     ));
                //   },
                // ),

                // App Drawer e Notice board
                _DrawerTile(
                  icon: Icons.campaign_outlined,
                  iconBg: const Color(0xFF059669),
                  label: 'নোটিশ বোর্ড',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const NoticeScreen(),
                    ));
                  },
                ),

                _DrawerTile(
                  icon: Icons.archive_outlined,
                  iconBg: const Color(0xFF6B7280),
                  label: 'আর্কাইভ',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const ArchiveScreen(),
                    ));
                  },
                ),

                _DrawerSectionLabel('অ্যাপ', textSecondary),

                _DrawerTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  iconBg: const Color(0xFF7C3AED),
                  label: 'Messages',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const ChatListScreen(),
                    ));
                  },
                ),
                _DrawerTile(
                  icon: Icons.gavel_rounded,
                  iconBg: const Color(0xFF059669),
                  label: 'নিয়মাবলী',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const RulesScreen(),
                    ));
                  },
                ),
                _DrawerTile(
                  icon: Icons.settings_outlined,
                  iconBg: const Color(0xFF374151),
                  label: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ));
                  },
                ),
              ],
            ),
          ),

          // ── Logout + Version ────────────────────────
          _DrawerFooter(onLogout: () {
            // Navigator.pop(context);
            _confirmLogout(context);
          }),
        ],
      ),
    );
  }

  // void _confirmLogout(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       title: const Text('Logout করবেন?',
  //           style: TextStyle(fontWeight: FontWeight.w700)),
  //       content: const Text('আপনি কি নিশ্চিতভাবে logout করতে চান?'),
  //       actions: [
  //         TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text('না')),
  //         FilledButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             context.read<AuthService>().logout();
  //           },
  //           child: const Text('হ্যাঁ, Logout'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // _confirmLogout method:
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout করবেন?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('আপনি কি নিশ্চিতভাবে logout করতে চান?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('না')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // dialog বন্ধ
              Navigator.pop(context); // drawer বন্ধ
              context.read<AuthService>().logout();
            },
            child: const Text('হ্যাঁ, Logout'),
          ),
        ],
      ),
    );
  }
}

// ── Shared Drawer Widgets ─────────────────────────────────────────────────────

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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A3328), const Color(0xFF0F2018)]
              : [primary, primary.withOpacity(0.8)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with camera icon
              Consumer<AuthService>(
                builder: (context, auth, _) => ProfileAvatar(
                  name: auth.currentUser?.name ?? user.name,
                  photoUrl: auth.currentUser?.photoUrl,
                  userId: user.uid,
                  radius: 36,
                  editable: true,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                user.email,
                style: const TextStyle(fontSize: 12, color: Colors.white60),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white30, width: 1),
                ),
                child: const Text(
                  'বাড়ীওয়ালা',
                  style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String label;
  final VoidCallback onTap;
  const _DrawerTile({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 19),
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
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

class _DrawerSectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _DrawerSectionLabel(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _DrawerFooter extends StatelessWidget {
  final VoidCallback onLogout;
  const _DrawerFooter({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onLogout,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.logout_rounded, color: Colors.red, size: 19),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'House Manager v1.0.0',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white24 : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── Landlord Profile Screen ───────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme color;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 11, color: color.onSurface.withOpacity(0.5))),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LandlordProfileScreen extends StatelessWidget {
  final dynamic user;
  const _LandlordProfileScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: color.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text('আমার প্রোফাইল',
                style: TextStyle(color: Colors.white, fontSize: 16)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.primary, color.primary.withOpacity(0.75)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: Colors.white24,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'L',
                            style: const TextStyle(
                                fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(user.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('যোগাযোগের তথ্য',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color.primary,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  _InfoTile(icon: Icons.email_outlined, label: 'Email', value: user.email, color: color),
                  const SizedBox(height: 10),
                  _InfoTile(icon: Icons.phone_outlined, label: 'Phone', value: user.phone, color: color),
                  const SizedBox(height: 10),
                  _InfoTile(icon: Icons.home_rounded, label: 'Role', value: 'Landlord', color: color),
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
                      label: const Text('Logout',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
              IconButton(
                icon: const Icon(Icons.forum_outlined, color: Colors.indigo),
                tooltip: 'Community Chat',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CommunityChatScreen(
                      propertyId: property.id,
                      propertyName: property.name,
                    ),
                  ),
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