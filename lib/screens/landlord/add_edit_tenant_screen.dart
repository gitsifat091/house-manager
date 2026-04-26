// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../models/tenant_model.dart';
// import '../../models/room_model.dart';
// import '../../models/property_model.dart';
// import '../../services/tenant_service.dart';
// import '../../services/property_service.dart';

// class AddEditTenantScreen extends StatefulWidget {
//   final String landlordId;
//   const AddEditTenantScreen({super.key, required this.landlordId});

//   @override
//   State<AddEditTenantScreen> createState() => _AddEditTenantScreenState();
// }

// class _AddEditTenantScreenState extends State<AddEditTenantScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameCtrl = TextEditingController();
//   final _phoneCtrl = TextEditingController();
//   final _emailCtrl = TextEditingController();
//   final _nidCtrl = TextEditingController();

//   List<PropertyModel> _properties = [];
//   List<RoomModel> _vacantRooms = [];
//   PropertyModel? _selectedProperty;
//   RoomModel? _selectedRoom;
//   bool _loading = false;
//   bool _dataLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     final propSnap = await FirebaseFirestore.instance
//         .collection('properties')
//         .where('landlordId', isEqualTo: widget.landlordId)
//         .get();

//     _properties = propSnap.docs
//         .map((d) => PropertyModel.fromMap(d.data(), d.id))
//         .toList();

//     setState(() => _dataLoading = false);
//   }

//   Future<void> _onPropertySelected(PropertyModel prop) async {
//     setState(() {
//       _selectedProperty = prop;
//       _selectedRoom = null;
//       _vacantRooms = [];
//     });

//     final service = TenantService();
//     final rooms = await service.getVacantRooms([prop.id]);
//     setState(() => _vacantRooms = rooms);
//   }

//   Future<void> _save() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_selectedProperty == null) {
//       _showError('Property select করুন');
//       return;
//     }
//     if (_selectedRoom == null) {
//       _showError('রুম select করুন');
//       return;
//     }

//     setState(() => _loading = true);

//     try {
//       final tenant = TenantModel(
//         id: '',
//         name: _nameCtrl.text.trim(),
//         phone: _phoneCtrl.text.trim(),
//         email: _emailCtrl.text.trim(),
//         nidNumber: _nidCtrl.text.trim(),
//         propertyId: _selectedProperty!.id,
//         propertyName: _selectedProperty!.name,
//         roomId: _selectedRoom!.id,
//         roomNumber: _selectedRoom!.roomNumber,
//         rentAmount: _selectedRoom!.rentAmount,
//         moveInDate: DateTime.now(),
//         landlordId: widget.landlordId, 
//       );

//       await TenantService().addTenant(tenant, widget.landlordId);
//       if (mounted) Navigator.pop(context);
//     } catch (e) {
//       if (mounted) {
//         setState(() => _loading = false);
//         _showError('Error: ${e.toString()}');
//       }
//     }
//   }

//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg), backgroundColor: Colors.red),
//     );
//   }

//   @override
//   void dispose() {
//     _nameCtrl.dispose(); _phoneCtrl.dispose();
//     _emailCtrl.dispose(); _nidCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('নতুন ভাড়াটিয়া'), centerTitle: true),
//       body: _dataLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(24),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Personal info section
//                     _sectionTitle('ব্যক্তিগত তথ্য'),
//                     const SizedBox(height: 12),
//                     TextFormField(
//                       controller: _nameCtrl,
//                       decoration: const InputDecoration(
//                         labelText: 'পুরো নাম',
//                         prefixIcon: Icon(Icons.person_outline),
//                       ),
//                       validator: (v) => v!.isEmpty ? 'নাম দিন' : null,
//                     ),
//                     const SizedBox(height: 14),
//                     TextFormField(
//                       controller: _phoneCtrl,
//                       keyboardType: TextInputType.phone,
//                       decoration: const InputDecoration(
//                         labelText: 'Phone Number',
//                         prefixIcon: Icon(Icons.phone_outlined),
//                       ),
//                       validator: (v) => v!.length < 11 ? 'সঠিক number দিন' : null,
//                     ),
//                     const SizedBox(height: 14),
//                     TextFormField(
//                       controller: _emailCtrl,
//                       keyboardType: TextInputType.emailAddress,
//                       decoration: const InputDecoration(
//                         labelText: 'Email',
//                         prefixIcon: Icon(Icons.email_outlined),
//                       ),
//                     ),
//                     const SizedBox(height: 14),
//                     TextFormField(
//                       controller: _nidCtrl,
//                       keyboardType: TextInputType.number,
//                       decoration: const InputDecoration(
//                         labelText: 'NID Number',
//                         prefixIcon: Icon(Icons.badge_outlined),
//                       ),
//                       validator: (v) => v!.isEmpty ? 'NID দিন' : null,
//                     ),
//                     const SizedBox(height: 24),

