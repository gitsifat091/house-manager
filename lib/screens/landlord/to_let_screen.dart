// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../services/auth_service.dart';
// import '../../../services/listing_service.dart';
// import '../../../models/listing_model.dart';
// import '../../../models/property_model.dart';
// import '../../../models/room_model.dart';
// import '../../../models/rental_request_model.dart';
// import 'rental_requests_screen.dart';

// class ToLetScreen extends StatelessWidget {
//   const ToLetScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final user = context.read<AuthService>().currentUser!;
//     final service = ListingService();
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final primary = Theme.of(context).colorScheme.primary;
//     final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
//     final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
//     final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);

//     return Scaffold(
//       backgroundColor: bg,
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           SliverAppBar(
//             pinned: true,
//             backgroundColor: bg,
//             elevation: 0,
//             leading: IconButton(
//               icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textPrimary),
//               onPressed: () => Navigator.pop(context),
//             ),
//             title: Text('ভাড়া দিন (To-Let)',
//                 style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
//             centerTitle: true,
//             actions: [
//               // Requests bell with badge
//               StreamBuilder<List>(
//                 stream: service.getLandlordRequests(user.uid),
//                 builder: (context, snap) {
//                   final pending = (snap.data ?? [])
//                       .where((r) => r.status == RentalRequestStatus.pending)
//                       .length;
//                   return Stack(
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.inbox_rounded, color: textPrimary),
//                         tooltip: 'আসা Requests',
//                         onPressed: () => Navigator.push(context,
//                             MaterialPageRoute(builder: (_) => RentalRequestsScreen(landlordId: user.uid))),
//                       ),
//                       if (pending > 0)
//                         Positioned(
//                           right: 6, top: 6,
//                           child: Container(
//                             padding: const EdgeInsets.all(4),
//                             decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
//                             child: Text('$pending',
//                                 style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
//                           ),
//                         ),
//                     ],
//                   );
//                 },
//               ),
//             ],
//           ),

//           // Active listings
//           StreamBuilder<List<ListingModel>>(
//             stream: service.getLandlordListings(user.uid),
//             builder: (context, snap) {
//               if (snap.connectionState == ConnectionState.waiting) {
//                 return SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: primary)));
//               }

//               final listings = snap.data ?? [];
//               final active = listings.where((l) => l.isActive).toList();
//               final inactive = listings.where((l) => !l.isActive).toList();

//               return SliverPadding(
//                 padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
//                 sliver: SliverList(
//                   delegate: SliverChildListDelegate([
//                     // Info banner
//                     Container(
//                       padding: const EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         color: primary.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(14),
//                         border: Border.all(color: primary.withOpacity(0.2)),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.info_outline_rounded, color: primary, size: 20),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: Text(
//                               'To-Let দিলে ভাড়াটিয়ারা "বাড়ি খুঁজুন" থেকে আপনার রুম দেখতে পাবে।',
//                               style: TextStyle(fontSize: 13, color: primary),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     // Active listings
//                     if (active.isNotEmpty) ...[
//                       _sectionHeader('সক্রিয় To-Let (${active.length})', Colors.green, textSecondary),
//                       ...active.map((l) => _ListingCard(
//                             listing: l,
//                             service: service,
//                             isDark: isDark,
//                             primary: primary,
//                             textPrimary: textPrimary,
//                             textSecondary: textSecondary,
//                           )),
//                       const SizedBox(height: 12),
//                     ],

//                     // Inactive/expired
//                     if (inactive.isNotEmpty) ...[
//                       _sectionHeader('নিষ্ক্রিয় (${inactive.length})', textSecondary, textSecondary),
//                       ...inactive.map((l) => _ListingCard(
//                             listing: l,
//                             service: service,
//                             isDark: isDark,
//                             primary: primary,
//                             textPrimary: textPrimary,
//                             textSecondary: textSecondary,
//                             inactive: true,
//                           )),
//                     ],

//                     if (listings.isEmpty)
//                       _emptyState(primary, textSecondary),
//                   ]),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       floatingActionButton: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [BoxShadow(color: primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
//         ),
//         child: FloatingActionButton.extended(
//           onPressed: () => Navigator.push(context,
//               MaterialPageRoute(builder: (_) => AddListingScreen(landlordId: user.uid))),
//           icon: const Icon(Icons.add_rounded),
//           label: const Text('নতুন To-Let দিন', style: TextStyle(fontWeight: FontWeight.w700)),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         ),
//       ),
//     );
//   }

