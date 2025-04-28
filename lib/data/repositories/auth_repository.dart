import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/domain/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      print("Connexion réussie : ${userCredential.user?.email}");
      return userCredential.user;
    } catch (e) {
      print("Erreur d'authentification : $e");
      return null;
    }
  }

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print("Erreur d'inscription : $e");
      return null;
    }
  }

  Future<void> saveUserInformation(UserModel userModel) async {
    try {
      await _firestore
        .collection('users')
        .doc(userModel.uid)
        .collection('informations')
        .doc('profile')
        .set(userModel.toMap());
    } catch (e) {
      print("Erreur lors de l'enregistrement des informations utilisateur : $e");
    }
  }

  Future<void> signOut() async {
    print("Déconnexion de l'utilisateur : ${_auth.currentUser?.email}");
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  String? getUserEmail() {
    return _auth.currentUser?.email;
  }

  String? getUserDisplayName() {
    return _auth.currentUser?.displayName;
  }

  String? getUserId() {
    return _auth.currentUser?.uid;
  }

  Future<UserModel?> getUserInformation(String uid) async {
    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('informations')
          .doc('profile')
          .get();

      if (docSnapshot.exists) {
        return UserModel.fromMap(uid, docSnapshot.data()!);
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  Future<void> updateUserInformation(UserModel userModel) async {
    try {
      await _firestore
          .collection('users')
          .doc(userModel.uid)
          .collection('informations')
          .doc('profile')
          .update(userModel.toMap());
    } catch (e) {
      print("Erreur lors de la mise à jour du profil : $e");
      throw Exception("Erreur lors de la mise à jour du profil");
    }
  }
}