//                     // Room assignment section
//                     _sectionTitle('রুম নির্বাচন'),
//                     const SizedBox(height: 12),

//                     // Property dropdown
//                     DropdownButtonFormField<PropertyModel>(
//                       value: _selectedProperty,
//                       hint: const Text('Property select করুন'),
//                       decoration: const InputDecoration(
//                         prefixIcon: Icon(Icons.home_work_outlined),
//                       ),
//                       items: _properties.map((p) => DropdownMenuItem(
//                         value: p,
//                         child: Text(p.name),
//                       )).toList(),
//                       onChanged: (p) {
//                         if (p != null) _onPropertySelected(p);
//                       },
//                     ),
//                     const SizedBox(height: 14),

//                     // Room dropdown
//                     DropdownButtonFormField<RoomModel>(
//                       value: _selectedRoom,
//                       hint: Text(_selectedProperty == null
//                           ? 'আগে property select করুন'
//                           : _vacantRooms.isEmpty
//                               ? 'কোনো খালি রুম নেই'
//                               : 'রুম select করুন'),
//                       decoration: const InputDecoration(
//                         prefixIcon: Icon(Icons.door_front_door_outlined),
//                       ),
//                       items: _vacantRooms.map((r) => DropdownMenuItem(
//                         value: r,
//                         child: Text('রুম ${r.roomNumber} — ৳${r.rentAmount.toStringAsFixed(0)}/মাস (${r.type})'),
//                       )).toList(),
//                       onChanged: _vacantRooms.isEmpty ? null : (r) {
//                         setState(() => _selectedRoom = r);
//                       },
//                     ),

//                     if (_selectedRoom != null) ...[
//                       const SizedBox(height: 12),
//                       Container(
//                         padding: const EdgeInsets.all(14),
//                         decoration: BoxDecoration(
//                           color: Theme.of(context).colorScheme.primaryContainer,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(Icons.info_outline,
//                                 color: Theme.of(context).colorScheme.primary),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Text(
//                                 'রুম ${_selectedRoom!.roomNumber} — মাসিক ভাড়া ৳${_selectedRoom!.rentAmount.toStringAsFixed(0)}',
//                                 style: TextStyle(
//                                     color: Theme.of(context).colorScheme.primary,
//                                     fontWeight: FontWeight.w500),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],

//                     const SizedBox(height: 32),
//                     SizedBox(
//                       width: double.infinity, height: 54,
//                       child: FilledButton(
//                         onPressed: _loading ? null : _save,
//                         style: FilledButton.styleFrom(
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14)),
//                         ),
//                         child: _loading
//                             ? const SizedBox(width: 22, height: 22,
//                                 child: CircularProgressIndicator(
//                                     color: Colors.white, strokeWidth: 2))
//                             : const Text('ভাড়াটিয়া Save করুন',
//                                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }

//   Widget _sectionTitle(String title) {
//     return Text(title, style: TextStyle(
//       fontSize: 15, fontWeight: FontWeight.bold,
//       color: Theme.of(context).colorScheme.primary,
//     ));
//   }
// }






import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/tenant_model.dart';
import '../../models/room_model.dart';
import '../../models/property_model.dart';
import '../../services/tenant_service.dart';

class AddEditTenantScreen extends StatefulWidget {
  final String landlordId;
  const AddEditTenantScreen({super.key, required this.landlordId});

  @override
  State<AddEditTenantScreen> createState() => _AddEditTenantScreenState();
}

