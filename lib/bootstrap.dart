// ============================ lib/bootstrap.dart ============================
import 'package:firebase_core/firebase_core.dart';


Future<void> bootstrap() async {
// The user will configure Firebase options (firebase_options.dart) externally
// await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Firebase.initializeApp();
}