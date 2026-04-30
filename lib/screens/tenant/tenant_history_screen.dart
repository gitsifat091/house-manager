import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/auth_service.dart';
import '../../../models/tenant_model.dart';
import '../../../models/payment_model.dart';

class TenantHistoryScreen extends StatelessWidget {
  const TenantHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            pinned: true,
            backgroundColor: bg,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('পূর্বের ইতিহাস',
                style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            centerTitle: true,
          ),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('tenants')
                .where('email', isEqualTo: user.email)
                .where('isActive', isEqualTo: false)
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: primary)));
              }

              final records = (snap.data?.docs ?? [])
                  .map((d) => TenantModel.fromMap(d.data() as Map<String, dynamic>, d.id))
                  .toList()
                ..sort((a, b) => b.moveInDate.compareTo(a.moveInDate));

              if (records.isEmpty) {
                return SliverFillRemaining(
                  child: _emptyState(primary, textSecondary),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _HistoryCard(
                      record: records[i],
                      index: i,
                      isDark: isDark,
                      primary: primary,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    childCount: records.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _emptyState(Color primary, Color textSecondary) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(color: primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.history_rounded, size: 46, color: primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 20),
          const Text('কোনো পূর্ব ইতিহাস নেই',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('রুম ছেড়ে দিলে এখানে ইতিহাস দেখা যাবে',
              style: TextStyle(fontSize: 14, color: textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── History Card ──────────────────────────────────────────────────────────────

class _HistoryCard extends StatefulWidget {
  final TenantModel record;
  final int index;
  final bool isDark;
  final Color primary;
  final Color textPrimary;
  final Color textSecondary;

  const _HistoryCard({
    required this.record,
    required this.index,
    required this.isDark,
    required this.primary,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  bool _expanded = false;

  static const List<Color> _colors = [
    Color(0xFF2D7A4F), Color(0xFF0891B2), Color(0xFFD97706),
    Color(0xFF5B4FBF), Color(0xFF059669),
  ];

  @override
  Widget build(BuildContext context) {
    final r = widget.record;
    final isDark = widget.isDark;
    final primary = widget.primary;
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final divider = isDark ? Colors.white10 : const Color(0xFFE5E7EB);
    final accentColor = _colors[widget.index % _colors.length];
    final moveOut = r.moveOutDate;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // ── Header ──
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: _expanded
                ? const BorderRadius.vertical(top: Radius.circular(18))
                : BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: accentColor.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.propertyName,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: widget.textPrimary)),
                        const SizedBox(height: 2),
                        Text('রুম ${r.roomNumber}',
                            style: TextStyle(fontSize: 12, color: widget.textSecondary)),
                        const SizedBox(height: 5),
                        // Date badge
                        Row(
                          children: [
                            _dateBadge(
                              Icons.login_rounded, _fmt(r.moveInDate), Colors.green),
                            const SizedBox(width: 6),
                            if (moveOut != null)
                              _dateBadge(Icons.logout_rounded, _fmt(moveOut), Colors.red),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: widget.textSecondary, size: 24),
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded ──
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _buildDetail(r, moveOut, divider, accentColor),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildDetail(TenantModel r, DateTime? moveOut, Color divider, Color accentColor) {
    final isDark = widget.isDark;
    return Column(
      children: [
        Divider(height: 1, color: divider),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats row
              Row(
                children: [
                  _statBox('৳${r.rentAmount.toStringAsFixed(0)}', 'মাসিক ভাড়া', accentColor, isDark),
                  const SizedBox(width: 10),
                  _statBox(_stayDuration(r.moveInDate, moveOut), 'বসবাসকাল', const Color(0xFF0891B2), isDark),
                  const SizedBox(width: 10),
                  _statBox(r.roomNumber, 'রুম নম্বর', const Color(0xFFD97706), isDark),
                ],
              ),
              const SizedBox(height: 14),

              // Payment history
              _sectionLabel('💳 পেমেন্ট ইতিহাস', widget.textSecondary),
              _TenantPaymentHistory(
                tenantId: r.id,
                isDark: isDark,
                primary: widget.primary,
                textSecondary: widget.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dateBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _statBox(String value, String label, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            FittedBox(child: Text(value,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color))),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 9, color: color.withOpacity(0.8)),
                textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String title, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5)),
      );

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  String _stayDuration(DateTime moveIn, DateTime? moveOut) {
    final end = moveOut ?? DateTime.now();
    final days = end.difference(moveIn).inDays;
    if (days < 30) return '$days দিন';
    final months = (days / 30).floor();
    if (months < 12) return '$months মাস';
    final years = (months / 12).floor();
    final rem = months % 12;
    return rem > 0 ? '$years বছর $rem মাস' : '$years বছর';
  }
}

// ── Payment History Widget ────────────────────────────────────────────────────

class _TenantPaymentHistory extends StatelessWidget {
  final String tenantId;
  final bool isDark;
  final Color primary;
  final Color textSecondary;

  const _TenantPaymentHistory({
    required this.tenantId,
    required this.isDark,
    required this.primary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('payments')
          .where('tenantId', isEqualTo: tenantId)
          .get(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
        }

        final payments = (snap.data?.docs ?? [])
            .map((d) => PaymentModel.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList()
          ..sort((a, b) {
            if (a.year != b.year) return b.year.compareTo(a.year);
            return b.month.compareTo(a.month);
          });

        if (payments.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF243320) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
            ),
            child: Text('কোনো পেমেন্ট রেকর্ড নেই',
                style: TextStyle(color: textSecondary, fontSize: 13)),
          );
        }

        final paidCount = payments.where((p) => p.status == PaymentStatus.paid).length;
        final totalPaid = payments
            .where((p) => p.status == PaymentStatus.paid)
            .fold(0.0, (s, p) => s + p.amount);

        return Column(
          children: [
            // Summary
            Row(
              children: [
                _chip(Icons.check_circle_outline_rounded,
                    '$paidCount মাস পরিশোধ', Colors.green),
                const SizedBox(width: 8),
                _chip(Icons.account_balance_wallet_outlined,
                    '৳${totalPaid.toStringAsFixed(0)} মোট', primary),
              ],
            ),
            const SizedBox(height: 10),

            // List
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF243320) : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  ...payments.take(6).toList().asMap().entries.map((entry) {
                    final i = entry.key;
                    final p = entry.value;
                    const months = ['', 'জান', 'ফেব', 'মার্চ', 'এপ্রি',
                      'মে', 'জুন', 'জুলা', 'আগ', 'সেপ্ট', 'অক্ট', 'নভে', 'ডিসে'];
                    final isPaid = p.status == PaymentStatus.paid;
                    final isLast = i == (payments.length > 6 ? 5 : payments.length - 1);

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  color: (isPaid ? Colors.green : const Color(0xFFD97706)).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isPaid ? Icons.check_rounded : Icons.schedule_rounded,
                                  color: isPaid ? Colors.green : const Color(0xFFD97706),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text('${months[p.month]} ${p.year}',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                                        color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                              ),
                              Text('৳${p.amount.toStringAsFixed(0)}',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                                      color: isPaid ? Colors.green : const Color(0xFFD97706))),
                            ],
                          ),
                        ),
                        if (!isLast)
                          Divider(height: 1,
                              color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
                              indent: 56),
                      ],
                    );
                  }),
                  if (payments.length > 6)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                      child: Text('+ আরও ${payments.length - 6} টি রেকর্ড',
                          style: TextStyle(fontSize: 12, color: textSecondary)),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Flexible(child: Text(label,
                style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}