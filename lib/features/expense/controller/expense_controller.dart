import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split_mate/core/utils.dart';
import 'package:split_mate/features/expense/repository/expense_repository.dart';
import 'package:split_mate/models/expense_model.dart';

final expenseControllerProvider = StateNotifierProvider<ExpenseController, bool>(
  (ref) => ExpenseController(expenseRepository: ref.watch(expenseRepositoryProvider)),
);

final userExpensesProvider = StreamProvider.family<List<ExpenseModel>, String>(
  (ref, userId) => ref.watch(expenseRepositoryProvider).fetchExpenses(userId),
);

class ExpenseController extends StateNotifier<bool> {
  final ExpenseRepository _expenseRepository;

  ExpenseController({required ExpenseRepository expenseRepository})
      : _expenseRepository = expenseRepository,
        super(false);

  Future<void> createExpense(
    BuildContext context,
    ExpenseModel expenseModel,
  ) async {
    state = true;
    final result = await _expenseRepository.createExpense(expenseModel);
    state = false;

    result.fold(
      (failure) => showSnackBar(context, failure.message),
      (_) {
        showSnackBar(context, 'Expense added successfully!');
        Navigator.of(context).pop(); // Navigate back to the previous screen
      },
    );
  }

  Future<void> updateExpense(
    BuildContext context,
    String expenseId,
    double newAmount,
  ) async {
    state = true;
    final result = await _expenseRepository.updateExpenseAmount(expenseId, newAmount);
    state = false;

    result.fold(
      (failure) => showSnackBar(context, failure.message),
      (_) {
        showSnackBar(context, 'Expense updated successfully!');
      },
    );
  }
}
