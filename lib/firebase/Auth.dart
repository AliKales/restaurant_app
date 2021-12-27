import 'package:firebase_auth/firebase_auth.dart';
import 'package:restaurant_app/funcs.dart';

class Auth {
  Future<bool> createUserWithEmail(String email, String password,context) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      Funcs().showSnackBar(context, e.message??"ERROR");
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
      Funcs().showSnackBar(context, e.message??"ERROR");
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
  String getUID(){
    return FirebaseAuth.instance.currentUser?.uid??"";
  }
}
