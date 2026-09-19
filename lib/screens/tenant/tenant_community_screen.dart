

import 'package:flutter/material.dart';
import '../community/community_chat_screen.dart';
import '../../services/tenant_identity_service.dart';
import '../../models/tenant_model.dart';

class TenantCommunityChatScreen extends StatelessWidget {
  final dynamic user;
  const TenantCommunityChatScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TenantModel?>(
      // Resolved by account, and only while the tenancy is active, so a
      // moved-out tenant loses community access.
      future: TenantIdentityService.activeTenancy(
        uid: user.uid,
        email: user.email,
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final tenant = snap.data;

        if (tenant == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Community Chat')),
            body: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('কোনো property তে assign হননি'),
                ],
              ),
            ),
          );
        }

        final propertyName = tenant.propertyName.trim();

        return CommunityChatScreen(
          propertyId: tenant.propertyId,
          propertyName: propertyName.isEmpty ? 'আমার বাড়ি' : propertyName,
        );
      },
    );
  }
}