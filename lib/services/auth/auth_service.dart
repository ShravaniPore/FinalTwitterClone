import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //sign user in
  Future<UserCredential> signInWithEmailandPassword(
      String email, String password) async {
    try {
      //signin
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      //catch errors
      throw Exception(e.code);
    }
  }

  Future<void> changePassword(String newPassword) async {
    try {
      // Get the currently logged-in user
      User? user = _firebaseAuth.currentUser;

      // Update the password
      await user!.updatePassword(newPassword);

      // Sign out the user after changing the password
      await signOut();

      // You may choose to navigate the user to the sign-in page or any other page after password change
    } catch (e) {
      // Handle any errors that occur during password change
      print('Error changing password: $e');
      throw Exception(e);
    }
  }

  //create a new user
  Future<UserCredential> signUpWithEmailandPassword(
      String email, String password) async {
    try {
      //signin
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      //catch errors
      throw Exception(e.code);
    }
  }

  //sign user out
  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }
}

//saving tweets
Future<void> saveTweet(String tweetText) async {
  try {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tweets')
        .add({
      'text': tweetText,
      'timestamp': DateTime.now(),
    });
    print('Tweet added successfully');
  } catch (e) {
    print('Error adding tweet: $e');
  }
}
