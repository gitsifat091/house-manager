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








// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../services/auth_service.dart';
// import '../../../services/rules_service.dart';
// import '../../../models/rule_model.dart';

// class RulesScreen extends StatefulWidget {
//   const RulesScreen({super.key});

//   @override
//   State<RulesScreen> createState() => _RulesScreenState();
// }

// class _RulesScreenState extends State<RulesScreen>
//     with SingleTickerProviderStateMixin
//     with TickerProviderStateMixin {
//   late TabController _tabController;
//   late AnimationController _animController;
//   late Animation<double> _fadeAnim;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
//     _animController.forward();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _animController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = context.read<AuthService>().currentUser!;
//     final service = RulesService();
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final primary = Theme.of(context).colorScheme.primary;
//     final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
//     final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
//     final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);

//     return Scaffold(
//       backgroundColor: bg,
//       body: FadeTransition(
//         opacity: _fadeAnim,
//         child: CustomScrollView(
//           physics: const BouncingScrollPhysics(),
//           slivers: [
//             // ── SliverAppBar with header ──────────────────────────────
//             SliverAppBar(
//               expandedHeight: 175,
//               collapsedHeight: 60,
//               pinned: true,
//               backgroundColor: bg,
//               elevation: 0,
//               leading: IconButton(
//                 icon: Icon(Icons.arrow_back_ios_new_rounded,
//                     size: 20, color: textPrimary),
//                 onPressed: () => Navigator.pop(context),
//               ),
//               title: Text(
//                 'নিয়মাবলী',
//                 style: TextStyle(
//                   color: textPrimary,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               centerTitle: true,
//               actions: [
//                 IconButton(
//                   icon: Icon(Icons.add_circle_outline_rounded,
//                       color: primary, size: 26),
//                   onPressed: () =>
//                       _showAddRuleSheet(context, user.uid, service),
//                   tooltip: 'নিয়ম যোগ করুন',
//                 ),
//                 const SizedBox(width: 4),
//               ],
//               flexibleSpace: FlexibleSpaceBar(
//                 background: _buildHeader(
//                   isDark: isDark,
//                   primary: primary,
//                   textPrimary: textPrimary,
//                   textSecondary: textSecondary,
//                   landlordId: user.uid,
//                   service: service,
//                 ),
//               ),
//               bottom: PreferredSize(
//                 preferredSize: const Size.fromHeight(48),
//                 child: Container(
//                   margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
//                   height: 42,
//                   decoration: BoxDecoration(
//                     color: isDark
//                         ? Colors.white.withOpacity(0.08)
//                         : primary.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: primary.withOpacity(0.15),
//                     ),
//                   ),
//                   child: TabBar(
//                     controller: _tabController,
//                     indicator: BoxDecoration(
//                       color: primary,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     indicatorSize: TabBarIndicatorSize.tab,
//                     dividerColor: Colors.transparent,
//                     labelColor: Colors.white,
//                     unselectedLabelColor: textSecondary,
//                     labelStyle: const TextStyle(
//                         fontSize: 13, fontWeight: FontWeight.w700),
//                     unselectedLabelStyle:
//                         const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
//                     tabs: const [
//                       Tab(text: '🏠  বাড়ির নিয়ম'),
//                       Tab(text: '⚖️  আইনী অধিকার'),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             // ── TabBarView as Sliver ──────────────────────────────────
//             SliverFillRemaining(
//               child: TabBarView(
//                 controller: _tabController,
//                 children: [
//                   _HouseRulesTab(
//                     landlordId: user.uid,
//                     service: service,
//                     isDark: isDark,
//                     primary: primary,
//                     onAdd: () => _showAddRuleSheet(context, user.uid, service),
//                   ),
//                   _LegalRulesTab(
//                     landlordId: user.uid,
//                     service: service,
//                     isDark: isDark,
//                     primary: primary,
//                     onAdd: () => _showAddRuleSheet(context, user.uid, service),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),

