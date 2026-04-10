import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/maintenance_service.dart';
import '../../../models/maintenance_model.dart';

class MaintenanceRequestsScreen extends StatelessWidget {
  const MaintenanceRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser!;
    final service = MaintenanceService();

    return Scaffold(
      appBar: AppBar(title: const Text('মেরামতের অনুরোধ'), centerTitle: true),
      body: StreamBuilder<List<MaintenanceModel>>(
        stream: service.getRequests(user.uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final requests = snap.data ?? [];
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.build_outlined, size: 80,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('কোনো অনুরোধ নেই',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (ctx, i) => _MaintenanceCard(
              req: requests[i], service: service,
            ),
          );
        },
      ),
    );
  }
}

class _MaintenanceCard extends StatelessWidget {
  final MaintenanceModel req;
  final MaintenanceService service;
  const _MaintenanceCard({required this.req, required this.service});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: color.primaryContainer,
                  child: Text(req.tenantName[0].toUpperCase(),
                      style: TextStyle(color: color.primary, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(req.tenantName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('${req.propertyName} • রুম ${req.roomNumber}',
                          style: TextStyle(fontSize: 12, color: color.onSurface.withOpacity(0.6))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(int.parse('FF${req.statusColorHex}', radix: 16)).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(req.statusLabel,
                      style: TextStyle(fontSize: 12, color: Color(int.parse('FF${req.statusColorHex}', radix: 16)),
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(req.title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(req.description,
                style: TextStyle(color: color.onSurface.withOpacity(0.7))),
            const SizedBox(height: 12),
            // Status buttons
            if (req.status != MaintenanceStatus.done)
              Row(
                children: [
                  if (req.status == MaintenanceStatus.pending)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => service.updateStatus(req.id, MaintenanceStatus.inProgress),
                        child: const Text('কাজ শুরু করুন'),
                      ),
                    ),
                  if (req.status == MaintenanceStatus.pending) const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => service.updateStatus(req.id, MaintenanceStatus.done),
                      child: const Text('সম্পন্ন'),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 4),
            Text(
              '${req.createdAt.day}/${req.createdAt.month}/${req.createdAt.year}',
              style: TextStyle(fontSize: 11, color: color.onSurface.withOpacity(0.4)),
            ),
          ],
        ),
      ),
    );
  }
}