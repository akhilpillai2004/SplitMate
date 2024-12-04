import 'package:split_mate/core/constants/constants.dart';

class UserModel {
  final String username;
  final String name;
  final String profilePic;
  final String uid;
  final bool isAuthenticated;
  //final double splitBalance;
  final List<String> friendsList;
  final String email;

  UserModel({
    required this.username,
    required this.name,
    required this.profilePic,
    required this.uid,
    required this.isAuthenticated,
    //required this.splitBalance,
    required this.friendsList,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'name': name,
      'profilePic': profilePic,
      'uid': uid,
      'isAuthenticated': isAuthenticated,
      //'splitBalance': splitBalance,
      'friendsList': friendsList,
      'email': email,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] ?? 'No Username',
      name: map['name'] ?? 'No Name',
      profilePic: map['profilePic'] ?? Constants.avatarDefault,
      uid: map['uid'] ?? '',
      isAuthenticated: map['isAuthenticated'] ?? false,
      //splitBalance: (map['splitBalance'] ?? 0.0) as double,
      friendsList: List<String>.from(map['friendsList'] ?? []),
      email: map['email'] ?? 'No email',
    );
  }

  static fromJson(user) {}
}
