import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split_mate/core/constants/constants.dart';
import 'package:split_mate/features/expense/screens/add_expense_screen.dart';
import 'package:split_mate/models/group_model.dart';
import 'package:split_mate/core/providers/firebase_providers.dart';
import 'package:split_mate/features/groups/screens/create_groups.dart';
import 'package:split_mate/features/groups/screens/group_face_screen.dart';
import 'package:split_mate/core/failure.dart';

class GroupsNotifier extends StateNotifier<List<GroupModel>> {
  final Ref ref;

  GroupsNotifier(this.ref) : super([]) {
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final currentUser = ref.watch(authProvider).currentUser;
    if (currentUser == null) {
      throw Failure('User is not logged in');
    }
    final currentUserId = currentUser.uid;

    try {
      final groupsSnapshot = await ref
          .watch(firestoreProvider)
          .collection('groups')
          .where('members', arrayContains: currentUserId)
          .get();

      state = groupsSnapshot.docs.map((doc) {
        return GroupModel.fromMap({
          'groupId': doc.id,
          'groupName': doc['groupName'],
          'groupIcon': doc['groupIcon'] ?? Constants.avatarDefault,
          'creatorId': doc['creatorId'],
          'members': List<String>.from(doc['members']),
          'totalBalance': doc['totalBalance']?.toDouble() ?? 0.0,
        });
      }).toList();
    } catch (e) {
      throw Failure('Failed to load groups: $e');
    }
  }
}

final groupsProvider =
    StateNotifierProvider<GroupsNotifier, List<GroupModel>>((ref) {
  return GroupsNotifier(ref);
});

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
      ),
      body: Column(
        children: [
          Expanded(
            child: groups.isEmpty
                ? Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateGroupsScreen(),
                          ),
                        ).then((_) =>
                            ref.read(groupsProvider.notifier)._loadGroups());
                      },
                      icon: const Icon(Icons.group_add, color: Colors.white),
                      label: const Text(
                        'Create New Group',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(170, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: groups.length + 1, // Add one for the button
                    itemBuilder: (context, index) {
                      if (index < groups.length) {
                        final group = groups[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(group.groupIcon),
                              radius: 30,
                            ),
                            title: Text(
                              group.groupName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text('Members: ${group.members.length}'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GroupFaceScreen(
                                    group: group,
                                    preSelectedGroup: group,
                                  ),
                                ),
                              ).then((_) => ref
                                  .read(groupsProvider.notifier)
                                  ._loadGroups());
                            },
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CreateGroupsScreen(),
                                  ),
                                ).then((_) => ref
                                    .read(groupsProvider.notifier)
                                    ._loadGroups());
                              },
                              icon: const Icon(Icons.group_add,
                                  color: Colors.white),
                              label: const Text(
                                'Create More Groups',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                minimumSize: const Size(170, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          // Navigate to AddExpenseScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddExpenseScreen(
                mode: 'group',
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