//       // ── FAB ──────────────────────────────────────────────────────────
//       floatingActionButton: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//                 color: primary.withOpacity(0.4),
//                 blurRadius: 16,
//                 offset: const Offset(0, 6))
//           ],
//         ),
//         child: FloatingActionButton.extended(
//           onPressed: () => _showAddRuleSheet(context, user.uid, service),
//           icon: const Icon(Icons.add_rounded),
//           label: const Text('নিয়ম যোগ করুন',
//               style: TextStyle(fontWeight: FontWeight.w700)),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         ),
//       ),
//     );
//   }

//   // ── Header (Settings style) ───────────────────────────────────────────
//   Widget _buildHeader({
//     required bool isDark,
//     required Color primary,
//     required Color textPrimary,
//     required Color textSecondary,
//     required String landlordId,
//     required RulesService service,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: isDark
//               ? [const Color(0xFF1A3328), const Color(0xFF0F1A14)]
//               : [const Color(0xFFE8F5EE), const Color(0xFFF5FAF7)],
//         ),
//       ),
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 70, 20, 16),
//           child: StreamBuilder<List<RuleModel>>(
//             stream: service.getRules(landlordId),
//             builder: (context, snap) {
//               final rules = snap.data ?? [];
//               final houseCount =
//                   rules.where((r) => r.category != RuleCategory.legal).length;
//               final legalCount =
//                   rules.where((r) => r.category == RuleCategory.legal).length +
//                       RulesService.defaultLegalRules.length;

//               return Row(
//                 children: [
//                   // Icon
//                   Container(
//                     width: 58,
//                     height: 58,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       gradient: LinearGradient(
//                         colors: [primary, primary.withOpacity(0.7)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                             color: primary.withOpacity(0.35),
//                             blurRadius: 14,
//                             offset: const Offset(0, 5))
//                       ],
//                     ),
//                     child: const Icon(Icons.gavel_rounded,
//                         color: Colors.white, size: 28),
//                   ),
//                   const SizedBox(width: 14),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text('নিয়মাবলী ব্যবস্থাপনা',
//                             style: TextStyle(
//                                 color: textPrimary,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w700)),
//                         const SizedBox(height: 4),
//                         Text('বাড়ির নিয়ম ও আইনী অধিকার',
//                             style:
//                                 TextStyle(color: textSecondary, fontSize: 12)),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             _statBadge(
//                                 '🏠 $houseCount টি নিয়ম', primary, isDark),
//                             const SizedBox(width: 8),
//                             _statBadge(
//                                 '⚖️ $legalCount টি আইন',
//                                 const Color(0xFF0891B2),
//                                 isDark),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _statBadge(String label, Color color, bool isDark) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//       decoration: BoxDecoration(
//         color: color.withOpacity(isDark ? 0.2 : 0.12),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Text(label,
//           style: TextStyle(
//               color: color, fontSize: 11, fontWeight: FontWeight.w600)),
//     );
//   }

//   // ── Add Rule Sheet ────────────────────────────────────────────────────
//   void _showAddRuleSheet(
//     BuildContext context,
//     String landlordId,
//     RulesService service, {
//     RuleModel? existing,
//   }) {
//     final titleCtrl =
//         TextEditingController(text: existing?.title ?? '');
//     final descCtrl =
//         TextEditingController(text: existing?.description ?? '');
//     RuleCategory selectedCat =
//         existing?.category ?? RuleCategory.house;
//     final formKey = GlobalKey<FormState>();

//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final primary = Theme.of(context).colorScheme.primary;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: isDark ? const Color(0xFF1A2C22) : Colors.white,
//       shape: const RoundedRectangleBorder(
//           borderRadius:
//               BorderRadius.vertical(top: Radius.circular(24))),
//       builder: (ctx) => StatefulBuilder(
//         builder: (ctx, setModalState) => Padding(
//           padding: EdgeInsets.only(
//             left: 20,
//             right: 20,
//             top: 20,
//             bottom: MediaQuery.of(context).viewInsets.bottom + 24,
//           ),
//           child: Form(
//             key: formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Handle bar
//                 Center(
//                   child: Container(
//                     width: 40,
//                     height: 4,
//                     margin: const EdgeInsets.only(bottom: 16),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.withOpacity(0.3),
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//                 ),

