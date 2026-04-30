import 'package:flutter/material.dart';
import '../../../models/rental_request_model.dart';
import '../../../services/listing_service.dart';

class MyRentalRequestsScreen extends StatelessWidget {
  final String userId;
  const MyRentalRequestsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final service = ListingService();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('আমার আবেদনসমূহ',
            style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: StreamBuilder<List<RentalRequestModel>>(
        stream: service.getTenantRequests(userId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primary));
          }
          final requests = snap.data ?? [];

          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.send_rounded, size: 64, color: primary.withOpacity(0.3)),
                  const SizedBox(height: 12),
                  const Text('কোনো আবেদন নেই', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('"বাড়ি খুঁজুন" থেকে আবেদন করুন',
                      style: TextStyle(fontSize: 14, color: textSecondary)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            itemCount: requests.length,
            itemBuilder: (ctx, i) => _RequestStatusCard(
              request: requests[i],
              isDark: isDark,
              primary: primary,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          );
        },
      ),
    );
  }
}

class _RequestStatusCard extends StatelessWidget {
  final RentalRequestModel request;
  final bool isDark;
  final Color primary;
  final Color textPrimary;
  final Color textSecondary;

  const _RequestStatusCard({
    required this.request,
    required this.isDark,
    required this.primary,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;

    Color statusColor;
    IconData statusIcon;
    String statusMsg;

    switch (request.status) {
      case RentalRequestStatus.accepted:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_rounded;
        statusMsg = 'বাড়ীওয়ালা আপনার আবেদন গ্রহণ করেছেন! আপনি এখন ভাড়াটিয়া হিসেবে যোগ হয়েছেন।';
        break;
      case RentalRequestStatus.rejected:
        statusColor = Colors.red;
        statusIcon = Icons.cancel_rounded;
        statusMsg = 'বাড়ীওয়ালা এই আবেদনটি প্রত্যাখ্যান করেছেন।';
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending_rounded;
        statusMsg = 'বাড়ীওয়ালার অনুমোদনের অপেক্ষায় আছে।';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.home_work_rounded, color: primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('${request.propertyName} — রুম ${request.roomNumber}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary)),
                ),
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
            const SizedBox(height: 8),
            Text('৳${request.rentAmount.toStringAsFixed(0)}/মাস',
                style: TextStyle(fontSize: 13, color: textSecondary)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, size: 14, color: statusColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(statusMsg,
                        style: TextStyle(fontSize: 12, color: statusColor)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'আবেদন: ${_fmt(request.createdAt)}',
              style: TextStyle(fontSize: 11, color: textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
}