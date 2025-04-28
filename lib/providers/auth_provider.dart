import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/auth_repository.dart';

// Fournisseur pour accéder à l'instance AuthRepository
final authRepositoryProvider = Provider((ref) => AuthRepository());

// StreamProvider pour écouter les changements d'état d'authentification
final authStateProvider = StreamProvider.autoDispose<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});
