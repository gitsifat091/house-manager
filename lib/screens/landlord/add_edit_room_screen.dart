import 'package:flutter/material.dart';
import '../../models/room_model.dart';
import '../../services/property_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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


  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      // ── নতুন room হলে limit check ──
      if (!_isEdit) {
        final existingRooms = await FirebaseFirestore.instance
            .collection('rooms')
            .where('propertyId', isEqualTo: widget.propertyId)
            .get();

        final propDoc = await FirebaseFirestore.instance
            .collection('properties')
            .doc(widget.propertyId)
            .get();
        final totalRooms = propDoc.data()?['totalRooms'] ?? 0;

        if (existingRooms.docs.length >= totalRooms) {
          setState(() => _loading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('সর্বোচ্চ $totalRooms টি রুম যোগ করা যাবে।'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      // ── বাকি code same ──
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
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text(_isEdit ? 'রুম Edit করুন' : 'নতুন রুম যোগ করুন'),
  //       centerTitle: true,
  //     ),
  //     body: SingleChildScrollView(
  //       padding: const EdgeInsets.all(24),
  //       child: Form(
  //         key: _formKey,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             TextFormField(
  //               controller: _numberCtrl,
  //               decoration: const InputDecoration(
  //                 labelText: 'রুম নম্বর',
  //                 hintText: 'যেমন: 101, A-1',
  //                 prefixIcon: Icon(Icons.tag_rounded),
  //               ),
  //               validator: (v) => v!.isEmpty ? 'রুম নম্বর দিন' : null,
  //             ),
  //             const SizedBox(height: 16),

  //             // Room type selector
  //             const Text('রুমের ধরন', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
  //             const SizedBox(height: 8),
  //             Wrap(
  //               spacing: 8,
  //               children: _roomTypes.map((type) {
  //                 final selected = _selectedType == type;
  //                 return ChoiceChip(
  //                   label: Text(type),
  //                   selected: selected,
  //                   onSelected: (_) => setState(() => _selectedType = type),
  //                 );
  //               }).toList(),
  //             ),
  //             const SizedBox(height: 16),

  //             TextFormField(
  //               controller: _rentCtrl,
  //               keyboardType: TextInputType.number,
  //               decoration: const InputDecoration(
  //                 labelText: 'মাসিক ভাড়া (৳)',
  //                 hintText: 'যেমন: 8000',
  //                 prefixIcon: Icon(Icons.currency_exchange_rounded),
  //               ),
  //               validator: (v) {
  //                 if (v!.isEmpty) return 'ভাড়ার পরিমাণ দিন';
  //                 if (double.tryParse(v) == null) return 'সঠিক পরিমাণ দিন';
  //                 return null;
  //               },
  //             ),
  //             const SizedBox(height: 32),

  //             SizedBox(
  //               width: double.infinity, height: 54,
  //               child: FilledButton(
  //                 onPressed: _loading ? null : _save,
  //                 style: FilledButton.styleFrom(
  //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  //                 ),
  //                 child: _loading
  //                     ? const SizedBox(width: 22, height: 22,
  //                         child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
  //                     : Text(_isEdit ? 'Update করুন' : 'রুম Save করুন',
  //                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── AppBar ──
          SliverAppBar(
            pinned: true,
            backgroundColor: bg,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              _isEdit ? 'রুম Edit করুন' : 'নতুন রুম যোগ করুন',
              style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            centerTitle: true,
          ),

          // ── Body ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── রুম নম্বর ──
                      _sectionLabel('রুম নম্বর', textSecondary),
                      _inputCard(
                        cardBg: cardBg,
                        isDark: isDark,
                        child: TextFormField(
                          controller: _numberCtrl,
                          style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: 'যেমন: 101, A-1, B-2',
                            hintStyle: TextStyle(color: textSecondary.withOpacity(0.6)),
                            prefixIcon: Icon(Icons.tag_rounded, color: primary, size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          validator: (v) => v!.isEmpty ? 'রুম নম্বর দিন' : null,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── রুমের ধরন ──
                      _sectionLabel('রুমের ধরন', textSecondary),
                      Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12, offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.8,
                          children: _roomTypes.map((type) {
                            final selected = _selectedType == type;
                            final typeIcon = _roomTypeIcon(type);
                            return GestureDetector(
                              onTap: () => setState(() => _selectedType = type),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? primary
                                      : (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF3F4F6)),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected ? primary : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(typeIcon,
                                        size: 16,
                                        color: selected ? Colors.white : textSecondary),
                                    const SizedBox(width: 6),
                                    Text(type,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: selected ? Colors.white : textSecondary,
                                        )),
                                    if (selected) ...[
                                      const SizedBox(width: 6),
                                      const Icon(Icons.check_circle_rounded,
                                          size: 14, color: Colors.white),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── মাসিক ভাড়া ──
                      _sectionLabel('মাসিক ভাড়া', textSecondary),
                      _inputCard(
                        cardBg: cardBg,
                        isDark: isDark,
                        child: TextFormField(
                          controller: _rentCtrl,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: 'পরিমাণ লিখুন (৳)',
                            hintStyle: TextStyle(color: textSecondary.withOpacity(0.6)),
                            prefixIcon: Icon(Icons.currency_exchange_rounded, color: primary, size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          validator: (v) {
                            if (v!.isEmpty) return 'ভাড়ার পরিমাণ দিন';
                            if (double.tryParse(v) == null) return 'সঠিক পরিমাণ দিন';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Save Button ──
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.4),
                              blurRadius: 16, offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            onPressed: _loading ? null : _save,
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 22, height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(_isEdit ? Icons.update_rounded : Icons.save_rounded,
                                          size: 20),
                                      const SizedBox(width: 10),
                                      Text(
                                        _isEdit ? 'Update করুন' : 'রুম Save করুন',
                                        style: const TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper methods ──
  Widget _sectionLabel(String title, Color textSecondary) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(title,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: textSecondary, letterSpacing: 0.5)),
      );

  Widget _inputCard({required Color cardBg, required bool isDark, required Widget child}) =>
      Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: child,
      );

  IconData _roomTypeIcon(String type) {
    switch (type) {
      case 'Single': return Icons.person_outline_rounded;
      case 'Double': return Icons.people_outline_rounded;
      case 'Family': return Icons.family_restroom_rounded;
      case 'Bachelor': return Icons.groups_outlined;
      default: return Icons.door_front_door_outlined;
    }
  }

}