//   Widget _sectionHeader(String title, Color color, Color textSecondary) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8, top: 4),
//       child: Text(title,
//           style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5)),
//     );
//   }

//   Widget _emptyState(Color primary, Color textSecondary) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 60),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 90, height: 90,
//               decoration: BoxDecoration(color: primary.withOpacity(0.1), shape: BoxShape.circle),
//               child: Icon(Icons.home_outlined, size: 46, color: primary.withOpacity(0.5)),
//             ),
//             const SizedBox(height: 20),
//             const Text('কোনো To-Let নেই', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             Text('নিচের বাটন দিয়ে To-Let যোগ করুন', style: TextStyle(fontSize: 14, color: textSecondary)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Listing Card ──────────────────────────────────────────────────────────────

// class _ListingCard extends StatelessWidget {
//   final ListingModel listing;
//   final ListingService service;
//   final bool isDark;
//   final Color primary;
//   final Color textPrimary;
//   final Color textSecondary;
//   final bool inactive;

//   const _ListingCard({
//     required this.listing,
//     required this.service,
//     required this.isDark,
//     required this.primary,
//     required this.textPrimary,
//     required this.textSecondary,
//     this.inactive = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
//     final accentColor = inactive ? textSecondary : primary;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: cardBg,
//         borderRadius: BorderRadius.circular(16),
//         border: inactive ? Border.all(color: textSecondary.withOpacity(0.2)) : null,
//         boxShadow: inactive
//             ? null
//             : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(14),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: accentColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(Icons.home_work_rounded, color: accentColor, size: 22),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('${listing.propertyName} — রুম ${listing.roomNumber}',
//                           style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
//                               color: inactive ? textSecondary : textPrimary)),
//                       Text('${listing.thana}, ${listing.district}',
//                           style: TextStyle(fontSize: 12, color: textSecondary)),
//                     ],
//                   ),
//                 ),
//                 if (!inactive)
//                   PopupMenuButton(
//                     icon: Icon(Icons.more_vert_rounded, color: textSecondary, size: 20),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     itemBuilder: (_) => [
//                       const PopupMenuItem(value: 'deactivate', child: Text('নিষ্ক্রিয় করুন')),
//                       const PopupMenuItem(
//                         value: 'delete',
//                         child: Text('Delete', style: TextStyle(color: Colors.red)),
//                       ),
//                     ],
//                     onSelected: (val) async {
//                       if (val == 'deactivate') await service.deactivateListing(listing.id);
//                       if (val == 'delete') await service.deleteListing(listing.id);
//                     },
//                   )
//                 else
//                   TextButton(
//                     onPressed: () async {
//                       await FirebaseFirestore.instance
//                           .collection('listings')
//                           .doc(listing.id)
//                           .update({'isActive': true});
//                     },
//                     child: Text('পুনরায় চালু', style: TextStyle(color: primary, fontSize: 12)),
//                   ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             Wrap(
//               spacing: 8,
//               runSpacing: 6,
//               children: [
//                 _chip('৳${listing.rentAmount.toStringAsFixed(0)}/মাস', Icons.payments_outlined, accentColor),
//                 _chip('${listing.bedrooms} বেড', Icons.bed_outlined, const Color(0xFF0891B2)),
//                 _chip('${listing.bathrooms} বাথ', Icons.bathroom_outlined, const Color(0xFF059669)),
//                 if (listing.hasBalcony) _chip('বারান্দা', Icons.balcony_outlined, const Color(0xFFD97706)),
//                 if (listing.hasParking) _chip('পার্কিং', Icons.local_parking_outlined, const Color(0xFF5B4FBF)),
//                 _chip(listing.roomType, Icons.people_outline_rounded, const Color(0xFF6B7280)),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _chip(String label, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color.withOpacity(0.25)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 12, color: color),
//           const SizedBox(width: 4),
//           Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════════════════════
// // ── Add Listing Screen ────────────────────────────────────────────────────────
// // ═══════════════════════════════════════════════════════════════════════════════

// class AddListingScreen extends StatefulWidget {
//   final String landlordId;
//   const AddListingScreen({super.key, required this.landlordId});

//   @override
//   State<AddListingScreen> createState() => _AddListingScreenState();
// }

// class _AddListingScreenState extends State<AddListingScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _service = ListingService();

//   // Property / Room selection
//   String? _selectedPropertyId;
//   String? _selectedPropertyName;
//   String? _selectedRoomId;
//   String? _selectedRoomNumber;
//   double _rentAmount = 0;
//   String _roomType = 'Family';
//   List<PropertyModel> _properties = [];
//   List<RoomModel> _vacantRooms = [];
//   bool _loadingProperties = true;

