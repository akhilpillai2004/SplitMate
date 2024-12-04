import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
//import 'package:split_mate/features/expense/screens/split_screen.dart';
import 'package:split_mate/models/expense_model.dart';
import 'package:split_mate/models/group_model.dart';
import 'package:split_mate/models/user_model.dart';
import 'package:split_mate/features/expense/screens/who_paid_screen.dart';
import 'package:split_mate/features/expense/screens/adjust_split_screen.dart';

class AddExpenseScreen extends StatefulWidget {
  final String mode; // Modes: 'group', 'friend', 'friend_face', 'group_face'
  final dynamic selectedEntity; // Can be a group or friend object
  final Function(List<UserModel>)? onSelectionChanged;

  const AddExpenseScreen({required this.mode, this.selectedEntity, this.onSelectionChanged, Key? key})
      : super(key: key);

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  String? selectedEntityName;
  TextEditingController searchController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool showSearchAndList = true;

  List<UserModel> userEntityList = [];
  List<GroupModel> groupEntityList = [];
  List<UserModel> filteredUserList = [];
  List<GroupModel> filteredGroupList = [];

  String paidByText = 'You'; // Default text for the "Paid by" button
  //static const splitButtonText = 'Equally'; // Constant text for "Split" button
  String selectedOption = 'You paid, split equally';

  @override
  void initState() {
    super.initState();
    if (widget.mode == 'group' || widget.mode == 'group_face') {
      _fetchGroups();
    }
    if (widget.mode == 'friend' || widget.mode == 'friend_face') {
      _fetchFriends();
    }

    if (widget.mode == 'friend_face' || widget.mode == 'group_face') {
      selectedEntityName = widget.selectedEntity;
      showSearchAndList = false;
    }
  }

