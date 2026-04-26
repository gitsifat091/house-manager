// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../services/auth_service.dart';
// import '../../../services/rules_service.dart';
// import '../../../models/rule_model.dart';

// class RulesScreen extends StatelessWidget {
//   const RulesScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final user = context.read<AuthService>().currentUser!;
//     final service = RulesService();

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
//         body: TabBarView(
//           children: [
//             // ── বাড়ির নিয়ম ──
//             _HouseRulesTab(landlordId: user.uid, service: service),
//             // ── আইনী অধিকার ──
//             _LegalRulesTab(landlordId: user.uid, service: service),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton.extended(
//           onPressed: () => _showAddRuleSheet(context, user.uid, service),
//           icon: const Icon(Icons.add),
//           label: const Text('নিয়ম যোগ করুন'),
//         ),
//       ),
//     );
//   }

//   void _showAddRuleSheet(
//       BuildContext context, String landlordId, RulesService service,
//       {RuleModel? existing}) {
//     final titleCtrl = TextEditingController(text: existing?.title ?? '');
//     final descCtrl = TextEditingController(text: existing?.description ?? '');
//     RuleCategory selectedCat = existing?.category ?? RuleCategory.house;
//     final formKey = GlobalKey<FormState>();

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (ctx) => StatefulBuilder(
//         builder: (ctx, setModalState) => Padding(
//           padding: EdgeInsets.only(
//             left: 20, right: 20, top: 20,
//             bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//           ),
//           child: Form(
//             key: formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(existing != null ? 'নিয়ম সম্পাদনা' : 'নতুন নিয়ম যোগ করুন',
//                     style: const TextStyle(
//                         fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 16),

//                 // Category selector
//                 const Text('ধরন',
//                     style: TextStyle(
//                         fontSize: 13, fontWeight: FontWeight.w500)),
//                 const SizedBox(height: 8),
//                 Wrap(
//                   spacing: 8,
//                   children: RuleCategory.values.map((cat) {
//                     final labels = ['বাড়ির নিয়ম', 'আইনী', 'ভাড়া', 'মেরামত'];
//                     return ChoiceChip(
//                       label: Text(labels[cat.index]),
//                       selected: selectedCat == cat,
//                       onSelected: (_) =>
//                           setModalState(() => selectedCat = cat),
//                     );
//                   }).toList(),
//                 ),
//                 const SizedBox(height: 14),

//                 TextFormField(
//                   controller: titleCtrl,
//                   decoration: const InputDecoration(
//                     labelText: 'নিয়মের শিরোনাম',
//                     hintText: 'যেমন: রাত ১০টার পর শব্দ নিষেধ',
//                   ),
//                   validator: (v) => v!.isEmpty ? 'শিরোনাম দিন' : null,
//                 ),
//                 const SizedBox(height: 12),

//                 TextFormField(
//                   controller: descCtrl,
//                   maxLines: 3,
//                   decoration: const InputDecoration(
//                     labelText: 'বিস্তারিত',
//                     hintText: 'নিয়মটি বিস্তারিত লিখুন',
//                   ),
//                   validator: (v) => v!.isEmpty ? 'বিস্তারিত লিখুন' : null,
//                 ),
//                 const SizedBox(height: 16),

//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: FilledButton(
//                     onPressed: () async {
//                       if (!formKey.currentState!.validate()) return;
//                       final rule = RuleModel(
//                         id: existing?.id ?? '',
//                         landlordId: landlordId,
//                         title: titleCtrl.text.trim(),
//                         description: descCtrl.text.trim(),
//                         category: selectedCat,
//                         createdAt: existing?.createdAt ?? DateTime.now(),
//                       );
//                       if (existing != null) {
//                         await service.updateRule(rule);
//                       } else {
//                         await service.addRule(rule);
//                       }
//                       if (ctx.mounted) Navigator.pop(ctx);
//                     },
//                     child: Text(existing != null ? 'Update করুন' : 'Save করুন'),
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

// // ── বাড়ির নিয়ম Tab ─────────────────────────────────────────

// class _HouseRulesTab extends StatelessWidget {
//   final String landlordId;
//   final RulesService service;
//   const _HouseRulesTab({required this.landlordId, required this.service});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<List<RuleModel>>(
//       stream: service.getRules(landlordId),
//       builder: (context, snap) {
//         if (snap.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final rules = (snap.data ?? [])
//             .where((r) => r.category != RuleCategory.legal)
//             .toList();

//         if (rules.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 90, height: 90,
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).colorScheme.primaryContainer,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(Icons.rule_rounded, size: 44,
//                       color: Theme.of(context).colorScheme.primary),
//                 ),
//                 const SizedBox(height: 16),
//                 const Text('কোনো নিয়ম নেই',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 8),
//                 const Text('নিচের বাটন দিয়ে নিয়ম যোগ করুন',
//                     style: TextStyle(color: Colors.grey)),
//               ],
//             ),
//           );
//         }

//         // Group by category
//         final Map<RuleCategory, List<RuleModel>> grouped = {};
//         for (final rule in rules) {
//           grouped.putIfAbsent(rule.category, () => []).add(rule);
//         }

//         return ListView(
//           padding: const EdgeInsets.all(16),
//           children: grouped.entries.map((entry) {
//             final cat = entry.key;
//             final catRules = entry.value;
//             final catColor = Color(int.parse(catRules.first.categoryColorHex, radix: 16));

//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Category header
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 8, top: 4),
//                   child: Row(
//                     children: [
//                       Text(catRules.first.categoryIcon,
//                           style: const TextStyle(fontSize: 16)),
//                       const SizedBox(width: 6),
//                       Text(catRules.first.categoryLabel,
//                           style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.bold,
//                               color: catColor)),
//                     ],
//                   ),
//                 ),

