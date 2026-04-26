// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../../../services/auth_service.dart';
// import '../../../models/payment_model.dart';
// import '../shared/notification_screen.dart';

// class ChartScreen extends StatefulWidget {
//   final GlobalKey<ScaffoldState>? scaffoldKey;
//   const ChartScreen({super.key, this.scaffoldKey});

//   @override
//   State<ChartScreen> createState() => _ChartScreenState();
// }

// class _ChartScreenState extends State<ChartScreen> {
//   bool _loading = true;
//   List<_MonthlyData> _monthlyData = [];
//   int _totalTenants = 0;
//   int _occupiedRooms = 0;
//   int _totalRooms = 0;
//   double _thisMonthIncome = 0;
//   double _thisMonthPending = 0;

//   final List<String> _months = [
//     '', 'জান', 'ফেব', 'মার্চ', 'এপ্রি',
//     'মে', 'জুন', 'জুলা', 'আগ', 'সেপ্ট',
//     'অক্ট', 'নভে', 'ডিসে'
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     final user = context.read<AuthService>().currentUser!;
//     final db = FirebaseFirestore.instance;
//     final now = DateTime.now();

//     // Tenants count
//     final tenantsSnap = await db
//         .collection('tenants')
//         .where('landlordId', isEqualTo: user.uid)
//         .where('isActive', isEqualTo: true)
//         .get();
//     _totalTenants = tenantsSnap.docs.length;

//     // Rooms
//     final propsSnap = await db
//         .collection('properties')
//         .where('landlordId', isEqualTo: user.uid)
//         .get();
//     for (final prop in propsSnap.docs) {
//       final roomsSnap = await db
//           .collection('rooms')
//           .where('propertyId', isEqualTo: prop.id)
//           .get();
//       _totalRooms += roomsSnap.docs.length;
//       _occupiedRooms += roomsSnap.docs
//           .where((r) => r.data()['status'] == 'occupied')
//           .length;
//     }

//     // Last 6 months payment data
//     final List<_MonthlyData> data = [];
//     for (int i = 5; i >= 0; i--) {
//       final month = now.month - i <= 0
//           ? now.month - i + 12
//           : now.month - i;
//       final year = now.month - i <= 0 ? now.year - 1 : now.year;

//       final paySnap = await db
//           .collection('payments')
//           .where('landlordId', isEqualTo: user.uid)
//           .where('month', isEqualTo: month)
//           .where('year', isEqualTo: year)
//           .get();

//       double paid = 0;
//       double pending = 0;
//       for (final doc in paySnap.docs) {
//         final p = PaymentModel.fromMap(doc.data(), doc.id);
//         if (p.status == PaymentStatus.paid) {
//           paid += p.amount;
//         } else {
//           pending += p.amount;
//         }
//       }

//       data.add(_MonthlyData(month: month, year: year, paid: paid, pending: pending));

//       if (month == now.month && year == now.year) {
//         _thisMonthIncome = paid;
//         _thisMonthPending = pending;
//       }
//     }