  void _fetchGroups() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('groups').get();
      List<GroupModel> groups = querySnapshot.docs
          .map((doc) => GroupModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      setState(() {
        groupEntityList = groups;
        filteredGroupList = List.from(groupEntityList);
      });
    } catch (e) {
      print("Error fetching groups: $e");
    }
  }

  void _fetchFriends() async {
    try {
      String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (uid.isEmpty) throw Exception("User is not logged in.");

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!userDoc.exists) throw Exception("User document not found.");

      UserModel currentUser =
          UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      List<String> friendUids = currentUser.friendsList;

      if (friendUids.isEmpty) {
        setState(() {
          userEntityList = [];
          filteredUserList = [];
        });
        return;
      }

      List<UserModel> friends = [];
      for (String friendUid in friendUids) {
        DocumentSnapshot friendDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(friendUid)
            .get();
        if (friendDoc.exists) {
          friends
              .add(UserModel.fromMap(friendDoc.data() as Map<String, dynamic>));
        }
      }

      setState(() {
        userEntityList = friends;
        filteredUserList = List.from(userEntityList);
      });
    } catch (e) {
      print("Error fetching friends: $e");
    }
  }

  Future<String> _getCurrentUserName() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId != null) {
      // Reference to the current user's document in Firestore
      final currentUserRef =
          FirebaseFirestore.instance.collection('users').doc(currentUserId);
      final doc = await currentUserRef.get();

      if (doc.exists) {
        // Extract the name field from the document
        return doc.data()?['name'] ??
            'Unknown'; // Return 'Unknown' if the name is not found
      }
    }

    return 'Unknown'; // Return 'Unknown' if the current user ID is null
  }

  void filterEntityList(String query) {
    if (widget.mode == 'group') {
      setState(() {
        filteredGroupList = groupEntityList
            .where((group) =>
                group.groupName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    } else if (widget.mode == 'friend') {
      setState(() {
        if (query.isEmpty) {
          filteredUserList = List.from(userEntityList);
        } else {
          filteredUserList = userEntityList
              .where((user) =>
                  user.name.toLowerCase().contains(query.toLowerCase()) ||
                  user.email.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }
      });
    }
  }

  void handleSelection(String entityName) {
    setState(() {
      selectedEntityName = entityName;
      showSearchAndList = false;
    });
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: widget.mode == 'group' ? 'Search groups' : 'Search Friends',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        onChanged: filterEntityList,
      ),
    );
  }

  Widget buildEntityList(List<dynamic> entities) {
    return Expanded(
      child: ListView.builder(
        itemCount: entities.length,
        itemBuilder: (context, index) {
          var entity = entities[index];
          return ListTile(
            title: Text(entity is GroupModel
                ? entity.groupName
                : (entity as UserModel).name),
            onTap: () => handleSelection(
                entity is GroupModel ? entity.groupName : entity.name),
          );
        },
      ),
    );
  }

  Widget buildForm() {
    return Column(
      children: [
        Text(
          'With you and: ${selectedEntityName ?? 'No entity selected'}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: descriptionController,
          decoration: const InputDecoration(
              labelText: 'Description', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: amountController,
          decoration: const InputDecoration(
              labelText: 'Amount', border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              setState(() {
                selectedDate = pickedDate;
              });
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.date_range, size: 20),
              const SizedBox(width: 8),
              Text(
                'Pick a date (${DateFormat.yMd().format(selectedDate)})',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        //if (widget.mode == 'group' ||
        //  widget.mode == 'group_face' || widget.mode == 'friend' || widget.mode == 'friend_face') // Check for 'group' mode
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Paid by'),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WhoPaidScreen(
                      mode: (widget.mode == 'group' ||
                              widget.mode == 'group_face')
                          ? 'group'
                          : (widget.mode == 'friend' ||
                                  widget.mode == 'friend_face')
                              ? 'friend'
                              : 'unknown',
                      name: selectedEntityName,
                      onSelectionChanged: (selectedName) {
                        setState(() {
                          paidByText = selectedName;
                        });
                      },
                    ),
                  ),
                );
              },
              child: Text(paidByText),
              style: ElevatedButton.styleFrom(
                //primary: Colors.green,
                //onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              ),
            ),
            Text('and split'),
            ElevatedButton(
              onPressed: () {
                if (selectedEntityName != null &&
                    descriptionController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  double amount = double.parse(amountController.text);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdjustSplitScreen(
                        mode: (widget.mode == 'group' ||
                              widget.mode == 'group_face')
                          ? 'group'
                          : (widget.mode == 'friend' ||
                                  widget.mode == 'friend_face')
                              ? 'friend'
                              : 'unknown',
                        amount: amount,
                        name: selectedEntityName,
                       // onSelectionChanged: (List<UserModel> splitWithList) {
       // widget.onSelectionChanged!(splitWithList); // Pass the list back to the parent
     // },
                      ),
                    ),
                  );
                }
              },
              child: const Text('Equally'),
              style: ElevatedButton.styleFrom(
                //primary: Colors.green,
                //onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              ),
            ),
          ],
        )
        
      ],
    );
  }

  // void _updateSelection(List<UserModel> selectedUsers) {
  //   widget.onSelectionChanged!(selectedUsers); // Notify the parent screen
  // }

  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () async {
              if (descriptionController.text.isNotEmpty &&
                  amountController.text.isNotEmpty &&
                  selectedEntityName != null) {
                try {
                  // Create a new ExpenseModel instance
                  double amount = double.parse(amountController.text);
                  String description = descriptionController.text;
                  DateTime date = selectedDate;
                  String paidBy = paidByText;

                  // Prepare splitWith list (example, modify as needed)
                  //List<dynamic> jsonList = jsonDecode(selectedEntityName);
                  List<UserModel> splitWithList = [];
                  //List<UserModel> splitWithList = [];

                  ExpenseModel newExpense = ExpenseModel(
                    expenseId: FirebaseFirestore.instance
                        .collection('expenses')
                        .doc()
                        .id,
                    groupId: null,
                    description: description,
                    amount: amount,
                    date: date,
                    paidBy: paidBy,
                    splitWith: splitWithList, // Populate with actual data
                    timestamp: DateTime.now(),
                    splitType: "Equally", // Modify as needed
                  );

                  // Save the expense to the Firestore database
                  await FirebaseFirestore.instance
                      .collection('expenses')
                      .doc(newExpense.expenseId)
                      .set(newExpense.toMap());

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Expense added successfully')),
                  );

                  // Optionally navigate back or reset form fields after saving
                  Navigator.pop(context);
                } catch (e) {
                  print("Error adding expense: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to add expense')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: showSearchAndList
            ? Column(
                children: [
                  buildSearchBar(),
                  widget.mode == 'group'
                      ? buildEntityList(filteredGroupList)
                      : buildEntityList(filteredUserList),
                ],
              )
            : buildForm(),
      ),
    );
  }
}









// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:split_mate/models/expense_model.dart';
// import 'package:split_mate/models/group_model.dart';
// import 'package:split_mate/models/user_model.dart';
// import 'package:split_mate/features/expense/screens/who_paid_screen.dart';
// import 'package:split_mate/features/expense/screens/adjust_split_screen.dart';

// class AddExpenseScreen extends StatefulWidget {
//   final String mode; // Modes: 'group', 'friend', 'friend_face', 'group_face'
//   final dynamic selectedEntity; // Can be a group or friend object

//   const AddExpenseScreen({required this.mode, this.selectedEntity, Key? key})
//       : super(key: key);

//   @override
//   _AddExpenseScreenState createState() => _AddExpenseScreenState();
// }

// class _AddExpenseScreenState extends State<AddExpenseScreen> {
//   String? selectedEntityName;
//   TextEditingController searchController = TextEditingController();
//   TextEditingController descriptionController = TextEditingController();
//   TextEditingController amountController = TextEditingController();
//   DateTime selectedDate = DateTime.now();
//   bool showSearchAndList = true;

//   List<UserModel> userEntityList = [];
//   List<GroupModel> groupEntityList = [];
//   List<UserModel> filteredUserList = [];
//   List<GroupModel> filteredGroupList = [];

//   String paidByText = 'You'; // Default text for the "Paid by" button
//   String selectedOption = 'You paid, split equally';

//   @override
//   void initState() {
//     super.initState();
//     if (widget.mode == 'group' || widget.mode == 'group_face') {
//       _fetchGroups();
//     }
//     if (widget.mode == 'friend' || widget.mode == 'friend_face') {
//       _fetchFriends();
//     }

//     if (widget.mode == 'friend_face' || widget.mode == 'group_face') {
//       selectedEntityName = widget.selectedEntity;
//       showSearchAndList = false;
//     }
//   }

//   void _fetchGroups() async {
//     try {
//       QuerySnapshot querySnapshot =
//           await FirebaseFirestore.instance.collection('groups').get();
//       List<GroupModel> groups = querySnapshot.docs
//           .map((doc) => GroupModel.fromMap(doc.data() as Map<String, dynamic>))
//           .toList();

//       setState(() {
//         groupEntityList = groups;
//         filteredGroupList = List.from(groupEntityList);
//       });
//     } catch (e) {
//       print("Error fetching groups: $e");
//     }
//   }

//   void _fetchFriends() async {
//     try {
//       String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
//       if (uid.isEmpty) throw Exception("User is not logged in.");

//       DocumentSnapshot userDoc =
//           await FirebaseFirestore.instance.collection('users').doc(uid).get();
//       if (!userDoc.exists) throw Exception("User document not found.");

//       UserModel currentUser =
//           UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
//       List<String> friendUids = currentUser.friendsList;

//       if (friendUids.isEmpty) {
//         setState(() {
//           userEntityList = [];
//           filteredUserList = [];
//         });
//         return;
//       }

