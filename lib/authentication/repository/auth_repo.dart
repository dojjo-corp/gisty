import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  AuthRepository();

  final auth = FirebaseAuth.instance;
  Future<UserCredential?> login({required String email, required String password}) async {
    try {
      return await auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        throw 'Wrong password provided for that user.';
      }
      return null;
    }
  }

  Future<UserCredential?> register(
      {required String email, required String password}) async {
    try {
      return await auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        throw 'The account already exists for that email.';
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