//     setState(() {
//       _monthlyData = data;
//       _loading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = context.read<AuthService>().currentUser!;
//     final color = Theme.of(context).colorScheme;

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.menu_rounded),
//           onPressed: () => widget.scaffoldKey?.currentState?.openDrawer(),
//         ),
//         title: const Text('রিপোর্ট ও পরিসংখ্যান'),
//         centerTitle: true,
//         actions: [
//           NotificationBell(userId: user.uid),
//           IconButton(
//             icon: const Icon(Icons.refresh_rounded),
//             onPressed: () {
//               setState(() => _loading = true);
//               _loadData();
//             },
//           ),
//         ],
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: () async {
//                 setState(() => _loading = true);
//                 await _loadData();
//               },
//               child: SingleChildScrollView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Summary cards
//                     _sectionTitle('এই মাসের সারসংক্ষেপ'),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         Expanded(child: _SummaryCard(
//                           icon: Icons.check_circle_rounded,
//                           label: 'আয় হয়েছে',
//                           value: '৳${_thisMonthIncome.toStringAsFixed(0)}',
//                           color: Colors.green,
//                         )),
//                         const SizedBox(width: 10),
//                         Expanded(child: _SummaryCard(
//                           icon: Icons.pending_rounded,
//                           label: 'বাকি আছে',
//                           value: '৳${_thisMonthPending.toStringAsFixed(0)}',
//                           color: Colors.orange,
//                         )),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         Expanded(child: _SummaryCard(
//                           icon: Icons.people_rounded,
//                           label: 'ভাড়াটিয়া',
//                           value: '$_totalTenants জন',
//                           color: color.primary,
//                         )),
//                         const SizedBox(width: 10),
//                         Expanded(child: _SummaryCard(
//                           icon: Icons.door_front_door_rounded,
//                           label: 'রুম ভাড়া হয়েছে',
//                           value: '$_occupiedRooms/$_totalRooms',
//                           color: Colors.blue,
//                         )),
//                       ],
//                     ),

//                     const SizedBox(height: 24),

//                     // Bar chart - monthly income
//                     _sectionTitle('গত ৬ মাসের আয়'),
//                     const SizedBox(height: 12),
//                     _IncomeBarChart(monthlyData: _monthlyData, months: _months),

//                     const SizedBox(height: 24),

//                     // Occupancy pie chart
//                     _sectionTitle('রুমের অবস্থা'),
//                     const SizedBox(height: 12),
//                     _OccupancyPieChart(
//                       occupied: _occupiedRooms,
//                       vacant: _totalRooms - _occupiedRooms,
//                     ),

//                     const SizedBox(height: 24),

//                     // Monthly payment status
//                     _sectionTitle('মাসিক পরিশোধের তুলনা'),
//                     const SizedBox(height: 12),
//                     _PaymentComparisonChart(
//                         monthlyData: _monthlyData, months: _months),

//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }

//   Widget _sectionTitle(String title) => Text(
//     title,
//     style: TextStyle(
//       fontSize: 16, fontWeight: FontWeight.bold,
//       color: Theme.of(context).colorScheme.primary,
//     ),
//   );
// }

// class _MonthlyData {
//   final int month;
//   final int year;
//   final double paid;
//   final double pending;
//   _MonthlyData({required this.month, required this.year, required this.paid, required this.pending});
// }

// class _SummaryCard extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final Color color;
//   const _SummaryCard({required this.icon, required this.label, required this.value, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: color.withOpacity(0.25)),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: color, size: 28),
//           const SizedBox(width: 10),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(label, style: TextStyle(fontSize: 12, color: color)),
//               Text(value, style: TextStyle(
//                   fontSize: 18, fontWeight: FontWeight.bold, color: color)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _IncomeBarChart extends StatelessWidget {
//   final List<_MonthlyData> monthlyData;
//   final List<String> months;
//   const _IncomeBarChart({required this.monthlyData, required this.months});

//   @override
//   Widget build(BuildContext context) {
//     final maxY = monthlyData.isEmpty ? 10000.0
//         : monthlyData.map((d) => d.paid + d.pending).reduce((a, b) => a > b ? a : b);
//     final color = Theme.of(context).colorScheme;

//     return Container(
//       height: 220,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color.surface,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: color.outlineVariant),
//       ),
//       child: monthlyData.isEmpty
//           ? const Center(child: Text('ডেটা নেই'))
//           : BarChart(
//               BarChartData(
//                 alignment: BarChartAlignment.spaceAround,
//                 maxY: maxY * 1.2,
//                 barTouchData: BarTouchData(
//                   touchTooltipData: BarTouchTooltipData(
//                     getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                       final d = monthlyData[groupIndex];
//                       return BarTooltipItem(
//                         '${months[d.month]}\n৳${rod.toY.toStringAsFixed(0)}',
//                         const TextStyle(color: Colors.white, fontSize: 12),
//                       );
//                     },
//                   ),
//                 ),
//                 titlesData: FlTitlesData(
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       getTitlesWidget: (value, meta) {
//                         final idx = value.toInt();
//                         if (idx < 0 || idx >= monthlyData.length) return const SizedBox();
//                         return Text(months[monthlyData[idx].month],
//                             style: const TextStyle(fontSize: 10));
//                       },
//                     ),
//                   ),
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 40,
//                       getTitlesWidget: (value, meta) => Text(
//                         '৳${(value / 1000).toStringAsFixed(0)}k',
//                         style: const TextStyle(fontSize: 9),
//                       ),
//                     ),
//                   ),
//                   topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                 ),
//                 gridData: FlGridData(
//                   drawHorizontalLine: true,
//                   horizontalInterval: maxY / 4,
//                   getDrawingHorizontalLine: (_) => FlLine(
//                     color: color.outlineVariant, strokeWidth: 0.5,
//                   ),
//                 ),
//                 borderData: FlBorderData(show: false),
//                 barGroups: List.generate(monthlyData.length, (i) {
//                   final d = monthlyData[i];
//                   return BarChartGroupData(
//                     x: i,
//                     barRods: [
//                       BarChartRodData(
//                         toY: d.paid,
//                         color: color.primary,
//                         width: 16,
//                         borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
//                         rodStackItems: [],
//                       ),
//                     ],
//                   );
//                 }),
//               ),
//             ),
//     );
//   }
// }

// class _OccupancyPieChart extends StatelessWidget {
//   final int occupied;
//   final int vacant;
//   const _OccupancyPieChart({required this.occupied, required this.vacant});

//   @override
//   Widget build(BuildContext context) {
//     final total = occupied + vacant;
//     final color = Theme.of(context).colorScheme;

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color.surface,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: color.outlineVariant),
//       ),
//       child: total == 0
//           ? const Center(child: Padding(
//               padding: EdgeInsets.all(20),
//               child: Text('রুম নেই')))
//           : Row(
//               children: [
//                 SizedBox(
//                   height: 160,
//                   width: 160,
//                   child: PieChart(
//                     PieChartData(
//                       sectionsSpace: 3,
//                       centerSpaceRadius: 40,
//                       sections: [
//                         PieChartSectionData(
//                           value: occupied.toDouble(),
//                           color: color.primary,
//                           title: '$occupied',
//                           titleStyle: const TextStyle(
//                               color: Colors.white, fontWeight: FontWeight.bold),
//                           radius: 50,
//                         ),
//                         PieChartSectionData(
//                           value: vacant.toDouble(),
//                           color: color.surfaceVariant,
//                           title: '$vacant',
//                           titleStyle: TextStyle(
//                               color: color.onSurfaceVariant, fontWeight: FontWeight.bold),
//                           radius: 50,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 24),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _legendItem(color.primary, 'ভাড়া হয়েছে', '$occupied টি'),
//                     const SizedBox(height: 12),
//                     _legendItem(color.surfaceVariant, 'খালি আছে', '$vacant টি'),
//                     const SizedBox(height: 12),
//                     Text('মোট: $total টি রুম',
//                         style: const TextStyle(fontWeight: FontWeight.bold)),
//                     Text(
//                       'Occupancy: ${total > 0 ? (occupied / total * 100).toStringAsFixed(0) : 0}%',
//                       style: TextStyle(color: color.primary, fontWeight: FontWeight.w500),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _legendItem(Color color, String label, String count) {
//     return Row(
//       children: [
//         Container(width: 14, height: 14, decoration: BoxDecoration(
//           color: color, borderRadius: BorderRadius.circular(4),
//         )),
//         const SizedBox(width: 8),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(label, style: const TextStyle(fontSize: 13)),
//             Text(count, style: const TextStyle(fontWeight: FontWeight.bold)),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class _PaymentComparisonChart extends StatelessWidget {
//   final List<_MonthlyData> monthlyData;
//   final List<String> months;
//   const _PaymentComparisonChart({required this.monthlyData, required this.months});

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;
//     final maxY = monthlyData.isEmpty ? 10000.0
//         : monthlyData.map((d) => d.paid + d.pending).reduce((a, b) => a > b ? a : b);

//     return Container(
//       height: 220,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color.surface,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: color.outlineVariant),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               _dot(color.primary), const SizedBox(width: 4),
//               const Text('পরিশোধ', style: TextStyle(fontSize: 12)),
//               const SizedBox(width: 12),
//               _dot(Colors.orange), const SizedBox(width: 4),
//               const Text('বাকি', style: TextStyle(fontSize: 12)),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Expanded(
//             child: monthlyData.isEmpty
//                 ? const Center(child: Text('ডেটা নেই'))
//                 : BarChart(
//                     BarChartData(
//                       alignment: BarChartAlignment.spaceAround,
//                       maxY: maxY * 1.2,
//                       barTouchData: BarTouchData(enabled: false),
//                       titlesData: FlTitlesData(
//                         bottomTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             getTitlesWidget: (value, meta) {
//                               final idx = value.toInt();
//                               if (idx < 0 || idx >= monthlyData.length) return const SizedBox();
//                               return Text(months[monthlyData[idx].month],
//                                   style: const TextStyle(fontSize: 9));
//                             },
//                           ),
//                         ),
//                         leftTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             reservedSize: 36,
//                             getTitlesWidget: (value, meta) => Text(
//                               '${(value / 1000).toStringAsFixed(0)}k',
//                               style: const TextStyle(fontSize: 9),
//                             ),
//                           ),
//                         ),
//                         topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                         rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                       ),
//                       gridData: FlGridData(
//                         drawHorizontalLine: true,
//                         horizontalInterval: maxY / 4,
//                         getDrawingHorizontalLine: (_) => FlLine(
//                           color: color.outlineVariant, strokeWidth: 0.5,
//                         ),
//                       ),
//                       borderData: FlBorderData(show: false),
//                       barGroups: List.generate(monthlyData.length, (i) {
//                         final d = monthlyData[i];
//                         return BarChartGroupData(
//                           x: i,
//                           barsSpace: 4,
//                           barRods: [
//                             BarChartRodData(
//                               toY: d.paid,
//                               color: color.primary,
//                               width: 10,
//                               borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
//                             ),
//                             BarChartRodData(
//                               toY: d.pending,
//                               color: Colors.orange,
//                               width: 10,
//                               borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
//                             ),
//                           ],
//                         );
//                       }),
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _dot(Color color) => Container(
//     width: 10, height: 10,
//     decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//   );
// }






import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../services/auth_service.dart';
import '../../../models/payment_model.dart';
import '../shared/notification_screen.dart';

class ChartScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const ChartScreen({super.key, this.scaffoldKey});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  List<_MonthlyData> _monthlyData = [];
  int _totalTenants = 0;
  int _occupiedRooms = 0;
  int _totalRooms = 0;
  double _thisMonthIncome = 0;
  double _thisMonthPending = 0;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<String> _months = [
    '',
    'জান', 'ফেব', 'মার্চ', 'এপ্রি',
    'মে', 'জুন', 'জুলা', 'আগ', 'সেপ্ট',
    'অক্ট', 'নভে', 'ডিসে',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _loadData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = context.read<AuthService>().currentUser!;
    final db = FirebaseFirestore.instance;
    final now = DateTime.now();

    // Reset counters on reload
    _totalRooms = 0;
    _occupiedRooms = 0;

    // Tenants count
    final tenantsSnap = await db
        .collection('tenants')
        .where('landlordId', isEqualTo: user.uid)
        .where('isActive', isEqualTo: true)
        .get();
    _totalTenants = tenantsSnap.docs.length;

    // Rooms
    final propsSnap = await db
        .collection('properties')
        .where('landlordId', isEqualTo: user.uid)
        .get();
    for (final prop in propsSnap.docs) {
      final roomsSnap = await db
          .collection('rooms')
          .where('propertyId', isEqualTo: prop.id)
          .get();
      _totalRooms += roomsSnap.docs.length;
      _occupiedRooms += roomsSnap.docs
          .where((r) => r.data()['status'] == 'occupied')
          .length;
    }

    // Last 6 months payment data
    final List<_MonthlyData> data = [];
    for (int i = 5; i >= 0; i--) {
      final month = now.month - i <= 0
          ? now.month - i + 12
          : now.month - i;
      final year =
          now.month - i <= 0 ? now.year - 1 : now.year;

      final paySnap = await db
          .collection('payments')
          .where('landlordId', isEqualTo: user.uid)
          .where('month', isEqualTo: month)
          .where('year', isEqualTo: year)
          .get();

      double paid = 0;
      double pending = 0;
      for (final doc in paySnap.docs) {
        final p = PaymentModel.fromMap(doc.data(), doc.id);
        if (p.status == PaymentStatus.paid) {
          paid += p.amount;
        } else {
          pending += p.amount;
        }
      }

      data.add(_MonthlyData(
          month: month, year: year, paid: paid, pending: pending));

      if (month == now.month && year == now.year) {
        _thisMonthIncome = paid;
        _thisMonthPending = pending;
      }
    }

    setState(() {
      _monthlyData = data;
      _loading = false;
    });
    _animController.forward(from: 0);
  }

  // ── Theme helpers ─────────────────────────────────────────
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
    final user = context.read<AuthService>().currentUser!;

    return Scaffold(
      backgroundColor: _bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── SliverAppBar ──────────────────────────────
            SliverAppBar(
              expandedHeight: 180,
              collapsedHeight: 60,
              pinned: true,
              backgroundColor: _bg,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.menu_rounded, color: _textPrimary),
                onPressed: () =>
                    widget.scaffoldKey?.currentState?.openDrawer(),
              ),
              title: Text(
                'রিপোর্ট ও পরিসংখ্যান',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
              actions: [
                NotificationBell(userId: user.uid),
                IconButton(
                  icon: Icon(Icons.refresh_rounded, color: _textPrimary),
                  onPressed: () {
                    setState(() => _loading = true);
                    _loadData();
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeroBg(),
              ),
            ),

            // ── Body ──────────────────────────────────────
            if (_loading)
              SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(color: _primary)),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── এই মাসের সারসংক্ষেপ ──
                    _sectionHeader('📊  এই মাসের সারসংক্ষেপ'),
                    _buildSummaryGrid(),
                    const SizedBox(height: 16),

                    // ── গত ৬ মাসের আয় ──
                    _sectionHeader('📈  গত ৬ মাসের আয়'),
                    _ChartCard(
                      isDark: _isDark,
                      cardBg: _cardBg,
                      child: _IncomeBarChart(
                        monthlyData: _monthlyData,
                        months: _months,
                        primary: _primary,
                        isDark: _isDark,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── রুমের অবস্থা ──
                    _sectionHeader('🚪  রুমের অবস্থা'),
                    _ChartCard(
                      isDark: _isDark,
                      cardBg: _cardBg,
                      child: _OccupancySection(
                        occupied: _occupiedRooms,
                        vacant: _totalRooms - _occupiedRooms,
                        primary: _primary,
                        isDark: _isDark,
                        textPrimary: _textPrimary,
                        textSecondary: _textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── মাসিক পরিশোধের তুলনা ──
                    _sectionHeader('💰  মাসিক পরিশোধের তুলনা'),
                    _ChartCard(
                      isDark: _isDark,
                      cardBg: _cardBg,
                      child: _PaymentComparisonChart(
                        monthlyData: _monthlyData,
                        months: _months,
                        primary: _primary,
                        isDark: _isDark,
                      ),
                    ),
                    const SizedBox(height: 32),
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
                child: const Icon(Icons.bar_chart_rounded,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'রিপোর্ট ও পরিসংখ্যান',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'আয়, ভাড়া ও রুমের বিস্তারিত বিশ্লেষণ',
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

  // ── 2×2 Summary Grid ─────────────────────────────────────
  Widget _buildSummaryGrid() {
    final items = [
      _SummaryItem(
        emoji: '✅',
        label: 'আয় হয়েছে',
        value: '৳${_thisMonthIncome.toStringAsFixed(0)}',
        color: const Color(0xFF059669),
      ),
      _SummaryItem(
        emoji: '⏳',
        label: 'বাকি আছে',
        value: '৳${_thisMonthPending.toStringAsFixed(0)}',
        color: const Color(0xFFD97706),
      ),
      _SummaryItem(
        emoji: '👥',
        label: 'ভাড়াটিয়া',
        value: '$_totalTenants জন',
        color: _primary,
      ),
      _SummaryItem(
        emoji: '🚪',
        label: 'রুম ভাড়া হয়েছে',
        value: '$_occupiedRooms/$_totalRooms',
        color: const Color(0xFF0891B2),
      ),
    ];

    return Container(
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
      child: Column(
        children: [
          // Row 1
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                    child: _summaryCell(items[0], topLeft: true)),
                VerticalDivider(width: 1, color: _divider),
                Expanded(
                    child: _summaryCell(items[1], topRight: true)),
              ],
            ),
          ),
          Divider(height: 1, color: _divider),
          // Row 2
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                    child:
                        _summaryCell(items[2], bottomLeft: true)),
                VerticalDivider(width: 1, color: _divider),
                Expanded(
                    child:
                        _summaryCell(items[3], bottomRight: true)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCell(
    _SummaryItem item, {
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: item.color.withOpacity(_isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: item.color.withOpacity(0.2), width: 1),
            ),
            child: Center(
              child: Text(item.emoji,
                  style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.value,
                  style: TextStyle(
                    color: item.color,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.label,
                  style: TextStyle(
                      color: _textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data Model ────────────────────────────────────────────────

class _MonthlyData {
  final int month;
  final int year;
  final double paid;
  final double pending;
  _MonthlyData({
    required this.month,
    required this.year,
    required this.paid,
    required this.pending,
  });
}

class _SummaryItem {
  final String emoji;
  final String label;
  final String value;
  final Color color;
  _SummaryItem({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });
}

// ── Chart Card Wrapper ────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final Color cardBg;

  const _ChartCard({
    required this.child,
    required this.isDark,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

// ── Income Bar Chart ──────────────────────────────────────────

class _IncomeBarChart extends StatelessWidget {
  final List<_MonthlyData> monthlyData;
  final List<String> months;
  final Color primary;
  final bool isDark;

  const _IncomeBarChart({
    required this.monthlyData,
    required this.months,
    required this.primary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (monthlyData.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('ডেটা নেই')),
      );
    }

    final maxY = monthlyData
        .map((d) => d.paid + d.pending)
        .reduce((a, b) => a > b ? a : b);
    final gridColor =
        isDark ? Colors.white10 : const Color(0xFFE5E7EB);

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (maxY * 1.25).clamp(1000, double.infinity),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) =>
                  isDark ? const Color(0xFF1A3328) : primary,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final d = monthlyData[groupIndex];
                return BarTooltipItem(
                  '${months[d.month]}\n৳${rod.toY.toStringAsFixed(0)}',
                  const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= monthlyData.length)
                    return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      months[monthlyData[idx].month],
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? Colors.white54
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (value, meta) => Text(
                  '৳${(value / 1000).toStringAsFixed(0)}k',
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark
                        ? Colors.white38
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            drawHorizontalLine: true,
            drawVerticalLine: false,
            horizontalInterval:
                (maxY * 1.25).clamp(1000, double.infinity) / 4,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: gridColor, strokeWidth: 0.8),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(monthlyData.length, (i) {
            final d = monthlyData[i];
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: d.paid,
                  gradient: LinearGradient(
                    colors: [primary, primary.withOpacity(0.7)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 18,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ── Occupancy Section ─────────────────────────────────────────

class _OccupancySection extends StatelessWidget {
  final int occupied;
  final int vacant;
  final Color primary;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  const _OccupancySection({
    required this.occupied,
    required this.vacant,
    required this.primary,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final total = occupied + vacant;

    if (total == 0) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('রুম নেই')),
      );
    }

    final occupancyPct =
        total > 0 ? (occupied / total * 100).toStringAsFixed(0) : '0';
    final vacantColor =
        isDark ? Colors.white24 : const Color(0xFFE5E7EB);

    return Row(
      children: [
        // Pie Chart
        SizedBox(
          height: 160,
          width: 160,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 38,
              sections: [
                PieChartSectionData(
                  value: occupied.toDouble(),
                  color: primary,
                  title: '$occupied',
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  radius: 52,
                ),
                PieChartSectionData(
                  value: vacant.toDouble(),
                  color: vacantColor,
                  title: '$vacant',
                  titleStyle: TextStyle(
                    color: textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  radius: 52,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),

        // Legend
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _legendRow(
                color: primary,
                label: 'ভাড়া হয়েছে',
                count: '$occupied টি',
                isDark: isDark,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              const SizedBox(height: 14),
              _legendRow(
                color: vacantColor,
                label: 'খালি আছে',
                count: '$vacant টি',
                isDark: isDark,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: primary.withOpacity(isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: primary.withOpacity(0.2), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'মোট $total টি রুম',
                      style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Occupancy $occupancyPct%',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendRow({
    required Color color,
    required String label,
    required String count,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    TextStyle(fontSize: 12, color: textSecondary)),
            Text(count,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: textPrimary)),
          ],
        ),
      ],
    );
  }
}

// ── Payment Comparison Chart ──────────────────────────────────

class _PaymentComparisonChart extends StatelessWidget {
  final List<_MonthlyData> monthlyData;
  final List<String> months;
  final Color primary;
  final bool isDark;

  const _PaymentComparisonChart({
    required this.monthlyData,
    required this.months,
    required this.primary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (monthlyData.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('ডেটা নেই')),
      );
    }

    final maxY = monthlyData
        .map((d) => d.paid + d.pending)
        .reduce((a, b) => a > b ? a : b);
    final gridColor =
        isDark ? Colors.white10 : const Color(0xFFE5E7EB);
    final labelColor =
        isDark ? Colors.white38 : const Color(0xFF9CA3AF);
    const pendingColor = Color(0xFFD97706);

    return Column(
      children: [
        // Legend
        Row(
          children: [
            _dot(primary),
            const SizedBox(width: 6),
            Text('পরিশোধ',
                style: TextStyle(
                    fontSize: 12,
                    color: primary,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 16),
            _dot(pendingColor),
            const SizedBox(width: 6),
            Text('বাকি',
                style: TextStyle(
                    fontSize: 12,
                    color: pendingColor,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (maxY * 1.25).clamp(1000, double.infinity),
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= monthlyData.length)
                        return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          months[monthlyData[idx].month],
                          style: TextStyle(
                              fontSize: 9, color: labelColor),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) => Text(
                      '${(value / 1000).toStringAsFixed(0)}k',
                      style:
                          TextStyle(fontSize: 9, color: labelColor),
                    ),
                  ),
                ),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                drawHorizontalLine: true,
                drawVerticalLine: false,
                horizontalInterval:
                    (maxY * 1.25).clamp(1000, double.infinity) / 4,
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: gridColor, strokeWidth: 0.8),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(monthlyData.length, (i) {
                final d = monthlyData[i];
                return BarChartGroupData(
                  x: i,
                  barsSpace: 4,
                  barRods: [
                    BarChartRodData(
                      toY: d.paid,
                      gradient: LinearGradient(
                        colors: [primary, primary.withOpacity(0.7)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 10,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4)),
                    ),
                    BarChartRodData(
                      toY: d.pending,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFD97706),
                          Color(0xFFF59E0B)
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 10,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4)),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dot(Color color) => Container(
        width: 10,
        height: 10,
        decoration:
            BoxDecoration(color: color, shape: BoxShape.circle),
      );
}