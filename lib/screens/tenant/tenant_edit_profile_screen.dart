import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user_model.dart';

class TenantEditProfileScreen extends StatefulWidget {
  final UserModel user;
  const TenantEditProfileScreen({super.key, required this.user});

  @override
  State<TenantEditProfileScreen> createState() => _TenantEditProfileScreenState();
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

      // Also update tenantName in rooms & payments
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
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('প্রোফাইল সম্পাদনা'), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Warning banner if already edited
                    if (_hasEdited)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.orange.shade700),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'আপনি আগে একবার তথ্য সম্পাদনা করেছেন। আর পরিবর্তন করা যাবে না।',
                                style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: color.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.edit_note_rounded, color: color.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'আপনি মাত্র একবার তথ্য পরিবর্তন করতে পারবেন।',
                                style: TextStyle(
                                    color: color.primary, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Form fields
                    TextFormField(
                      controller: _nameCtrl,
                      enabled: !_hasEdited,
                      decoration: const InputDecoration(
                        labelText: 'পুরো নাম',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => v!.isEmpty ? 'নাম দিন' : null,
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _phoneCtrl,
                      enabled: !_hasEdited,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (v) =>
                          v!.length < 11 ? 'সঠিক number দিন' : null,
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _emailCtrl,
                      enabled: !_hasEdited,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _nidCtrl,
                      enabled: !_hasEdited,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'NID Number',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (v) => v!.isEmpty ? 'NID দিন' : null,
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: (_hasEdited || _saving) ? null : _save,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text(
                                _hasEdited
                                    ? 'আর পরিবর্তন করা যাবে না'
                                    : 'সংরক্ষণ করুন',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
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