//                 Row(
//                   children: [
//                     Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                           color: primary,
//                           borderRadius: BorderRadius.circular(10)),
//                       child: const Icon(Icons.add_rounded,
//                           color: Colors.white, size: 22),
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       existing != null
//                           ? 'নিয়ম সম্পাদনা'
//                           : 'নতুন নিয়ম যোগ করুন',
//                       style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w700,
//                           color: isDark
//                               ? Colors.white
//                               : const Color(0xFF1A1A1A)),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),

//                 // Category chips
//                 Text('ধরন বেছে নিন',
//                     style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w700,
//                         color: isDark
//                             ? Colors.white54
//                             : const Color(0xFF6B7280),
//                         letterSpacing: 0.5)),
//                 const SizedBox(height: 10),
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: RuleCategory.values.map((cat) {
//                     final labels = [
//                       '🏠 বাড়ির নিয়ম',
//                       '⚖️ আইনী',
//                       '💰 ভাড়া',
//                       '🔧 মেরামত'
//                     ];
//                     final isSelected = selectedCat == cat;
//                     return GestureDetector(
//                       onTap: () =>
//                           setModalState(() => selectedCat = cat),
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 14, vertical: 8),
//                         decoration: BoxDecoration(
//                           color: isSelected
//                               ? primary
//                               : primary.withOpacity(0.08),
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                             color: isSelected
//                                 ? primary
//                                 : primary.withOpacity(0.2),
//                           ),
//                         ),
//                         child: Text(
//                           labels[cat.index],
//                           style: TextStyle(
//                             color: isSelected
//                                 ? Colors.white
//                                 : primary,
//                             fontSize: 13,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//                 const SizedBox(height: 16),

//                 // Title field
//                 TextFormField(
//                   controller: titleCtrl,
//                   style: TextStyle(
//                       color:
//                           isDark ? Colors.white : const Color(0xFF1A1A1A)),
//                   decoration: InputDecoration(
//                     labelText: 'নিয়মের শিরোনাম',
//                     hintText: 'যেমন: রাত ১০টার পর শব্দ নিষেধ',
//                     prefixIcon: Icon(Icons.title_rounded, color: primary),
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: primary, width: 2),
//                     ),
//                     filled: true,
//                     fillColor: isDark
//                         ? Colors.white.withOpacity(0.05)
//                         : primary.withOpacity(0.04),
//                   ),
//                   validator: (v) =>
//                       v!.isEmpty ? 'শিরোনাম দিন' : null,
//                 ),
//                 const SizedBox(height: 12),

//                 // Description field
//                 TextFormField(
//                   controller: descCtrl,
//                   maxLines: 3,
//                   style: TextStyle(
//                       color:
//                           isDark ? Colors.white : const Color(0xFF1A1A1A)),
//                   decoration: InputDecoration(
//                     labelText: 'বিস্তারিত',
//                     hintText: 'নিয়মটি বিস্তারিত লিখুন',
//                     prefixIcon: Padding(
//                       padding: const EdgeInsets.only(bottom: 40),
//                       child: Icon(Icons.description_outlined,
//                           color: primary),
//                     ),
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: primary, width: 2),
//                     ),
//                     filled: true,
//                     fillColor: isDark
//                         ? Colors.white.withOpacity(0.05)
//                         : primary.withOpacity(0.04),
//                   ),
//                   validator: (v) =>
//                       v!.isEmpty ? 'বিস্তারিত লিখুন' : null,
//                 ),
//                 const SizedBox(height: 20),

