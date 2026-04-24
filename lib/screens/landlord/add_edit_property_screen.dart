// import 'package:flutter/material.dart';
// import '../../models/property_model.dart';
// import '../../services/property_service.dart';

// class AddEditPropertyScreen extends StatefulWidget {
//   final String landlordId;
//   final PropertyModel? property;
//   const AddEditPropertyScreen({super.key, required this.landlordId, this.property});

//   @override
//   State<AddEditPropertyScreen> createState() => _AddEditPropertyScreenState();
// }

// class _AddEditPropertyScreenState extends State<AddEditPropertyScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameCtrl = TextEditingController();
//   final _addressCtrl = TextEditingController();
//   final _roomsCtrl = TextEditingController();
//   bool _loading = false;

//   bool get _isEdit => widget.property != null;

//   @override
//   void initState() {
//     super.initState();
//     if (_isEdit) {
//       _nameCtrl.text = widget.property!.name;
//       _addressCtrl.text = widget.property!.address;
//       _roomsCtrl.text = widget.property!.totalRooms.toString();
//     }
//   }

//   @override
//   void dispose() {
//     _nameCtrl.dispose(); _addressCtrl.dispose(); _roomsCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _save() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _loading = true);

//     final service = PropertyService();
//     final property = PropertyModel(
//       id: widget.property?.id ?? '',
//       landlordId: widget.landlordId,
//       name: _nameCtrl.text.trim(),
//       address: _addressCtrl.text.trim(),
//       totalRooms: int.parse(_roomsCtrl.text.trim()),
//       createdAt: widget.property?.createdAt ?? DateTime.now(),
//     );

//     if (_isEdit) {
//       await service.updateProperty(property);
//     } else {
//       await service.addProperty(property);
//     }

//     if (mounted) Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_isEdit ? 'Property Edit করুন' : 'নতুন Property'),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               const SizedBox(height: 8),
//               TextFormField(
//                 controller: _nameCtrl,
//                 decoration: const InputDecoration(
//                   labelText: 'Property এর নাম',
//                   hintText: 'যেমন: রহমান ভিলা',
//                   prefixIcon: Icon(Icons.home_work_outlined),
//                 ),
//                 validator: (v) => v!.isEmpty ? 'নাম দিন' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _addressCtrl,
//                 maxLines: 2,
//                 decoration: const InputDecoration(
//                   labelText: 'ঠিকানা',
//                   hintText: 'যেমন: মিরপুর-১০, ঢাকা',
//                   prefixIcon: Icon(Icons.location_on_outlined),
//                 ),
//                 validator: (v) => v!.isEmpty ? 'ঠিকানা দিন' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _roomsCtrl,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   labelText: 'মোট রুম সংখ্যা',
//                   prefixIcon: Icon(Icons.door_front_door_outlined),
//                 ),
//                 validator: (v) {
//                   if (v!.isEmpty) return 'রুম সংখ্যা দিন';
//                   if (int.tryParse(v) == null) return 'সংখ্যা দিন';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 32),
//               SizedBox(
//                 width: double.infinity, height: 54,
//                 child: FilledButton(
//                   onPressed: _loading ? null : _save,
//                   style: FilledButton.styleFrom(
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                   ),
//                   child: _loading
//                       ? const SizedBox(width: 22, height: 22,
//                           child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                       : Text(_isEdit ? 'Update করুন' : 'Save করুন',
//                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }







import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../services/property_service.dart';

class AddEditPropertyScreen extends StatefulWidget {
  final String landlordId;
  final PropertyModel? property;
  const AddEditPropertyScreen(
      {super.key, required this.landlordId, this.property});

  @override
  State<AddEditPropertyScreen> createState() =>
      _AddEditPropertyScreenState();
}

