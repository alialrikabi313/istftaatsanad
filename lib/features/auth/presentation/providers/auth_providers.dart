import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../auth/data/datasources/firebase_auth_remote.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/domain/entities/app_user.dart';


final firebaseAuthProvider = Provider<fb.FirebaseAuth>((ref) => fb.FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);


final authRemoteProvider = Provider<FirebaseAuthRemote>((ref) {
  return FirebaseAuthRemote(ref.watch(firebaseAuthProvider), ref.watch(firestoreProvider));
});


final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteProvider));
});


final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});


final signInControllerProvider = StateNotifierProvider<SignInController, AsyncValue<AppUser?>>((ref) {
  return SignInController(ref.watch(authRepositoryProvider));
});


class SignInController extends StateNotifier<AsyncValue<AppUser?>> {
  final AuthRepository _repo;
  SignInController(this._repo) : super(const AsyncData(null));


  Future<void> signIn(String email, String code) async {
    state = const AsyncLoading();
    final res = await _repo.signInWithEmailCode(email: email, code: code);
    state = res.match(
          (l) => AsyncError(l, StackTrace.current),
          (r) => AsyncData(r),
    );
  }
}

