import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/tenant_model.dart';

class LandlordEditTenantScreen extends StatefulWidget {
  final TenantModel tenant;
  const LandlordEditTenantScreen({super.key, required this.tenant});

  @override
  State<LandlordEditTenantScreen> createState() =>
      _LandlordEditTenantScreenState();
}

class _LandlordEditTenantScreenState
    extends State<LandlordEditTenantScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.tenant.name);
  late final _phoneCtrl = TextEditingController(text: widget.tenant.phone);
  late final _emailCtrl = TextEditingController(text: widget.tenant.email);
  late final _nidCtrl = TextEditingController(text: widget.tenant.nidNumber);
  late final _rentCtrl = TextEditingController(
      text: widget.tenant.rentAmount.toStringAsFixed(0));
  bool _saving = false;

  late DateTime _moveInDate;

  @override
  void initState() {
    super.initState();
    _moveInDate = widget.tenant.moveInDate;  // initState এ নিয়ে যাও
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _nidCtrl.dispose();
    _rentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final newName = _nameCtrl.text.trim();
      final newRent = double.parse(_rentCtrl.text.trim());

      await FirebaseFirestore.instance
          .collection('tenants')
          .doc(widget.tenant.id)
          .update({
        'name': newName,
        'phone': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'nidNumber': _nidCtrl.text.trim(),
        'rentAmount': newRent,
        'moveInDate': _moveInDate.millisecondsSinceEpoch, 
      });

      // Update room tenantName if name changed
      if (newName != widget.tenant.name) {
        final roomSnap = await FirebaseFirestore.instance
            .collection('rooms')
            .where('tenantId', isEqualTo: widget.tenant.id)
            .get();
        for (final doc in roomSnap.docs) {
          await doc.reference.update({'tenantName': newName});
        }
      }

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
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.tenant.name} এর তথ্য'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: color.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings_rounded,
                        color: color.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('Landlord হিসেবে যেকোনো সময় edit করতে পারবেন',
                        style: TextStyle(color: color.primary, fontSize: 13)),
                  ],
                ),
              ),

              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'পুরো নাম',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v!.isEmpty ? 'নাম দিন' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (v) => v!.length < 11 ? 'সঠিক number দিন' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nidCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'NID Number',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (v) => v!.isEmpty ? 'NID দিন' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _rentCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'মাসিক ভাড়া (৳)',
                  prefixIcon: Icon(Icons.currency_exchange_rounded),
                ),
                validator: (v) {
                  if (v!.isEmpty) return 'ভাড়া দিন';
                  if (double.tryParse(v) == null) return 'সঠিক পরিমাণ দিন';
                  return null;
                },
              ),

              const SizedBox(height: 14),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _moveInDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && mounted) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_moveInDate),
                    );
                    if (time != null) {
                      setState(() {
                        _moveInDate = DateTime(
                          picked.year, picked.month, picked.day,
                          time.hour, time.minute,
                        );
                      });
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, color: color.primary),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('প্রবেশের তারিখ ও সময়',
                              style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(
                            '${_moveInDate.day}/${_moveInDate.month}/${_moveInDate.year} '
                            '${_moveInDate.hour.toString().padLeft(2, '0')}:'
                            '${_moveInDate.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.edit_rounded, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
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
                      : const Text('আপডেট করুন',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}