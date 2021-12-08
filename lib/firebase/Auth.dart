import 'package:firebase_auth/firebase_auth.dart';
import 'package:restaurant_app/funcs.dart';

class Auth {
  Future<bool> createUserWithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> signInWithEmail(String email, String password,context) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Funcs().showSnackBar(context, "No user found for that email.");
      } else if (e.code == 'wrong-password') {
        Funcs().showSnackBar(context,"Wrong password provided for that user.");
      }
      return false;
    }
  }

  Future<bool> checkEMailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      return true;
    } else {
      return false;
    }
  }

  String getEMail(){
    return FirebaseAuth.instance.currentUser?.email??"";
  }
}
