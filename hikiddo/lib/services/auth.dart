// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hikiddo/constants.dart';
import 'package:hikiddo/models/user.dart';
import 'package:hikiddo/services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // user object based on Firebase
  UserModel? _userFromFirebaseUser(User? user) {
    return user != null ? UserModel(uid: user.uid) : null;
  }

  Stream<UserModel?> get user {
    return _auth
        .authStateChanges()
        .map((User? user) => user != null ? UserModel(uid: user.uid) : null);
  }

  // sign in with email and password
  Future userSignIn(BuildContext context, String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signed in: ${user?.email}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),), backgroundColor: lightBlueColor,),
      );
      return _userFromFirebaseUser(user);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      return null;
    }
  }

  // register with email and password
Future<User?> registerUser(BuildContext context, String email, String password, String name) async {
  try {
    UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    User? user = result.user;

    if (user != null) {
      // Create a new document for the user with the uid
      await DatabaseService(uid: user.uid).updateUserData(name, email, 'phoneNumber', password);
      return user;  // Return the User object directly
    }
    return null;
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('An account with this Email already exists')),
    );
    return null;
  }
}

  // Method to send verification email
Future<void> sendVerificationEmail(User user, BuildContext context) async {
  try {
    await user.sendEmailVerification();
    print("Verification email sent to ${user.email}");  // Debug: Check if this line executes
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Verification email has been sent to ${user.email}. Please verify to continue.')),
    );
  } catch (e) {
    print("Failed to send verification email: ${e}");  // Debug: Log any errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to send verification email: ${e.toString()}')),
    );
  }
}

// Method to check if email is verified
Future<bool> isEmailVerified(User user) async {
  await user.reload();
  var currentUser = _auth.currentUser;
  return currentUser!.emailVerified;
}

  //fogot password
  Future<void> sendPasswordResetEmail(String email, Function(String) onMessage) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      onMessage("Password reset email sent.");
    } catch (e) {
      onMessage("Failed to send password reset email. Please try again.");
    }
  }

  //sign out
  Future<void> signOut(BuildContext context) async {
    try {
      return await _auth.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      return;
    }
  }
}
