import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;
  User? get user => _user;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Login dengan Email & Password
  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email.trim(), password: password);

      // Manually update user and notify listeners
      _user = userCredential.user;
      notifyListeners();

      return AuthResult(success: true, user: userCredential.user);
    } on FirebaseAuthException catch (e) {
      String message = 'Terjadi kesalahan';

      switch (e.code) {
        case 'user-not-found':
          message = 'Email tidak terdaftar';
          break;
        case 'wrong-password':
          message = 'Password salah';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid';
          break;
        case 'user-disabled':
          message = 'Akun telah dinonaktifkan';
          break;
        case 'invalid-credential':
          message = 'Email atau password salah';
          break;
        default:
          message = 'Login gagal: ${e.message}';
      }

      return AuthResult(success: false, message: message);
    } catch (e) {
      return AuthResult(success: false, message: 'Terjadi kesalahan: $e');
    }
  }

  // Register dengan Email & Password
  Future<AuthResult> registerWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      // Update display name
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();
      _user = _auth.currentUser;
      notifyListeners();

      return AuthResult(success: true, user: userCredential.user);
    } on FirebaseAuthException catch (e) {
      String message = 'Terjadi kesalahan';

      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email sudah terdaftar';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid';
          break;
        case 'weak-password':
          message = 'Password terlalu lemah (minimal 6 karakter)';
          break;
        case 'operation-not-allowed':
          message = 'Operasi tidak diizinkan';
          break;
        default:
          message = 'Registrasi gagal: ${e.message}';
      }

      return AuthResult(success: false, message: message);
    } catch (e) {
      return AuthResult(success: false, message: 'Terjadi kesalahan: $e');
    }
  }

  // Login dengan Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult(success: false, message: 'Login dibatalkan');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Manually update user and notify listeners
      _user = userCredential.user;
      notifyListeners();

      return AuthResult(success: true, user: userCredential.user);
    } catch (e) {
      print('Error Google Sign In: $e');
      return AuthResult(success: false, message: 'Login Google gagal: $e');
    }
  }

  // Reset Password
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult(
        success: true,
        message: 'Email reset password telah dikirim',
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Terjadi kesalahan';

      switch (e.code) {
        case 'user-not-found':
          message = 'Email tidak terdaftar';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid';
          break;
        default:
          message = 'Gagal mengirim email: ${e.message}';
      }

      return AuthResult(success: false, message: message);
    } catch (e) {
      return AuthResult(success: false, message: 'Terjadi kesalahan: $e');
    }
  }

  // Logout
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

// Helper class untuk result
class AuthResult {
  final bool success;
  final String? message;
  final User? user;

  AuthResult({required this.success, this.message, this.user});
}
