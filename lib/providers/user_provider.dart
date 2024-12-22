import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  bool _isDataLoaded = false;
  bool _isDayMode = true;
  bool get isDayMode => _isDayMode;


  UserModel? get user => _user;
  bool get isDataLoaded => _isDataLoaded;

  void toggleTheme() {
    _isDayMode = !_isDayMode;
    notifyListeners();
  }
  Future<void> loadUserData() async {
    try {
      print("Fetching user data...");

      // Ensure data loaded flag is reset before fetching
      _isDataLoaded = false;
      notifyListeners();

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        print("No user is logged in.");
        return;
      }

      final userDoc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();

      if (userDoc.exists) {
        final data = userDoc.data();
        print("User document found: $data");

        if (data == null) {
          print("User document is null. This shouldn't happen.");
        } else {
          print("Validating fields in user document...");
          print("FullName: ${data['FullName']}");
          print("Email: ${data['Email']}");
          print("ProfileImage: ${data['ProfileImage']}");
        }

        // Parse the data into the UserModel
        _user = UserModel.fromJson(data!, uid);
        print("User data successfully loaded.");
      } else {
        print("No user document found for UID: $uid");
        _user = null; // Set user to null if not found
      }
    } catch (e) {
      print("Error loading user data: $e");
      _user = null; // Ensure user is null in case of errors
    } finally {
      _isDataLoaded = true; // Mark data as loaded
      notifyListeners();
    }
  }
  Future<void> updateUserName(String newName) async {
    try {
      if (_user != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(_user!.id)
            .update({'FullName': newName});
        _user = _user!.copyWith(fullName: newName);
        notifyListeners();
      }
    } catch (e) {
      print("Error updating name: $e");
    }
  }

  Future<void> updateUserAvatar(String newAvatar) async {
    try {
      if (_user != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(_user!.id)
            .update({'ProfileImage': newAvatar});
        _user = _user!.copyWith(profileImage: newAvatar);
        notifyListeners();
      }
    } catch (e) {
      print("Error updating avatar: $e");
    }
  }


  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      _user = null;
      _isDataLoaded = false;
      notifyListeners();
    } catch (e) {
      print("Error logging out: $e");
    }
  }
}
