import 'package:firebase_auth/firebase_auth.dart';

Future<String> signInAnonymously() async {
  var userCredential = await FirebaseAuth.instance.signInAnonymously();
  return userCredential.user.uid;
}
