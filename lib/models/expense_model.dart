import 'package:split_mate/models/user_model.dart';

class ExpenseModel {
  final String expenseId;
  final String? groupId;
  final String description;
  final double amount;
  final DateTime date;
  final String paidBy;
  final List<UserModel> splitWith;
  final bool isSettled;
  final double? pendingAmount;
  final DateTime timestamp;
  final String splitType; // e.g., "Equally", "Unequally", "Percentage-based"
  //final Map<String, double>? splitDetails;

  ExpenseModel({
    required this.expenseId,
    this.groupId,
    required this.description,
    required this.amount,
    required this.date,
    required this.paidBy,
    required this.splitWith,
    this.isSettled = false,
    this.pendingAmount,
    required this.timestamp,
    this.splitType = "Equally",
    //this.splitDetails,
  });

  Map<String, dynamic> toMap() {
    return {
      'expenseId': expenseId,
      'groupId': groupId,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'paidBy': paidBy,
      'splitWith': splitWith.map((user) => user.toMap()).toList(),
      'isSettled': isSettled,
      'pendingAmount': pendingAmount,
      'timestamp': timestamp.toIso8601String(),
      'splitType': splitType,
      //'splitDetails': splitDetails,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      expenseId: map['expenseId'] ?? '',
      groupId: map['groupId'] ?? '',
      description: map['description'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      paidBy: map['paidBy'] ?? '',
      splitWith: (map['splitWith'] as List<dynamic>? ?? [])
        .map((item) => UserModel.fromMap(
          item is Map<String, dynamic> 
            ? item 
            : {}
        ))
        .toList(),
      isSettled: map['isSettled'] ?? false,
      pendingAmount: (map['pendingAmount'] ?? 0.0).toDouble(),
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      splitType: map['splitType'] ?? 'Equally',
      //splitDetails: Map<String, double>.from(map['splitDetails'] ?? {}),
    );
  }
}
