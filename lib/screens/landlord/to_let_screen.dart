import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/auth_service.dart';
import '../../../services/listing_service.dart';
import '../../../models/listing_model.dart';
import '../../../models/property_model.dart';
import '../../../models/room_model.dart';
import '../../../models/rental_request_model.dart';
import 'rental_requests_screen.dart';

class ToLetScreen extends StatelessWidget {
  const ToLetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser!;
    final service = ListingService();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: bg,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('ভাড়া দিন (To-Let)',
                style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            centerTitle: true,
            actions: [
              // Requests bell with badge
              StreamBuilder<List>(
                stream: service.getLandlordRequests(user.uid),
                builder: (context, snap) {
                  final pending = (snap.data ?? [])
                      .where((r) => r.status == RentalRequestStatus.pending)
                      .length;
                  return Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.inbox_rounded, color: textPrimary),
                        tooltip: 'আসা Requests',
                        onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => RentalRequestsScreen(landlordId: user.uid))),
                      ),
                      if (pending > 0)
                        Positioned(
                          right: 6, top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: Text('$pending',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),

          // Active listings
          StreamBuilder<List<ListingModel>>(
            stream: service.getLandlordListings(user.uid),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: primary)));
              }

              final listings = snap.data ?? [];
              final active = listings.where((l) => l.isActive).toList();
              final inactive = listings.where((l) => !l.isActive).toList();

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Info banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'To-Let দিলে ভাড়াটিয়ারা "বাড়ি খুঁজুন" থেকে আপনার রুম দেখতে পাবে।',
                              style: TextStyle(fontSize: 13, color: primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Active listings
                    if (active.isNotEmpty) ...[
                      _sectionHeader('সক্রিয় To-Let (${active.length})', Colors.green, textSecondary),
                      ...active.map((l) => _ListingCard(
                            listing: l,
                            service: service,
                            isDark: isDark,
                            primary: primary,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          )),
                      const SizedBox(height: 12),
                    ],

                    // Inactive/expired
                    if (inactive.isNotEmpty) ...[
                      _sectionHeader('নিষ্ক্রিয় (${inactive.length})', textSecondary, textSecondary),
                      ...inactive.map((l) => _ListingCard(
                            listing: l,
                            service: service,
                            isDark: isDark,
                            primary: primary,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            inactive: true,
                          )),
                    ],

                    if (listings.isEmpty)
                      _emptyState(primary, textSecondary),
                  ]),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => AddListingScreen(landlordId: user.uid))),
          icon: const Icon(Icons.add_rounded),
          label: const Text('নতুন To-Let দিন', style: TextStyle(fontWeight: FontWeight.w700)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color color, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(title,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5)),
    );
  }

  Widget _emptyState(Color primary, Color textSecondary) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(color: primary.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.home_outlined, size: 46, color: primary.withOpacity(0.5)),
            ),
            const SizedBox(height: 20),
            const Text('কোনো To-Let নেই', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('নিচের বাটন দিয়ে To-Let যোগ করুন', style: TextStyle(fontSize: 14, color: textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ── Listing Card ──────────────────────────────────────────────────────────────

class _ListingCard extends StatelessWidget {
  final ListingModel listing;
  final ListingService service;
  final bool isDark;
  final Color primary;
  final Color textPrimary;
  final Color textSecondary;
  final bool inactive;

  const _ListingCard({
    required this.listing,
    required this.service,
    required this.isDark,
    required this.primary,
    required this.textPrimary,
    required this.textSecondary,
    this.inactive = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final accentColor = inactive ? textSecondary : primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: inactive ? Border.all(color: textSecondary.withOpacity(0.2)) : null,
        boxShadow: inactive
            ? null
            : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.home_work_rounded, color: accentColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${listing.propertyName} — রুম ${listing.roomNumber}',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                              color: inactive ? textSecondary : textPrimary)),
                      Text('${listing.thana}, ${listing.district}',
                          style: TextStyle(fontSize: 12, color: textSecondary)),
                    ],
                  ),
                ),
                if (!inactive)
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert_rounded, color: textSecondary, size: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'deactivate', child: Text('নিষ্ক্রিয় করুন')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                    onSelected: (val) async {
                      if (val == 'deactivate') await service.deactivateListing(listing.id);
                      if (val == 'delete') await service.deleteListing(listing.id);
                    },
                  )
                else
                  TextButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('listings')
                          .doc(listing.id)
                          .update({'isActive': true});
                    },
                    child: Text('পুনরায় চালু', style: TextStyle(color: primary, fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _chip('৳${listing.rentAmount.toStringAsFixed(0)}/মাস', Icons.payments_outlined, accentColor),
                _chip('${listing.bedrooms} বেড', Icons.bed_outlined, const Color(0xFF0891B2)),
                _chip('${listing.bathrooms} বাথ', Icons.bathroom_outlined, const Color(0xFF059669)),
                if (listing.hasBalcony) _chip('বারান্দা', Icons.balcony_outlined, const Color(0xFFD97706)),
                if (listing.hasParking) _chip('পার্কিং', Icons.local_parking_outlined, const Color(0xFF5B4FBF)),
                _chip(listing.roomType, Icons.people_outline_rounded, const Color(0xFF6B7280)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Add Listing Screen ────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class AddListingScreen extends StatefulWidget {
  final String landlordId;
  const AddListingScreen({super.key, required this.landlordId});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ListingService();

  // Property / Room selection
  String? _selectedPropertyId;
  String? _selectedPropertyName;
  String? _selectedRoomId;
  String? _selectedRoomNumber;
  double _rentAmount = 0;
  String _roomType = 'Family';
  List<PropertyModel> _properties = [];
  List<RoomModel> _vacantRooms = [];
  bool _loadingProperties = true;

  // Location
  final _divisionCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _thanaCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  // Details
  final _sizeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  int _bedrooms = 2;
  int _bathrooms = 1;
  int _kitchens = 1;
  int _floor = 1;
  bool _hasDining = false;
  bool _hasBalcony = false;
  bool _hasParking = false;
  bool _hasLift = false;
  bool _hasGenerator = false;
  bool _isGasPiped = false;
  bool _allowsBachelor = false;
  bool _allowsFamily = true;
  bool _allowsStudent = false;
  bool _loading = false;

  final List<String> _divisions = [
    'ঢাকা', 'চট্টগ্রাম', 'রাজশাহী', 'খুলনা', 'বরিশাল', 'সিলেট', 'রংপুর', 'ময়মনসিংহ'
  ];

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    final snap = await FirebaseFirestore.instance
        .collection('properties')
        .where('landlordId', isEqualTo: widget.landlordId)
        .get();
    setState(() {
      _properties = snap.docs
          .map((d) => PropertyModel.fromMap(d.data(), d.id))
          .toList();
      _loadingProperties = false;
    });
  }

  Future<void> _loadVacantRooms(String propertyId) async {
    final snap = await FirebaseFirestore.instance
        .collection('rooms')
        .where('propertyId', isEqualTo: propertyId)
        .where('status', isEqualTo: 'vacant')
        .get();
    setState(() {
      _vacantRooms = snap.docs
          .map((d) => RoomModel.fromMap(d.data() as Map<String, dynamic>, d.id))
          .toList();
      _selectedRoomId = null;
      _selectedRoomNumber = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('রুম সিলেক্ট করুন'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _loading = true);

    final user = context.read<AuthService>().currentUser!;

    final listing = ListingModel(
      id: '',
      landlordId: widget.landlordId,
      landlordName: user.name,
      landlordPhone: user.phone,
      propertyId: _selectedPropertyId!,
      propertyName: _selectedPropertyName!,
      roomId: _selectedRoomId!,
      roomNumber: _selectedRoomNumber!,
      roomType: _roomType,
      rentAmount: _rentAmount,
      area: _thanaCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      division: _divisionCtrl.text.trim(),
      district: _districtCtrl.text.trim(),
      thana: _thanaCtrl.text.trim(),
      floorSize: _sizeCtrl.text.isNotEmpty ? double.tryParse(_sizeCtrl.text) : null,
      bedrooms: _bedrooms,
      bathrooms: _bathrooms,
      kitchens: _kitchens,
      hasDiningRoom: _hasDining,
      hasBalcony: _hasBalcony,
      hasParking: _hasParking,
      hasLift: _hasLift,
      hasGenerator: _hasGenerator,
      isGasPiped: _isGasPiped,
      allowsBachelor: _allowsBachelor,
      allowsFamily: _allowsFamily,
      allowsStudent: _allowsStudent,
      floor: _floor,
      description: _descCtrl.text.trim(),
      createdAt: DateTime.now(),
    );

    try {
      await _service.addListing(listing);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('To-Let দেওয়া হয়েছে!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('নতুন To-Let দিন'),
        centerTitle: true,
      ),
      body: _loadingProperties
          ? Center(child: CircularProgressIndicator(color: primary))
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Property & Room ──
                    _sectionTitle('🏠 Property ও রুম', primary),
                    const SizedBox(height: 10),

                    // Property dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Property বেছে নিন',
                        prefixIcon: Icon(Icons.home_work_outlined),
                      ),
                      items: _properties.map((p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(p.name),
                      )).toList(),
                      onChanged: (val) {
                        final prop = _properties.firstWhere((p) => p.id == val);
                        setState(() {
                          _selectedPropertyId = val;
                          _selectedPropertyName = prop.name;
                          _addressCtrl.text = prop.address;
                        });
                        _loadVacantRooms(val!);
                      },
                      validator: (v) => v == null ? 'Property সিলেক্ট করুন' : null,
                    ),
                    const SizedBox(height: 12),

                    // Room dropdown
                    if (_selectedPropertyId != null)
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'খালি রুম বেছে নিন',
                          prefixIcon: Icon(Icons.door_front_door_outlined),
                        ),
                        value: _selectedRoomId,
                        items: _vacantRooms.map((r) => DropdownMenuItem(
                          value: r.id,
                          child: Text('রুম ${r.roomNumber} — ৳${r.rentAmount.toStringAsFixed(0)} (${r.type})'),
                        )).toList(),
                        onChanged: (val) {
                          final room = _vacantRooms.firstWhere((r) => r.id == val);
                          setState(() {
                            _selectedRoomId = val;
                            _selectedRoomNumber = room.roomNumber;
                            _rentAmount = room.rentAmount;
                            _roomType = room.type;
                          });
                        },
                        validator: (v) => v == null ? 'রুম সিলেক্ট করুন' : null,
                      ),

                    const SizedBox(height: 20),

                    // ── Location ──
                    _sectionTitle('📍 অবস্থান', primary),
                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'বিভাগ',
                        prefixIcon: Icon(Icons.map_outlined),
                      ),
                      items: _divisions.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (v) => _divisionCtrl.text = v ?? '',
                      validator: (v) => v == null ? 'বিভাগ সিলেক্ট করুন' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _districtCtrl,
                      decoration: const InputDecoration(
                        labelText: 'জেলা',
                        prefixIcon: Icon(Icons.location_city_outlined),
                      ),
                      validator: (v) => v!.isEmpty ? 'জেলা দিন' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _thanaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'থানা / এলাকা',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (v) => v!.isEmpty ? 'এলাকা দিন' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(
                        labelText: 'সম্পূর্ণ ঠিকানা',
                        prefixIcon: Icon(Icons.home_outlined),
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: 20),

                    // ── Flat Details ──
                    _sectionTitle('📐 ফ্ল্যাটের বিস্তারিত', primary),
                    const SizedBox(height: 12),

                    // Counters row
                    _counterRow('বেডরুম', _bedrooms, (v) => setState(() => _bedrooms = v),
                        Icons.bed_outlined, primary),
                    const SizedBox(height: 10),
                    _counterRow('বাথরুম', _bathrooms, (v) => setState(() => _bathrooms = v),
                        Icons.bathroom_outlined, const Color(0xFF0891B2)),
                    const SizedBox(height: 10),
                    _counterRow('রান্নাঘর', _kitchens, (v) => setState(() => _kitchens = v),
                        Icons.kitchen_outlined, const Color(0xFF059669)),
                    const SizedBox(height: 10),
                    _counterRow('তলা', _floor, (v) => setState(() => _floor = v),
                        Icons.stairs_outlined, const Color(0xFFD97706)),
                    const SizedBox(height: 12),

                    // Size field
                    TextFormField(
                      controller: _sizeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'ফ্ল্যাট সাইজ (বর্গফুট)',
                        hintText: 'যেমন: 850',
                        prefixIcon: Icon(Icons.square_foot_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Amenities
                    _sectionTitle('✅ সুযোগ-সুবিধা', primary),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _toggleChip('ডাইনিং', _hasDining, (v) => setState(() => _hasDining = v), primary),
                        _toggleChip('বারান্দা', _hasBalcony, (v) => setState(() => _hasBalcony = v), primary),
                        _toggleChip('পার্কিং', _hasParking, (v) => setState(() => _hasParking = v), primary),
                        _toggleChip('লিফট', _hasLift, (v) => setState(() => _hasLift = v), primary),
                        _toggleChip('জেনারেটর', _hasGenerator, (v) => setState(() => _hasGenerator = v), primary),
                        _toggleChip('পাইপ গ্যাস', _isGasPiped, (v) => setState(() => _isGasPiped = v), primary),
                      ],
                    ),

                    const SizedBox(height: 16),
                    _sectionTitle('👥 কারা থাকতে পারবে', primary),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _toggleChip('পরিবার', _allowsFamily, (v) => setState(() => _allowsFamily = v), primary),
                        _toggleChip('ব্যাচেলর', _allowsBachelor, (v) => setState(() => _allowsBachelor = v), primary),
                        _toggleChip('ছাত্র/ছাত্রী', _allowsStudent, (v) => setState(() => _allowsStudent = v), primary),
                      ],
                    ),

                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'অতিরিক্ত বিবরণ (ঐচ্ছিক)',
                        hintText: 'আরো কোনো তথ্য দিতে চাইলে লিখুন...',
                        prefixIcon: Icon(Icons.notes_outlined),
                      ),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity, height: 54,
                      child: FilledButton(
                        onPressed: _loading ? null : _submit,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _loading
                            ? const SizedBox(width: 22, height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.campaign_rounded),
                                  SizedBox(width: 10),
                                  Text('To-Let প্রকাশ করুন',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionTitle(String title, Color color) {
    return Row(
      children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }

  Widget _counterRow(String label, int value, ValueChanged<int> onChange, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline_rounded),
            color: value > 1 ? color : Colors.grey,
            onPressed: value > 1 ? () => onChange(value - 1) : null,
            visualDensity: VisualDensity.compact,
          ),
          Text('$value', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: color,
            onPressed: () => onChange(value + 1),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _toggleChip(String label, bool selected, ValueChanged<bool> onChange, Color color) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onChange,
      selectedColor: color.withOpacity(0.15),
      checkmarkColor: color,
      labelStyle: TextStyle(color: selected ? color : null, fontWeight: selected ? FontWeight.w600 : null),
      side: BorderSide(color: selected ? color : Colors.grey.withOpacity(0.3)),
    );
  }
}