import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth firebaseAuth =
      FirebaseAuth.instance; // Firebase Auth instance

  User? get currentUser => firebaseAuth.currentUser; // Get the current user

  Stream<User?> get authStateChanges =>
      firebaseAuth.authStateChanges(); // Stream of auth state changes

  Future<UserCredential> logIn({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logOut() async {
    await firebaseAuth.signOut(); // Sign out the user
  }

  Future<void> forgetPasword(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUserName(String username) async {
    await currentUser?.updateDisplayName(username);
  }

  Future<void> deleteAccount({
    required String email,
    required String password
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
    await currentUser?.reauthenticateWithCredential(credential);
    await currentUser?.delete();
    await firebaseAuth.signOut();
  }

  Future <void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: currentPassword);
    await currentUser?.reauthenticateWithCredential(credential);
    await currentUser?.updatePassword(newPassword);
  }

}
