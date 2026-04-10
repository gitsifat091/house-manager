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

class _ChartScreenState extends State<ChartScreen> {
  bool _loading = true;
  List<_MonthlyData> _monthlyData = [];
  int _totalTenants = 0;
  int _occupiedRooms = 0;
  int _totalRooms = 0;
  double _thisMonthIncome = 0;
  double _thisMonthPending = 0;

  final List<String> _months = [
    '', 'জান', 'ফেব', 'মার্চ', 'এপ্রি',
    'মে', 'জুন', 'জুলা', 'আগ', 'সেপ্ট',
    'অক্ট', 'নভে', 'ডিসে'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = context.read<AuthService>().currentUser!;
    final db = FirebaseFirestore.instance;
    final now = DateTime.now();

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
      final year = now.month - i <= 0 ? now.year - 1 : now.year;

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

      data.add(_MonthlyData(month: month, year: year, paid: paid, pending: pending));

      if (month == now.month && year == now.year) {
        _thisMonthIncome = paid;
        _thisMonthPending = pending;
      }
    }

    setState(() {
      _monthlyData = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser!;
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => widget.scaffoldKey?.currentState?.openDrawer(),
        ),
        title: const Text('রিপোর্ট ও পরিসংখ্যান'),
        centerTitle: true,
        actions: [
          NotificationBell(userId: user.uid),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() => _loading = true);
              _loadData();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                setState(() => _loading = true);
                await _loadData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary cards
                    _sectionTitle('এই মাসের সারসংক্ষেপ'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _SummaryCard(
                          icon: Icons.check_circle_rounded,
                          label: 'আয় হয়েছে',
                          value: '৳${_thisMonthIncome.toStringAsFixed(0)}',
                          color: Colors.green,
                        )),
                        const SizedBox(width: 10),
                        Expanded(child: _SummaryCard(
                          icon: Icons.pending_rounded,
                          label: 'বাকি আছে',
                          value: '৳${_thisMonthPending.toStringAsFixed(0)}',
                          color: Colors.orange,
                        )),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _SummaryCard(
                          icon: Icons.people_rounded,
                          label: 'ভাড়াটিয়া',
                          value: '$_totalTenants জন',
                          color: color.primary,
                        )),
                        const SizedBox(width: 10),
                        Expanded(child: _SummaryCard(
                          icon: Icons.door_front_door_rounded,
                          label: 'রুম ভাড়া হয়েছে',
                          value: '$_occupiedRooms/$_totalRooms',
                          color: Colors.blue,
                        )),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Bar chart - monthly income
                    _sectionTitle('গত ৬ মাসের আয়'),
                    const SizedBox(height: 12),
                    _IncomeBarChart(monthlyData: _monthlyData, months: _months),

                    const SizedBox(height: 24),

                    // Occupancy pie chart
                    _sectionTitle('রুমের অবস্থা'),
                    const SizedBox(height: 12),
                    _OccupancyPieChart(
                      occupied: _occupiedRooms,
                      vacant: _totalRooms - _occupiedRooms,
                    ),

                    const SizedBox(height: 24),

                    // Monthly payment status
                    _sectionTitle('মাসিক পরিশোধের তুলনা'),
                    const SizedBox(height: 12),
                    _PaymentComparisonChart(
                        monthlyData: _monthlyData, months: _months),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
    ),
  );
}