//                 // Save button
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: FilledButton.icon(
//                     icon: Icon(
//                         existing != null
//                             ? Icons.check_rounded
//                             : Icons.save_rounded,
//                         size: 20),
//                     label: Text(
//                       existing != null ? 'Update করুন' : 'Save করুন',
//                       style: const TextStyle(
//                           fontSize: 15, fontWeight: FontWeight.w700),
//                     ),
//                     style: FilledButton.styleFrom(
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14)),
//                     ),
//                     onPressed: () async {
//                       if (!formKey.currentState!.validate()) return;
//                       final rule = RuleModel(
//                         id: existing?.id ?? '',
//                         landlordId: landlordId,
//                         title: titleCtrl.text.trim(),
//                         description: descCtrl.text.trim(),
//                         category: selectedCat,
//                         createdAt:
//                             existing?.createdAt ?? DateTime.now(),
//                       );
//                       if (existing != null) {
//                         await service.updateRule(rule);
//                       } else {
//                         await service.addRule(rule);
//                       }
//                       if (ctx.mounted) Navigator.pop(ctx);
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════════════════════
// // ── House Rules Tab ───────────────────────────────────────────────────────────
// // ═══════════════════════════════════════════════════════════════════════════════

// class _HouseRulesTab extends StatelessWidget {
//   final String landlordId;
//   final RulesService service;
//   final bool isDark;
//   final Color primary;
//   final VoidCallback onAdd;

//   const _HouseRulesTab({
//     required this.landlordId,
//     required this.service,
//     required this.isDark,
//     required this.primary,
//     required this.onAdd,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final textSecondary =
//         isDark ? Colors.white54 : const Color(0xFF6B7280);

//     return StreamBuilder<List<RuleModel>>(
//       stream: service.getRules(landlordId),
//       builder: (context, snap) {
//         if (snap.connectionState == ConnectionState.waiting) {
//           return Center(
//               child: CircularProgressIndicator(color: primary));
//         }

//         final rules = (snap.data ?? [])
//             .where((r) => r.category != RuleCategory.legal)
//             .toList();

//         if (rules.isEmpty) {
//           return _emptyState(
//             context,
//             icon: Icons.rule_rounded,
//             title: 'কোনো নিয়ম নেই',
//             subtitle: 'FAB বাটন দিয়ে নতুন নিয়ম যোগ করুন',
//             primary: primary,
//             textSecondary: textSecondary,
//           );
//         }

//         // Group by category
//         final Map<RuleCategory, List<RuleModel>> grouped = {};
//         for (final rule in rules) {
//           grouped.putIfAbsent(rule.category, () => []).add(rule);
//         }

//         return ListView(
//           padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
//           physics: const BouncingScrollPhysics(),
//           children: grouped.entries.map((entry) {
//             final catRules = entry.value;
//             final catColor = Color(
//                 int.parse(catRules.first.categoryColorHex, radix: 16));

//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // ── Category Header (Settings sectionHeader style) ──
//                 Padding(
//                   padding:
//                       const EdgeInsets.only(left: 4, bottom: 8, top: 4),
//                   child: Row(
//                     children: [
//                       Text(catRules.first.categoryIcon,
//                           style: const TextStyle(fontSize: 14)),
//                       const SizedBox(width: 6),
//                       Text(
//                         catRules.first.categoryLabel.toUpperCase(),
//                         style: TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w700,
//                           color: catColor,
//                           letterSpacing: 1.2,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: catColor.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text('${catRules.length} টি',
//                             style: TextStyle(
//                                 fontSize: 10,
//                                 color: catColor,
//                                 fontWeight: FontWeight.w600)),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // ── Rules Card (Settings _card style) ──
//                 Container(
//                   decoration: BoxDecoration(
//                     color: isDark
//                         ? const Color(0xFF1A2C22)
//                         : Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                           color: Colors.black.withOpacity(0.06),
//                           blurRadius: 12,
//                           offset: const Offset(0, 4))
//                     ],
//                   ),
//                   child: Column(
//                     children: catRules.asMap().entries.map((entry) {
//                       final i = entry.key;
//                       final rule = entry.value;
//                       final isLast = i == catRules.length - 1;
//                       return _RuleTile(
//                         rule: rule,
//                         service: service,
//                         isDark: isDark,
//                         primary: primary,
//                         isLast: isLast,
//                       );
//                     }).toList(),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//               ],
//             );
//           }).toList(),
//         );
//       },
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════════════════════
// // ── Legal Rules Tab ───────────────────────────────────────────────────────────
// // ═══════════════════════════════════════════════════════════════════════════════

