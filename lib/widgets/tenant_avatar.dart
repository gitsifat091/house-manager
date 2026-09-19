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
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tenant_model.dart';

class TenantAvatar extends StatefulWidget {
  final String tenantName;
  final String tenantEmail;
  final double radius;

  const TenantAvatar({
    super.key,
    required this.tenantName,
    required this.tenantEmail,
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
    // Accounts registered since emails were normalised store them lowercased;
    // older ones kept whatever casing was typed, so try both.
    final candidates = <String>{
      TenantModel.normaliseEmail(widget.tenantEmail),
      widget.tenantEmail.trim(),
    }..removeWhere((e) => e.isEmpty);

    for (final email in candidates) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
        if (snap.docs.isEmpty) continue;
        if (!mounted) return;
        setState(() {
          _photoUrl = snap.docs.first.data()['photoUrl'] as String?;
        });
        return;
      } catch (_) {
        return;
      }
    }
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