//   // Location
//   final _divisionCtrl = TextEditingController();
//   final _districtCtrl = TextEditingController();
//   final _thanaCtrl = TextEditingController();
//   final _addressCtrl = TextEditingController();

//   // Details
//   final _sizeCtrl = TextEditingController();
//   final _descCtrl = TextEditingController();
//   int _bedrooms = 2;
//   int _bathrooms = 1;
//   int _kitchens = 1;
//   int _floor = 1;
//   bool _hasDining = false;
//   bool _hasBalcony = false;
//   bool _hasParking = false;
//   bool _hasLift = false;
//   bool _hasGenerator = false;
//   bool _isGasPiped = false;
//   bool _allowsBachelor = false;
//   bool _allowsFamily = true;
//   bool _allowsStudent = false;
//   bool _loading = false;

//   final List<String> _divisions = [
//     'ঢাকা', 'চট্টগ্রাম', 'রাজশাহী', 'খুলনা', 'বরিশাল', 'সিলেট', 'রংপুর', 'ময়মনসিংহ'
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadProperties();
//   }

//   Future<void> _loadProperties() async {
//     final snap = await FirebaseFirestore.instance
//         .collection('properties')
//         .where('landlordId', isEqualTo: widget.landlordId)
//         .get();
//     setState(() {
//       _properties = snap.docs
//           .map((d) => PropertyModel.fromMap(d.data(), d.id))
//           .toList();
//       _loadingProperties = false;
//     });
//   }

//   Future<void> _loadVacantRooms(String propertyId) async {
//     final snap = await FirebaseFirestore.instance
//         .collection('rooms')
//         .where('propertyId', isEqualTo: propertyId)
//         .where('status', isEqualTo: 'vacant')
//         .get();
//     setState(() {
//       _vacantRooms = snap.docs
//           .map((d) => RoomModel.fromMap(d.data() as Map<String, dynamic>, d.id))
//           .toList();
//       _selectedRoomId = null;
//       _selectedRoomNumber = null;
//     });
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_selectedRoomId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('রুম সিলেক্ট করুন'), backgroundColor: Colors.red));
//       return;
//     }

//     setState(() => _loading = true);

//     final user = context.read<AuthService>().currentUser!;

//     final listing = ListingModel(
//       id: '',
//       landlordId: widget.landlordId,
//       landlordName: user.name,
//       landlordPhone: user.phone,
//       propertyId: _selectedPropertyId!,
//       propertyName: _selectedPropertyName!,
//       roomId: _selectedRoomId!,
//       roomNumber: _selectedRoomNumber!,
//       roomType: _roomType,
//       rentAmount: _rentAmount,
//       area: _thanaCtrl.text.trim(),
//       address: _addressCtrl.text.trim(),
//       division: _divisionCtrl.text.trim(),
//       district: _districtCtrl.text.trim(),
//       thana: _thanaCtrl.text.trim(),
//       floorSize: _sizeCtrl.text.isNotEmpty ? double.tryParse(_sizeCtrl.text) : null,
//       bedrooms: _bedrooms,
//       bathrooms: _bathrooms,
//       kitchens: _kitchens,
//       hasDiningRoom: _hasDining,
//       hasBalcony: _hasBalcony,
//       hasParking: _hasParking,
//       hasLift: _hasLift,
//       hasGenerator: _hasGenerator,
//       isGasPiped: _isGasPiped,
//       allowsBachelor: _allowsBachelor,
//       allowsFamily: _allowsFamily,
//       allowsStudent: _allowsStudent,
//       floor: _floor,
//       description: _descCtrl.text.trim(),
//       createdAt: DateTime.now(),
//     );