class _AddEditTenantScreenState extends State<AddEditTenantScreen>
    with SingleTickerProviderStateMixin {
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

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

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
    final rooms = await TenantService().getVacantRooms([prop.id]);
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
    _animController.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _nidCtrl.dispose();
    super.dispose();
  }

  // ── Shorthand theme helpers ───────────────────────────────
  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;
  Color get _primary => Theme.of(context).colorScheme.primary;
  Color get _bg =>
      _isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
  Color get _cardBg =>
      _isDark ? const Color(0xFF1A2C22) : Colors.white;
  Color get _textPrimary =>
      _isDark ? Colors.white : const Color(0xFF1A1A1A);
  Color get _textSecondary =>
      _isDark ? Colors.white54 : const Color(0xFF6B7280);
  Color get _divider =>
      _isDark ? Colors.white10 : const Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: _dataLoading
          ? Center(child: CircularProgressIndicator(color: _primary))
          : FadeTransition(
              opacity: _fadeAnim,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── App Bar ──────────────────────────────
                  SliverAppBar(
                    expandedHeight: 180,
                    collapsedHeight: 60,
                    pinned: true,
                    backgroundColor: _bg,
                    elevation: 0,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: _textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: Text(
                      'নতুন ভাড়াটিয়া',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    centerTitle: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildHeroBg(),
                    ),
                  ),

                  // ── Form Body ─────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // ── ব্যক্তিগত তথ্য ──
                        _sectionHeader('👤  ব্যক্তিগত তথ্য'),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _card([
                                _inputTile(
                                  icon: Icons.person_outline_rounded,
                                  iconBg: _primary,
                                  label: 'পুরো নাম',
                                  hint: 'যেমন: মোঃ রফিকুল ইসলাম',
                                  controller: _nameCtrl,
                                  keyboardType: TextInputType.name,
                                  validator: (v) =>
                                      v!.isEmpty ? 'নাম দিন' : null,
                                  isLast: false,
                                ),
                                _inputTile(
                                  icon: Icons.phone_outlined,
                                  iconBg: const Color(0xFF059669),
                                  label: 'Phone Number',
                                  hint: '01XXXXXXXXX',
                                  controller: _phoneCtrl,
                                  keyboardType: TextInputType.phone,
                                  validator: (v) => v!.length < 11
                                      ? 'সঠিক number দিন'
                                      : null,
                                  isLast: false,
                                ),
                                _inputTile(
                                  icon: Icons.email_outlined,
                                  iconBg: const Color(0xFF0891B2),
                                  label: 'Email',
                                  hint: 'example@email.com',
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: null,
                                  isLast: false,
                                ),
                                _inputTile(
                                  icon: Icons.badge_outlined,
                                  iconBg: const Color(0xFF5B4FBF),
                                  label: 'NID Number',
                                  hint: 'জাতীয় পরিচয়পত্র নম্বর',
                                  controller: _nidCtrl,
                                  keyboardType: TextInputType.number,
                                  validator: (v) =>
                                      v!.isEmpty ? 'NID দিন' : null,
                                  isLast: true,
                                ),
                              ]),

                              const SizedBox(height: 12),

                              // ── রুম নির্বাচন ──
                              _sectionHeader('🏠  রুম নির্বাচন'),
                              _card([
                                _dropdownTile<PropertyModel>(
                                  icon: Icons.home_work_outlined,
                                  iconBg: const Color(0xFFD97706),
                                  label: 'Property',
                                  hint: 'Property select করুন',
                                  value: _selectedProperty,
                                  items: _properties
                                      .map((p) => DropdownMenuItem(
                                            value: p,
                                            child: Text(
                                              p.name,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: _textPrimary,
                                                  fontSize: 14),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (p) {
                                    if (p != null)
                                      _onPropertySelected(p);
                                  },
                                  isLast: false,
                                ),
                                _dropdownTile<RoomModel>(
                                  icon: Icons.door_front_door_outlined,
                                  iconBg: const Color(0xFF059669),
                                  label: 'রুম',
                                  hint: _selectedProperty == null
                                      ? 'আগে property select করুন'
                                      : _vacantRooms.isEmpty
                                          ? 'কোনো খালি রুম নেই'
                                          : 'রুম select করুন',
                                  value: _selectedRoom,
                                  items: _vacantRooms
                                      .map((r) => DropdownMenuItem(
                                            value: r,
                                            child: Text(
                                              'রুম ${r.roomNumber} — ৳${r.rentAmount.toStringAsFixed(0)}/মাস (${r.type})',
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: _textPrimary,
                                                  fontSize: 14),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: _vacantRooms.isEmpty
                                      ? null
                                      : (r) =>
                                          setState(() => _selectedRoom = r),
                                  isLast: true,
                                ),
                              ]),

                              // ── Selected Room Info Card ──
                              if (_selectedRoom != null) ...[
                                const SizedBox(height: 12),
                                _RoomInfoCard(
                                  room: _selectedRoom!,
                                  primary: _primary,
                                  isDark: _isDark,
                                ),
                              ],

                              const SizedBox(height: 24),

                              // ── Save Button ──
                              GestureDetector(
                                onTap: _loading ? null : _save,
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  width: double.infinity,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(14),
                                    color: _loading
                                        ? _primary.withOpacity(0.6)
                                        : _primary,
                                    boxShadow: _loading
                                        ? []
                                        : [
                                            BoxShadow(
                                              color: _primary
                                                  .withOpacity(0.4),
                                              blurRadius: 16,
                                              offset: const Offset(0, 6),
                                            )
                                          ],
                                  ),
                                  child: Center(
                                    child: _loading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child:
                                                CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Row(
                                            mainAxisSize:
                                                MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons
                                                    .person_add_alt_1_rounded,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                'ভাড়াটিয়া Save করুন',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ── Hero Background ───────────────────────────────────────
  Widget _buildHeroBg() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isDark
              ? [const Color(0xFF1A3328), const Color(0xFF0F1A14)]
              : [const Color(0xFFE8F5EE), const Color(0xFFF5FAF7)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 70, 20, 16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [_primary, _primary.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: const Icon(Icons.person_add_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'নতুন ভাড়াটিয়া যোগ করুন',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'তথ্য পূরণ করে রুম assign করুন',
                      style: TextStyle(
                          color: _textSecondary, fontSize: 12),
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

  // ── Section Header — same as settings_screen ─────────────
  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
        child: Text(
          title,
          style: TextStyle(
            color: _textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      );

  // ── Card Container — same as settings_screen ─────────────
  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(children: children),
      );

  // ── Input Tile — settings _navTile style with TextField ──
  Widget _inputTile({
    required IconData icon,
    required Color iconBg,
    required String label,
    required String hint,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required FormFieldValidator<String>? validator,
    required bool isLast,
  }) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  validator: validator,
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: label,
                    hintText: hint,
                    labelStyle:
                        TextStyle(color: _textSecondary, fontSize: 13),
                    hintStyle: TextStyle(
                        color: _textSecondary.withOpacity(0.5),
                        fontSize: 13),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 70),
            child: Divider(height: 1, color: _divider),
          ),
      ],
    );
  }

  // ── Dropdown Tile — settings style ───────────────────────
  Widget _dropdownTile<T>({
    required IconData icon,
    required Color iconBg,
    required String label,
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    required bool isLast,
  }) {
    final disabled = onChanged == null;

    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: disabled ? iconBg.withOpacity(0.35) : iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon,
                    color: Colors.white
                        .withOpacity(disabled ? 0.5 : 1.0),
                    size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    value: value,
                    isExpanded: true,
                    hint: Text(
                      hint,
                      style: TextStyle(
                          color: _textSecondary.withOpacity(
                              disabled ? 0.5 : 1.0),
                          fontSize: 14),
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: disabled
                          ? _textSecondary.withOpacity(0.3)
                          : _textSecondary,
                      size: 20,
                    ),
                    dropdownColor: _cardBg,
                    items: items,
                    onChanged: onChanged,
                    style: TextStyle(
                        color: _textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 70),
            child: Divider(height: 1, color: _divider),
          ),
      ],
    );
  }
}

// ── Selected Room Info Card ───────────────────────────────────

class _RoomInfoCard extends StatelessWidget {
  final RoomModel room;
  final Color primary;
  final bool isDark;

  const _RoomInfoCard({
    required this.room,
    required this.primary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primary.withOpacity(isDark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: primary.withOpacity(0.25),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Icon(Icons.check_circle_outline_rounded, color: primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'রুম ${room.roomNumber} নির্বাচিত',
                  style: TextStyle(
                    color: primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'মাসিক ভাড়া: ৳${room.rentAmount.toStringAsFixed(0)} • ধরন: ${room.type}',
                  style: TextStyle(
                    color: primary.withOpacity(0.8),
                    fontSize: 12,
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