class _MonthlyData {
  final int month;
  final int year;
  final double paid;
  final double pending;
  _MonthlyData({required this.month, required this.year, required this.paid, required this.pending});
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _SummaryCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: color)),
              Text(value, style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

class _IncomeBarChart extends StatelessWidget {
  final List<_MonthlyData> monthlyData;
  final List<String> months;
  const _IncomeBarChart({required this.monthlyData, required this.months});

  @override
  Widget build(BuildContext context) {
    final maxY = monthlyData.isEmpty ? 10000.0
        : monthlyData.map((d) => d.paid + d.pending).reduce((a, b) => a > b ? a : b);
    final color = Theme.of(context).colorScheme;

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.outlineVariant),
      ),
      child: monthlyData.isEmpty
          ? const Center(child: Text('ডেটা নেই'))
          : BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final d = monthlyData[groupIndex];
                      return BarTooltipItem(
                        '${months[d.month]}\n৳${rod.toY.toStringAsFixed(0)}',
                        const TextStyle(color: Colors.white, fontSize: 12),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= monthlyData.length) return const SizedBox();
                        return Text(months[monthlyData[idx].month],
                            style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        '৳${(value / 1000).toStringAsFixed(0)}k',
                        style: const TextStyle(fontSize: 9),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  drawHorizontalLine: true,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: color.outlineVariant, strokeWidth: 0.5,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(monthlyData.length, (i) {
                  final d = monthlyData[i];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: d.paid,
                        color: color.primary,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        rodStackItems: [],
                      ),
                    ],
                  );
                }),
              ),
            ),
    );
  }
}

class _OccupancyPieChart extends StatelessWidget {
  final int occupied;
  final int vacant;
  const _OccupancyPieChart({required this.occupied, required this.vacant});

  @override
  Widget build(BuildContext context) {
    final total = occupied + vacant;
    final color = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.outlineVariant),
      ),
      child: total == 0
          ? const Center(child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('রুম নেই')))
          : Row(
              children: [
                SizedBox(
                  height: 160,
                  width: 160,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          value: occupied.toDouble(),
                          color: color.primary,
                          title: '$occupied',
                          titleStyle: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                          radius: 50,
                        ),
                        PieChartSectionData(
                          value: vacant.toDouble(),
                          color: color.surfaceVariant,
                          title: '$vacant',
                          titleStyle: TextStyle(
                              color: color.onSurfaceVariant, fontWeight: FontWeight.bold),
                          radius: 50,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _legendItem(color.primary, 'ভাড়া হয়েছে', '$occupied টি'),
                    const SizedBox(height: 12),
                    _legendItem(color.surfaceVariant, 'খালি আছে', '$vacant টি'),
                    const SizedBox(height: 12),
                    Text('মোট: $total টি রুম',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      'Occupancy: ${total > 0 ? (occupied / total * 100).toStringAsFixed(0) : 0}%',
                      style: TextStyle(color: color.primary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _legendItem(Color color, String label, String count) {
    return Row(
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(4),
        )),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 13)),
            Text(count, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

class _PaymentComparisonChart extends StatelessWidget {
  final List<_MonthlyData> monthlyData;
  final List<String> months;
  const _PaymentComparisonChart({required this.monthlyData, required this.months});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final maxY = monthlyData.isEmpty ? 10000.0
        : monthlyData.map((d) => d.paid + d.pending).reduce((a, b) => a > b ? a : b);

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _dot(color.primary), const SizedBox(width: 4),
              const Text('পরিশোধ', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 12),
              _dot(Colors.orange), const SizedBox(width: 4),
              const Text('বাকি', style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: monthlyData.isEmpty
                ? const Center(child: Text('ডেটা নেই'))
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY * 1.2,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= monthlyData.length) return const SizedBox();
                              return Text(months[monthlyData[idx].month],
                                  style: const TextStyle(fontSize: 9));
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            getTitlesWidget: (value, meta) => Text(
                              '${(value / 1000).toStringAsFixed(0)}k',
                              style: const TextStyle(fontSize: 9),
                            ),
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        drawHorizontalLine: true,
                        horizontalInterval: maxY / 4,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: color.outlineVariant, strokeWidth: 0.5,
                        ),
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
                              color: color.primary,
                              width: 10,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                            BarChartRodData(
                              toY: d.pending,
                              color: Colors.orange,
                              width: 10,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(
    width: 10, height: 10,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}