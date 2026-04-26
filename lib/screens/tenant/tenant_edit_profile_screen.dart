// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../models/user_model.dart';

// class TenantEditProfileScreen extends StatefulWidget {
//   final UserModel user;
//   const TenantEditProfileScreen({super.key, required this.user});

//   @override
//   State<TenantEditProfileScreen> createState() => _TenantEditProfileScreenState();
// }

// class _TenantEditProfileScreenState extends State<TenantEditProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameCtrl = TextEditingController();
//   final _phoneCtrl = TextEditingController();
//   final _emailCtrl = TextEditingController();
//   final _nidCtrl = TextEditingController();

//   bool _loading = true;
//   bool _saving = false;
//   bool _hasEdited = false;
//   String? _tenantDocId;

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     final snap = await FirebaseFirestore.instance
//         .collection('tenants')
//         .where('email', isEqualTo: widget.user.email)
//         .where('isActive', isEqualTo: true)
//         .get();

//     if (snap.docs.isNotEmpty) {
//       final data = snap.docs.first.data();
//       _tenantDocId = snap.docs.first.id;
//       _nameCtrl.text = data['name'] ?? '';
//       _phoneCtrl.text = data['phone'] ?? '';
//       _emailCtrl.text = data['email'] ?? '';
//       _nidCtrl.text = data['nidNumber'] ?? '';
//       _hasEdited = data['hasEdited'] ?? false;
//     }

//     setState(() => _loading = false);
//   }

//   Future<void> _save() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_tenantDocId == null) return;

//     setState(() => _saving = true);

//     try {
//       await FirebaseFirestore.instance
//           .collection('tenants')
//           .doc(_tenantDocId)
//           .update({
//         'name': _nameCtrl.text.trim(),
//         'phone': _phoneCtrl.text.trim(),
//         'email': _emailCtrl.text.trim(),
//         'nidNumber': _nidCtrl.text.trim(),
//         'hasEdited': true,
//       });

//       // Also update tenantName in rooms & payments
//       await FirebaseFirestore.instance
//           .collection('rooms')
//           .where('tenantId', isEqualTo: _tenantDocId)
//           .get()
//           .then((snap) {
//         for (final doc in snap.docs) {
//           doc.reference.update({'tenantName': _nameCtrl.text.trim()});
//         }
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('তথ্য সফলভাবে আপডেট হয়েছে'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _saving = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _phoneCtrl.dispose();
//     _emailCtrl.dispose();
//     _nidCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;

//     return Scaffold(
//       appBar: AppBar(title: const Text('প্রোফাইল সম্পাদনা'), centerTitle: true),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(24),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Warning banner if already edited
//                     if (_hasEdited)
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(14),
//                         margin: const EdgeInsets.only(bottom: 20),
//                         decoration: BoxDecoration(
//                           color: Colors.orange.shade50,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: Colors.orange.shade300),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(Icons.info_outline,
//                                 color: Colors.orange.shade700),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Text(
//                                 'আপনি আগে একবার তথ্য সম্পাদনা করেছেন। আর পরিবর্তন করা যাবে না।',
//                                 style: TextStyle(
//                                     color: Colors.orange.shade800,
//                                     fontSize: 13),
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     else
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(14),
//                         margin: const EdgeInsets.only(bottom: 20),
//                         decoration: BoxDecoration(
//                           color: color.primaryContainer,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(Icons.edit_note_rounded, color: color.primary),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Text(
//                                 'আপনি মাত্র একবার তথ্য পরিবর্তন করতে পারবেন।',
//                                 style: TextStyle(
//                                     color: color.primary, fontSize: 13),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                     // Form fields
//                     TextFormField(
//                       controller: _nameCtrl,
//                       enabled: !_hasEdited,
//                       decoration: const InputDecoration(
//                         labelText: 'পুরো নাম',
//                         prefixIcon: Icon(Icons.person_outline),
//                       ),
//                       validator: (v) => v!.isEmpty ? 'নাম দিন' : null,
//                     ),
//                     const SizedBox(height: 14),

//                     TextFormField(
//                       controller: _phoneCtrl,
//                       enabled: !_hasEdited,
//                       keyboardType: TextInputType.phone,
//                       decoration: const InputDecoration(
//                         labelText: 'Phone Number',
//                         prefixIcon: Icon(Icons.phone_outlined),
//                       ),
//                       validator: (v) =>
//                           v!.length < 11 ? 'সঠিক number দিন' : null,
//                     ),
//                     const SizedBox(height: 14),

//                     TextFormField(
//                       controller: _emailCtrl,
//                       enabled: !_hasEdited,
//                       keyboardType: TextInputType.emailAddress,
//                       decoration: const InputDecoration(
//                         labelText: 'Email',
//                         prefixIcon: Icon(Icons.email_outlined),
//                       ),
//                     ),
//                     const SizedBox(height: 14),

//                     TextFormField(
//                       controller: _nidCtrl,
//                       enabled: !_hasEdited,
//                       keyboardType: TextInputType.number,
//                       decoration: const InputDecoration(
//                         labelText: 'NID Number',
//                         prefixIcon: Icon(Icons.badge_outlined),
//                       ),
//                       validator: (v) => v!.isEmpty ? 'NID দিন' : null,
//                     ),
//                     const SizedBox(height: 32),

//                     SizedBox(
//                       width: double.infinity,
//                       height: 54,
//                       child: FilledButton(
//                         onPressed: (_hasEdited || _saving) ? null : _save,
//                         style: FilledButton.styleFrom(
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14)),
//                         ),
//                         child: _saving
//                             ? const SizedBox(
//                                 width: 22,
//                                 height: 22,
//                                 child: CircularProgressIndicator(
//                                     color: Colors.white, strokeWidth: 2))
//                             : Text(
//                                 _hasEdited
//                                     ? 'আর পরিবর্তন করা যাবে না'
//                                     : 'সংরক্ষণ করুন',
//                                 style: const TextStyle(
//                                     fontSize: 16, fontWeight: FontWeight.w600),
//                               ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }







import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user_model.dart';

class TenantEditProfileScreen extends StatefulWidget {
  final UserModel user;
  const TenantEditProfileScreen({super.key, required this.user});

  @override
  State<TenantEditProfileScreen> createState() =>
      _TenantEditProfileScreenState();
}

class _TenantEditProfileScreenState extends State<TenantEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _nidCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _hasEdited = false;
  String? _tenantDocId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final snap = await FirebaseFirestore.instance
        .collection('tenants')
        .where('email', isEqualTo: widget.user.email)
        .where('isActive', isEqualTo: true)
        .get();

    if (snap.docs.isNotEmpty) {
      final data = snap.docs.first.data();
      _tenantDocId = snap.docs.first.id;
      _nameCtrl.text = data['name'] ?? '';
      _phoneCtrl.text = data['phone'] ?? '';
      _emailCtrl.text = data['email'] ?? '';
      _nidCtrl.text = data['nidNumber'] ?? '';
      _hasEdited = data['hasEdited'] ?? false;
    }

    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tenantDocId == null) return;

    setState(() => _saving = true);

    try {
      await FirebaseFirestore.instance
          .collection('tenants')
          .doc(_tenantDocId)
          .update({
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'nidNumber': _nidCtrl.text.trim(),
        'hasEdited': true,
      });

      // Also update tenantName in rooms
      await FirebaseFirestore.instance
          .collection('rooms')
          .where('tenantId', isEqualTo: _tenantDocId)
          .get()
          .then((snap) {
        for (final doc in snap.docs) {
          doc.reference.update({'tenantName': _nameCtrl.text.trim()});
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('তথ্য সফলভাবে আপডেট হয়েছে'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _nidCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final divider = isDark ? Colors.white10 : const Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('প্রোফাইল সম্পাদনা',
            style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: primary))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Status Banner ────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: _hasEdited
                            ? Colors.orange.withOpacity(isDark ? 0.15 : 0.08)
                            : primary.withOpacity(isDark ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _hasEdited
                              ? Colors.orange.withOpacity(0.4)
                              : primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _hasEdited
                                ? Icons.lock_outline_rounded
                                : Icons.edit_note_rounded,
                            color: _hasEdited ? Colors.orange : primary,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _hasEdited
                                  ? 'আপনি আগে একবার তথ্য সম্পাদনা করেছেন। আর পরিবর্তন করা যাবে না।'
                                  : 'আপনি মাত্র একবার তথ্য পরিবর্তন করতে পারবেন।',
                              style: TextStyle(
                                fontSize: 12,
                                color: _hasEdited ? Colors.orange : primary,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Section Header ───────────────────────────────
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 10),
                      child: Text('👤  ব্যক্তিগত তথ্য',
                          style: TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5)),
                    ),

                    // ── Form Card ────────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: Column(
                        children: [
                          _FormField(
                            controller: _nameCtrl,
                            enabled: !_hasEdited,
                            icon: Icons.person_outline_rounded,
                            iconColor: primary,
                            label: 'পুরো নাম',
                            keyboardType: TextInputType.name,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            dividerColor: divider,
                            showDivider: true,
                            validator: (v) =>
                                v!.isEmpty ? 'নাম দিন' : null,
                          ),
                          _FormField(
                            controller: _phoneCtrl,
                            enabled: !_hasEdited,
                            icon: Icons.phone_outlined,
                            iconColor: const Color(0xFF059669),
                            label: 'Phone Number',
                            keyboardType: TextInputType.phone,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            dividerColor: divider,
                            showDivider: true,
                            validator: (v) =>
                                v!.length < 11 ? 'সঠিক number দিন' : null,
                          ),
                          _FormField(
                            controller: _emailCtrl,
                            enabled: !_hasEdited,
                            icon: Icons.email_outlined,
                            iconColor: const Color(0xFF0891B2),
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            dividerColor: divider,
                            showDivider: true,
                          ),
                          _FormField(
                            controller: _nidCtrl,
                            enabled: !_hasEdited,
                            icon: Icons.badge_outlined,
                            iconColor: const Color(0xFF5B4FBF),
                            label: 'NID Number',
                            keyboardType: TextInputType.number,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            dividerColor: divider,
                            showDivider: false,
                            validator: (v) =>
                                v!.isEmpty ? 'NID দিন' : null,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Save Button ──────────────────────────────────
                    GestureDetector(
                      onTap: (_hasEdited || _saving) ? null : _save,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: _hasEdited
                              ? (isDark
                                  ? Colors.white10
                                  : const Color(0xFFE5E7EB))
                              : primary,
                          boxShadow: _hasEdited
                              ? []
                              : [
                                  BoxShadow(
                                      color: primary.withOpacity(0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6))
                                ],
                        ),
                        child: Center(
                          child: _saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _hasEdited
                                          ? Icons.lock_outline_rounded
                                          : Icons.save_rounded,
                                      color: _hasEdited
                                          ? textSecondary
                                          : Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _hasEdited
                                          ? 'আর পরিবর্তন করা যাবে না'
                                          : 'সংরক্ষণ করুন',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: _hasEdited
                                            ? textSecondary
                                            : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// ── Reusable Form Field ───────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final IconData icon;
  final Color iconColor;
  final String label;
  final TextInputType keyboardType;
  final Color textPrimary;
  final Color textSecondary;
  final Color dividerColor;
  final bool showDivider;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.enabled,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.keyboardType,
    required this.textPrimary,
    required this.textSecondary,
    required this.dividerColor,
    required this.showDivider,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: enabled
                      ? iconColor.withOpacity(0.12)
                      : iconColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon,
                    color: enabled
                        ? iconColor
                        : iconColor.withOpacity(0.4),
                    size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  enabled: enabled,
                  keyboardType: keyboardType,
                  validator: validator,
                  style: TextStyle(
                      color: enabled
                          ? textPrimary
                          : textPrimary.withOpacity(0.45),
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    labelText: label,
                    labelStyle: TextStyle(
                        color: textSecondary.withOpacity(0.8),
                        fontSize: 13),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                    isDense: true,
                  ),
                ),
              ),
              if (!enabled)
                Icon(Icons.lock_outline_rounded,
                    size: 16,
                    color: textSecondary.withOpacity(0.5)),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 68),
            child: Divider(height: 1, color: dividerColor),
          ),
      ],
    );
  }
}