//       List<UserModel> friends = [];
//       for (String friendUid in friendUids) {
//         DocumentSnapshot friendDoc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(friendUid)
//             .get();
//         if (friendDoc.exists) {
//           friends.add(UserModel.fromMap(friendDoc.data() as Map<String, dynamic>));
//         }
//       }

//       setState(() {
//         userEntityList = friends;
//         filteredUserList = List.from(userEntityList);
//       });
//     } catch (e) {
//       print("Error fetching friends: $e");
//     }
//   }

//   Future<String> _getCurrentUserName() async {
//     final currentUserId = FirebaseAuth.instance.currentUser?.uid;

//     if (currentUserId != null) {
//       final currentUserRef =
//           FirebaseFirestore.instance.collection('users').doc(currentUserId);
//       final doc = await currentUserRef.get();

//       if (doc.exists) {
//         return doc.data()?['name'] ?? 'Unknown';
//       }
//     }

//     return 'Unknown';
//   }

//   void filterEntityList(String query) {
//     if (widget.mode == 'group') {
//       setState(() {
//         filteredGroupList = groupEntityList
//             .where((group) => group.groupName.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//       });
//     } else if (widget.mode == 'friend') {
//       setState(() {
//         if (query.isEmpty) {
//           filteredUserList = List.from(userEntityList);
//         } else {
//           filteredUserList = userEntityList
//               .where((user) =>
//                   user.name.toLowerCase().contains(query.toLowerCase()) ||
//                   user.email.toLowerCase().contains(query.toLowerCase()))
//               .toList();
//         }
//       });
//     }
//   }

//   void handleSelection(String entityName) {
//     setState(() {
//       selectedEntityName = entityName;
//       showSearchAndList = false;
//     });
//   }

//   Widget buildSearchBar() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: TextField(
//         controller: searchController,
//         decoration: InputDecoration(
//           hintText: widget.mode == 'group' ? 'Search groups' : 'Search Friends',
//           prefixIcon: const Icon(Icons.search),
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
//         ),
//         onChanged: filterEntityList,
//       ),
//     );
//   }

//   Widget buildEntityList(List<dynamic> entities) {
//     return Expanded(
//       child: ListView.builder(
//         itemCount: entities.length,
//         itemBuilder: (context, index) {
//           var entity = entities[index];
//           return ListTile(
//             title: Text(entity is GroupModel
//                 ? entity.groupName
//                 : (entity as UserModel).name),
//             onTap: () => handleSelection(
//                 entity is GroupModel ? entity.groupName : entity.name),
//           );
//         },
//       ),
//     );
//   }

