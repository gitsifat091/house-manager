import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/rules_service.dart';
import '../../../models/rule_model.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser!;
    final service = RulesService();

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
        body: TabBarView(
          children: [
            // ── বাড়ির নিয়ম ──
            _HouseRulesTab(landlordId: user.uid, service: service),
            // ── আইনী অধিকার ──
            _LegalRulesTab(landlordId: user.uid, service: service),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddRuleSheet(context, user.uid, service),
          icon: const Icon(Icons.add),
          label: const Text('নিয়ম যোগ করুন'),
        ),
      ),
    );
  }

  void _showAddRuleSheet(
      BuildContext context, String landlordId, RulesService service,
      {RuleModel? existing}) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    RuleCategory selectedCat = existing?.category ?? RuleCategory.house;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(existing != null ? 'নিয়ম সম্পাদনা' : 'নতুন নিয়ম যোগ করুন',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // Category selector
                const Text('ধরন',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: RuleCategory.values.map((cat) {
                    final labels = ['বাড়ির নিয়ম', 'আইনী', 'ভাড়া', 'মেরামত'];
                    return ChoiceChip(
                      label: Text(labels[cat.index]),
                      selected: selectedCat == cat,
                      onSelected: (_) =>
                          setModalState(() => selectedCat = cat),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'নিয়মের শিরোনাম',
                    hintText: 'যেমন: রাত ১০টার পর শব্দ নিষেধ',
                  ),
                  validator: (v) => v!.isEmpty ? 'শিরোনাম দিন' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'বিস্তারিত',
                    hintText: 'নিয়মটি বিস্তারিত লিখুন',
                  ),
                  validator: (v) => v!.isEmpty ? 'বিস্তারিত লিখুন' : null,
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final rule = RuleModel(
                        id: existing?.id ?? '',
                        landlordId: landlordId,
                        title: titleCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        category: selectedCat,
                        createdAt: existing?.createdAt ?? DateTime.now(),
                      );
                      if (existing != null) {
                        await service.updateRule(rule);
                      } else {
                        await service.addRule(rule);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Text(existing != null ? 'Update করুন' : 'Save করুন'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── বাড়ির নিয়ম Tab ─────────────────────────────────────────

class _HouseRulesTab extends StatelessWidget {
  final String landlordId;
  final RulesService service;
  const _HouseRulesTab({required this.landlordId, required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RuleModel>>(
      stream: service.getRules(landlordId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final rules = (snap.data ?? [])
            .where((r) => r.category != RuleCategory.legal)
            .toList();

        if (rules.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.rule_rounded, size: 44,
                      color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 16),
                const Text('কোনো নিয়ম নেই',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('নিচের বাটন দিয়ে নিয়ম যোগ করুন',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        // Group by category
        final Map<RuleCategory, List<RuleModel>> grouped = {};
        for (final rule in rules) {
          grouped.putIfAbsent(rule.category, () => []).add(rule);
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: grouped.entries.map((entry) {
            final cat = entry.key;
            final catRules = entry.value;
            final catColor = Color(int.parse(catRules.first.categoryColorHex, radix: 16));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category header
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: Row(
                    children: [
                      Text(catRules.first.categoryIcon,
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(catRules.first.categoryLabel,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: catColor)),
                    ],
                  ),
                ),

                // Rules
                ...catRules.map((rule) => _RuleCard(
                  rule: rule,
                  service: service,
                  onEdit: () {},
                )),

                const SizedBox(height: 12),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}

// ── আইনী অধিকার Tab ─────────────────────────────────────────

class _LegalRulesTab extends StatelessWidget {
  final String landlordId;
  final RulesService service;
  const _LegalRulesTab({required this.landlordId, required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RuleModel>>(
      stream: service.getRules(landlordId),
      builder: (context, snap) {
        final customLegal = (snap.data ?? [])
            .where((r) => r.category == RuleCategory.legal)
            .toList();

        final defaultRules = RulesService.defaultLegalRules;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Pre-loaded সরকারি নিয়ম
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Color(0xFF1565C0), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'এগুলো বাংলাদেশের প্রচলিত ভাড়াটিয়া আইন অনুযায়ী। আইনজীবীর পরামর্শ নিন।',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFF1565C0)),
                    ),
                  ),
                ],
              ),
            ),

            // Default legal rules
            ...defaultRules.map((rule) => _DefaultLegalCard(rule: rule)),

            // Custom legal rules
            if (customLegal.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('আপনার যোগ করা আইনী নিয়ম',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...customLegal.map((rule) => _RuleCard(
                rule: rule, service: service, onEdit: () {},
              )),
            ],
          ],
        );
      },
    );
  }
}

// ── Rule Card ─────────────────────────────────────────────────

class _RuleCard extends StatelessWidget {
  final RuleModel rule;
  final RulesService service;
  final VoidCallback onEdit;
  const _RuleCard({required this.rule, required this.service, required this.onEdit});

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
            PopupMenuButton(
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'delete',
                    child: Text('মুছুন',
                        style: TextStyle(color: Colors.red))),
              ],
              onSelected: (val) async {
                if (val == 'delete') await service.deleteRule(rule.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DefaultLegalCard extends StatelessWidget {
  final Map<String, dynamic> rule;
  const _DefaultLegalCard({required this.rule});

  @override
  Widget build(BuildContext context) {
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
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('⚖️', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(rule['title'],
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('সরকারি',
                            style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF1565C0),
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
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
    );
  }
}