// class _LegalRulesTab extends StatelessWidget {
//   final String landlordId;
//   final RulesService service;
//   final bool isDark;
//   final Color primary;
//   final VoidCallback onAdd;

//   const _LegalRulesTab({
//     required this.landlordId,
//     required this.service,
//     required this.isDark,
//     required this.primary,
//     required this.onAdd,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final textSecondary =
//         isDark ? Colors.white54 : const Color(0xFF6B7280);
//     const legalColor = Color(0xFF0891B2);

//     return StreamBuilder<List<RuleModel>>(
//       stream: service.getRules(landlordId),
//       builder: (context, snap) {
//         final customLegal = (snap.data ?? [])
//             .where((r) => r.category == RuleCategory.legal)
//             .toList();
//         final defaultRules = RulesService.defaultLegalRules;

//         return ListView(
//           padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
//           physics: const BouncingScrollPhysics(),
//           children: [
//             // ── Info Banner (Settings style card) ──────────────────
//             Container(
//               margin: const EdgeInsets.only(bottom: 16),
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 color: legalColor.withOpacity(isDark ? 0.15 : 0.08),
//                 borderRadius: BorderRadius.circular(14),
//                 border:
//                     Border.all(color: legalColor.withOpacity(0.25)),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 36,
//                     height: 36,
//                     decoration: BoxDecoration(
//                       color: legalColor.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: const Icon(Icons.info_outline_rounded,
//                         color: legalColor, size: 18),
//                   ),
//                   const SizedBox(width: 12),
//                   const Expanded(
//                     child: Text(
//                       'এগুলো বাংলাদেশের প্রচলিত ভাড়াটিয়া আইন অনুযায়ী। বিস্তারিত জানতে আইনজীবীর পরামর্শ নিন।',
//                       style: TextStyle(
//                           fontSize: 12,
//                           color: legalColor,
//                           height: 1.5,
//                           fontWeight: FontWeight.w500),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // ── Default Legal Rules Section Header ──────────────────
//             Padding(
//               padding:
//                   const EdgeInsets.only(left: 4, bottom: 8, top: 4),
//               child: Row(
//                 children: [
//                   const Text('⚖️',
//                       style: TextStyle(fontSize: 14)),
//                   const SizedBox(width: 6),
//                   const Text(
//                     'সরকারি আইন',
//                     style: TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.w700,
//                       color: legalColor,
//                       letterSpacing: 1.2,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 8, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: legalColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text('${defaultRules.length} টি',
//                         style: const TextStyle(
//                             fontSize: 10,
//                             color: legalColor,
//                             fontWeight: FontWeight.w600)),
//                   ),
//                 ],
//               ),
//             ),

//             // ── Default Legal Rules Card ────────────────────────────
//             Container(
//               decoration: BoxDecoration(
//                 color: isDark ? const Color(0xFF1A2C22) : Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                       color: Colors.black.withOpacity(0.06),
//                       blurRadius: 12,
//                       offset: const Offset(0, 4))
//                 ],
//               ),
//               child: Column(
//                 children: defaultRules.asMap().entries.map((entry) {
//                   final i = entry.key;
//                   final rule = entry.value;
//                   final isLast = i == defaultRules.length - 1;
//                   return _DefaultLegalTile(
//                     rule: rule,
//                     isDark: isDark,
//                     isLast: isLast,
//                   );
//                 }).toList(),
//               ),
//             ),

