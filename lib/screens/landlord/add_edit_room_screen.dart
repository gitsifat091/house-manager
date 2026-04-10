import 'package:flutter/material.dart';
import '../../models/room_model.dart';
import '../../services/property_service.dart';

class AddEditRoomScreen extends StatefulWidget {
  final String propertyId;
  final RoomModel? room;
  const AddEditRoomScreen({super.key, required this.propertyId, this.room});

  @override
  State<AddEditRoomScreen> createState() => _AddEditRoomScreenState();
}

class _AddEditRoomScreenState extends State<AddEditRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberCtrl = TextEditingController();
  final _rentCtrl = TextEditingController();
  String _selectedType = 'Single';
  bool _loading = false;

  final List<String> _roomTypes = ['Single', 'Double', 'Family', 'Bachelor'];
  bool get _isEdit => widget.room != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _numberCtrl.text = widget.room!.roomNumber;
      _rentCtrl.text = widget.room!.rentAmount.toStringAsFixed(0);
      _selectedType = widget.room!.type;
    }
  }

  @override
  void dispose() {
    _numberCtrl.dispose(); _rentCtrl.dispose();
    super.dispose();
  }

  // Future<void> _save() async {
  //   if (!_formKey.currentState!.validate()) return;
  //   setState(() => _loading = true);

  //   final service = PropertyService();
  //   final room = RoomModel(
  //     id: widget.room?.id ?? '',
  //     propertyId: widget.propertyId,
  //     roomNumber: _numberCtrl.text.trim(),
  //     type: _selectedType,
  //     rentAmount: double.parse(_rentCtrl.text.trim()),
  //     status: widget.room?.status ?? RoomStatus.vacant,
  //     tenantId: widget.room?.tenantId,
  //     tenantName: widget.room?.tenantName,
  //   );

  //   if (_isEdit) {
  //     await service.updateRoom(room);
  //   } else {
  //     await service.addRoom(room);
  //   }

  //   if (mounted) Navigator.pop(context);
  // }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final service = PropertyService();
      final room = RoomModel(
        id: widget.room?.id ?? '',
        propertyId: widget.propertyId,
        roomNumber: _numberCtrl.text.trim(),
        type: _selectedType,
        rentAmount: double.parse(_rentCtrl.text.trim()),
        status: widget.room?.status ?? RoomStatus.vacant,
        tenantId: widget.room?.tenantId,
        tenantName: widget.room?.tenantName,
      );

      if (_isEdit) {
        await service.updateRoom(room);
      } else {
        await service.addRoom(room);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'রুম Edit করুন' : 'নতুন রুম যোগ করুন'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _numberCtrl,
                decoration: const InputDecoration(
                  labelText: 'রুম নম্বর',
                  hintText: 'যেমন: 101, A-1',
                  prefixIcon: Icon(Icons.tag_rounded),
                ),
                validator: (v) => v!.isEmpty ? 'রুম নম্বর দিন' : null,
              ),
              const SizedBox(height: 16),

              // Room type selector
              const Text('রুমের ধরন', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _roomTypes.map((type) {
                  final selected = _selectedType == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedType = type),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _rentCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'মাসিক ভাড়া (৳)',
                  hintText: 'যেমন: 8000',
                  prefixIcon: Icon(Icons.currency_exchange_rounded),
                ),
                validator: (v) {
                  if (v!.isEmpty) return 'ভাড়ার পরিমাণ দিন';
                  if (double.tryParse(v) == null) return 'সঠিক পরিমাণ দিন';
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
                      : Text(_isEdit ? 'Update করুন' : 'রুম Save করুন',
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