//                 // Rules
//                 ...catRules.map((rule) => _RuleCard(
//                   rule: rule,
//                   service: service,
//                   onEdit: () {},
//                 )),

//                 const SizedBox(height: 12),
//               ],
//             );
//           }).toList(),
//         );
//       },
//     );
//   }
// }

// // ── আইনী অধিকার Tab ─────────────────────────────────────────

// class _LegalRulesTab extends StatelessWidget {
//   final String landlordId;
//   final RulesService service;
//   const _LegalRulesTab({required this.landlordId, required this.service});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<List<RuleModel>>(
//       stream: service.getRules(landlordId),
//       builder: (context, snap) {
//         final customLegal = (snap.data ?? [])
//             .where((r) => r.category == RuleCategory.legal)
//             .toList();

//         final defaultRules = RulesService.defaultLegalRules;

//         return ListView(
//           padding: const EdgeInsets.all(16),
//           children: [
//             // Pre-loaded সরকারি নিয়ম
//             Container(
//               padding: const EdgeInsets.all(12),
//               margin: const EdgeInsets.only(bottom: 16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE3F2FD),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Row(
//                 children: [
//                   Icon(Icons.info_outline_rounded,
//                       color: Color(0xFF1565C0), size: 18),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'এগুলো বাংলাদেশের প্রচলিত ভাড়াটিয়া আইন অনুযায়ী। আইনজীবীর পরামর্শ নিন।',
//                       style: TextStyle(
//                           fontSize: 12, color: Color(0xFF1565C0)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Default legal rules
//             ...defaultRules.map((rule) => _DefaultLegalCard(rule: rule)),

//             // Custom legal rules
//             if (customLegal.isNotEmpty) ...[
//               const SizedBox(height: 16),
//               const Text('আপনার যোগ করা আইনী নিয়ম',
//                   style: TextStyle(
//                       fontSize: 14, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               ...customLegal.map((rule) => _RuleCard(
//                 rule: rule, service: service, onEdit: () {},
//               )),
//             ],
//           ],
//         );
//       },
//     );
//   }
// }

// // ── Rule Card ─────────────────────────────────────────────────

// class _RuleCard extends StatelessWidget {
//   final RuleModel rule;
//   final RulesService service;
//   final VoidCallback onEdit;
//   const _RuleCard({required this.rule, required this.service, required this.onEdit});

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
//             PopupMenuButton(
//               itemBuilder: (_) => [
//                 const PopupMenuItem(value: 'delete',
//                     child: Text('মুছুন',
//                         style: TextStyle(color: Colors.red))),
//               ],
//               onSelected: (val) async {
//                 if (val == 'delete') await service.deleteRule(rule.id);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _DefaultLegalCard extends StatelessWidget {
//   final Map<String, dynamic> rule;
//   const _DefaultLegalCard({required this.rule});

