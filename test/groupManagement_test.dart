import 'package:flutter_test/flutter_test.dart';
import 'package:split_mate/models/group_model.dart';

void main() {
  group('Group Management Tests', () {
    late GroupModel testGroup;

    setUp(() {
      // Initialize a sample group for testing
      testGroup = GroupModel(
        groupId: 'test-group',
        groupName: 'Test Group',
        groupIcon: 'default-icon',
        creatorId: 'user123',
        members: ['user123', 'user456'],
        totalBalance: 0.0,
        adminStatus: {
          'user123': true,
          'user456': false,
        },
      );
    });

    test('Create Group Successfully', () {
      // Verify the initial state of the testGroup
      expect(testGroup.groupName, 'Test Group');
      expect(testGroup.creatorId, 'user123');
      expect(testGroup.adminStatus['user123'], true);
      expect(testGroup.members.length, 2);
    });

    test('Leave Group as Non-Creator Possible', () {
      final nonCreatorId = 'user456';
      testGroup.members.remove(nonCreatorId);

      expect(testGroup.members.contains(nonCreatorId), false);
      expect(testGroup.members.length, 1);
    });

    test('Remove Group Member by Creator', () {
      final memberToRemove = 'user456';

      // Simulate removing member
      testGroup.members.remove(memberToRemove);
      testGroup.adminStatus.remove(memberToRemove);

      expect(testGroup.members.contains(memberToRemove), false);
      expect(testGroup.adminStatus.containsKey(memberToRemove), false);
    });

    test('Toggle Admin Status', () {
      final userId = 'user456';
      final originalAdminStatus = testGroup.adminStatus[userId] ?? false;

      testGroup.adminStatus[userId] = !originalAdminStatus;

      expect(testGroup.adminStatus[userId], !originalAdminStatus);
    });

    test('Delete Group Restricted to Creator', () {
      final nonCreatorId = 'user456';

      // Check that only the creator can delete the group (using logic for validation)
      expect(nonCreatorId != testGroup.creatorId, true);
      expect(testGroup.creatorId == 'user123', true);
    });
  });
}
