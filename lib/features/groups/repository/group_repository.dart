import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:split_mate/core/constants/firebase_constants.dart';
import 'package:split_mate/core/failure.dart';
import 'package:split_mate/core/providers/firebase_providers.dart';
import 'package:split_mate/core/type_defs.dart';
import 'package:split_mate/models/group_model.dart';

final groupRepositoryProvider = Provider((ref) {
  return GroupRepository(firestore: ref.read(firestoreProvider));
});

class GroupRepository {
  final FirebaseFirestore _firestore;

  GroupRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _groups =>
      _firestore.collection(FirebaseConstants.groupsCollection);

  FutureEither<void> createGroup(GroupModel groupModel) async {
    try {
      await _groups.doc(groupModel.groupId).set(groupModel.toMap());
      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? 'Firebase error occurred.'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<GroupModel>> fetchGroups(String userId) {
    return _groups
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GroupModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> updateGroupBalance(String groupId, double newBalance) async {
    try {
      await _groups.doc(groupId).update({'totalBalance': newBalance});
    } catch (e) {
      throw Failure('Failed to update group balance: $e');
    }
  }
}
