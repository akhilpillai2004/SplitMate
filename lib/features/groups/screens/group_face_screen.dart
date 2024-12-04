import 'package:flutter/material.dart';
import 'package:split_mate/features/expense/screens/add_expense_screen.dart';
import 'package:split_mate/models/group_model.dart';
import 'package:split_mate/features/groups/screens/group_settings.dart'; // Import the new screen
//import 'package:split_mate/models/user_model.dart'; // Ensure this import is included

class GroupFaceScreen extends StatelessWidget {
  final GroupModel group;
  final GroupModel? preSelectedGroup; // Added parameter for pre-selected user/group

  const GroupFaceScreen({
    Key? key,
    required this.group,
    this.preSelectedGroup, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        //title: Text(group.groupName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupSettingsScreen(group: group),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(group.groupIcon),
                  radius: 30, // Adjusted size to match style
                ),
                const SizedBox(width: 12), // Spacing adjusted for consistency
                Expanded(
                  child: Text(
                    group.groupName,
                    style: const TextStyle(
                      fontSize: 21, // Adjusted font size for consistency
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(
              color: Colors.grey,
              height: 32,
              thickness: 1,
            ),
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
                    child: const Text(
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
                    child: const Text(
                      'Generate Report',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
           // Divider(),
           const SizedBox(height: 20,),
           Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Balances',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                          'No pending balances',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        )
                  
                ],
              ),
            ),

            
          ],
        ),
      ),
      // Add this FloatingActionButton at the bottom of the `Scaffold`
      floatingActionButton: ElevatedButton(
        onPressed: () {
          // Navigate to AddExpenseScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddExpenseScreen(
                mode: 'group_face',
                selectedEntity: group.groupName,
                //onSelectionChanged: (selectedName) => print('Selected: $selectedName'),

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