//   Widget buildForm() {
//     return Column(
//       children: [
//         Text(
//           'With you and: ${selectedEntityName ?? 'No entity selected'}',
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 16),
//         TextField(
//           controller: descriptionController,
//           decoration: const InputDecoration(
//               labelText: 'Description', border: OutlineInputBorder()),
//         ),
//         const SizedBox(height: 16),
//         TextField(
//           controller: amountController,
//           decoration: const InputDecoration(
//               labelText: 'Amount', border: OutlineInputBorder()),
//           keyboardType: TextInputType.number,
//         ),
//         const SizedBox(height: 16),
//         TextButton(
//           onPressed: () async {
//             DateTime? pickedDate = await showDatePicker(
//               context: context,
//               initialDate: selectedDate,
//               firstDate: DateTime(2000),
//               lastDate: DateTime(2100),
//             );
//             if (pickedDate != null) {
//               setState(() {
//                 selectedDate = pickedDate;
//               });
//             }
//           },
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.date_range, size: 20),
//               const SizedBox(width: 8),
//               Text(
//                 'Pick a date (${DateFormat.yMd().format(selectedDate)})',
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             Text('Paid by'),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => WhoPaidScreen(
//                       mode: (widget.mode == 'group' || widget.mode == 'group_face')
//                           ? 'group'
//                           : (widget.mode == 'friend' || widget.mode == 'friend_face')
//                               ? 'friend'
//                               : 'unknown',
//                       name: selectedEntityName,
//                       onSelectionChanged: (selectedName) {
//                         setState(() {
//                           paidByText = selectedName;
//                         });
//                       },
//                     ),
//                   ),
//                 );
//               },
//               child: Text(paidByText),
//               style: ElevatedButton.styleFrom(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
//               ),
//             ),
//             Text('and split'),
//             ElevatedButton(
//               onPressed: () {
//                 if (selectedEntityName != null &&
//                     descriptionController.text.isNotEmpty &&
//                     amountController.text.isNotEmpty) {
//                   double amount = double.parse(amountController.text);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => AdjustSplitScreen(
//                         mode: (widget.mode == 'group' || widget.mode == 'group_face')
//                             ? 'group'
//                             : (widget.mode == 'friend' || widget.mode == 'friend_face')
//                                 ? 'friend'
//                                 : 'unknown',
//                         amount: amount,
//                         name: selectedEntityName,
//                         onSelectionChanged: (selectedName) {
//                           setState(() {
//                             // Handle any needed update after selection change
//                           });
//                         },
//                       ),
//                     ),
//                   );
//                 }
//               },
//               child: const Text('Split'),
//               style: ElevatedButton.styleFrom(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add Expense'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             buildSearchBar(),
//             showSearchAndList
//                 ? (widget.mode == 'group'
//                     ? buildEntityList(filteredGroupList)
//                     : widget.mode == 'friend'
//                         ? buildEntityList(filteredUserList)
//                         : Container())
//                 : buildForm(),
//           ],
//         ),
//       ),
//     );
//   }
// }




// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:split_mate/features/expense/screens/split_screen.dart';
// import 'package:split_mate/models/expense_model.dart';
// import 'package:split_mate/models/group_model.dart';
// import 'package:split_mate/models/user_model.dart';
// import 'package:split_mate/features/expense/screens/who_paid_screen.dart';
// import 'package:split_mate/features/expense/screens/adjust_split_screen.dart';

// class AddExpenseScreen extends StatefulWidget {
//   final String mode; // Modes: 'group', 'friend', 'friend_face', 'group_face'
//   final dynamic selectedEntity; // Can be a group or friend object

//   const AddExpenseScreen({required this.mode, this.selectedEntity, Key? key})
//       : super(key: key);

//   @override
//   _AddExpenseScreenState createState() => _AddExpenseScreenState();
// }

// class _AddExpenseScreenState extends State<AddExpenseScreen> {
//   String? selectedEntityName;
//   TextEditingController searchController = TextEditingController();
//   TextEditingController descriptionController = TextEditingController();
//   TextEditingController amountController = TextEditingController();
//   DateTime selectedDate = DateTime.now();
//   bool showSearchAndList = true;

//   List<UserModel> userEntityList = [];
//   List<GroupModel> groupEntityList = [];
//   List<UserModel> filteredUserList = [];
//   List<GroupModel> filteredGroupList = [];

//   String paidByText = 'You'; // Default text for the "Paid by" button
//   String selectedOption = 'You paid, split equally';
//   String paidByUid = '';

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }

//   void _initializeData() {
//     if (widget.mode.contains('group')) {
//       _fetchGroups();
//     } else if (widget.mode.contains('friend')) {
//       _fetchFriends();
//     }

//     if (widget.mode.contains('face')) {
//       selectedEntityName = widget.selectedEntity;
//       showSearchAndList = false;
//     }
//   }

//   void handleSelection(String entityName) {
//     setState(() {
//       selectedEntityName = entityName;
//       showSearchAndList = false;
//     });
//   }

