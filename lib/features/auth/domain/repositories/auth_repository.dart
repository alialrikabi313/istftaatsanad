import 'package:fpdart/fpdart.dart';
import '../entities/app_user.dart';


abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();


  /// Sign in via email + one-time code stored/verified in Firestore (or Cloud Function).
  /// Return Right(user) on success, Left(message) on error.
  Future<Either<String, AppUser>> signInWithEmailCode({required String email, required String code});
  Future<void> signOut();
}