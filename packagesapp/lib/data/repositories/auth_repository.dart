import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/user_profile_model.dart';
import '../remote/auth_remote_datasource.dart';
import '../remote/dio_client.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final AuthRemoteDataSource _remote = AuthRemoteDataSource();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentUser != null;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _updateToken();
    return cred;
  }

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(displayName);
    await _updateToken();
    await _syncProfile(cred.user!);
    return cred;
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    await _updateToken();
    await _syncProfile(cred.user!);
    return cred;
  }

  Future<void> signOut() async {
    DioClient.setAuthToken(null);
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> _updateToken() async {
    final token = await _auth.currentUser?.getIdToken();
    DioClient.setAuthToken(token);
  }

  Future<void> refreshToken() async => _updateToken();

  Future<void> _syncProfile(User user) async {
    try {
      final profile = UserProfileModel(
        uid: user.uid,
        displayName: user.displayName ?? '',
        email: user.email ?? '',
        photoUrl: user.photoURL,
        createdAt: DateTime.now().toIso8601String(),
      );
      await _remote.syncProfile(profile);
    } catch (_) {}
  }

  Future<void> submitFeedback({
    required String message,
    required String email,
    String? name,
  }) async {
    await _remote.submitFeedback(message: message, email: email, name: name);
  }
}
