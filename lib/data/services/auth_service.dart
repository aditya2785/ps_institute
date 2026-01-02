import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ---------------------------------------------------------
  // Get Current Firebase User
  // ---------------------------------------------------------
  User? get currentUser => _auth.currentUser;

  // ---------------------------------------------------------
  // EMAIL + PASSWORD LOGIN
  // ---------------------------------------------------------
  Future<User?> loginWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    return credential.user;
  }

  // ---------------------------------------------------------
  // EMAIL + PASSWORD REGISTER
  // ---------------------------------------------------------
  Future<User?> registerWithEmail(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    return credential.user;
  }

  // ---------------------------------------------------------
  // GOOGLE SIGN-IN
  // ---------------------------------------------------------
  Future<User?> loginWithGoogle() async {
    final googleSignIn = GoogleSignIn();

    // Ask user to choose Google account
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null; // cancelled by user

    final googleAuth = await googleUser.authentication;

    // Build Firebase credential
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }

  // ---------------------------------------------------------
  // PHONE AUTH — SEND OTP
  // ---------------------------------------------------------
  Future<String?> sendOtp(
      String phoneNumber, Function(String, int?) onCodeSent) async {
    String verificationId = "";

    await _auth.verifyPhoneNumber(
      phoneNumber: "+91$phoneNumber",
      timeout: const Duration(seconds: 60),

      // Auto verification (rare cases)
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },

      verificationFailed: (FirebaseAuthException e) {
        throw e.message ?? "Phone verification failed";
      },

      codeSent: (String verId, int? resendToken) {
        verificationId = verId;
        onCodeSent(verId, resendToken);
      },

      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );

    return verificationId;
  }

  // ---------------------------------------------------------
  // VERIFY OTP
  // ---------------------------------------------------------
  Future<User?> verifyOtp(String verificationId, String otp) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp.trim(),
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }

  // ---------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------
  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}

    await _auth.signOut();
  }
}
