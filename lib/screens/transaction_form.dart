import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/services/database_service.dart';
import 'package:uuid/uuid.dart';

class TransactionForm extends StatefulWidget {
  final TransactionModel? transaction;
  final bool isPayingBill;
  const TransactionForm({
    super.key,
    this.transaction,
    this.isPayingBill = false,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  String _type = 'expense';
  String _selectedCategory = 'Makanan';
  DateTime _selectedDate = DateTime.now();

  // (DATA KATEGORI TETAP SAMA SEPERTI KODE ASLI)
  final Map<String, List<String>> _categories = {
    'expense': [
      'Makanan',
      'Belanja',
      'Transportasi',
      'Hiburan',
      'Kesehatan',
      'Pendidikan',
      'Rumah Tangga',
      'Pakaian',
      'Olahraga',
      'Listrik',
      'Air',
      'Internet',
      'Sewa',
      'Cicilan',
      'Asuransi',
      'Telepon',
      'TV Kabel',
      'Langganan',
      'Lainnya',
    ],
    'income': [
      'Gaji',
      'Bonus',
      'Hadiah',
      'Investasi',
      'Penjualan',
      'Freelance',
      'Bisnis',
      'Lainnya',
    ],
    'bill': [
      'Listrik',
      'Air',
      'Internet',
      'Sewa',
      'Cicilan',
      'Asuransi',
      'Telepon',
      'TV Kabel',
      'Langganan',
      'Lainnya',
    ],
  };

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toInt().toString();
      _descController.text = widget.transaction!.description;
      _type = widget.isPayingBill ? 'expense' : widget.transaction!.type;

      final currentCategory = widget.transaction!.category;
      if (_categories[_type]!.contains(currentCategory)) {
        _selectedCategory = currentCategory;
      } else {
        _selectedCategory = _categories[_type]![0];
      }

      _selectedDate = widget.isPayingBill
          ? DateTime.now()
          : widget.transaction!.date;
    } else {
      _selectedCategory = _categories[_type]![0];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menghitung tinggi keyboard agar form naik ke atas
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      padding: EdgeInsets.only(
        top: 10,
        left: 0,
        right: 0,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar (Garis kecil di atas)
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 20),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      widget.isPayingBill ? "Bayar Tagihan" : "Transaksi Baru",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1F36),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  if (!widget.isPayingBill) ...[
                    _buildTypeSelector(),
                    const SizedBox(height: 25),
                  ],

                  const Text(
                    "Judul",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildField(
                    _titleController,
                    "Cth: Makan Siang",
                    Icons.edit_outlined,
                  ),

                  const SizedBox(height: 15),
                  const Text(
                    "Nominal",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildRupiahField(),

                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Kategori",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildCategoryDropdown(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Tanggal",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildDatePicker(context),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                  const Text(
                    "Catatan (Opsional)",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildField(
                    _descController,
                    "Tambahkan keterangan...",
                    Icons.notes_rounded,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1F36),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 60),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      widget.isPayingBill
                          ? "Konfirmasi Pembayaran"
                          : "Simpan Transaksi",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: ['expense', 'income', 'bill'].map((t) {
          final isSelected = _type == t;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _type = t;
                _selectedCategory = _categories[t]![0];
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    t == 'expense'
                        ? 'Keluar'
                        : t == 'income'
                        ? 'Masuk'
                        : 'Tagihan',
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      cursorColor: Colors.black,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontWeight: FontWeight.normal,
        ),
        prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
        ),
      ),
    );
  }

  // Widget khusus untuk field Rupiah dengan prefix "Rp"
  Widget _buildRupiahField() {
    return TextField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      cursorColor: Colors.black,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: "0",
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontWeight: FontWeight.normal,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 20, right: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Rp",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey,
          ),
          dropdownColor: Colors.white, // Dropdown tetap putih di dark mode
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          items: _categories[_type]!
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(
                    c,
                    style: const TextStyle(
                      color: Colors.black87, // Teks item tetap hitam
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedCategory = v!),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: widget.isPayingBill
          ? null
          : () async {
              DateTime? p = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF1A1F36),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (p != null) setState(() => _selectedDate = p);
            },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: Colors.grey,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                DateFormat('dd MMM').format(_selectedDate),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() async {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi judul dan nominal'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final tx = TransactionModel(
      id: widget.transaction?.id ?? const Uuid().v4(),
      title: _titleController.text,
      amount: double.parse(_amountController.text),
      date: _selectedDate,
      category: _selectedCategory,
      type: widget.isPayingBill ? 'expense' : _type,
      isPaid: widget.isPayingBill ? true : (_type == 'bill' ? false : true),
      description: _descController.text,
    );

    await DatabaseService().addTransaction(tx);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                widget.isPayingBill ? 'Tagihan Lunas!' : 'Data tersimpan',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1A1F36),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );
    }
  }
}
