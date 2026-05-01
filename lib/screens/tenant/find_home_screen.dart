import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/listing_model.dart';
import '../../../models/rental_request_model.dart';
import '../../../services/listing_service.dart';
import '../../../services/auth_service.dart';

class FindHomeScreen extends StatefulWidget {
  const FindHomeScreen({super.key});

  @override
  State<FindHomeScreen> createState() => _FindHomeScreenState();
}

class _FindHomeScreenState extends State<FindHomeScreen> {
  final _service = ListingService();

  String _selectedDivision = '';
  String _districtCtrl = '';
  String _thanaCtrl = '';
  double _maxRent = 0;
  String _roomType = 'সব';

  List<ListingModel> _results = [];
  bool _loading = false;
  bool _searched = false;

  final _districtTF = TextEditingController();
  final _thanaTF = TextEditingController();
  final _maxRentTF = TextEditingController();

  final List<String> _divisions = [
    'সব', 'ঢাকা', 'চট্টগ্রাম', 'রাজশাহী', 'খুলনা', 'বরিশাল', 'সিলেট', 'রংপুর', 'ময়মনসিংহ'
  ];
  final List<String> _roomTypes = ['সব', 'Single', 'Double', 'Family', 'Bachelor'];

  Future<void> _search() async {
    setState(() { _loading = true; _searched = true; });
    try {
      final results = await _service.searchListings(
        division: _selectedDivision.isEmpty || _selectedDivision == 'সব' ? null : _selectedDivision,
        district: _districtTF.text.trim().isEmpty ? null : _districtTF.text.trim(),
        thana: _thanaTF.text.trim().isEmpty ? null : _thanaTF.text.trim(),
        maxRent: _maxRentTF.text.trim().isEmpty ? null : double.tryParse(_maxRentTF.text.trim()),
        roomType: _roomType == 'সব' ? null : _roomType,
      );
      setState(() { _results = results; _loading = false; });
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;

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
            title: Text('বাড়ি খুঁজুন',
                style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            centerTitle: true,
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Filter Card ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ফিল্টার করুন',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary)),
                        const SizedBox(height: 12),

                        // Division
                        DropdownButtonFormField<String>(
                          value: _selectedDivision.isEmpty ? 'সব' : _selectedDivision,
                          decoration: InputDecoration(
                            labelText: 'বিভাগ',
                            prefixIcon: const Icon(Icons.map_outlined),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: _divisions.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                          onChanged: (v) => setState(() => _selectedDivision = v ?? 'সব'),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _districtTF,
                                decoration: InputDecoration(
                                  labelText: 'জেলা',
                                  prefixIcon: const Icon(Icons.location_city_outlined),
                                  filled: true,
                                  fillColor: isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _thanaTF,
                                decoration: InputDecoration(
                                  labelText: 'থানা/এলাকা',
                                  prefixIcon: const Icon(Icons.location_on_outlined),
                                  filled: true,
                                  fillColor: isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _maxRentTF,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'সর্বোচ্চ ভাড়া (৳)',
                                  prefixIcon: const Icon(Icons.payments_outlined),
                                  filled: true,
                                  fillColor: isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _roomType,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: 'ধরন',
                                  prefixIcon: const Icon(Icons.people_outline_rounded),
                                  filled: true,
                                  fillColor: isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                ),
                                items: _roomTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                                onChanged: (v) => setState(() => _roomType = v ?? 'সব'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        SizedBox(
                          width: double.infinity, height: 46,
                          child: FilledButton.icon(
                            onPressed: _loading ? null : _search,
                            icon: _loading
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.search_rounded),
                            label: Text(_loading ? 'খোঁজা হচ্ছে...' : 'বাড়ি খুঁজুন'),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (_searched)
                    Text(
                      _loading ? '' : '${_results.length} টি বাড়ি পাওয়া গেছে',
                      style: TextStyle(fontSize: 13, color: textSecondary, fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ),
          ),

          // Results
          if (_searched && !_loading)
            _results.isEmpty
                ? SliverToBoxAdapter(child: _emptyResult(primary, textSecondary))
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _ListingTile(
                          listing: _results[i],
                          isDark: isDark,
                          primary: primary,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        childCount: _results.length,
                      ),
                    ),
                  ),

          if (!_searched)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.search_rounded, size: 64, color: primary.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    Text('উপরের ফিল্টার দিয়ে বাড়ি খুঁজুন',
                        style: TextStyle(fontSize: 14, color: textSecondary)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _emptyResult(Color primary, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(
        children: [
          Icon(Icons.home_outlined, size: 64, color: primary.withOpacity(0.3)),
          const SizedBox(height: 12),
          const Text('এই ফিল্টারে কোনো বাড়ি নেই',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('ভিন্ন এলাকা বা ভাড়া দিয়ে আবার খুঁজুন',
              style: TextStyle(fontSize: 14, color: textSecondary)),
        ],
      ),
    );
  }
}

// ── Listing Tile ──────────────────────────────────────────────────────────────

class _ListingTile extends StatelessWidget {
  final ListingModel listing;
  final bool isDark;
  final Color primary;
  final Color textPrimary;
  final Color textSecondary;

  const _ListingTile({
    required this.listing,
    required this.isDark,
    required this.primary,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => ListingDetailScreen(listing: listing))),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.home_work_rounded, color: primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(listing.propertyName,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary)),
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded, size: 12, color: textSecondary),
                              const SizedBox(width: 3),
                              Text('${listing.thana}, ${listing.district}',
                                  style: TextStyle(fontSize: 12, color: textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('৳${listing.rentAmount.toStringAsFixed(0)}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primary)),
                        Text('/মাস', style: TextStyle(fontSize: 11, color: textSecondary)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _chip('${listing.bedrooms} বেড', Icons.bed_outlined, const Color(0xFF0891B2)),
                    _chip('${listing.bathrooms} বাথ', Icons.bathroom_outlined, const Color(0xFF059669)),
                    if (listing.floorSize != null)
                      _chip('${listing.floorSize!.toStringAsFixed(0)} sqft', Icons.square_foot_outlined,
                          const Color(0xFFD97706)),
                    _chip(listing.roomType, Icons.people_outline_rounded, primary),
                    if (listing.hasBalcony) _chip('বারান্দা', Icons.balcony_outlined, const Color(0xFF5B4FBF)),
                    if (listing.hasParking) _chip('পার্কিং', Icons.local_parking_outlined, const Color(0xFF6B7280)),
                  ],
                ),

                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.person_outlined, size: 12, color: textSecondary),
                    const SizedBox(width: 4),
                    Text('${listing.landlordName} • ${listing.landlordPhone}',
                        style: TextStyle(fontSize: 12, color: textSecondary)),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded, color: textSecondary, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Listing Detail + Request Screen ──────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class ListingDetailScreen extends StatefulWidget {
  final ListingModel listing;
  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  final _service = ListingService();
  bool _requesting = false;
  bool _alreadyRequested = false;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _nidCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _prefillUserInfo();
    _checkAlreadyRequested();
  }

  void _prefillUserInfo() {
    // Provider থেকে user info prefill
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthService>().currentUser;
      if (user != null) {
        _nameCtrl.text = user.name;
        _phoneCtrl.text = user.phone;
        _emailCtrl.text = user.email;
      }
    });
  }

  Future<void> _checkAlreadyRequested() async {
    final user = context.read<AuthService>().currentUser;
    if (user == null) return;
    final snap = await _service.getTenantRequests(user.uid).first;
    setState(() {
      _alreadyRequested = snap.any((r) => r.roomId == widget.listing.roomId &&
          r.status == RentalRequestStatus.pending);
    });
  }

  Future<void> _sendRequest() async {
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty || _nidCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('নাম, ফোন ও NID দিন'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _requesting = true);
    final user = context.read<AuthService>().currentUser!;

    final request = RentalRequestModel(
      id: '',
      listingId: widget.listing.id,
      landlordId: widget.listing.landlordId,
      propertyId: widget.listing.propertyId,
      propertyName: widget.listing.propertyName,
      roomId: widget.listing.roomId,
      roomNumber: widget.listing.roomNumber,
      rentAmount: widget.listing.rentAmount,
      tenantUserId: user.uid,
      tenantName: _nameCtrl.text.trim(),
      tenantPhone: _phoneCtrl.text.trim(),
      tenantEmail: _emailCtrl.text.trim(),
      tenantNid: _nidCtrl.text.trim(),
      message: _msgCtrl.text.trim(),
      createdAt: DateTime.now(),
    );

    try {
      await _service.sendRequest(request);
      setState(() { _requesting = false; _alreadyRequested = true; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('আবেদন পাঠানো হয়েছে! বাড়ীওয়ালার অনুমোদনের অপেক্ষা করুন। ✅'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _requesting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final divider = isDark ? Colors.white10 : const Color(0xFFE5E7EB);

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
            title: Text('বিস্তারিত',
                style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            centerTitle: true,
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Hero card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, primary.withOpacity(0.75)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(listing.propertyName,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text('${listing.address}, ${listing.thana}, ${listing.district}',
                              style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('৳${listing.rentAmount.toStringAsFixed(0)}/মাস',
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('রুম নং: ${listing.roomNumber} • ${listing.roomType}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Details grid
                _card(cardBg, [
                  _detailGrid(listing, textPrimary, textSecondary),
                ]),
                const SizedBox(height: 12),

                // Amenities
                _sectionHeader('সুযোগ-সুবিধা', primary),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    if (listing.hasDiningRoom) _amenity('ডাইনিং রুম', Icons.dining_outlined, primary),
                    if (listing.hasBalcony) _amenity('বারান্দা', Icons.balcony_outlined, const Color(0xFF0891B2)),
                    if (listing.hasParking) _amenity('পার্কিং', Icons.local_parking_outlined, const Color(0xFF059669)),
                    if (listing.hasLift) _amenity('লিফট', Icons.elevator_outlined, const Color(0xFF5B4FBF)),
                    if (listing.hasGenerator) _amenity('জেনারেটর', Icons.bolt_outlined, const Color(0xFFD97706)),
                    if (listing.isGasPiped) _amenity('পাইপ গ্যাস', Icons.local_fire_department_outlined, Colors.red),
                  ],
                ),
                const SizedBox(height: 14),

                // Who can stay
                _sectionHeader('কারা থাকতে পারবে', primary),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    if (listing.allowsFamily) _amenity('পরিবার', Icons.family_restroom_outlined, Colors.green),
                    if (listing.allowsBachelor) _amenity('ব্যাচেলর', Icons.person_outlined, const Color(0xFF0891B2)),
                    if (listing.allowsStudent) _amenity('ছাত্র/ছাত্রী', Icons.school_outlined, const Color(0xFFD97706)),
                  ],
                ),

                if (listing.description.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _sectionHeader('বিবরণ', primary),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: divider),
                    ),
                    child: Text(listing.description, style: TextStyle(color: textSecondary, fontSize: 14, height: 1.5)),
                  ),
                ],

                // Landlord contact
                const SizedBox(height: 14),
                _sectionHeader('বাড়ীওয়ালার তথ্য', primary),
                _card(cardBg, [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22, backgroundColor: primary.withOpacity(0.15),
                          child: Icon(Icons.person_rounded, color: primary),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(listing.landlordName,
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary)),
                            Text(listing.landlordPhone,
                                style: TextStyle(fontSize: 13, color: textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),

                const SizedBox(height: 24),

                // ── Request Form ──
                if (_alreadyRequested)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.green),
                        SizedBox(width: 10),
                        Text('আপনি ইতিমধ্যে এই রুমের জন্য আবেদন করেছেন',
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                else ...[
                  _sectionHeader('ভাড়ার আবেদন করুন', primary),
                  _card(cardBg, [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _field(_nameCtrl, 'পুরো নাম', Icons.person_outline_rounded),
                          const SizedBox(height: 10),
                          _field(_phoneCtrl, 'ফোন নম্বর', Icons.phone_outlined, type: TextInputType.phone),
                          const SizedBox(height: 10),
                          _field(_emailCtrl, 'Email', Icons.email_outlined, type: TextInputType.emailAddress),
                          const SizedBox(height: 10),
                          _field(_nidCtrl, 'NID নম্বর', Icons.badge_outlined, type: TextInputType.number),
                          const SizedBox(height: 10),
                          _field(_msgCtrl, 'বাড়ীওয়ালার জন্য বার্তা (ঐচ্ছিক)', Icons.chat_bubble_outline_rounded, maxLines: 3),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity, height: 50,
                            child: FilledButton.icon(
                              onPressed: _requesting ? null : _sendRequest,
                              icon: _requesting
                                  ? const SizedBox(width: 18, height: 18,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.send_rounded),
                              label: Text(_requesting ? 'পাঠানো হচ্ছে...' : 'আবেদন পাঠান'),
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ],

              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailGrid(ListingModel l, Color textPrimary, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.4,
        children: [
          _gridItem('${l.bedrooms}', 'বেডরুম', Icons.bed_outlined, const Color(0xFF0891B2)),
          _gridItem('${l.bathrooms}', 'বাথরুম', Icons.bathroom_outlined, const Color(0xFF059669)),
          _gridItem('${l.kitchens}', 'রান্নাঘর', Icons.kitchen_outlined, const Color(0xFFD97706)),
          _gridItem('${l.floor}তলা', 'তলা', Icons.stairs_outlined, const Color(0xFF5B4FBF)),
          if (l.floorSize != null)
            _gridItem('${l.floorSize!.toStringAsFixed(0)}', 'বর্গফুট', Icons.square_foot_outlined, Colors.teal),
          _gridItem(l.roomType, 'ধরন', Icons.people_outline_rounded, const Color(0xFF059669)),
        ],
      ),
    );
  }

  Widget _gridItem(String value, String label, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 9, color: color.withOpacity(0.8)), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(title,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5)),
      );

  Widget _card(Color bg, List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(children: children),
      );

  Widget _amenity(String label, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType type = TextInputType.text, int maxLines = 1}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}