//   void _fetchGroups() async {
//     try {
//       final querySnapshot =
//           await FirebaseFirestore.instance.collection('groups').get();
//       final groups = querySnapshot.docs
//           .map((doc) => GroupModel.fromMap(doc.data() as Map<String, dynamic>))
//           .toList();

//       setState(() {
//         groupEntityList = groups;
//         filteredGroupList = List.from(groupEntityList);
//       });
//     } catch (e) {
//       _showErrorMessage("Error fetching groups: $e");
//     }
//   }

//   void _fetchFriends() async {
//     try {
//       final uid = FirebaseAuth.instance.currentUser?.uid;
//       if (uid == null) throw Exception("User not logged in.");

//       final userDoc =
//           await FirebaseFirestore.instance.collection('users').doc(uid).get();
//       if (!userDoc.exists) throw Exception("User document not found.");

//       final currentUser =
//           UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
//       final friends =
//           await Future.wait(currentUser.friendsList.map((friendUid) async {
//         final friendDoc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(friendUid)
//             .get();
//         return friendDoc.exists
//             ? UserModel.fromMap(friendDoc.data() as Map<String, dynamic>)
//             : null;
//       }));

//       setState(() {
//         userEntityList = friends.whereType<UserModel>().toList();
//         filteredUserList = List.from(userEntityList);
//       });
//     } catch (e) {
//       _showErrorMessage("Error fetching friends: $e");
//     }
//   }

//   void filterEntityList(String query) {
//     if (widget.mode == 'group') {
//       setState(() {
//         filteredGroupList = groupEntityList
//             .where((group) =>
//                 group.groupName.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//       });
//     } else if (widget.mode == 'friend') {
//       setState(() {
//         if (query.isEmpty) {
//           filteredUserList = List.from(userEntityList);
//         } else {
//           filteredUserList = userEntityList
//               .where((user) =>
//                   user.name.toLowerCase().contains(query.toLowerCase()) ||
//                   user.email.toLowerCase().contains(query.toLowerCase()))
//               .toList();
//         }
//       });
//     }
//   }

//   void _showErrorMessage(String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(message)));
//   }

//   void _saveExpense() async {
//     if (descriptionController.text.isEmpty ||
//         amountController.text.isEmpty ||
//         selectedEntityName == null) {
//       _showErrorMessage("Please fill all fields.");
//       return;
//     }

//     try {
//       final amount = double.tryParse(amountController.text);
//       if (amount == null) throw Exception("Invalid amount entered.");

//       final expense = ExpenseModel(
//         expenseId: FirebaseFirestore.instance.collection('expenses').doc().id,
//         groupId: null,
//         description: descriptionController.text,
//         amount: amount,
//         date: selectedDate,
//         paidBy: paidByText,
//         splitWith: [],
//         timestamp: DateTime.now(),
//         splitType: "Equally",
//       );

//       await FirebaseFirestore.instance
//           .collection('expenses')
//           .doc(expense.expenseId)
//           .set(expense.toMap());

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Expense added successfully.")),
//       );

//       Navigator.pop(context);
//     } catch (e) {
//       _showErrorMessage("Failed to add expense: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Add Expense')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (showSearchAndList) buildSearchBar(),
//             if (showSearchAndList)
//               buildEntityList(widget.mode.contains('group')
//                   ? filteredGroupList
//                   : filteredUserList),
//             if (!showSearchAndList) buildForm(),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _saveExpense,
//         child: const Icon(Icons.check),
//       ),
//     );
//   }

//   Widget buildSearchBar() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: TextField(
//         controller: searchController,
//         decoration: InputDecoration(
//           hintText: widget.mode == 'group' ? 'Search groups' : 'Search Friends',
//           prefixIcon: const Icon(Icons.search),
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
//         ),
//         onChanged: filterEntityList,
//       ),
//     );
//   }

