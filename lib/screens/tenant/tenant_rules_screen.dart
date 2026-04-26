// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../models/rule_model.dart';
// import '../../../models/user_model.dart';
// import '../../../services/rules_service.dart';

// class TenantRulesScreen extends StatelessWidget {
//   final UserModel user;
//   const TenantRulesScreen({super.key, required this.user});

//   Future<String?> _getLandlordId() async {
//     final snap = await FirebaseFirestore.instance
//         .collection('tenants')
//         .where('email', isEqualTo: user.email)
//         .where('isActive', isEqualTo: true)
//         .get();
//     if (snap.docs.isEmpty) return null;
//     return snap.docs.first.data()['landlordId'] as String?;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('নিয়মাবলী'),
//           centerTitle: true,
//           bottom: const TabBar(
//             tabs: [
//               Tab(text: 'বাড়ির নিয়ম'),
//               Tab(text: 'আইনী অধিকার'),
//             ],
//           ),
//         ),
//         body: FutureBuilder<String?>(
//           future: _getLandlordId(),
//           builder: (context, snap) {
//             if (snap.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             final landlordId = snap.data;
//             if (landlordId == null) {
//               return const Center(child: Text('তথ্য পাওয়া যায়নি'));
//             }

//             return TabBarView(
//               children: [
//                 // বাড়ির নিয়ম
//                 StreamBuilder<List<RuleModel>>(
//                   stream: RulesService().getRules(landlordId),
//                   builder: (context, snap2) {
//                     final rules = (snap2.data ?? [])
//                         .where((r) => r.category != RuleCategory.legal)
//                         .toList();

//                     if (rules.isEmpty) {
//                       return const Center(
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text('🏠', style: TextStyle(fontSize: 56)),
//                             SizedBox(height: 12),
//                             Text('কোনো বিশেষ নিয়ম নেই',
//                                 style: TextStyle(
//                                     fontSize: 16, fontWeight: FontWeight.bold)),
//                           ],
//                         ),
//                       );
//                     }

//                     return ListView(
//                       padding: const EdgeInsets.all(16),
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(12),
//                           margin: const EdgeInsets.only(bottom: 16),
//                           decoration: BoxDecoration(
//                             color: Theme.of(context).colorScheme.primaryContainer,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(Icons.info_outline,
//                                   color: Theme.of(context).colorScheme.primary,
//                                   size: 18),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   'এই নিয়মগুলো আপনার বাড়ীওয়ালা নির্ধারণ করেছেন।',
//                                   style: TextStyle(
//                                       fontSize: 12,
//                                       color: Theme.of(context).colorScheme.primary),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         ...rules.map((rule) => _TenantRuleCard(rule: rule)),
//                       ],
//                     );
//                   },
//                 ),

