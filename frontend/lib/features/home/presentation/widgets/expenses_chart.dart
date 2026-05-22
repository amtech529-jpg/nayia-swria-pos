import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/core/constants/app_colors.dart';

class ExpensesChart extends StatefulWidget {
  const ExpensesChart({super.key});
  @override
  State<ExpensesChart> createState() => _ExpensesChartState();
}

class _ExpensesChartState extends State<ExpensesChart> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  final List<String> _months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  // All zeros until expenses module is implemented
  List<BarChartGroupData> get _bars => List.generate(
    DateTime(
      _selectedYear,
      _selectedMonth + 1,
      0,
    ).day,
    (i) => BarChartGroupData(
      x: i + 1,
      barRods: [BarChartRodData(
        toY: 0,
        color: const Color(0xFF6366f1),
        width: 8,
        borderRadius: BorderRadius.circular(3),
      )],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
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
              const Text('Expenses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.tableText)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFfef3c7), borderRadius: BorderRadius.circular(8)),
                child: const Text('Coming Soon', style: TextStyle(fontSize: 10, color: Color(0xFFd97706), fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              _ddl(_months[_selectedMonth - 1], _months, (v) => setState(() => _selectedMonth = _months.indexOf(v!) + 1)),
              const SizedBox(width: 8),
              _ddl(_selectedYear.toString(), ['2024','2025','2026'], (v) => setState(() => _selectedYear = int.parse(v!))),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Expenses module data will appear here once expenses are recorded.',
            style: TextStyle(fontSize: 11, color: AppColors.tableSubText),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: isMobile ? 160 : 220,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    axisNameWidget: const RotatedBox(quarterTurns: 3, child: Text('Amount', style: TextStyle(fontSize: 10, color: AppColors.tableSubText))),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (v, _) => Text('Rs ${v.toInt()}', style: const TextStyle(fontSize: 8, color: AppColors.tableSubText)),
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
                maxY: 1000,
                barGroups: _bars,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                      'Day ${group.x}\nRs ${rod.toY.toStringAsFixed(0)}',
                      const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ddl(String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(border: Border.all(color: AppColors.cardBorder), borderRadius: BorderRadius.circular(6)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 14),
          style: const TextStyle(fontSize: 12, color: AppColors.tableText),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
