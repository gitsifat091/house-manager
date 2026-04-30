import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/rental_request_model.dart';
import '../../../services/listing_service.dart';

class RentalRequestsScreen extends StatelessWidget {
  final String landlordId;
  const RentalRequestsScreen({super.key, required this.landlordId});

  @override
  Widget build(BuildContext context) {
    final service = ListingService();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('ভাড়ার আবেদন',
            style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: StreamBuilder<List<RentalRequestModel>>(
        stream: service.getLandlordRequests(landlordId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primary));
          }
          final all = snap.data ?? [];
          final pending = all.where((r) => r.status == RentalRequestStatus.pending).toList();
          final others = all.where((r) => r.status != RentalRequestStatus.pending).toList();

          if (all.isEmpty) {
            return _emptyState(primary, isDark);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              if (pending.isNotEmpty) ...[
                _label('অপেক্ষমাণ (${pending.length})', Colors.orange),
                ...pending.map((r) => _RequestCard(
                      request: r,
                      service: service,
                      isDark: isDark,
                      primary: primary,
                      textPrimary: textPrimary,
                    )),
                const SizedBox(height: 12),
              ],
              if (others.isNotEmpty) ...[
                _label('পূর্ববর্তী (${others.length})',
                    isDark ? Colors.white38 : const Color(0xFF9CA3AF)),
                ...others.map((r) => _RequestCard(
                      request: r,
                      service: service,
                      isDark: isDark,
                      primary: primary,
                      textPrimary: textPrimary,
                      readonly: true,
                    )),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _label(String text, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(text,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5)),
      );

  Widget _emptyState(Color primary, bool isDark) {
    final textSecondary = isDark ? Colors.white38 : const Color(0xFF6B7280);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(color: primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.inbox_rounded, size: 46, color: primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 20),
          const Text('কোনো আবেদন নেই', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('ভাড়াটিয়ারা আবেদন করলে এখানে দেখাবে',
              style: TextStyle(fontSize: 14, color: textSecondary)),
        ],
      ),
    );
  }
}

// ── Request Card ──────────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  final RentalRequestModel request;
  final ListingService service;
  final bool isDark;
  final Color primary;
  final Color textPrimary;
  final bool readonly;

  const _RequestCard({
    required this.request,
    required this.service,
    required this.isDark,
    required this.primary,
    required this.textPrimary,
    this.readonly = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final divider = isDark ? Colors.white10 : const Color(0xFFE5E7EB);

    Color statusColor;
    IconData statusIcon;
    switch (request.status) {
      case RentalRequestStatus.accepted:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_rounded;
        break;
      case RentalRequestStatus.rejected:
        statusColor = Colors.red;
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: primary.withOpacity(0.15),
                  child: Text(
                    request.tenantName.isNotEmpty ? request.tenantName[0].toUpperCase() : 'T',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.tenantName,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary)),
                      Text('${request.propertyName} — রুম ${request.roomNumber}',
                          style: TextStyle(fontSize: 12, color: textSecondary)),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(request.statusLabel,
                          style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: divider),
            const SizedBox(height: 10),

            // Contact info
            _info(Icons.phone_outlined, request.tenantPhone, const Color(0xFF059669), textSecondary),
            const SizedBox(height: 6),
            _info(Icons.email_outlined, request.tenantEmail, const Color(0xFF0891B2), textSecondary),
            const SizedBox(height: 6),
            _info(Icons.badge_outlined, 'NID: ${request.tenantNid}', const Color(0xFF5B4FBF), textSecondary),
            const SizedBox(height: 6),
            _info(Icons.payments_outlined, '৳${request.rentAmount.toStringAsFixed(0)}/মাস', primary, textSecondary),

            if (request.message.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded, size: 14, color: textSecondary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(request.message, style: TextStyle(fontSize: 13, color: textSecondary))),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 6),
            Text(
              _formatDate(request.createdAt),
              style: TextStyle(fontSize: 11, color: textSecondary),
            ),

            // Action buttons — only for pending
            if (!readonly && request.status == RentalRequestStatus.pending) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _reject(context),
                      icon: const Icon(Icons.close_rounded, size: 16, color: Colors.red),
                      label: const Text('প্রত্যাখ্যান', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _accept(context),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('গ্রহণ করুন'),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _info(IconData icon, String text, Color color, Color textSecondary) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 13, color: textSecondary)),
      ],
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Future<void> _accept(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('আবেদন গ্রহণ করবেন?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
          '${request.tenantName} কে রুম ${request.roomNumber} এ ভাড়াটিয়া হিসেবে যোগ করা হবে।\n\n'
          'রুমটি স্বয়ংক্রিয়ভাবে Occupied হয়ে যাবে।',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('বাতিল')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('হ্যাঁ, যোগ করুন')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await service.acceptRequest(request);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${request.tenantName} ভাড়াটিয়া হিসেবে যোগ হয়েছেন! ✅'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'), backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> _reject(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('আবেদন প্রত্যাখ্যান করবেন?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('${request.tenantName} এর আবেদন বাতিল করা হবে।'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('না')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('প্রত্যাখ্যান করুন'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    await service.rejectRequest(request.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('আবেদন প্রত্যাখ্যাত হয়েছে')));
    }
  }
}