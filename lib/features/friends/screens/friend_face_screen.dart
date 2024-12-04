import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:split_mate/features/expense/screens/add_expense_screen.dart';
import 'package:split_mate/features/friends/screens/friends_settings.dart';
import 'package:split_mate/models/expense_model.dart';
import 'package:split_mate/models/user_model.dart';

class FriendFaceScreen extends StatefulWidget {
  final String friendId;
  final String name;
  final String profilePic;
  final String email;
  final UserModel? preSelectedUser;

  FriendFaceScreen({
    required this.friendId,
    required this.name,
    required this.profilePic,
    required this.email,
    this.preSelectedUser,
  });

  @override
  _FriendFaceScreenState createState() => _FriendFaceScreenState();
  
  //void onSelectionChanged(List<UserModel> splitWithList) {}
}

class _FriendFaceScreenState extends State<FriendFaceScreen> {
  List<ExpenseModel> pastExpenses = [];
  List<String> balances = []; // Store balance texts from SplitScreen

  @override
  void initState() {
    super.initState();
    _fetchPastExpenses();
  }

  Future<void> _fetchPastExpenses() async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('expenses')
          .where('paidBy', isEqualTo: currentUserId)
          .get();

      List<ExpenseModel> expenses = snapshot.docs.map((doc) {
        return ExpenseModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      setState(() {
        pastExpenses = expenses.where((expense) {
          return expense.splitWith.any((user) => user.uid == widget.friendId);
        }).toList();
      });
    } catch (e) {
      print('Error fetching past expenses: $e');
      setState(() {
        pastExpenses = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FriendsSettingsScreen(
                    friendId: widget.friendId,
                    name: widget.name,
                    profilePic: widget.profilePic,
                    email: widget.email, // Pass email if available
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(widget.profilePic),
                  ),
                  SizedBox(width: 12),
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Divider(),

            // Buttons Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Add functionality for Settle Up
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(
                      'Settle Up',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Add functionality for Generate Report
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(
                      'Generate Report',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            //Divider(),
            const SizedBox(
              height: 20,
            ),
            // Balances Section
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Balances',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  balances.isEmpty
                      ? Text(
                          'No pending balances',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600]),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: balances.map((balance) {
                            return Text(
                              balance,
                              style: TextStyle(fontSize: 16),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
            // Divider(),

            // Expenses Section
            // pastExpenses.isEmpty
            //     ? Center(
            //         child: Padding(
            //           padding: const EdgeInsets.all(16.0),
            //           child: Text('No past expenses found with ${widget.name}'),
            //         ),
            //       )
            //     : ListView.builder(
            //         physics: NeverScrollableScrollPhysics(),
            //         shrinkWrap: true,
            //         itemCount: pastExpenses.length,
            //         itemBuilder: (context, index) {
            //           ExpenseModel expense = pastExpenses[index];
            //           return ListTile(
            //             title: Text(expense.description),
            //             subtitle:
            //                 Text('Amount: \$${expense.amount.toStringAsFixed(2)}'),
            //             trailing: Text(expense.date.toLocal().toString()),
            //             onTap: () {
            //               // Optional: Add more details or actions on tap
            //             },
            //           );
            //         },
            //       ),
          ],
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          // Navigate to AddExpenseScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddExpenseScreen(
                mode: 'friend_face',
                selectedEntity: widget.name,
      //           onSelectionChanged: (List<UserModel> splitWithList) {
      //   widget.onSelectionChanged(splitWithList); // Pass the list back to the parent
      // },

              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.blue, // Set button background color
          onPrimary: Colors.white, // Set text color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40), // Rounded corners
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 22, vertical: 15), // Padding for the button
        ),
        child: const Text(
          'Add Expense',
          style: TextStyle(
            fontSize: 16, // Font size for the button text
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
