import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:split_mate/core/constants/firebase_constants.dart';
import 'package:split_mate/core/failure.dart';
import 'package:split_mate/core/providers/firebase_providers.dart';
import 'package:split_mate/core/type_defs.dart';
import 'package:split_mate/models/expense_model.dart';

final expenseRepositoryProvider = Provider((ref) {
  return ExpenseRepository(firestore: ref.read(firestoreProvider));
});

class ExpenseRepository {
  final FirebaseFirestore _firestore;

  ExpenseRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _expenses =>
      _firestore.collection(FirebaseConstants.expensesCollection);

  FutureEither<void> createExpense(ExpenseModel expenseModel) async {
    try {
      await _expenses.doc(expenseModel.expenseId).set(expenseModel.toMap());
      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? 'Firebase error occurred.'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<ExpenseModel>> fetchExpenses(String userId) {
    return _expenses
        .where('splitWith', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpenseModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  FutureEither<void> updateExpenseAmount(String expenseId, double newAmount) async {
    try {
      await _expenses.doc(expenseId).update({'amount': newAmount});
      return right(null);
    } catch (e) {
      return left(Failure('Failed to update expense amount: $e'));
    }
  }
}
