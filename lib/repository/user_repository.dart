import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final _db = FirebaseFirestore.instance;

  /// **Create a new user in Firestore**
  /// Adds the user to the `Users` collection and role-specific subcollection (if applicable).
  Future<void> createUser(UserModel user) async {
    try {
      // Add shared user data to the Users collection
      await _db.collection("Users").doc(user.uid).set(user.toJson());

      // Add role-specific data to the respective subcollection
      if (user.roleSpecificData.isNotEmpty) {
        await _db
            .collection("Users")
            .doc(user.uid)
            .collection(user.role)
            .add(user.roleSpecificData);
      }

      print("User created successfully");
    } catch (e) {
      print("Error creating user: $e");
    }
  }

  /// **Fetch user data**
  /// Retrieves shared data from the `Users` collection and role-specific data from subcollections.
  Future<UserModel?> getUser(String userId) async {
    try {
      // Fetch shared user data
      final userDoc = await _db.collection("Users").doc(userId).get();
      if (!userDoc.exists) return null;

      final sharedData = userDoc.data()!;

      // Fetch role-specific data based on the user's role
      final role = sharedData['Role'] ?? 'member';
      Map<String, dynamic> roleSpecificData = {};

      if (role != 'member') {
        final roleDocs = await _db
            .collection("Users")
            .doc(userId)
            .collection(role)
            .get();

        if (roleDocs.docs.isNotEmpty) {
          roleSpecificData = roleDocs.docs.first.data(); // Assuming one document per role
        }
      }

      // Return a complete UserModel
      return UserModel.fromJson(sharedData, userId, roleSpecificData);
    } catch (e) {
      print("Error fetching user: $e");
    }
    return null;
  }

  /// **Update user data**
  /// Updates shared data in the `Users` collection and role-specific data in subcollections.
  Future<void> updateUser(UserModel user) async {
    try {
      // Update shared user data in the Users collection
      await _db.collection("Users").doc(user.uid).update(user.toJson());

      // Update role-specific data in the respective subcollection
      if (user.roleSpecificData.isNotEmpty) {
        final role = user.role;
        final roleCollection = _db
            .collection("Users")
            .doc(user.uid)
            .collection(role);

        // Check if role-specific data already exists
        final roleDocs = await roleCollection.get();
        if (roleDocs.docs.isNotEmpty) {
          // Update existing role-specific document
          await roleDocs.docs.first.reference.update(user.roleSpecificData);
        } else {
          // Add new role-specific document if it doesn't exist
          await roleCollection.add(user.roleSpecificData);
        }
      }

      print("User updated successfully");
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  /// **Delete user**
  /// Deletes the user from the `Users` collection and their role-specific data.
  Future<void> deleteUser(String userId, String role) async {
    try {
      // Delete shared user data
      await _db.collection("Users").doc(userId).delete();

      // Delete role-specific data
      final roleDocs = await _db
          .collection("Users")
          .doc(userId)
          .collection(role)
          .get();

      for (var doc in roleDocs.docs) {
        await doc.reference.delete();
      }

      print("User deleted successfully");
    } catch (e) {
      print("Error deleting user: $e");
    }
  }
}