class _AddEditPropertyScreenState extends State<AddEditPropertyScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _roomsCtrl = TextEditingController();
  bool _loading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool get _isEdit => widget.property != null;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    if (_isEdit) {
      _nameCtrl.text = widget.property!.name;
      _addressCtrl.text = widget.property!.address;
      _roomsCtrl.text = widget.property!.totalRooms.toString();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _roomsCtrl.dispose();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary =
        isDark ? Colors.white54 : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── App Bar with Hero ─────────────────────────
            SliverAppBar(
              expandedHeight: 180,
              collapsedHeight: 60,
              pinned: true,
              backgroundColor: bg,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 20, color: textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                _isEdit ? 'Property Edit' : 'নতুন Property',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeroHeader(
                    primary: primary,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary),
              ),
            ),

            // ── Form Body ─────────────────────────────────
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: SlideTransition(
                  position: _slideAnim,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Property তথ্য section ──
                        _sectionHeader(
                            '🏠  Property তথ্য', textSecondary),
                        _buildCard(cardBg, [
                          _buildField(
                            controller: _nameCtrl,
                            label: 'Property এর নাম',
                            hint: 'যেমন: রহমান ভিলা',
                            icon: Icons.home_work_outlined,
                            iconBg: primary,
                            isDark: isDark,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            validator: (v) =>
                                v!.isEmpty ? 'নাম দিন' : null,
                          ),
                        ]),

                        const SizedBox(height: 12),

                        // ── অবস্থান section ──
                        _sectionHeader('📍  অবস্থান', textSecondary),
                        _buildCard(cardBg, [
                          _buildField(
                            controller: _addressCtrl,
                            label: 'ঠিকানা',
                            hint: 'যেমন: মিরপুর-১০, ঢাকা',
                            icon: Icons.location_on_outlined,
                            iconBg: const Color(0xFF0891B2),
                            isDark: isDark,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            maxLines: 3,
                            validator: (v) =>
                                v!.isEmpty ? 'ঠিকানা দিন' : null,
                          ),
                        ]),

                        const SizedBox(height: 12),

                        // ── রুম section ──
                        _sectionHeader('🚪  রুম', textSecondary),
                        _buildCard(cardBg, [
                          _buildField(
                            controller: _roomsCtrl,
                            label: 'মোট রুম সংখ্যা',
                            hint: 'যেমন: 8',
                            icon: Icons.door_front_door_outlined,
                            iconBg: const Color(0xFFD97706),
                            isDark: isDark,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v!.isEmpty) return 'রুম সংখ্যা দিন';
                              if (int.tryParse(v) == null)
                                return 'সংখ্যা দিন';
                              return null;
                            },
                          ),
                        ]),

                        const SizedBox(height: 28),

                        // ── Save Button ──
                        GestureDetector(
                          onTap: _loading ? null : _save,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: _loading
                                  ? null
                                  : LinearGradient(
                                      colors: [
                                        primary,
                                        primary.withOpacity(0.8)
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                              color: _loading
                                  ? primary.withOpacity(0.5)
                                  : null,
                              boxShadow: _loading
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: primary.withOpacity(0.4),
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
                                      child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _isEdit
                                              ? Icons.save_rounded
                                              : Icons.add_home_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          _isEdit
                                              ? 'Update করুন'
                                              : 'Property যোগ করুন',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero Header ───────────────────────────────────────────
  Widget _buildHeroHeader({
    required Color primary,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
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
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [primary, primary.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Icon(
                  _isEdit
                      ? Icons.home_outlined
                      : Icons.add_home_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isEdit ? 'Property সম্পাদনা' : 'নতুন Property',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isEdit
                        ? 'তথ্য আপডেট করুন'
                        : 'নতুন বাড়ি/ফ্ল্যাট যোগ করুন',
                    style: TextStyle(
                        color: textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────
  Widget _sectionHeader(String title, Color color) => Padding(
        padding:
            const EdgeInsets.only(left: 4, bottom: 8, top: 4),
        child: Text(
          title,
          style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5),
        ),
      );

  Widget _buildCard(Color bg, List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(children: children),
      );

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color iconBg,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(icon, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              style: TextStyle(
                  color: textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                labelStyle: TextStyle(
                    color: textSecondary, fontSize: 13),
                hintStyle: TextStyle(
                    color: textSecondary.withOpacity(0.6),
                    fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    const EdgeInsets.only(bottom: 4),
              ),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }
}