import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split_mate/core/utils.dart';
import 'package:split_mate/features/groups/repository/group_repository.dart';
import 'package:split_mate/models/group_model.dart';

final groupControllerProvider = StateNotifierProvider<GroupController, bool>(
  (ref) => GroupController(groupRepository: ref.watch(groupRepositoryProvider)),
);

final userGroupsProvider = StreamProvider.family<List<GroupModel>, String>(
  (ref, userId) => ref.watch(groupRepositoryProvider).fetchGroups(userId),
);

class GroupController extends StateNotifier<bool> {
  final GroupRepository _groupRepository;

  GroupController({required GroupRepository groupRepository})
      : _groupRepository = groupRepository,
        super(false);

  Future<void> createGroup(
    BuildContext context,
    GroupModel groupModel,
  ) async {
    state = true;
    final result = await _groupRepository.createGroup(groupModel);
    state = false;

    result.fold(
      (failure) => showSnackBar(context, failure.message),
      (_) {
        showSnackBar(context, 'Group created successfully!');
        Navigator.of(context).pop(); // Navigate back to the groups screen
      },
    );
  }
}
