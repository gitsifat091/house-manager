import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../services/property_service.dart';

class AddEditPropertyScreen extends StatefulWidget {
  final String landlordId;
  final PropertyModel? property;
  const AddEditPropertyScreen({super.key, required this.landlordId, this.property});

  @override
  State<AddEditPropertyScreen> createState() => _AddEditPropertyScreenState();
}

class _AddEditPropertyScreenState extends State<AddEditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _roomsCtrl = TextEditingController();
  bool _loading = false;

  bool get _isEdit => widget.property != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _nameCtrl.text = widget.property!.name;
      _addressCtrl.text = widget.property!.address;
      _roomsCtrl.text = widget.property!.totalRooms.toString();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _addressCtrl.dispose(); _roomsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final service = PropertyService();
    final property = PropertyModel(
      id: widget.property?.id ?? '',
      landlordId: widget.landlordId,
      name: _nameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      totalRooms: int.parse(_roomsCtrl.text.trim()),
      createdAt: widget.property?.createdAt ?? DateTime.now(),
    );

    if (_isEdit) {
      await service.updateProperty(property);
    } else {
      await service.addProperty(property);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Property Edit করুন' : 'নতুন Property'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Property এর নাম',
                  hintText: 'যেমন: রহমান ভিলা',
                  prefixIcon: Icon(Icons.home_work_outlined),
                ),
                validator: (v) => v!.isEmpty ? 'নাম দিন' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'ঠিকানা',
                  hintText: 'যেমন: মিরপুর-১০, ঢাকা',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (v) => v!.isEmpty ? 'ঠিকানা দিন' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roomsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'মোট রুম সংখ্যা',
                  prefixIcon: Icon(Icons.door_front_door_outlined),
                ),
                validator: (v) {
                  if (v!.isEmpty) return 'রুম সংখ্যা দিন';
                  if (int.tryParse(v) == null) return 'সংখ্যা দিন';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 54,
                child: FilledButton(
                  onPressed: _loading ? null : _save,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_isEdit ? 'Update করুন' : 'Save করুন',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}