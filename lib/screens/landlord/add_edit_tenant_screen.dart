import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/tenant_model.dart';
import '../../models/room_model.dart';
import '../../models/property_model.dart';
import '../../services/tenant_service.dart';
import '../../services/property_service.dart';

class AddEditTenantScreen extends StatefulWidget {
  final String landlordId;
  const AddEditTenantScreen({super.key, required this.landlordId});

  @override
  State<AddEditTenantScreen> createState() => _AddEditTenantScreenState();
}

class _AddEditTenantScreenState extends State<AddEditTenantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _nidCtrl = TextEditingController();

  List<PropertyModel> _properties = [];
  List<RoomModel> _vacantRooms = [];
  PropertyModel? _selectedProperty;
  RoomModel? _selectedRoom;
  bool _loading = false;
  bool _dataLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final propSnap = await FirebaseFirestore.instance
        .collection('properties')
        .where('landlordId', isEqualTo: widget.landlordId)
        .get();

    _properties = propSnap.docs
        .map((d) => PropertyModel.fromMap(d.data(), d.id))
        .toList();

    setState(() => _dataLoading = false);
  }

  Future<void> _onPropertySelected(PropertyModel prop) async {
    setState(() {
      _selectedProperty = prop;
      _selectedRoom = null;
      _vacantRooms = [];
    });

    final service = TenantService();
    final rooms = await service.getVacantRooms([prop.id]);
    setState(() => _vacantRooms = rooms);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProperty == null) {
      _showError('Property select করুন');
      return;
    }
    if (_selectedRoom == null) {
      _showError('রুম select করুন');
      return;
    }

    setState(() => _loading = true);

    try {
      final tenant = TenantModel(
        id: '',
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        nidNumber: _nidCtrl.text.trim(),
        propertyId: _selectedProperty!.id,
        propertyName: _selectedProperty!.name,
        roomId: _selectedRoom!.id,
        roomNumber: _selectedRoom!.roomNumber,
        rentAmount: _selectedRoom!.rentAmount,
        moveInDate: DateTime.now(),
        landlordId: widget.landlordId, 
      );

      await TenantService().addTenant(tenant, widget.landlordId);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _showError('Error: ${e.toString()}');
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose();
    _emailCtrl.dispose(); _nidCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('নতুন ভাড়াটিয়া'), centerTitle: true),
      body: _dataLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal info section
                    _sectionTitle('ব্যক্তিগত তথ্য'),
                    const SizedBox(height: 12),
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
                        labelText: 'Email (optional)',
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
                    const SizedBox(height: 24),

                    // Room assignment section
                    _sectionTitle('রুম নির্বাচন'),
                    const SizedBox(height: 12),

                    // Property dropdown
                    DropdownButtonFormField<PropertyModel>(
                      value: _selectedProperty,
                      hint: const Text('Property select করুন'),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.home_work_outlined),
                      ),
                      items: _properties.map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.name),
                      )).toList(),
                      onChanged: (p) {
                        if (p != null) _onPropertySelected(p);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Room dropdown
                    DropdownButtonFormField<RoomModel>(
                      value: _selectedRoom,
                      hint: Text(_selectedProperty == null
                          ? 'আগে property select করুন'
                          : _vacantRooms.isEmpty
                              ? 'কোনো খালি রুম নেই'
                              : 'রুম select করুন'),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.door_front_door_outlined),
                      ),
                      items: _vacantRooms.map((r) => DropdownMenuItem(
                        value: r,
                        child: Text('রুম ${r.roomNumber} — ৳${r.rentAmount.toStringAsFixed(0)}/মাস (${r.type})'),
                      )).toList(),
                      onChanged: _vacantRooms.isEmpty ? null : (r) {
                        setState(() => _selectedRoom = r);
                      },
                    ),

                    if (_selectedRoom != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'রুম ${_selectedRoom!.roomNumber} — মাসিক ভাড়া ৳${_selectedRoom!.rentAmount.toStringAsFixed(0)}',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity, height: 54,
                      child: FilledButton(
                        onPressed: _loading ? null : _save,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _loading
                            ? const SizedBox(width: 22, height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('ভাড়াটিয়া Save করুন',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: TextStyle(
      fontSize: 15, fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
    ));
  }
}