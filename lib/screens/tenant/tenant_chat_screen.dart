import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user_model.dart';
import '../../../models/tenant_model.dart';
import '../../../services/chat_service.dart';
import '../shared/chat_screen.dart';

class TenantChatScreen extends StatefulWidget {
  final UserModel user;
  const TenantChatScreen({super.key, required this.user});

  @override
  State<TenantChatScreen> createState() => _TenantChatScreenState();
}

class _TenantChatScreenState extends State<TenantChatScreen> {
  String? _chatRoomId;
  String? _landlordName;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChat();
  }

  Future<void> _loadChat() async {
    final tenantSnap = await FirebaseFirestore.instance
        .collection('tenants')
        .where('email', isEqualTo: widget.user.email)
        .where('isActive', isEqualTo: true)
        .get();

    if (tenantSnap.docs.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    final tenant = TenantModel.fromMap(
        tenantSnap.docs.first.data(), tenantSnap.docs.first.id);

    // Landlord নাম নাও
    final landlordDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(tenant.landlordId)
        .get();
    _landlordName = landlordDoc.data()?['name'] ?? 'বাড়ীওয়ালা';

    // ChatRoom খোঁজো বা বানাও
    final chatService = ChatService();
    _chatRoomId = await chatService.getOrCreateChatRoom(
      landlordId: tenant.landlordId,
      landlordName: _landlordName!,
      tenant: tenant,
    );

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );

    if (_chatRoomId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Messages')),
        body: const Center(child: Text('চ্যাট শুরু করা যাচ্ছে না')),
      );
    }

    return ChatScreen(
      chatRoomId: _chatRoomId!,
      currentUserId: widget.user.uid,
      currentUserName: widget.user.name,
      otherUserName: _landlordName ?? 'বাড়ীওয়ালা',
      isLandlord: false,
    );
  }
}