// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import '../community/community_chat_screen.dart';

// class TenantCommunityChatScreen extends StatelessWidget {
//   final dynamic user;
//   const TenantCommunityChatScreen({super.key, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<QuerySnapshot>(
//       future: FirebaseFirestore.instance
//           .collection('tenants')
//           .where('userId', isEqualTo: user.uid)
//           .get(),
//       builder: (context, snap) {
//         if (snap.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         if (snap.hasError) {
//           return Scaffold(
//             appBar: AppBar(title: const Text('Community Chat')),
//             body: Center(child: Text('Error: ${snap.error}')),
//           );
//         }

//         // Filter out archived tenants in code (not query)
//         final docs = snap.data?.docs.where((doc) {
//           final data = doc.data() as Map<String, dynamic>;
//           return data['isArchived'] != true;
//         }).toList() ?? [];

//         if (docs.isEmpty) {
//           // Debug: show uid to verify
//           return Scaffold(
//             appBar: AppBar(title: const Text('Community Chat')),
//             body: Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(Icons.home_outlined, size: 64, color: Colors.grey),
//                   const SizedBox(height: 16),
//                   const Text('কোনো property তে assign হননি'),
//                   const SizedBox(height: 8),
//                   Text('UID: ${user.uid}',
//                       style: const TextStyle(fontSize: 11, color: Colors.grey)),
//                 ],
//               ),
//             ),
//           );
//         }

//         final tenantData = docs.first.data() as Map<String, dynamic>;
//         final propertyId = tenantData['propertyId'] ?? '';
//         final propertyName = tenantData['propertyName'] 
//             ?? tenantData['property_name'] 
//             ?? 'আমার বাড়ি';

//         if (propertyId.isEmpty) {
//           return Scaffold(
//             appBar: AppBar(title: const Text('Community Chat')),
//             body: const Center(child: Text('Property ID পাওয়া যায়নি')),
//           );
//         }

//         return CommunityChatScreen(
//           propertyId: propertyId,
//           propertyName: propertyName,
//         );
//       },
//     );
//   }
// }







import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../community/community_chat_screen.dart';

class TenantCommunityChatScreen extends StatelessWidget {
  final dynamic user;
  const TenantCommunityChatScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('tenants')
          .where('email', isEqualTo: user.email) // ← email দিয়ে query
          .get(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snap.data?.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['isArchived'] != true;
        }).toList() ?? [];

        if (docs.isEmpty) {
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

        final tenantData = docs.first.data() as Map<String, dynamic>;
        final propertyId = tenantData['propertyId'] ?? '';
        final propertyName = tenantData['propertyName'] ?? 'আমার বাড়ি';

        return CommunityChatScreen(
          propertyId: propertyId,
          propertyName: propertyName,
        );
      },
    );
  }
}