//             // ── Custom Legal Rules ──────────────────────────────────
//             if (customLegal.isNotEmpty) ...[
//               const SizedBox(height: 16),
//               Padding(
//                 padding:
//                     const EdgeInsets.only(left: 4, bottom: 8, top: 4),
//                 child: Row(
//                   children: [
//                     const Text('📝',
//                         style: TextStyle(fontSize: 14)),
//                     const SizedBox(width: 6),
//                     Text(
//                       'আপনার যোগ করা আইনী নিয়ম'.toUpperCase(),
//                       style: const TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF5B4FBF),
//                         letterSpacing: 1.2,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                   color:
//                       isDark ? const Color(0xFF1A2C22) : Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                         color: Colors.black.withOpacity(0.06),
//                         blurRadius: 12,
//                         offset: const Offset(0, 4))
//                   ],
//                 ),
//                 child: Column(
//                   children: customLegal.asMap().entries.map((entry) {
//                     final i = entry.key;
//                     final rule = entry.value;
//                     final isLast = i == customLegal.length - 1;
//                     return _RuleTile(
//                       rule: rule,
//                       service: service,
//                       isDark: isDark,
//                       primary: primary,
//                       isLast: isLast,
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ],

//             // ── Add legal rule prompt ───────────────────────────────
//             const SizedBox(height: 16),
//             GestureDetector(
//               onTap: onAdd,
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(14),
//                   border: Border.all(
//                       color: legalColor.withOpacity(0.4), width: 1.5),
//                   color: legalColor
//                       .withOpacity(isDark ? 0.08 : 0.04),
//                 ),
//                 child: const Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.add_rounded, color: legalColor, size: 20),
//                     SizedBox(width: 8),
//                     Text('আইনী নিয়ম যোগ করুন',
//                         style: TextStyle(
//                             color: legalColor,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600)),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════════════════════
// // ── Rule Tile (Settings _navTile style) ──────────────────────────────────────
// // ═══════════════════════════════════════════════════════════════════════════════

// class _RuleTile extends StatelessWidget {
//   final RuleModel rule;
//   final RulesService service;
//   final bool isDark;
//   final Color primary;
//   final bool isLast;

//   const _RuleTile({
//     required this.rule,
//     required this.service,
//     required this.isDark,
//     required this.primary,
//     required this.isLast,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final catColor =
//         Color(int.parse(rule.categoryColorHex, radix: 16));
//     final textPrimary =
//         isDark ? Colors.white : const Color(0xFF1A1A1A);
//     final textSecondary =
//         isDark ? Colors.white54 : const Color(0xFF6B7280);
//     final divider =
//         isDark ? Colors.white10 : const Color(0xFFE5E7EB);

//     return Column(
//       children: [
//         Material(
//           color: Colors.transparent,
//           child: InkWell(
//             borderRadius: BorderRadius.circular(isLast ? 16 : 0),
//             onTap: () {}, // tap to expand (optional future feature)
//             child: Padding(
//               padding: const EdgeInsets.symmetric(
//                   horizontal: 16, vertical: 13),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Icon (Settings iconBg style)
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: catColor,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Center(
//                       child: Text(rule.categoryIcon,
//                           style: const TextStyle(fontSize: 18)),
//                     ),
//                   ),
//                   const SizedBox(width: 14),

//                   // Content
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(rule.title,
//                             style: TextStyle(
//                                 color: textPrimary,
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w600)),
//                         const SizedBox(height: 3),
//                         Text(rule.description,
//                             style: TextStyle(
//                                 color: textSecondary,
//                                 fontSize: 12,
//                                 height: 1.4)),
//                       ],
//                     ),
//                   ),

