import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/sales/presentation/providers/sales_provider.dart';
import 'package:frontend/features/sales/data/models/sale_model.dart';

class PosStatsChart extends ConsumerStatefulWidget {
  const PosStatsChart({super.key});
  @override
  ConsumerState<PosStatsChart> createState() => _PosStatsChartState();
}

class _PosStatsChartState extends ConsumerState<PosStatsChart> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  final List<String> _months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  // Group sales by day for selected month/year
  Map<int, Map<String, double>> _buildDailyTotals(List<SaleModel> sales) {
    final Map<int, Map<String, double>> daily = {};
    for (final sale in sales) {
      try {
        final d = DateTime.parse(sale.saleDate);
        if (d.month == _selectedMonth && d.year == _selectedYear) {
          final day = d.day;
          daily.putIfAbsent(day, () => {'sale': 0, 'paid': 0, 'due': 0});
          daily[day]!['sale'] = (daily[day]!['sale'] ?? 0) + sale.netTotal;
          daily[day]!['paid'] = (daily[day]!['paid'] ?? 0) + sale.paidAmount;
          daily[day]!['due']  = (daily[day]!['due']  ?? 0) + sale.pendingAmount;
        }
      } catch (_) {}
    }
    return daily;
  }

  List<FlSpot> _spotsForKey(Map<int, Map<String, double>> daily, String key) {
    final days = daily.keys.toList()..sort();
    if (days.isEmpty) return [const FlSpot(1, 0)];
    return days.map((d) => FlSpot(d.toDouble(), daily[d]![key] ?? 0)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final salesState = ref.watch(salesListProvider);
    final sales = salesState.value ?? [];
    final daily = _buildDailyTotals(sales);

    final saleSpots  = _spotsForKey(daily, 'sale');
    final paidSpots  = _spotsForKey(daily, 'paid');
    final dueSpots   = _spotsForKey(daily, 'due');

    final lines = [
      {'label': 'Total Sale',         'color': const Color(0xFF3b82f6), 'spots': saleSpots},
      {'label': 'Total Sale Payment', 'color': const Color(0xFF22c55e), 'spots': paidSpots},
      {'label': 'Total Sale Due',     'color': const Color(0xFFef4444), 'spots': dueSpots},
    ];

    // Max Y for chart scaling
    double maxY = 1000;
    for (final l in lines) {
      for (final s in l['spots'] as List<FlSpot>) {
        if (s.y > maxY) maxY = s.y;
      }
    }
    maxY = (maxY * 1.2).ceilToDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('POS Stats (Live)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.tableText)),
              const Spacer(),
              if (salesState.isLoading) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              const SizedBox(width: 8),
              _dropdown(_months[_selectedMonth - 1], _months, (v) => setState(() => _selectedMonth = _months.indexOf(v!) + 1)),
              const SizedBox(width: 8),
              _dropdown(_selectedYear.toString(), ['2024','2025','2026'], (v) => setState(() => _selectedYear = int.parse(v!))),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            daily.isEmpty
                ? 'No sales data for ${_months[_selectedMonth - 1]} $_selectedYear'
                : '${daily.length} active day(s) with sales',
            style: const TextStyle(fontSize: 11, color: AppColors.tableSubText),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: isMobile ? 200 : 280,
            child: LineChart(
              LineChartData(
                maxY: maxY,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    axisNameWidget: const Text('Amount', style: TextStyle(fontSize: 10, color: AppColors.tableSubText)),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 70,
                      getTitlesWidget: (v, _) => Text(
                        v >= 1000000 ? 'Rs ${(v / 1000000).toStringAsFixed(1)}M'
                            : v >= 1000 ? 'Rs ${(v / 1000).toStringAsFixed(0)}K'
                            : 'Rs ${v.toInt()}',
                        style: const TextStyle(fontSize: 9, color: AppColors.tableSubText),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameWidget: const Text('Day', style: TextStyle(fontSize: 10, color: AppColors.tableSubText)),
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 9, color: AppColors.tableSubText)),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((s) {
                      final label = lines[s.barIndex]['label'] as String;
                      return LineTooltipItem(
                        'Day ${s.x.toInt()}\n$label\nRs ${s.y.toStringAsFixed(0)}',
                        TextStyle(color: lines[s.barIndex]['color'] as Color, fontSize: 11, fontWeight: FontWeight.w600),
                      );
                    }).toList(),
                  ),
                ),
                lineBarsData: List.generate(lines.length, (i) => LineChartBarData(
                  spots: lines[i]['spots'] as List<FlSpot>,
                  isCurved: true,
                  color: lines[i]['color'] as Color,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (s, _, __, ___) => FlDotCirclePainter(
                      radius: 3,
                      color: lines[i]['color'] as Color,
                      strokeWidth: 1,
                      strokeColor: Colors.white,
                    ),
                  ),
                  belowBarData: BarAreaData(show: false),
                )),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: lines.map((l) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 12, height: 3, color: l['color'] as Color),
                const SizedBox(width: 4),
                Text(l['label'] as String, style: const TextStyle(fontSize: 10, color: AppColors.tableSubText)),
              ],
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _dropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(border: Border.all(color: AppColors.cardBorder), borderRadius: BorderRadius.circular(6)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 14),
          style: const TextStyle(fontSize: 12, color: AppColors.tableText),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