//     try {
//       await _service.addListing(listing);
//       if (mounted) {
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('To-Let দেওয়া হয়েছে!'), backgroundColor: Colors.green));
//       }
//     } catch (e) {
//       setState(() => _loading = false);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final primary = Theme.of(context).colorScheme.primary;
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('নতুন To-Let দিন'),
//         centerTitle: true,
//       ),
//       body: _loadingProperties
//           ? Center(child: CircularProgressIndicator(color: primary))
//           : Form(
//               key: _formKey,
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [

//                     // ── Property & Room ──
//                     _sectionTitle('🏠 Property ও রুম', primary),
//                     const SizedBox(height: 10),

//                     // Property dropdown
//                     DropdownButtonFormField<String>(
//                       decoration: const InputDecoration(
//                         labelText: 'Property বেছে নিন',
//                         prefixIcon: Icon(Icons.home_work_outlined),
//                       ),
//                       items: _properties.map((p) => DropdownMenuItem(
//                         value: p.id,
//                         child: Text(p.name),
//                       )).toList(),
//                       onChanged: (val) {
//                         final prop = _properties.firstWhere((p) => p.id == val);
//                         setState(() {
//                           _selectedPropertyId = val;
//                           _selectedPropertyName = prop.name;
//                           _addressCtrl.text = prop.address;
//                         });
//                         _loadVacantRooms(val!);
//                       },
//                       validator: (v) => v == null ? 'Property সিলেক্ট করুন' : null,
//                     ),
//                     const SizedBox(height: 12),

//                     // Room dropdown
//                     if (_selectedPropertyId != null)
//                       DropdownButtonFormField<String>(
//                         decoration: const InputDecoration(
//                           labelText: 'খালি রুম বেছে নিন',
//                           prefixIcon: Icon(Icons.door_front_door_outlined),
//                         ),
//                         value: _selectedRoomId,
//                         items: _vacantRooms.map((r) => DropdownMenuItem(
//                           value: r.id,
//                           child: Text('রুম ${r.roomNumber} — ৳${r.rentAmount.toStringAsFixed(0)} (${r.type})'),
//                         )).toList(),
//                         onChanged: (val) {
//                           final room = _vacantRooms.firstWhere((r) => r.id == val);
//                           setState(() {
//                             _selectedRoomId = val;
//                             _selectedRoomNumber = room.roomNumber;
//                             _rentAmount = room.rentAmount;
//                             _roomType = room.type;
//                           });
//                         },
//                         validator: (v) => v == null ? 'রুম সিলেক্ট করুন' : null,
//                       ),

//                     const SizedBox(height: 20),

//                     // ── Location ──
//                     _sectionTitle('📍 অবস্থান', primary),
//                     const SizedBox(height: 10),

//                     DropdownButtonFormField<String>(
//                       decoration: const InputDecoration(
//                         labelText: 'বিভাগ',
//                         prefixIcon: Icon(Icons.map_outlined),
//                       ),
//                       items: _divisions.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
//                       onChanged: (v) => _divisionCtrl.text = v ?? '',
//                       validator: (v) => v == null ? 'বিভাগ সিলেক্ট করুন' : null,
//                     ),
//                     const SizedBox(height: 12),
//                     TextFormField(
//                       controller: _districtCtrl,
//                       decoration: const InputDecoration(
//                         labelText: 'জেলা',
//                         prefixIcon: Icon(Icons.location_city_outlined),
//                       ),
//                       validator: (v) => v!.isEmpty ? 'জেলা দিন' : null,
//                     ),
//                     const SizedBox(height: 12),
//                     TextFormField(
//                       controller: _thanaCtrl,
//                       decoration: const InputDecoration(
//                         labelText: 'থানা / এলাকা',
//                         prefixIcon: Icon(Icons.location_on_outlined),
//                       ),
//                       validator: (v) => v!.isEmpty ? 'এলাকা দিন' : null,
//                     ),
//                     const SizedBox(height: 12),
//                     TextFormField(
//                       controller: _addressCtrl,
//                       decoration: const InputDecoration(
//                         labelText: 'সম্পূর্ণ ঠিকানা',
//                         prefixIcon: Icon(Icons.home_outlined),
//                       ),
//                       maxLines: 2,
//                     ),

//                     const SizedBox(height: 20),

//                     // ── Flat Details ──
//                     _sectionTitle('📐 ফ্ল্যাটের বিস্তারিত', primary),
//                     const SizedBox(height: 12),

//                     // Counters row
//                     _counterRow('বেডরুম', _bedrooms, (v) => setState(() => _bedrooms = v),
//                         Icons.bed_outlined, primary),
//                     const SizedBox(height: 10),
//                     _counterRow('বাথরুম', _bathrooms, (v) => setState(() => _bathrooms = v),
//                         Icons.bathroom_outlined, const Color(0xFF0891B2)),
//                     const SizedBox(height: 10),
//                     _counterRow('রান্নাঘর', _kitchens, (v) => setState(() => _kitchens = v),
//                         Icons.kitchen_outlined, const Color(0xFF059669)),
//                     const SizedBox(height: 10),
//                     _counterRow('তলা', _floor, (v) => setState(() => _floor = v),
//                         Icons.stairs_outlined, const Color(0xFFD97706)),
//                     const SizedBox(height: 12),

//                     // Size field
//                     TextFormField(
//                       controller: _sizeCtrl,
//                       keyboardType: TextInputType.number,
//                       decoration: const InputDecoration(
//                         labelText: 'ফ্ল্যাট সাইজ (বর্গফুট)',
//                         hintText: 'যেমন: 850',
//                         prefixIcon: Icon(Icons.square_foot_outlined),
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     // Amenities
//                     _sectionTitle('✅ সুযোগ-সুবিধা', primary),
//                     const SizedBox(height: 8),
//                     Wrap(
//                       spacing: 8,
//                       runSpacing: 8,
//                       children: [
//                         _toggleChip('ডাইনিং', _hasDining, (v) => setState(() => _hasDining = v), primary),
//                         _toggleChip('বারান্দা', _hasBalcony, (v) => setState(() => _hasBalcony = v), primary),
//                         _toggleChip('পার্কিং', _hasParking, (v) => setState(() => _hasParking = v), primary),
//                         _toggleChip('লিফট', _hasLift, (v) => setState(() => _hasLift = v), primary),
//                         _toggleChip('জেনারেটর', _hasGenerator, (v) => setState(() => _hasGenerator = v), primary),
//                         _toggleChip('পাইপ গ্যাস', _isGasPiped, (v) => setState(() => _isGasPiped = v), primary),
//                       ],
//                     ),

//                     const SizedBox(height: 16),
//                     _sectionTitle('👥 কারা থাকতে পারবে', primary),
//                     const SizedBox(height: 8),
//                     Wrap(
//                       spacing: 8,
//                       runSpacing: 8,
//                       children: [
//                         _toggleChip('পরিবার', _allowsFamily, (v) => setState(() => _allowsFamily = v), primary),
//                         _toggleChip('ব্যাচেলর', _allowsBachelor, (v) => setState(() => _allowsBachelor = v), primary),
//                         _toggleChip('ছাত্র/ছাত্রী', _allowsStudent, (v) => setState(() => _allowsStudent = v), primary),
//                       ],
//                     ),

//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _descCtrl,
//                       decoration: const InputDecoration(
//                         labelText: 'অতিরিক্ত বিবরণ (ঐচ্ছিক)',
//                         hintText: 'আরো কোনো তথ্য দিতে চাইলে লিখুন...',
//                         prefixIcon: Icon(Icons.notes_outlined),
//                       ),
//                       maxLines: 3,
//                     ),

//                     const SizedBox(height: 32),
//                     SizedBox(
//                       width: double.infinity, height: 54,
//                       child: FilledButton(
//                         onPressed: _loading ? null : _submit,
//                         style: FilledButton.styleFrom(
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                         ),
//                         child: _loading
//                             ? const SizedBox(width: 22, height: 22,
//                                 child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                             : const Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(Icons.campaign_rounded),
//                                   SizedBox(width: 10),
//                                   Text('To-Let প্রকাশ করুন',
//                                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//                                 ],
//                               ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }

//   Widget _sectionTitle(String title, Color color) {
//     return Row(
//       children: [
//         Container(width: 4, height: 18, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
//         const SizedBox(width: 8),
//         Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
//       ],
//     );
//   }

//   Widget _counterRow(String label, int value, ValueChanged<int> onChange, IconData icon, Color color) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: cardBg,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: color, size: 20),
//           const SizedBox(width: 10),
//           Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
//           IconButton(
//             icon: const Icon(Icons.remove_circle_outline_rounded),
//             color: value > 1 ? color : Colors.grey,
//             onPressed: value > 1 ? () => onChange(value - 1) : null,
//             visualDensity: VisualDensity.compact,
//           ),
//           Text('$value', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
//           IconButton(
//             icon: const Icon(Icons.add_circle_outline_rounded),
//             color: color,
//             onPressed: () => onChange(value + 1),
//             visualDensity: VisualDensity.compact,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _toggleChip(String label, bool selected, ValueChanged<bool> onChange, Color color) {
//     return FilterChip(
//       label: Text(label),
//       selected: selected,
//       onSelected: onChange,
//       selectedColor: color.withOpacity(0.15),
//       checkmarkColor: color,
//       labelStyle: TextStyle(color: selected ? color : null, fontWeight: selected ? FontWeight.w600 : null),
//       side: BorderSide(color: selected ? color : Colors.grey.withOpacity(0.3)),
//     );
//   }
// }










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

  // ── Details Bottom Sheet ──────────────────────────────────────────────────
  void _showDetails(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (inactive ? textSecondary : primary).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.home_work_rounded,
                                color: inactive ? textSecondary : primary, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${listing.propertyName} — রুম ${listing.roomNumber}',
                                  style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w800, color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text('${listing.thana}, ${listing.district}',
                                    style: TextStyle(fontSize: 13, color: textSecondary)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: inactive
                                  ? textSecondary.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              inactive ? 'নিষ্ক্রিয়' : 'সক্রিয়',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: inactive ? textSecondary : Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Rent highlight
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primary.withOpacity(0.15),
                              primary.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.payments_outlined, color: primary, size: 22),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('মাসিক ভাড়া',
                                    style: TextStyle(fontSize: 12, color: primary.withOpacity(0.7))),
                                Text(
                                  '৳${listing.rentAmount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                      fontSize: 24, fontWeight: FontWeight.w900, color: primary),
                                ),
                              ],
                            ),
                            const Spacer(),
                            _detailPill(listing.roomType, Icons.people_outline_rounded, primary),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Details grid
                      _detailsSection('🏠 রুমের বিবরণ', textPrimary, textSecondary, primary),
                      const SizedBox(height: 10),
                      _infoGrid([
                        _InfoItem(Icons.bed_outlined, 'বেডরুম', '${listing.bedrooms}টি', const Color(0xFF0891B2)),
                        _InfoItem(Icons.bathroom_outlined, 'বাথরুম', '${listing.bathrooms}টি', const Color(0xFF059669)),
                        _InfoItem(Icons.kitchen_outlined, 'রান্নাঘর', '${listing.kitchens}টি', const Color(0xFFD97706)),
                        _InfoItem(Icons.stairs_outlined, 'তলা', '${listing.floor} তলা', const Color(0xFF5B4FBF)),
                        if (listing.floorSize != null)
                          _InfoItem(Icons.square_foot_outlined, 'সাইজ',
                              '${listing.floorSize!.toStringAsFixed(0)} বর্গফুট', const Color(0xFF6B7280)),
                      ], isDark),
                      const SizedBox(height: 20),

                      // Location
                      _detailsSection('📍 অবস্থান', textPrimary, textSecondary, primary),
                      const SizedBox(height: 10),
                      _locationRow(Icons.map_outlined, 'বিভাগ', listing.division, textPrimary, textSecondary),
                      _locationRow(Icons.location_city_outlined, 'জেলা', listing.district, textPrimary, textSecondary),
                      _locationRow(Icons.location_on_outlined, 'থানা', listing.thana, textPrimary, textSecondary),
                      if (listing.address.isNotEmpty)
                        _locationRow(Icons.home_outlined, 'ঠিকানা', listing.address, textPrimary, textSecondary),

                      const SizedBox(height: 20),

                      // Amenities
                      _detailsSection('✅ সুযোগ-সুবিধা', textPrimary, textSecondary, primary),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: [
                          if (listing.hasDiningRoom)
                            _amenityChip('ডাইনিং', Icons.dining_outlined, const Color(0xFF0891B2), isDark),
                          if (listing.hasBalcony)
                            _amenityChip('বারান্দা', Icons.balcony_outlined, const Color(0xFFD97706), isDark),
                          if (listing.hasParking)
                            _amenityChip('পার্কিং', Icons.local_parking_outlined, const Color(0xFF5B4FBF), isDark),
                          if (listing.hasLift)
                            _amenityChip('লিফট', Icons.elevator_outlined, const Color(0xFF059669), isDark),
                          if (listing.hasGenerator)
                            _amenityChip('জেনারেটর', Icons.bolt_outlined, const Color(0xFFF59E0B), isDark),
                          if (listing.isGasPiped)
                            _amenityChip('পাইপ গ্যাস', Icons.local_fire_department_outlined, const Color(0xFFEF4444), isDark),
                          if (!listing.hasDiningRoom && !listing.hasBalcony &&
                              !listing.hasParking && !listing.hasLift &&
                              !listing.hasGenerator && !listing.isGasPiped)
                            Text('কোনো অতিরিক্ত সুবিধা নেই',
                                style: TextStyle(color: textSecondary, fontSize: 13)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Who can stay
                      _detailsSection('👥 কারা থাকতে পারবে', textPrimary, textSecondary, primary),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: [
                          if (listing.allowsFamily)
                            _amenityChip('পরিবার', Icons.family_restroom_outlined, Colors.green, isDark),
                          if (listing.allowsBachelor)
                            _amenityChip('ব্যাচেলর', Icons.person_outlined, const Color(0xFF0891B2), isDark),
                          if (listing.allowsStudent)
                            _amenityChip('ছাত্র/ছাত্রী', Icons.school_outlined, const Color(0xFF5B4FBF), isDark),
                        ],
                      ),

                      if (listing.description.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _detailsSection('📝 অতিরিক্ত বিবরণ', textPrimary, textSecondary, primary),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: textSecondary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(listing.description,
                              style: TextStyle(fontSize: 14, color: textPrimary, height: 1.5)),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Action buttons at bottom of sheet
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => EditListingScreen(
                                    listing: listing, service: service),
                                ));
                              },
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text('সম্পাদনা'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                foregroundColor: primary,
                                side: BorderSide(color: primary.withOpacity(0.4)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close_rounded, size: 18),
                              label: const Text('বন্ধ করুন'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailsSection(String title, Color textPrimary, Color textSecondary, Color primary) {
    return Row(
      children: [
        Container(width: 3, height: 16,
            decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary)),
      ],
    );
  }

  Widget _infoGrid(List<_InfoItem> items, bool isDark) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: items.map((item) => Container(
        decoration: BoxDecoration(
          color: item.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: item.color.withOpacity(0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: item.color, size: 18),
            const SizedBox(height: 4),
            Text(item.value,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: item.color)),
            Text(item.label,
                style: TextStyle(fontSize: 10, color: item.color.withOpacity(0.7))),
          ],
        ),
      )).toList(),
    );
  }

  Widget _locationRow(IconData icon, String label, String value,
      Color textPrimary, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: textSecondary),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontSize: 13, color: textSecondary)),
          Expanded(
            child: Text(value,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _detailPill(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _amenityChip(String label, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Main card build ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final accentColor = inactive ? textSecondary : primary;

    return GestureDetector(
      onTap: () => _showDetails(context),
      child: Container(
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
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18, color: Colors.blueAccent),
                              SizedBox(width: 8),
                              Text('সম্পাদনা করুন'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'deactivate',
                          child: Row(
                            children: [
                              Icon(Icons.pause_circle_outline_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('নিষ্ক্রিয় করুন'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (val) async {
                        if (val == 'edit') {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => EditListingScreen(listing: listing, service: service),
                          ));
                        }
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
              // Tap hint
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.touch_app_outlined, size: 12, color: textSecondary.withOpacity(0.5)),
                    const SizedBox(width: 4),
                    Text('বিস্তারিত দেখতে ট্যাপ করুন',
                        style: TextStyle(fontSize: 10, color: textSecondary.withOpacity(0.5))),
                  ],
                ),
              ),
            ],
          ),
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

// ── Helper model for detail grid ──────────────────────────────────────────────

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoItem(this.icon, this.label, this.value, this.color);
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Edit Listing Screen ───────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class EditListingScreen extends StatefulWidget {
  final ListingModel listing;
  final ListingService service;

  const EditListingScreen({
    super.key,
    required this.listing,
    required this.service,
  });

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _districtCtrl = TextEditingController(text: widget.listing.district);
  late final _thanaCtrl = TextEditingController(text: widget.listing.thana);
  late final _addressCtrl = TextEditingController(text: widget.listing.address);
  late final _sizeCtrl = TextEditingController(
      text: widget.listing.floorSize?.toStringAsFixed(0) ?? '');
  late final _descCtrl = TextEditingController(text: widget.listing.description);
  late final _rentCtrl = TextEditingController(
      text: widget.listing.rentAmount.toStringAsFixed(0));

  late int _bedrooms = widget.listing.bedrooms;
  late int _bathrooms = widget.listing.bathrooms;
  late int _kitchens = widget.listing.kitchens;
  late int _floor = widget.listing.floor;
  late bool _hasDining = widget.listing.hasDiningRoom;
  late bool _hasBalcony = widget.listing.hasBalcony;
  late bool _hasParking = widget.listing.hasParking;
  late bool _hasLift = widget.listing.hasLift;
  late bool _hasGenerator = widget.listing.hasGenerator;
  late bool _isGasPiped = widget.listing.isGasPiped;
  late bool _allowsBachelor = widget.listing.allowsBachelor;
  late bool _allowsFamily = widget.listing.allowsFamily;
  late bool _allowsStudent = widget.listing.allowsStudent;
  late String _selectedDivision = widget.listing.division;
  bool _loading = false;

  final List<String> _divisions = [
    'ঢাকা', 'চট্টগ্রাম', 'রাজশাহী', 'খুলনা', 'বরিশাল', 'সিলেট', 'রংপুর', 'ময়মনসিংহ'
  ];

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance
          .collection('listings')
          .doc(widget.listing.id)
          .update({
        'rentAmount': double.tryParse(_rentCtrl.text.trim()) ?? widget.listing.rentAmount,
        'division': _selectedDivision,
        'district': _districtCtrl.text.trim(),
        'thana': _thanaCtrl.text.trim(),
        'area': _thanaCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'floorSize': _sizeCtrl.text.isNotEmpty ? double.tryParse(_sizeCtrl.text) : null,
        'bedrooms': _bedrooms,
        'bathrooms': _bathrooms,
        'kitchens': _kitchens,
        'floor': _floor,
        'hasDiningRoom': _hasDining,
        'hasBalcony': _hasBalcony,
        'hasParking': _hasParking,
        'hasLift': _hasLift,
        'hasGenerator': _hasGenerator,
        'isGasPiped': _isGasPiped,
        'allowsBachelor': _allowsBachelor,
        'allowsFamily': _allowsFamily,
        'allowsStudent': _allowsStudent,
        'description': _descCtrl.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('To-Let আপডেট হয়েছে!'), backgroundColor: Colors.green));
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
  void dispose() {
    _districtCtrl.dispose();
    _thanaCtrl.dispose();
    _addressCtrl.dispose();
    _sizeCtrl.dispose();
    _descCtrl.dispose();
    _rentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Let সম্পাদনা'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Read-only info banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${widget.listing.propertyName} — রুম ${widget.listing.roomNumber}',
                        style: TextStyle(fontSize: 13, color: primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Rent ──
              _sectionTitle('💰 ভাড়া', primary),
              const SizedBox(height: 10),
              TextFormField(
                controller: _rentCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'মাসিক ভাড়া (৳)',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (v) => v!.isEmpty ? 'ভাড়া দিন' : null,
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
                value: _divisions.contains(_selectedDivision) ? _selectedDivision : null,
                items: _divisions.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => setState(() => _selectedDivision = v ?? _selectedDivision),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _districtCtrl,
                decoration: const InputDecoration(
                  labelText: 'জেলা', prefixIcon: Icon(Icons.location_city_outlined)),
                validator: (v) => v!.isEmpty ? 'জেলা দিন' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _thanaCtrl,
                decoration: const InputDecoration(
                  labelText: 'থানা / এলাকা', prefixIcon: Icon(Icons.location_on_outlined)),
                validator: (v) => v!.isEmpty ? 'এলাকা দিন' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'সম্পূর্ণ ঠিকানা', prefixIcon: Icon(Icons.home_outlined)),
                maxLines: 2,
              ),

              const SizedBox(height: 20),

              // ── Room details ──
              _sectionTitle('📐 রুমের বিস্তারিত', primary),
              const SizedBox(height: 12),

              _counterRow('বেডরুম', _bedrooms, (v) => setState(() => _bedrooms = v),
                  Icons.bed_outlined, primary, cardBg),
              const SizedBox(height: 10),
              _counterRow('বাথরুম', _bathrooms, (v) => setState(() => _bathrooms = v),
                  Icons.bathroom_outlined, const Color(0xFF0891B2), cardBg),
              const SizedBox(height: 10),
              _counterRow('রান্নাঘর', _kitchens, (v) => setState(() => _kitchens = v),
                  Icons.kitchen_outlined, const Color(0xFF059669), cardBg),
              const SizedBox(height: 10),
              _counterRow('তলা', _floor, (v) => setState(() => _floor = v),
                  Icons.stairs_outlined, const Color(0xFFD97706), cardBg),
              const SizedBox(height: 12),

              TextFormField(
                controller: _sizeCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ফ্ল্যাট সাইজ (বর্গফুট)',
                  prefixIcon: Icon(Icons.square_foot_outlined),
                ),
              ),

              const SizedBox(height: 16),

              // Amenities
              _sectionTitle('✅ সুযোগ-সুবিধা', primary),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
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
                spacing: 8, runSpacing: 8,
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
                  onPressed: _loading ? null : _save,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_outlined),
                            SizedBox(width: 10),
                            Text('পরিবর্তন সংরক্ষণ করুন',
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
        Container(width: 4, height: 18,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }

  Widget _counterRow(String label, int value, ValueChanged<int> onChange,
      IconData icon, Color color, Color cardBg) {
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
        Container(width: 4, height: 18,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
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