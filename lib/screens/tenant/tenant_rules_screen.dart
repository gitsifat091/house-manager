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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('নিয়মাবলী'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'বাড়ির নিয়ম'),
              Tab(text: 'আইনী অধিকার'),
            ],
          ),
        ),
        body: FutureBuilder<String?>(
          future: _getLandlordId(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final landlordId = snap.data;
            if (landlordId == null) {
              return const Center(child: Text('তথ্য পাওয়া যায়নি'));
            }

            return TabBarView(
              children: [
                // বাড়ির নিয়ম
                StreamBuilder<List<RuleModel>>(
                  stream: RulesService().getRules(landlordId),
                  builder: (context, snap2) {
                    final rules = (snap2.data ?? [])
                        .where((r) => r.category != RuleCategory.legal)
                        .toList();

                    if (rules.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🏠', style: TextStyle(fontSize: 56)),
                            SizedBox(height: 12),
                            Text('কোনো বিশেষ নিয়ম নেই',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'এই নিয়মগুলো আপনার বাড়ীওয়ালা নির্ধারণ করেছেন।',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...rules.map((rule) => _TenantRuleCard(rule: rule)),
                      ],
                    );
                  },
                ),

                // আইনী অধিকার
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.balance_rounded,
                              color: Color(0xFF1565C0), size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'বাংলাদেশের আইন অনুযায়ী আপনার অধিকারসমূহ।',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF1565C0)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...RulesService.defaultLegalRules.map((rule) =>
                        Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 38, height: 38,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE3F2FD),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: Text('⚖️',
                                        style: TextStyle(fontSize: 18)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(rule['title'],
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(rule['description'],
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.7),
                                              height: 1.5)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TenantRuleCard extends StatelessWidget {
  final RuleModel rule;
  const _TenantRuleCard({required this.rule});

  @override
  Widget build(BuildContext context) {
    final catColor = Color(int.parse(rule.categoryColorHex, radix: 16));
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: catColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(rule.categoryIcon,
                    style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rule.title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(rule.description,
                      style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
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