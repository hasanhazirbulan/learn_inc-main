import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final _db = FirebaseFirestore.instance;

  // Create a new user in Firestore
  Future<void> createUser(UserModel user) async {
    try {
      await _db.collection("Users").doc(user.id).set(user.toJson());
      print("User created successfully");
    } catch (e) {
      print("Error creating user: $e");
    }
  }

  // Fetch user data
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _db.collection("Users").doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!, doc.id);
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
    return null;
  }

  // Update user data
  Future<void> updateUser(UserModel user) async {
    try {
      await _db.collection("Users").doc(user.id).update(user.toJson());
      print("User updated successfully");
    } catch (e) {
      print("Error updating user: $e");
    }
  }
}
