import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/services/database_service.dart';
import 'package:money_manager/screens/transaction_form.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = "";
  String _activeFilter = "Semua";
  String _typeFilter = "Semua Tipe";
  String _categoryFilter = "Semua Kategori";

  final List<String> _timeFilters = [
    "Semua",
    "Hari Ini",
    "Minggu Ini",
    "Bulan Ini",
    "Tahun Ini",
  ];

  final List<String> _typeFilters = ["Semua Tipe", "Pemasukan", "Pengeluaran"];

  List<String> _getAllCategories(List<TransactionModel> transactions) {
    final categories = transactions
        .where((t) => t.isPaid)
        .map((t) => t.category)
        .toSet()
        .toList();
    categories.sort();
    return ["Semua Kategori", ...categories];
  }

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
          "Riwayat Transaksi",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
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

          final allCategories = _getAllCategories(snapshot.data!);

          return Column(
            children: [
              // Search Bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: "Cari transaksi...",
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.grey[400],
                      size: 22,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              // Filter Section
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time Filter (Horizontal Chips)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _timeFilters.map((f) {
                          bool isSel = _activeFilter == f;
                          return GestureDetector(
                            onTap: () => setState(() => _activeFilter = f),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? Colors.black
                                    : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isSel
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                f,
                                style: TextStyle(
                                  color: isSel
                                      ? Colors.white
                                      : Colors.grey[700],
                                  fontSize: 13,
                                  fontWeight: isSel
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Dropdown Filters Row
                    Row(
                      children: [
                        // Type Filter Dropdown
                        Expanded(
                          child: _buildDropdownFilter(
                            value: _typeFilter,
                            items: _typeFilters,
                            onChanged: (v) =>
                                setState(() => _typeFilter = v ?? _typeFilter),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Category Filter Dropdown
                        Expanded(
                          child: _buildDropdownFilter(
                            value: _categoryFilter,
                            items: allCategories,
                            onChanged: (v) => setState(
                              () => _categoryFilter = v ?? _categoryFilter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Expanded(child: _buildTransactionList(snapshot.data!, currency)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
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
            fontWeight: FontWeight.w500,
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

  Widget _buildTransactionList(
    List<TransactionModel> transactions,
    NumberFormat currency,
  ) {
    var list = transactions.where((t) => t.isPaid).toList();
    DateTime now = DateTime.now();

    // Logic Filter Time
    if (_activeFilter == "Hari Ini") {
      list = list
          .where(
            (t) =>
                t.date.day == now.day &&
                t.date.month == now.month &&
                t.date.year == now.year,
          )
          .toList();
    } else if (_activeFilter == "Minggu Ini") {
      list = list
          .where((t) => t.date.isAfter(now.subtract(const Duration(days: 7))))
          .toList();
    } else if (_activeFilter == "Bulan Ini") {
      list = list
          .where((t) => t.date.month == now.month && t.date.year == now.year)
          .toList();
    } else if (_activeFilter == "Tahun Ini") {
      list = list.where((t) => t.date.year == now.year).toList();
    }

    // Logic Filter Type
    if (_typeFilter == "Pemasukan") {
      list = list.where((t) => t.type == 'income').toList();
    } else if (_typeFilter == "Pengeluaran") {
      list = list.where((t) => t.type == 'expense').toList();
    }

    // Logic Filter Category
    if (_categoryFilter != "Semua Kategori") {
      list = list.where((t) => t.category == _categoryFilter).toList();
    }

    // Logic Search
    list = list
        .where(
          (t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    // Sort by date descending
    list.sort((a, b) => b.date.compareTo(a.date));

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "Data tidak ditemukan",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Coba ubah filter atau pencarian",
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    // Group transactions by date
    Map<String, List<TransactionModel>> groupedTransactions = {};
    for (var transaction in list) {
      String dateKey = DateFormat('yyyy-MM-dd').format(transaction.date);
      if (!groupedTransactions.containsKey(dateKey)) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(transaction);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        String dateKey = groupedTransactions.keys.elementAt(index);
        List<TransactionModel> dayTransactions = groupedTransactions[dateKey]!;
        DateTime date = DateTime.parse(dateKey);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Separator
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
              child: Text(
                _formatDateSeparator(date),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),

            // Transactions for this day
            ...dayTransactions.map((t) => _buildTransactionCard(t, currency)),

            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  String _formatDateSeparator(DateTime date) {
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(const Duration(days: 1));

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return "Hari Ini";
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return "Kemarin";
    } else {
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    }
  }

  Widget _buildTransactionCard(TransactionModel t, NumberFormat currency) {
    return GestureDetector(
      onTap: () => _showDetail(context, t, currency),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: t.type == 'income'
                    ? Colors.black.withOpacity(0.05)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                t.type == 'income'
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: t.type == 'income'
                    ? Colors.black
                    : const Color(0xFFEF4444),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('HH:mm').format(t.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            t.category,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  t.type == 'income'
                      ? currency.format(t.amount)
                      : '- ${currency.format(t.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: t.type == 'income'
                        ? Colors.black
                        : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(
    BuildContext context,
    TransactionModel t,
    NumberFormat currency,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              "Detail Transaksi",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 28),

            // Transaction Details
            _rowDetail("Nama", t.title),
            _rowDetail(
              "Jumlah",
              t.type == 'income'
                  ? currency.format(t.amount)
                  : '- ${currency.format(t.amount)}',
              isAmount: true,
              isExpense: t.type == 'expense',
            ),
            _rowDetail("Kategori", t.category),
            _rowDetail(
              "Tipe",
              t.type == 'income' ? 'Pemasukan' : 'Pengeluaran',
            ),
            _rowDetail(
              "Tanggal",
              DateFormat('dd MMMM yyyy, HH:mm').format(t.date),
            ),
            _rowDetail(
              "Deskripsi",
              t.description.isEmpty ? "-" : t.description,
            ),
            const SizedBox(height: 28),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (c) => TransactionForm(transaction: t),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.edit_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          "Edit",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      _confirmDelete(context, t);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.delete_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          "Hapus",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, TransactionModel t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Hapus Transaksi?",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          "Apakah Anda yakin ingin menghapus transaksi '${t.title}'? Tindakan ini tidak dapat dibatalkan.",
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Batal",
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              DatabaseService().deleteTransaction(t.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail sheet
            },
            child: const Text(
              "Hapus",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowDetail(
    String label,
    String value, {
    bool isAmount = false,
    bool isExpense = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isAmount && isExpense
                    ? const Color(0xFFEF4444)
                    : Colors.black,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}
