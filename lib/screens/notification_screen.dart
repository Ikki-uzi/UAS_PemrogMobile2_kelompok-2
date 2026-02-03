import 'package:flutter/material.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/services/database_service.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Notifikasi",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<List<TransactionModel>>(
        stream: DatabaseService().transactions,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          // Filter tagihan H-1 atau Hari H yang belum lunas
          final now = DateTime.now();
          final notifications = snapshot.data!.where((t) {
            if (t.isPaid || t.type != 'bill') return false;
            final diff = t.date.difference(now).inDays;
            return diff <= 1; // H-1 atau sudah lewat
          }).toList();

          if (notifications.isEmpty) {
            return Center(
              child: Text(
                "Tidak ada notifikasi baru",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index];
              bool isOverdue = n.date.isBefore(now);

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isOverdue ? Colors.red[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isOverdue ? Colors.red : Colors.orange,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: isOverdue ? Colors.red : Colors.orange,
                      size: 28,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pengingat Tagihan: ${n.title}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isOverdue
                                  ? Colors.red[900]
                                  : Colors.orange[900],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isOverdue
                                ? "Sudah melewati jatuh tempo!"
                                : "Besok saatnya membayar tagihan ini.",
                            style: TextStyle(
                              fontSize: 13,
                              color: isOverdue
                                  ? Colors.red[800]
                                  : Colors.orange[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
