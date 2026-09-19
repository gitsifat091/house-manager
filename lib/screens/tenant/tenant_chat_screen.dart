import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../services/chat_service.dart';
import '../shared/chat_screen.dart';
import '../../services/public_profile_service.dart';
import '../../services/tenant_identity_service.dart';

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
    final tenant = await TenantIdentityService.activeTenancy(
      uid: widget.user.uid,
      email: widget.user.email,
    );

    if (tenant == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    // Landlord নাম নাও — display name only, from the public profile.
    _landlordName =
        await PublicProfileService.nameOf(tenant.landlordId) ?? 'বাড়ীওয়ালা';

    // ChatRoom খোঁজো বা বানাও
    final chatService = ChatService();
    _chatRoomId = await chatService.getOrCreateChatRoom(
      landlordId: tenant.landlordId,
      landlordName: _landlordName!,
      tenant: tenant,
    );

    if (!mounted) return;
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