//                   // Delete menu (Settings chevron style)
//                   PopupMenuButton(
//                     icon: Icon(Icons.more_vert_rounded,
//                         color: textSecondary, size: 18),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                     itemBuilder: (_) => [
//                       PopupMenuItem(
//                         value: 'delete',
//                         child: Row(children: [
//                           const Icon(Icons.delete_outline_rounded,
//                               size: 18, color: Colors.red),
//                           const SizedBox(width: 10),
//                           const Text('মুছে ফেলুন',
//                               style: TextStyle(color: Colors.red)),
//                         ]),
//                       ),
//                     ],
//                     onSelected: (val) async {
//                       if (val == 'delete') {
//                         final confirm = await showDialog<bool>(
//                           context: context,
//                           builder: (_) => AlertDialog(
//                             shape: RoundedRectangleBorder(
//                                 borderRadius:
//                                     BorderRadius.circular(16)),
//                             title: const Text('মুছে ফেলবেন?',
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.w700)),
//                             content: Text(
//                                 '"${rule.title}" নিয়মটি মুছে যাবে।'),
//                             actions: [
//                               TextButton(
//                                   onPressed: () =>
//                                       Navigator.pop(context, false),
//                                   child: const Text('না')),
//                               FilledButton(
//                                 onPressed: () =>
//                                     Navigator.pop(context, true),
//                                 style: FilledButton.styleFrom(
//                                     backgroundColor: Colors.red),
//                                 child: const Text('হ্যাঁ, মুছুন'),
//                               ),
//                             ],
//                           ),
//                         );
//                         if (confirm == true) {
//                           await service.deleteRule(rule.id);
//                         }
//                       }
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         if (!isLast)
//           Padding(
//             padding: const EdgeInsets.only(left: 70),
//             child: Divider(height: 1, color: divider),
//           ),
//       ],
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════════════════════
// // ── Default Legal Tile (non-deletable) ───────────────────────────────────────
// // ═══════════════════════════════════════════════════════════════════════════════

// class _DefaultLegalTile extends StatelessWidget {
//   final Map<String, dynamic> rule;
//   final bool isDark;
//   final bool isLast;

//   const _DefaultLegalTile({
//     required this.rule,
//     required this.isDark,
//     required this.isLast,
//   });

//   @override
//   Widget build(BuildContext context) {
//     const legalColor = Color(0xFF0891B2);
//     final textPrimary =
//         isDark ? Colors.white : const Color(0xFF1A1A1A);
//     final textSecondary =
//         isDark ? Colors.white54 : const Color(0xFF6B7280);
//     final divider =
//         isDark ? Colors.white10 : const Color(0xFFE5E7EB);

//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(
//               horizontal: 16, vertical: 13),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Icon
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: legalColor.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Center(
//                   child: Text('⚖️',
//                       style: TextStyle(fontSize: 18)),
//                 ),
//               ),
//               const SizedBox(width: 14),

//               // Content
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(rule['title'],
//                               style: TextStyle(
//                                   color: textPrimary,
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.w600)),
//                         ),
//                         // Badge (Settings badge style)
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 3),
//                           decoration: BoxDecoration(
//                             color: legalColor.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: const Text('সরকারি',
//                               style: TextStyle(
//                                   color: legalColor,
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.w600)),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 3),
//                     Text(rule['description'],
//                         style: TextStyle(
//                             color: textSecondary,
//                             fontSize: 12,
//                             height: 1.4)),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         if (!isLast)
//           Padding(
//             padding: const EdgeInsets.only(left: 70),
//             child: Divider(height: 1, color: divider),
//           ),
//       ],
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════════════════════
// // ── Empty State ───────────────────────────────────────────────────────────────
// // ═══════════════════════════════════════════════════════════════════════════════

// Widget _emptyState(
//   BuildContext context, {
//   required IconData icon,
//   required String title,
//   required String subtitle,
//   required Color primary,
//   required Color textSecondary,
// }) {
//   return Center(
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 90,
//           height: 90,
//           decoration: BoxDecoration(
//             color: primary.withOpacity(0.08),
//             shape: BoxShape.circle,
//             border: Border.all(color: primary.withOpacity(0.2), width: 2),
//           ),
//           child: Icon(icon, size: 44, color: primary.withOpacity(0.5)),
//         ),
//         const SizedBox(height: 20),
//         Text(title,
//             style: const TextStyle(
//                 fontSize: 18, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 8),
//         Text(subtitle,
//             style: TextStyle(fontSize: 14, color: textSecondary)),
//       ],
//     ),
//   );
// }