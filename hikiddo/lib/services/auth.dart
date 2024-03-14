import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hikiddo/models/user.dart';
import 'package:hikiddo/services/database.dart';


class AuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // user object based on Firebase
  UserModel? _userFromFirebaseUser(User? user){
    return user != null ? UserModel(uid: user.uid) : null;
  }

  Stream<UserModel?> get user {
  return _auth.authStateChanges()
    .map((User? user) => user != null ? UserModel(uid: user.uid) : null);
}


  // sign in with email and password
  Future userSignIn(String email, String password) async {
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      print("Signed in: ${user?.email}");
      return _userFromFirebaseUser(user);
    } catch(e){
      print(e.toString());
      return null;
    }
  }

  // register with email and password
  Future registerUser(String email, String password, String name) async{
    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      // create a new document for the user with the uid
      await DatabaseService(uid: user!.uid).updateUserData(name, email ,'phoneNumber', password);
      return _userFromFirebaseUser(user);
    } catch(e){
      print(e.toString());
      return null;
    }
  }

  //sign out
  Future<void> signOut() async {
    try{
      return await _auth.signOut();
    }catch(e){
      print(e.toString());
      return null;
    }
  }
}