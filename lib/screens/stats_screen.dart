import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/services/database_service.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _selectedPeriod = 'Bulan Ini';
  String _selectedType = 'Semua';
  String _chartType = 'Bar'; // Bar, Pie

  final List<String> _periods = [
    'Minggu Ini',
    'Bulan Ini',
    '3 Bulan',
    '6 Bulan',
    'Tahun Ini',
  ];

  final List<String> _types = ['Semua', 'Pemasukan', 'Pengeluaran'];

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          "Statistik",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<TransactionModel>>(
        stream: DatabaseService().transactions,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            );
          }

          final transactions = snapshot.data!.where((t) => t.isPaid).toList();
          final filteredData = _filterTransactions(transactions);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                _buildFilters(),
                const SizedBox(height: 20),
                _buildSummaryCards(filteredData, currency),
                const SizedBox(height: 24),
                _buildChartTypeSelector(),
                const SizedBox(height: 16),
                _buildChart(filteredData),
                const SizedBox(height: 24),
                _buildCategoryBreakdown(filteredData, currency),
                const SizedBox(height: 24),
                _buildTopTransactions(filteredData, currency),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  List<TransactionModel> _filterTransactions(
    List<TransactionModel> transactions,
  ) {
    DateTime now = DateTime.now();
    List<TransactionModel> filtered = transactions;

    // Filter by period
    switch (_selectedPeriod) {
      case 'Minggu Ini':
        filtered = transactions
            .where((t) => t.date.isAfter(now.subtract(const Duration(days: 7))))
            .toList();
        break;
      case 'Bulan Ini':
        filtered = transactions
            .where((t) => t.date.month == now.month && t.date.year == now.year)
            .toList();
        break;
      case '3 Bulan':
        filtered = transactions
            .where(
              (t) => t.date.isAfter(now.subtract(const Duration(days: 90))),
            )
            .toList();
        break;
      case '6 Bulan':
        filtered = transactions
            .where(
              (t) => t.date.isAfter(now.subtract(const Duration(days: 180))),
            )
            .toList();
        break;
      case 'Tahun Ini':
        filtered = transactions.where((t) => t.date.year == now.year).toList();
        break;
    }

    // Filter by type
    if (_selectedType == 'Pemasukan') {
      filtered = filtered.where((t) => t.type == 'income').toList();
    } else if (_selectedType == 'Pengeluaran') {
      filtered = filtered.where((t) => t.type == 'expense').toList();
    }

    return filtered;
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdownFilter(
              label: "Periode",
              value: _selectedPeriod,
              items: _periods,
              onChanged: (v) =>
                  setState(() => _selectedPeriod = v ?? _selectedPeriod),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDropdownFilter(
              label: "Tipe",
              value: _selectedType,
              items: _types,
              onChanged: (v) =>
                  setState(() => _selectedType = v ?? _selectedType),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.black87,
            size: 20,
          ),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSummaryCards(
    List<TransactionModel> data,
    NumberFormat currency,
  ) {
    final income = data
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
    final expense = data
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
    final balance = income - expense;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.black, Color(0xFF2D2D2D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Total Saldo",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  currency.format(balance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMiniCard(
                  'Pemasukan',
                  income,
                  currency,
                  Colors.black,
                  Icons.arrow_downward_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMiniCard(
                  'Pengeluaran',
                  expense,
                  currency,
                  const Color(0xFFEF4444),
                  Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard(
    String label,
    double amount,
    NumberFormat currency,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            currency.format(amount),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Text(
            'Grafik',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          _buildChartButton('Bar', Icons.bar_chart_rounded),
          const SizedBox(width: 10),
          _buildChartButton('Pie', Icons.pie_chart_rounded),
        ],
      ),
    );
  }

  Widget _buildChartButton(String type, IconData icon) {
    final isSelected = _chartType == type;
    return GestureDetector(
      onTap: () => setState(() => _chartType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 6),
            Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<TransactionModel> data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tren Transaksi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: _chartType == 'Pie'
                ? _buildPieChart(data)
                : _buildBarChart(data),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<TransactionModel> data) {
    final Map<DateTime, double> incomeMap = {};
    final Map<DateTime, double> expenseMap = {};

    for (var t in data) {
      final date = DateTime(t.date.year, t.date.month, t.date.day);
      if (t.type == 'income') {
        incomeMap[date] = (incomeMap[date] ?? 0) + t.amount;
      } else {
        expenseMap[date] = (expenseMap[date] ?? 0) + t.amount;
      }
    }

    final dates = {...incomeMap.keys, ...expenseMap.keys}.toList()
      ..sort((a, b) => a.compareTo(b));

    if (dates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart_rounded, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'Tidak ada data',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    double maxY = 0;
    final incomeColor = Colors.black;
    final expenseColor = const Color(0xFFEF4444);

    final barGroups = <BarChartGroupData>[];
    for (var i = 0; i < dates.length; i++) {
      final d = dates[i];
      final inc = incomeMap[d] ?? 0;
      final exp = expenseMap[d] ?? 0;
      if (inc > maxY) maxY = inc;
      if (exp > maxY) maxY = exp;

      if (_selectedType == 'Semua') {
        barGroups.add(
          BarChartGroupData(
            x: i,
            barsSpace: 6,
            barRods: [
              BarChartRodData(
                toY: inc,
                color: incomeColor,
                width: 8,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
              BarChartRodData(
                toY: exp,
                color: expenseColor,
                width: 8,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          ),
        );
      } else if (_selectedType == 'Pemasukan') {
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: inc,
                color: incomeColor,
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          ),
        );
      } else {
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: exp,
                color: expenseColor,
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_selectedType == 'Semua')
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: incomeColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('Pemasukan', style: TextStyle(fontSize: 11)),
                  ],
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: expenseColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('Pengeluaran', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY * 1.2,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= dates.length) return const Text('');
                      final date = dates[value.toInt()];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('dd/MM').format(date),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${(value / 1000).toStringAsFixed(0)}k',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: Colors.grey[200]!, strokeWidth: 1);
                },
              ),
              barGroups: barGroups,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart(List<TransactionModel> data) {
    final Map<String, double> incMap = {};
    final Map<String, double> expMap = {};

    for (var t in data) {
      if (t.type == 'income') {
        incMap[t.category] = (incMap[t.category] ?? 0) + t.amount;
      } else {
        expMap[t.category] = (expMap[t.category] ?? 0) + t.amount;
      }
    }

    if (incMap.isEmpty && expMap.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_rounded, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'Tidak ada data',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final incColors = [
      Colors.black,
      const Color(0xFF4B5563),
      const Color(0xFF6B7280),
      const Color(0xFF9CA3AF),
    ];
    final expColors = [
      const Color(0xFFEF4444),
      const Color(0xFFF97316),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
    ];

    final total =
        incMap.values.fold(0.0, (s, v) => s + v) +
        expMap.values.fold(0.0, (s, v) => s + v);

    final sections = <PieChartSectionData>[];
    final legendItems = <Map<String, dynamic>>[];

    var idx = 0;
    incMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..forEach((e) {
        final amt = e.value;
        final perc = total > 0 ? (amt / total * 100) : 0;
        final color = incColors[idx % incColors.length];
        sections.add(
          PieChartSectionData(
            color: color,
            value: amt,
            title: '${perc.toStringAsFixed(0)}%',
            radius: 62,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
        legendItems.add({
          'label': e.key,
          'color': color,
          'type': 'Pemasukan',
          'amount': amt,
        });
        idx++;
      });

    idx = 0;
    expMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..forEach((e) {
        final amt = e.value;
        final perc = total > 0 ? (amt / total * 100) : 0;
        final color = expColors[idx % expColors.length];
        sections.add(
          PieChartSectionData(
            color: color,
            value: amt,
            title: '${perc.toStringAsFixed(0)}%',
            radius: 62,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
        legendItems.add({
          'label': e.key,
          'color': color,
          'type': 'Pengeluaran',
          'amount': amt,
        });
        idx++;
      });

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 48,
                sections: sections,
                pieTouchData: PieTouchData(enabled: false),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 6.0),
            child: Wrap(
              runSpacing: 10,
              spacing: 8,
              children: legendItems.map((it) {
                return SizedBox(
                  width: 160,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: it['color'] as Color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              it['label'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              NumberFormat.currency(
                                locale: 'id_ID',
                                symbol: 'Rp ',
                                decimalDigits: 0,
                              ).format(it['amount']),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(
    List<TransactionModel> data,
    NumberFormat currency,
  ) {
    final Map<String, double> incMap = {};
    final Map<String, double> expMap = {};

    for (var t in data) {
      if (t.type == 'income') {
        incMap[t.category] = (incMap[t.category] ?? 0) + t.amount;
      } else {
        expMap[t.category] = (expMap[t.category] ?? 0) + t.amount;
      }
    }

    if (incMap.isEmpty && expMap.isEmpty) return const SizedBox.shrink();

    Widget _buildSection(
      String title,
      Map<String, double> map,
      Color color,
      double totalType,
    ) {
      final entries = map.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      if (entries.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Text(
                currency.format(totalType),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...entries.take(5).map((entry) {
            final percentage = totalType > 0
                ? (entry.value / totalType * 100)
                : 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        currency.format(entry.value),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      );
    }

    final incTotal = incMap.values.fold(0.0, (s, v) => s + v);
    final expTotal = expMap.values.fold(0.0, (s, v) => s + v);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Breakdown Kategori',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedType == 'Semua') ...[
            _buildSection('Pemasukan', incMap, Colors.black, incTotal),
            const SizedBox(height: 18),
            _buildSection(
              'Pengeluaran',
              expMap,
              const Color(0xFFEF4444),
              expTotal,
            ),
          ] else ...[
            if (_selectedType == 'Pemasukan')
              _buildSection('Pemasukan', incMap, Colors.black, incTotal),
            if (_selectedType == 'Pengeluaran')
              _buildSection(
                'Pengeluaran',
                expMap,
                const Color(0xFFEF4444),
                expTotal,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTopTransactions(
    List<TransactionModel> data,
    NumberFormat currency,
  ) {
    final sortedData = data.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    if (sortedData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top 5 Transaksi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          ...sortedData.take(5).map((transaction) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[200]!, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: transaction.type == 'income'
                          ? Colors.black.withOpacity(0.05)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      transaction.type == 'income'
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: transaction.type == 'income'
                          ? Colors.black
                          : const Color(0xFFEF4444),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                transaction.category,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('dd MMM').format(transaction.date),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currency.format(transaction.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: transaction.type == 'income'
                          ? Colors.black
                          : const Color(0xFFEF4444),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