//   @override
//   Widget build(BuildContext context) {
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
//                 color: const Color(0xFFE3F2FD),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Center(
//                 child: Text('⚖️', style: TextStyle(fontSize: 18)),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(rule['title'],
//                             style: const TextStyle(
//                                 fontSize: 14, fontWeight: FontWeight.bold)),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFE3F2FD),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: const Text('সরকারি',
//                             style: TextStyle(
//                                 fontSize: 10,
//                                 color: Color(0xFF1565C0),
//                                 fontWeight: FontWeight.w500)),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text(rule['description'],
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
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/rules_service.dart';
import '../../../models/rule_model.dart';

class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen>
    // with SingleTickerProviderStateMixin {
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _animController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);

    final user = context.read<AuthService>().currentUser!;
    final service = RulesService();

    return Scaffold(
      backgroundColor: bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 180,
              collapsedHeight: 60,
              pinned: true,
              forceElevated: innerBoxIsScrolled,
              backgroundColor: bg,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'নিয়মাবলী',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.add_circle_outline_rounded,
                    color: primary,
                    size: 26,
                  ),
                  tooltip: 'নিয়ম যোগ করুন',
                  onPressed: () =>
                      _showAddRuleSheet(context, user.uid, service),
                ),
                const SizedBox(width: 4),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeroBg(
                  primary: primary,
                  isDark: isDark,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: isDark
                        ? Colors.white54
                        : const Color(0xFF6B7280),
                    labelStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: '🏠  বাড়ির নিয়ম'),
                      Tab(text: '⚖️  আইনী অধিকার'),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _HouseRulesTab(
                landlordId: user.uid,
                service: service,
                isDark: isDark,
                primary: primary,
                onEdit: (rule) =>
                    _showAddRuleSheet(context, user.uid, service, existing: rule),
              ),
              _LegalRulesTab(
                landlordId: user.uid,
                service: service,
                isDark: isDark,
                primary: primary,
                onEdit: (rule) =>
                    _showAddRuleSheet(context, user.uid, service, existing: rule),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero Background ───────────────────────────────────────
  Widget _buildHeroBg({required Color primary, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A3328), const Color(0xFF0F1A14)]
              : [const Color(0xFFE8F5EE), const Color(0xFFF5FAF7)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 70, 20, 60),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [primary, primary.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: const Icon(Icons.rule_folder_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'বাড়ির নিয়মাবলী',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // const SizedBox(height: 4),
                    Text(
                      'বাড়ির নিয়ম ও আইনী অধিকার এক জায়গায়',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white54
                            : const Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Add / Edit Rule Bottom Sheet ──────────────────────────
  void _showAddRuleSheet(
    BuildContext context,
    String landlordId,
    RulesService service, {
    RuleModel? existing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final titleCtrl =
        TextEditingController(text: existing?.title ?? '');
    final descCtrl =
        TextEditingController(text: existing?.description ?? '');
    RuleCategory selectedCat =
        existing?.category ?? RuleCategory.house;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2C22) : Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white24
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        existing != null
                            ? Icons.edit_rounded
                            : Icons.add_rounded,
                        color: primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      existing != null
                          ? 'নিয়ম সম্পাদনা'
                          : 'নতুন নিয়ম যোগ করুন',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white
                            : const Color(0xFF1A1A1A),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Category selector
                Text(
                  'ধরন বেছে নিন',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? Colors.white54
                        : const Color(0xFF6B7280),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: RuleCategory.values.map((cat) {
                    final labels = [
                      '🏠 বাড়ির নিয়ম',
                      '⚖️ আইনী',
                      '💰 ভাড়া',
                      '🔧 মেরামত'
                    ];
                    final selected = selectedCat == cat;
                    return GestureDetector(
                      onTap: () =>
                          setModalState(() => selectedCat = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? primary
                              : (isDark
                                  ? Colors.white.withOpacity(0.06)
                                  : Colors.black.withOpacity(0.04)),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? primary
                                : (isDark
                                    ? Colors.white12
                                    : Colors.black12),
                          ),
                        ),
                        child: Text(
                          labels[cat.index],
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : (isDark
                                    ? Colors.white70
                                    : const Color(0xFF374151)),
                            fontSize: 13,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Title field
                TextFormField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'নিয়মের শিরোনাম',
                    hintText: 'যেমন: রাত ১০টার পর শব্দ নিষেধ',
                    prefixIcon:
                        const Icon(Icons.title_rounded, size: 20),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.black.withOpacity(0.03),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: primary, width: 1.5),
                    ),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? 'শিরোনাম দিন' : null,
                ),
                const SizedBox(height: 12),

                // Description field
                TextFormField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'বিস্তারিত',
                    hintText: 'নিয়মটি বিস্তারিত লিখুন',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.description_outlined, size: 20),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.black.withOpacity(0.03),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: primary, width: 1.5),
                    ),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? 'বিস্তারিত লিখুন' : null,
                ),
                const SizedBox(height: 20),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final rule = RuleModel(
                        id: existing?.id ?? '',
                        landlordId: landlordId,
                        title: titleCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        category: selectedCat,
                        createdAt:
                            existing?.createdAt ?? DateTime.now(),
                      );
                      if (existing != null) {
                        await service.updateRule(rule);
                      } else {
                        await service.addRule(rule);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    icon: Icon(existing != null
                        ? Icons.check_rounded
                        : Icons.add_rounded),
                    label: Text(
                      existing != null ? 'Update করুন' : 'Save করুন',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
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

// ══════════════════════════════════════════════════════════════
// বাড়ির নিয়ম Tab
// ══════════════════════════════════════════════════════════════

class _HouseRulesTab extends StatelessWidget {
  final String landlordId;
  final RulesService service;
  final bool isDark;
  final Color primary;
  final void Function(RuleModel) onEdit;

  const _HouseRulesTab({
    required this.landlordId,
    required this.service,
    required this.isDark,
    required this.primary,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final textSecondary =
        isDark ? Colors.white54 : const Color(0xFF6B7280);

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
          return _EmptyState(
            icon: Icons.rule_folder_outlined,
            primary: primary,
            title: 'কোনো নিয়ম নেই',
            subtitle: 'উপরের + বাটন দিয়ে নিয়ম যোগ করুন',
          );
        }

        // Group by category
        final Map<RuleCategory, List<RuleModel>> grouped = {};
        for (final rule in rules) {
          grouped.putIfAbsent(rule.category, () => []).add(rule);
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: grouped.entries.map((entry) {
            final catRules = entry.value;
            final catColor = Color(
                int.parse(catRules.first.categoryColorHex, radix: 16));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header — same style as settings_screen
                Padding(
                  padding:
                      const EdgeInsets.only(left: 4, bottom: 8, top: 4),
                  child: Row(
                    children: [
                      Text(catRules.first.categoryIcon,
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        catRules.first.categoryLabel,
                        style: TextStyle(
                          color: catColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: catColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${catRules.length}টি',
                          style: TextStyle(
                            color: catColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Card wrapper — same as settings _card
                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: List.generate(catRules.length, (i) {
                      final rule = catRules[i];
                      return Column(
                        children: [
                          _RuleTile(
                            rule: rule,
                            service: service,
                            isDark: isDark,
                            primary: primary,
                            onEdit: () => onEdit(rule),
                          ),
                          if (i < catRules.length - 1)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 70),
                              child: Divider(
                                height: 1,
                                color: isDark
                                    ? Colors.white10
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// আইনী অধিকার Tab
// ══════════════════════════════════════════════════════════════

class _LegalRulesTab extends StatelessWidget {
  final String landlordId;
  final RulesService service;
  final bool isDark;
  final Color primary;
  final void Function(RuleModel) onEdit;

  const _LegalRulesTab({
    required this.landlordId,
    required this.service,
    required this.isDark,
    required this.primary,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final textSecondary =
        isDark ? Colors.white54 : const Color(0xFF6B7280);
    final textPrimary =
        isDark ? Colors.white : const Color(0xFF1A1A1A);

    return StreamBuilder<List<RuleModel>>(
      stream: service.getRules(landlordId),
      builder: (context, snap) {
        final customLegal = (snap.data ?? [])
            .where((r) => r.category == RuleCategory.legal)
            .toList();
        final defaultRules = RulesService.defaultLegalRules;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1565C0).withOpacity(0.15)
                    : const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF1565C0).withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.info_outline_rounded,
                          color: Color(0xFF1565C0), size: 18),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'এগুলো বাংলাদেশের প্রচলিত ভাড়াটিয়া আইন অনুযায়ী। সিদ্ধান্ত নেওয়ার আগে আইনজীবীর পরামর্শ নিন।',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1565C0),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Section header for default rules
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
              child: Row(
                children: [
                  const Text('⚖️', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    'সরকারি আইনী নিয়ম',
                    style: TextStyle(
                      color: const Color(0xFF1565C0)
                          .withOpacity(isDark ? 0.8 : 1.0),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${defaultRules.length}টি',
                      style: const TextStyle(
                        color: Color(0xFF1565C0),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Default legal rules in card
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: List.generate(defaultRules.length, (i) {
                  final rule = defaultRules[i];
                  return Column(
                    children: [
                      _DefaultLegalTile(
                        rule: rule,
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                      if (i < defaultRules.length - 1)
                        Padding(
                          padding: const EdgeInsets.only(left: 70),
                          child: Divider(
                            height: 1,
                            color: isDark
                                ? Colors.white10
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                    ],
                  );
                }),
              ),
            ),

            // Custom legal rules
            if (customLegal.isNotEmpty) ...[
              const SizedBox(height: 20),
              Padding(
                padding:
                    const EdgeInsets.only(left: 4, bottom: 8, top: 4),
                child: Row(
                  children: [
                    const Text('📝', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      'আপনার যোগ করা আইনী নিয়ম',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: List.generate(customLegal.length, (i) {
                    final rule = customLegal[i];
                    return Column(
                      children: [
                        _RuleTile(
                          rule: rule,
                          service: service,
                          isDark: isDark,
                          primary: primary,
                          onEdit: () => onEdit(rule),
                        ),
                        if (i < customLegal.length - 1)
                          Padding(
                            padding: const EdgeInsets.only(left: 70),
                            child: Divider(
                              height: 1,
                              color: isDark
                                  ? Colors.white10
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                      ],
                    );
                  }),
                ),
              ),
            ],

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Rule Tile (editable/deletable) — settings _navTile style
// ══════════════════════════════════════════════════════════════

class _RuleTile extends StatelessWidget {
  final RuleModel rule;
  final RulesService service;
  final bool isDark;
  final Color primary;
  final VoidCallback onEdit;

  const _RuleTile({
    required this.rule,
    required this.service,
    required this.isDark,
    required this.primary,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final catColor =
        Color(int.parse(rule.categoryColorHex, radix: 16));
    final textPrimary =
        isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary =
        isDark ? Colors.white54 : const Color(0xFF6B7280);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(rule.categoryIcon,
                      style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.title,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      rule.description,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded,
                    color: textSecondary, size: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined,
                            size: 18, color: primary),
                        const SizedBox(width: 10),
                        const Text('সম্পাদনা'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 18, color: Colors.red),
                        SizedBox(width: 10),
                        Text('মুছুন',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (val) async {
                  if (val == 'edit') {
                    onEdit();
                  } else if (val == 'delete') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        title: const Text('নিয়ম মুছবেন?',
                            style:
                                TextStyle(fontWeight: FontWeight.w700)),
                        content: Text(
                            '"${rule.title}" — এই নিয়মটি স্থায়ীভাবে মুছে যাবে।'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: const Text('না'),
                          ),
                          FilledButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            style: FilledButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Text('হ্যাঁ, মুছুন'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await service.deleteRule(rule.id);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Default Legal Tile (read-only)
// ══════════════════════════════════════════════════════════════

class _DefaultLegalTile extends StatelessWidget {
  final Map<String, dynamic> rule;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  const _DefaultLegalTile({
    required this.rule,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('⚖️', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        rule['title'],
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'সরকারি',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  rule['description'],
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Empty State Widget
// ══════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final Color primary;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.primary,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 44, color: primary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}