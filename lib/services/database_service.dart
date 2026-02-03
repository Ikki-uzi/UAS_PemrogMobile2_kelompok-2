import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // Stream data transaksi (Realtime)
  Stream<List<TransactionModel>> get transactions {
    return _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Tambah Transaksi
  Future<void> addTransaction(TransactionModel transaction) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc(transaction.id)
        .set(transaction.toMap());
  }

  // Hapus Transaksi
  Future<void> deleteTransaction(String id) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc(id)
        .delete();
  }
}
