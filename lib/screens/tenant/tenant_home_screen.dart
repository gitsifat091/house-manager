

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/tenant_model.dart';
import '../../../models/room_model.dart';
import '../../../models/user_model.dart';
import 'tenant_edit_profile_screen.dart';
import '../shared/notification_screen.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/profile_avatar.dart';
import '../../services/tenant_identity_service.dart';

class TenantHomeScreen extends StatelessWidget {
  final UserModel user;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const TenantHomeScreen({super.key, required this.user, this.scaffoldKey});

  Future<Map<String, dynamic>> _loadData() async {
    final db = FirebaseFirestore.instance;
    final tenant = await TenantIdentityService.activeTenancy(
      uid: user.uid,
      email: user.email,
    );

    if (tenant == null) return {'tenant': null, 'room': null};

    final roomSnap = await db.collection('rooms').doc(tenant.roomId).get();
    RoomModel? room;
    if (roomSnap.exists) room = RoomModel.fromMap(roomSnap.data()!, roomSnap.id);

    return {'tenant': tenant, 'room': room};
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadData(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primary));
          }

          final tenant = snap.data?['tenant'] as TenantModel?;
          final room = snap.data?['room'] as RoomModel?;

          if (tenant == null) {
            return _buildNotFound(context, primary, textPrimary, textSecondary, isDark, bg);
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Collapsing AppBar ──────────────────────────────────
              SliverAppBar(
                expandedHeight: 200,
                collapsedHeight: 60,
                pinned: true,
                backgroundColor: bg,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.menu_rounded, color: isDark ? Colors.white : textPrimary),
                  onPressed: () => scaffoldKey?.currentState?.openDrawer(),
                ),
                title: Text(
                  'হোম',
                  style: TextStyle(
                      color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                centerTitle: true,
                actions: [
                  NotificationBell(userId: user.uid),
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: textPrimary, size: 20),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => TenantEditProfileScreen(user: user)),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeader(
                    context: context,
                    tenant: tenant,
                    primary: primary,
                    isDark: isDark,
                    textPrimary: textPrimary,
                  ),
                ),
              ),

              // ── Body ─────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _sectionHeader('🚪  আমার রুম', textSecondary),
                    _RoomCard(tenant: tenant, room: room, primary: primary, isDark: isDark),
                    const SizedBox(height: 16),

                    _sectionHeader('💳  ভাড়ার তথ্য', textSecondary),
                    _RentStatusCard(tenant: tenant, primary: primary, isDark: isDark),
                    const SizedBox(height: 16),

                    _sectionHeader('📋  বিস্তারিত', textSecondary),
                    _DetailsCard(
                      tenant: tenant,
                      primary: primary,
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Header background ──────────────────────────────────────────────────────
  Widget _buildHeader({
    required BuildContext context,
    required TenantModel tenant,
    required Color primary,
    required bool isDark,
    required Color textPrimary,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A3328), const Color(0xFF0F1A14)]
              : [const Color(0xFFE8F5EE), const Color(0xFFF5FAF7)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 70, 20, 16),
          child: Row(
            children: [
              Consumer<AuthService>(
                builder: (context, auth, _) => ProfileAvatar(
                  name: tenant.name,
                  photoUrl: auth.currentUser?.photoUrl,
                  userId: auth.currentUser?.uid ?? '',
                  radius: 30,
                  editable: false,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'স্বাগতম, ${tenant.name.split(' ')[0]}!',
                      style: TextStyle(
                          color: textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tenant.phone,
                      style: TextStyle(color: textPrimary.withOpacity(0.6), fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primary.withOpacity(0.3), width: 1),
                      ),
                      child: Text(
                        'ভাড়াটিয়া',
                        style: TextStyle(
                            color: primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Not Found — drawer button সহ ─────────────────────────────────────────
  Widget _buildNotFound(
    BuildContext context,
    Color primary,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
    Color bg,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── AppBar with drawer button ──
        SliverAppBar(
          pinned: true,
          collapsedHeight: 60,
          backgroundColor: bg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.menu_rounded, color: textPrimary),
            onPressed: () => scaffoldKey?.currentState?.openDrawer(),
          ),
          title: Text(
            'হোম',
            style: TextStyle(
                color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
          actions: [
            NotificationBell(userId: user.uid),
          ],
        ),

        // ── Welcome banner for new tenant ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1A3328), const Color(0xFF0F2018)]
                      : [primary, primary.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.waving_hand_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'স্বাগতম, ${user.name.split(' ')[0]}!',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'House Manager এ আপনাকে স্বাগত',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Info card ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2C22) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.home_outlined,
                        size: 36, color: primary.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'এখনো কোনো রুমে যোগ হননি',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'বাড়ি খুঁজতে drawer মেনু থেকে "বাড়ি খুঁজুন" ব্যবহার করুন অথবা বাড়ীওয়ালার সাথে যোগাযোগ করুন।',
                    style: TextStyle(fontSize: 13, color: textSecondary, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Hint arrow pointing to drawer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_rounded, size: 18, color: primary),
                      const SizedBox(width: 8),
                      Text(
                        'উপরে বাম কোণের মেনু বাটন চাপুন',
                        style: TextStyle(
                            fontSize: 13,
                            color: primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, Color color) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
        child: Text(title,
            style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
      );
}

// ── Room Card ─────────────────────────────────────────────────────────────────

class _RoomCard extends StatelessWidget {
  final TenantModel tenant;
  final RoomModel? room;
  final Color primary;
  final bool isDark;
  const _RoomCard(
      {required this.tenant,
      required this.room,
      required this.primary,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primary.withOpacity(0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: primary.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: const Icon(Icons.door_front_door_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'রুম ${tenant.roomNumber}',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    room?.type ?? '',
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _badge(
                          label: 'ভাড়া চলছে',
                          color: const Color(0xFF059669),
                          icon: Icons.check_circle_rounded),
                      const SizedBox(width: 8),
                      _badge(
                          label: '৳${tenant.rentAmount.toStringAsFixed(0)}/মাস',
                          color: primary,
                          icon: Icons.payments_rounded),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Rent Status Card ──────────────────────────────────────────────────────────

class _RentStatusCard extends StatelessWidget {
  final TenantModel tenant;
  final Color primary;
  final bool isDark;
  const _RentStatusCard(
      {required this.tenant, required this.primary, required this.isDark});

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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;

    return FutureBuilder<bool>(
      future: _checkPayment(tenant.id, now.month, now.year),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Container(
            height: 80,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: CircularProgressIndicator(color: primary)),
          );
        }

        final isPaid = snap.data ?? false;
        final statusColor =
            isPaid ? const Color(0xFF059669) : const Color(0xFFD97706);
        final statusBg = isDark
            ? statusColor.withOpacity(0.15)
            : statusColor.withOpacity(0.07);

        return Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Icon(
                    isPaid
                        ? Icons.check_circle_rounded
                        : Icons.pending_rounded,
                    color: statusColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPaid
                            ? 'এই মাসের ভাড়া পরিশোধ হয়েছে'
                            : 'এই মাসের ভাড়া বাকি আছে',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: statusColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'মাসিক ভাড়া: ৳${tenant.rentAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                            fontSize: 13,
                            color: statusColor.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: statusColor.withOpacity(0.5), blurRadius: 6)
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Details Card ──────────────────────────────────────────────────────────────

class _DetailsCard extends StatelessWidget {
  final TenantModel tenant;
  final Color primary;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  const _DetailsCard({
    required this.tenant,
    required this.primary,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final divColor = isDark ? Colors.white10 : const Color(0xFFE5E7EB);

    final items = [
      _DetailItem(Icons.badge_outlined, 'NID', tenant.nidNumber,
          const Color(0xFF5B4FBF)),
      _DetailItem(
          Icons.calendar_today_outlined,
          'প্রবেশের তারিখ',
          '${tenant.moveInDate.day}/${tenant.moveInDate.month}/${tenant.moveInDate.year}',
          const Color(0xFF0891B2)),
      _DetailItem(
          Icons.home_work_outlined, 'Property', tenant.propertyName, primary),
      _DetailItem(
          Icons.email_outlined,
          'Email',
          tenant.email.isEmpty ? 'নেই' : tenant.email,
          const Color(0xFFD97706)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: item.color, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.label,
                              style:
                                  TextStyle(fontSize: 11, color: textSecondary)),
                          const SizedBox(height: 2),
                          Text(item.value,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.only(left: 70),
                  child: Divider(height: 1, color: divColor),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _DetailItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _DetailItem(this.icon, this.label, this.value, this.color);
}