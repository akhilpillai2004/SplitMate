import 'package:flutter/material.dart';
import 'package:split_mate/features/home/screens/friends_screen.dart';
import 'package:split_mate/features/home/screens/groups_screen.dart';
import 'package:split_mate/features/home/screens/account_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Set default selected index for the BottomNavigationBar
  int _selectedIndex = 1;

  // Handle the BottomNavigationBar click event
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Define a list of pages for each navigation tab
  final List<Widget> _pages = [
    const GroupsScreen(),
    const FriendsScreen(),
    const ActivityScreen(),
    const AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.white,
        automaticallyImplyLeading: false,
        //title: const Text('Home Screen'),
        centerTitle: true,
        elevation: 3.0,
        actions: [
          // Search icon on the right side of the app bar
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Add search functionality here
            },
          ),
          // Add new contact icon on the right side of the app bar
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              // Add new contact functionality here
            },
          ),
        ],
        // elevation: 0, // Remove shadow
        // bottom: PreferredSize(
        //   preferredSize: const Size.fromHeight(1.0), // Thin line height
        //   child: Container(
        //     color: Colors.black, // Black color for the line
        //     height: 0.3, // Line thickness
        //   ),
        // ),
      ),
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green, // Green color for selected item
        unselectedItemColor: Colors.grey, // Grey color for unselected items
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Friends',
            
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notes),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

// Dummy Pages for the bottom navigation
// class GroupsScreen extends StatelessWidget {
//   const GroupsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text('Groups Screen'),
//     );
//   }
// }

// class FriendsScreen extends StatelessWidget {
//   const FriendsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text('Friends Screen'),
//     );
//   }
// }

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Activity Screen'),
    );
  }
}

// class AccountScreen extends StatelessWidget {
//   const AccountScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text('Account Screen'),
//     );
//   }
// }
