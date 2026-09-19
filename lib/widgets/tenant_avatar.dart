// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class TenantAvatar extends StatefulWidget {
//   final String tenantName;
//   final String tenantEmail;
//   final double radius;

//   const TenantAvatar({
//     super.key,
//     required this.tenantName,
//     required this.tenantEmail,
//     this.radius = 22,
//   });

//   @override
//   State<TenantAvatar> createState() => _TenantAvatarState();
// }

// class _TenantAvatarState extends State<TenantAvatar> {
//   String? _photoUrl;

//   @override
//   void initState() {
//     super.initState();
//     _loadPhoto();
//   }

//   Future<void> _loadPhoto() async {
//     try {
//       final snap = await FirebaseFirestore.instance
//           .collection('users')
//           .where('email', isEqualTo: widget.tenantEmail)
//           .get();
//       if (snap.docs.isNotEmpty && mounted) {
//         setState(() {
//           _photoUrl = snap.docs.first.data()['photoUrl'] as String?;
//         });
//       }
//     } catch (_) {}
//   }

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;
//     final hasPhoto = _photoUrl != null && _photoUrl!.isNotEmpty;

//     return CircleAvatar(
//       radius: widget.radius,
//       backgroundColor: color.primaryContainer,
//       backgroundImage: hasPhoto
//           ? (_photoUrl!.startsWith('data:')
//               ? MemoryImage(base64Decode(_photoUrl!.split(',').last))
//               : NetworkImage(_photoUrl!) as ImageProvider)
//           : null,
//       child: !hasPhoto
//           ? Text(
//               widget.tenantName.isNotEmpty
//                   ? widget.tenantName[0].toUpperCase()
//                   : '?',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: color.primary,
//                 fontSize: widget.radius * 0.75,
//               ),
//             )
//           : null,
//     );
//   }
// }





import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/public_profile_service.dart';

class TenantAvatar extends StatefulWidget {
  final String tenantName;

  /// Auth uid of the person, when it is known.
  ///
  /// Null means we cannot resolve a picture and fall back to initials. This
  /// used to be an email matched against the users collection, which read
  /// other people's records and, at three of the five call sites, was passed
  /// an empty string or a name and so never matched anything anyway.
  final String? userId;

  final double radius;

  const TenantAvatar({
    super.key,
    required this.tenantName,
    this.userId,
    this.radius = 22,
  });

  @override
  State<TenantAvatar> createState() => _TenantAvatarState();
}

class _TenantAvatarState extends State<TenantAvatar> {
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadPhoto();
  }

  Future<void> _loadPhoto() async {
    final uid = widget.userId;
    if (uid == null || uid.isEmpty) return;
    final photo = await PublicProfileService.photoOf(uid);
    if (!mounted || photo == null) return;
    setState(() => _photoUrl = photo);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final hasPhoto = _photoUrl != null && _photoUrl!.isNotEmpty;

    return ClipOval(
      child: CircleAvatar(
        radius: widget.radius,
        backgroundColor: primary,
        backgroundImage: hasPhoto
            ? (_photoUrl!.startsWith('data:')
                ? MemoryImage(base64Decode(_photoUrl!.split(',').last))
                : NetworkImage(_photoUrl!) as ImageProvider)
            : null,
        child: !hasPhoto
            ? Text(
                widget.tenantName.isNotEmpty
                    ? widget.tenantName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: widget.radius * 0.75,
                ),
              )
            : null,
      ),
    );
  }
}