//   Widget buildEntityList(List<dynamic> entities) {
//     return Expanded(
//       child: ListView.builder(
//         itemCount: entities.length,
//         itemBuilder: (context, index) {
//           var entity = entities[index];
//           return ListTile(
//             title: Text(entity is GroupModel
//                 ? entity.groupName
//                 : (entity as UserModel).name),
//             onTap: () => handleSelection(
//                 entity is GroupModel ? entity.groupName : entity.name),
//           );
//         },
//       ),
//     );
//   }

//   Widget buildForm() {
//     return Column(
//       children: [
//         Text(
//           'With you and: ${selectedEntityName ?? 'No entity selected'}',
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 16),
//         TextField(
//           controller: descriptionController,
//           decoration: const InputDecoration(
//               labelText: 'Description', border: OutlineInputBorder()),
//         ),
//         const SizedBox(height: 16),
//         TextField(
//           controller: amountController,
//           decoration: const InputDecoration(
//               labelText: 'Amount', border: OutlineInputBorder()),
//           keyboardType: TextInputType.number,
//         ),
//         const SizedBox(height: 16),
//         TextButton(
//           onPressed: () async {
//             DateTime? pickedDate = await showDatePicker(
//               context: context,
//               initialDate: selectedDate,
//               firstDate: DateTime(2000),
//               lastDate: DateTime(2100),
//             );
//             if (pickedDate != null) {
//               setState(() {
//                 selectedDate = pickedDate;
//               });
//             }
//           },
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.date_range, size: 20),
//               const SizedBox(width: 8),
//               Text(
//                 'Pick a date (${DateFormat.yMd().format(selectedDate)})',
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//         if (widget.mode == 'group' ||
//             widget.mode == 'group_face') // Check for 'group' mode
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               Text('Paid by'),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => WhoPaidScreen(
//                         groupName: selectedEntityName,
//                         onSelectionChanged: (selectedName) {
//                           setState(() {
//                             paidByText = selectedName;
//                           });
//                         },
//                       ),
//                     ),
//                   );
//                 },
//                 child: Text(paidByText),
//                 style: ElevatedButton.styleFrom(
//                   //primary: Colors.green,
//                   //onPrimary: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
//                 ),
//               ),
//               Text('and split'),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => AdjustSplitScreen(
//                         groupName: selectedEntityName,
//                         onSelectionChanged: (selectedName) {
//                           // setState(() {
//                           //   //paidByText = selectedName;
//                           // });
//                         },
//                       ),
//                     ),
//                   );
//                 },
//                 child: const Text('Equally'),
//                 style: ElevatedButton.styleFrom(
//                   //primary: Colors.green,
//                   //onPrimary: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
//                 ),
//               ),
//             ],
//           )
//         else if (widget.mode == 'friend' ||
//             widget.mode == 'friend_face') // Check for 'friend' mode
//           ElevatedButton(
//             onPressed: () async {
//               if (selectedEntityName != null &&
//                   descriptionController.text.isNotEmpty &&
//                   amountController.text.isNotEmpty) {
//                 double amount = double.parse(amountController.text);
//                 // Navigate to split_screen.dart, passing the required data
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => SplitScreen(
//                       onOptionSelected: (selectedData) {
//                         // Extract the selected option and paidByUid from the map
//                         String selectedOption = selectedData['option'];
//                         String paidByUid = selectedData['paidByUid'];

//                         // Use these values as needed in your state or logic
//                         setState(() {
//                           this.selectedOption =
//                               selectedOption; // Assuming this is part of your state
//                           this.paidByUid =
//                               paidByUid; // Save the paidByUid for further use
//                         });
//                       },
//                       friendName: selectedEntityName,
//                       amount: amount,
//                     ),
//                   ),
//                 );
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Please fill all fields')),
//                 );
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               primary: Colors.green,
//               onPrimary: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
//             ),
//             child: Text(
//               selectedOption, // Display the current selected option
//               style: const TextStyle(fontSize: 16),
//             ),
//           ),
//       ],
//     );
//   }
// }