//                 // আইনী অধিকার
//                 ListView(
//                   padding: const EdgeInsets.all(16),
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       margin: const EdgeInsets.only(bottom: 16),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFE3F2FD),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Row(
//                         children: [
//                           Icon(Icons.balance_rounded,
//                               color: Color(0xFF1565C0), size: 18),
//                           SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               'বাংলাদেশের আইন অনুযায়ী আপনার অধিকারসমূহ।',
//                               style: TextStyle(
//                                   fontSize: 12, color: Color(0xFF1565C0)),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     ...RulesService.defaultLegalRules.map((rule) =>
//                         Card(
//                           margin: const EdgeInsets.only(bottom: 10),
//                           child: Padding(
//                             padding: const EdgeInsets.all(14),
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Container(
//                                   width: 38, height: 38,
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFE3F2FD),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: const Center(
//                                     child: Text('⚖️',
//                                         style: TextStyle(fontSize: 18)),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(rule['title'],
//                                           style: const TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.bold)),
//                                       const SizedBox(height: 4),
//                                       Text(rule['description'],
//                                           style: TextStyle(
//                                               fontSize: 13,
//                                               color: Theme.of(context)
//                                                   .colorScheme
//                                                   .onSurface
//                                                   .withOpacity(0.7),
//                                               height: 1.5)),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         )),
//                   ],
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class _TenantRuleCard extends StatelessWidget {
//   final RuleModel rule;
//   const _TenantRuleCard({required this.rule});

//   @override
//   Widget build(BuildContext context) {
//     final catColor = Color(int.parse(rule.categoryColorHex, radix: 16));
//     return Card(
//       margin: const EdgeInsets.only(bottom: 10),
//       child: Padding(
//         padding: const EdgeInsets.all(14),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               width: 38, height: 38,
//               decoration: BoxDecoration(
//                 color: catColor.withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Center(
//                 child: Text(rule.categoryIcon,
//                     style: const TextStyle(fontSize: 18)),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(rule.title,
//                       style: const TextStyle(
//                           fontSize: 14, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 4),
//                   Text(rule.description,
//                       style: TextStyle(
//                           fontSize: 13,
//                           color: Theme.of(context)
//                               .colorScheme
//                               .onSurface
//                               .withOpacity(0.7),
//                           height: 1.5)),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }








import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/rule_model.dart';
import '../../../models/user_model.dart';
import '../../../services/rules_service.dart';

class TenantRulesScreen extends StatelessWidget {
  final UserModel user;
  const TenantRulesScreen({super.key, required this.user});

  Future<String?> _getLandlordId() async {
    final snap = await FirebaseFirestore.instance
        .collection('tenants')
        .where('email', isEqualTo: user.email)
        .where('isActive', isEqualTo: true)
        .get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first.data()['landlordId'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bg,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              backgroundColor: bg,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 20, color: textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text('নিয়মাবলী',
                  style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              centerTitle: true,
              bottom: TabBar(
                labelColor: primary,
                unselectedLabelColor: textSecondary,
                indicatorColor: primary,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontSize: 14),
                tabs: const [
                  Tab(text: 'বাড়ির নিয়ম'),
                  Tab(text: 'আইনী অধিকার'),
                ],
              ),
            ),
          ],
          body: FutureBuilder<String?>(
            future: _getLandlordId(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(color: primary));
              }
              final landlordId = snap.data;
              if (landlordId == null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                            color: primary.withOpacity(0.1),
                            shape: BoxShape.circle),
                        child: Icon(Icons.info_outline_rounded,
                            size: 40, color: primary.withOpacity(0.5)),
                      ),
                      const SizedBox(height: 16),
                      Text('তথ্য পাওয়া যায়নি',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textPrimary)),
                    ],
                  ),
                );
              }

              return TabBarView(
                children: [
                  // ── Tab 1: বাড়ির নিয়ম ─────────────────────────
                  StreamBuilder<List<RuleModel>>(
                    stream: RulesService().getRules(landlordId),
                    builder: (context, snap2) {
                      final rules = (snap2.data ?? [])
                          .where((r) => r.category != RuleCategory.legal)
                          .toList();

                      if (snap2.connectionState == ConnectionState.waiting) {
                        return Center(
                            child: CircularProgressIndicator(color: primary));
                      }

                      if (rules.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🏠',
                                  style: TextStyle(fontSize: 56)),
                              const SizedBox(height: 12),
                              Text('কোনো বিশেষ নিয়ম নেই',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary)),
                              const SizedBox(height: 6),
                              Text('বাড়ীওয়ালা নিয়ম যোগ করলে এখানে দেখাবে',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: textSecondary)),
                            ],
                          ),
                        );
                      }

                      return ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                        children: [
                          // Info banner
                          _InfoBanner(
                            icon: Icons.info_outline_rounded,
                            text:
                                'এই নিয়মগুলো আপনার বাড়ীওয়ালা নির্ধারণ করেছেন।',
                            color: primary,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 12),
                          ...rules.map((rule) => _RuleCard(
                                rule: rule,
                                isDark: isDark,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                              )),
                        ],
                      );
                    },
                  ),

                  // ── Tab 2: আইনী অধিকার ─────────────────────────
                  ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    children: [
                      _InfoBanner(
                        icon: Icons.balance_rounded,
                        text: 'বাংলাদেশের আইন অনুযায়ী আপনার অধিকারসমূহ।',
                        color: const Color(0xFF0891B2),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      ...RulesService.defaultLegalRules.map(
                        (rule) => _LegalRuleCard(
                          title: rule['title'],
                          description: rule['description'],
                          isDark: isDark,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Info Banner ───────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool isDark;
  const _InfoBanner({
    required this.icon,
    required this.text,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                  height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rule Card (বাড়ির নিয়ম) ───────────────────────────────────────────────────

class _RuleCard extends StatelessWidget {
  final RuleModel rule;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  const _RuleCard({
    required this.rule,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final catColor = Color(int.parse(rule.categoryColorHex, radix: 16));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: catColor.withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: catColor.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(rule.categoryIcon,
                    style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rule.title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textPrimary)),
                  const SizedBox(height: 5),
                  Text(rule.description,
                      style: TextStyle(
                          fontSize: 13,
                          color: textSecondary,
                          height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Legal Rule Card ───────────────────────────────────────────────────────────

class _LegalRuleCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  const _LegalRuleCard({
    required this.title,
    required this.description,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    const legalColor = Color(0xFF0891B2);
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: legalColor.withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: legalColor.withOpacity(0.3)),
              ),
              child: const Center(
                child:
                    Text('⚖️', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textPrimary)),
                  const SizedBox(height: 5),
                  Text(description,
                      style: TextStyle(
                          fontSize: 13,
                          color: textSecondary,
                          height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}