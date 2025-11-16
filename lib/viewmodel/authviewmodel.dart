import 'package:abast_veiculo/services/authservice.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthViewModel {
  final AuthService _authService = AuthService();
  String? userid;
  String? mail;

  Future signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final usercred = await _authService.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      userid = usercred.user?.uid;
      mail = usercred.user?.email;
      print('✅ AuthViewModel: Usuário logado: $userid, Email: $mail');
      return true;
    } on FirebaseAuthException catch (e) {
      throw e.code;
    }
  }

  Future createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _authService.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw e.code;
    }
  }

  Future signOut() async {
    await _authService.signOut();
  }
}
