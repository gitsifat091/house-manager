import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/tenant_model.dart';
import '../../../models/room_model.dart';
import '../../../models/user_model.dart';
import 'tenant_edit_profile_screen.dart';
import '../shared/notification_screen.dart';


class TenantHomeScreen extends StatelessWidget {
  final UserModel user;
  // const TenantHomeScreen({super.key, required this.user});
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const TenantHomeScreen({super.key, required this.user, this.scaffoldKey});

  Future<Map<String, dynamic>> _loadData() async {
    final db = FirebaseFirestore.instance;

    // Get tenant info by matching email
    final tenantSnap = await db
        .collection('tenants')
        .where('email', isEqualTo: user.email)
        .where('isActive', isEqualTo: true)
        .get();

    if (tenantSnap.docs.isEmpty) {
      return {'tenant': null, 'room': null};
    }

    final tenant = TenantModel.fromMap(tenantSnap.docs.first.data(), tenantSnap.docs.first.id);

    // Get room info
    final roomSnap = await db.collection('rooms').doc(tenant.roomId).get();
    RoomModel? room;
    if (roomSnap.exists) {
      room = RoomModel.fromMap(roomSnap.data()!, roomSnap.id);
    }

    return {'tenant': tenant, 'room': room};
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadData(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tenant = snap.data?['tenant'] as TenantModel?;
          final room = snap.data?['room'] as RoomModel?;

          if (tenant == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, size: 64, color: color.primary.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  const Text('আপনার তথ্য পাওয়া যায়নি', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('বাড়ীওয়ালার সাথে যোগাযোগ করুন', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                leading: IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => scaffoldKey?.currentState?.openDrawer(),
                ),
                expandedHeight: 180,
                pinned: true,
                actions: [
                  NotificationBell(userId: user.uid),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TenantEditProfileScreen(user: user),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      color: color.primary,
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white24,
                              child: Text(
                                tenant.name[0].toUpperCase(),
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text('স্বাগতম, ${tenant.name}!',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text(tenant.phone,
                                style: const TextStyle(fontSize: 13, color: Colors.white70)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Room info card
                    _SectionTitle(title: 'আমার রুম'),
                    const SizedBox(height: 10),
                    _RoomInfoCard(tenant: tenant, room: room),
                    const SizedBox(height: 20),

                    // Rent info
                    _SectionTitle(title: 'ভাড়ার তথ্য'),
                    const SizedBox(height: 10),
                    _RentInfoCard(tenant: tenant),
                    const SizedBox(height: 20),

                    // Quick info
                    _SectionTitle(title: 'বিস্তারিত'),
                    const SizedBox(height: 10),
                    _InfoRow(icon: Icons.badge_outlined, label: 'NID', value: tenant.nidNumber),
                    _InfoRow(icon: Icons.calendar_today_outlined, label: 'প্রবেশের তারিখ',
                        value: '${tenant.moveInDate.day}/${tenant.moveInDate.month}/${tenant.moveInDate.year}'),
                    _InfoRow(icon: Icons.home_work_outlined, label: 'Property', value: tenant.propertyName),
                    _InfoRow(icon: Icons.email_outlined, label: 'Email', value: tenant.email.isEmpty ? 'নেই' : tenant.email),
                    const SizedBox(height: 20),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: TextStyle(
      fontSize: 15, fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
    ));
  }
}

class _RoomInfoCard extends StatelessWidget {
  final TenantModel tenant;
  final RoomModel? room;
  const _RoomInfoCard({required this.tenant, this.room});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: color.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.door_front_door_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('রুম ${tenant.roomNumber}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color.primary)),
                Text(room?.type ?? '', style: TextStyle(color: color.primary.withOpacity(0.7))),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('ভাড়া চলছে', style: TextStyle(
                      fontSize: 12, color: Colors.green.shade800, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RentInfoCard extends StatelessWidget {
  final TenantModel tenant;
  const _RentInfoCard({required this.tenant});

  @override
  Widget build(BuildContext context) {
    // Check this month's payment
    final now = DateTime.now();
    return FutureBuilder<bool>(
      future: _checkPayment(tenant.id, now.month, now.year),
      builder: (context, snap) {
        final isPaid = snap.data ?? false;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPaid ? Colors.green.shade200 : Colors.orange.shade200,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isPaid ? Icons.check_circle_rounded : Icons.pending_rounded,
                color: isPaid ? Colors.green : Colors.orange,
                size: 36,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPaid ? 'এই মাসের ভাড়া পরিশোধ হয়েছে' : 'এই মাসের ভাড়া বাকি আছে',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isPaid ? Colors.green.shade800 : Colors.orange.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'মাসিক ভাড়া: ৳${tenant.rentAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: isPaid ? Colors.green.shade700 : Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _checkPayment(String tenantId, int month, int year) async {
    final snap = await FirebaseFirestore.instance
        .collection('payments')
        .where('tenantId', isEqualTo: tenantId)
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .where('status', isEqualTo: 'paid')
        .get();
    return snap.docs.isNotEmpty;
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)))),
        ],
      ),
    );
  }
}