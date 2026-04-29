import 'package:fpdart/fpdart.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_remote.dart';


class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthRemote remote;
  AuthRepositoryImpl(this.remote);


  @override
  Stream<AppUser?> authStateChanges() => remote.authChanges();


  @override
  Future<Either<String, AppUser>> signInWithEmailCode({required String email, required String code}) async {
    try {
      final user = await remote.signInWithEmailAndCode(email, code);
      return Right(user);
    } catch (e) {
      return Left(e.toString());
    }
  }


  @override
  Future<void> signOut() => remote.signOut();
}