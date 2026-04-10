import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'dart:convert';

class ProfileAvatar extends StatefulWidget {
  final String name;
  final String? photoUrl;
  final double radius;
  final bool editable;
  final String userId;

  const ProfileAvatar({
    super.key,
    required this.name,
    required this.userId,
    this.photoUrl,
    this.radius = 52,
    this.editable = false,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  bool _uploading = false;

  Future<void> _pickAndUpload(BuildContext context) async {
    // Show source selection
    final source = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text('প্রোফাইল ছবি পরিবর্তন করুন',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.photo_library_rounded,
                    color: Theme.of(context).colorScheme.primary),
              ),
              title: const Text('Gallery থেকে বেছে নিন'),
              onTap: () => Navigator.pop(context, false),
            ),
            ListTile(
              leading: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.camera_alt_rounded,
                    color: Theme.of(context).colorScheme.primary),
              ),
              title: const Text('Camera দিয়ে তুলুন'),
              onTap: () => Navigator.pop(context, true),
            ),
            if (widget.photoUrl != null)
              ListTile(
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: Colors.red),
                ),
                title: const Text('ছবি সরিয়ে ফেলুন',
                    style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  await context.read<AuthService>().updateProfilePicture('');
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (source == null) return;

    setState(() => _uploading = true);

    try {
      final storage = StorageService();
      final imageBytes = await storage.pickImage(fromCamera: source);

      if (imageBytes == null) {
        setState(() => _uploading = false);
        return;
      }

      final url = await storage.uploadProfilePicture(
        userId: widget.userId,
        imageBytes: imageBytes,
      );

      if (url != null && context.mounted) {
        await context.read<AuthService>().updateProfilePicture(url);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('প্রোফাইল ছবি আপডেট হয়েছে'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final hasPhoto = widget.photoUrl != null && widget.photoUrl!.isNotEmpty;

    return GestureDetector(
      onTap: widget.editable ? () => _pickAndUpload(context) : null,
      child: Stack(
        children: [
          // Avatar
          CircleAvatar(
            radius: widget.radius,
            backgroundColor: color.primaryContainer,
            backgroundImage: hasPhoto
              ? (widget.photoUrl!.startsWith('data:')
                  ? MemoryImage(base64Decode(
                      widget.photoUrl!.split(',').last))
                  : NetworkImage(widget.photoUrl!) as ImageProvider)
              : null,
            child: _uploading
                ? SizedBox(
                    width: widget.radius,
                    height: widget.radius,
                    child: const CircularProgressIndicator(strokeWidth: 3),
                  )
                : !hasPhoto
                    ? Text(
                        widget.name.isNotEmpty
                            ? widget.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: widget.radius * 0.8,
                          fontWeight: FontWeight.bold,
                          color: color.primary,
                        ),
                      )
                    : null,
          ),

          // Edit badge
          if (widget.editable)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: color.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: color.surface, width: 2),
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
        ],
      ),
    );
  }
}