import 'package:split_mate/core/constants/constants.dart';

class GroupModel {
  final String groupId;
  String groupName;
  final String groupIcon;
  final String creatorId;
  final List<String> members;
  final double totalBalance;
  final Map<String, bool> adminStatus; // Added to keep track of admin status

  GroupModel({
    required this.groupId,
    required this.groupName,
    required this.groupIcon,
    required this.creatorId,
    required this.members,
    required this.totalBalance,
    required this.adminStatus, // Initialize admin status map
  });

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'groupIcon': groupIcon,
      'creatorId': creatorId,
      'members': members,
      'totalBalance': totalBalance,
      'adminStatus': adminStatus, // Add admin status to map
    };
  }

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      groupId: map['groupId'] ?? '',
      groupName: map['groupName'] ?? 'Unnamed Group',
      groupIcon: map['groupIcon'] ?? Constants.avatarDefault,
      creatorId: map['creatorId'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      totalBalance: (map['totalBalance'] ?? 0.0) as double,
      adminStatus: Map<String, bool>.from(map['adminStatus'] ?? {}),
    );
  }
}
