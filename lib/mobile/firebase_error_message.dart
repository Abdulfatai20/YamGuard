import 'package:firebase_auth/firebase_auth.dart';

String getFriendlyFirebaseError(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'Email address is not valid.';
    case 'user-disabled':
      return 'This user has been disabled.';
    case 'user-not-found':
      return 'No account found for this email.';
    case 'wrong-password':
      return 'Incorrect password. Please try again.';
    case 'email-already-in-use':
      return 'This email is already registered.';
    case 'weak-password':
      return 'Your password is too weak.';
    case 'operation-not-allowed':
      return 'This operation is not allowed.';
    default:
      return 'Something went wrong. Please try again.';
  }
}
