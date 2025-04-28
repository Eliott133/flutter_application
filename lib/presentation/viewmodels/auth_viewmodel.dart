import 'package:flutter_application/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application/domain/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AsyncValue<UserModel?>>(
  (ref) => AuthViewModel(ref.watch(authRepositoryProvider)),
);

class AuthViewModel extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository authRepository;

  AuthViewModel(this.authRepository) : super(const AsyncValue.loading()) {
    // Appelle la récupération automatique de l'utilisateur
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final iud = await authRepository.getUserId();
      final user = await authRepository.getUserInformation(iud!);
      print("uid load current user $iud");
      print("user load current user $user");
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Connexion utilisateur
  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await authRepository.signInWithEmail(email, password);
      if (user != null) {
        final userModel = await authRepository.getUserInformation(user.uid);
        print(userModel);
        print(user.uid);
        if (userModel != null) {
          print("ici");
          state = AsyncValue.data(userModel);
          print(state);
        } else {
          state = AsyncValue.error('Utilisateur non trouvé', StackTrace.current);
        }
      } else {
        state = AsyncValue.error('Erreur de connexion', StackTrace.current);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Inscription utilisateur
  Future<void> signUp(String email, String password, String firstName, String lastName) async {
    state = const AsyncValue.loading();
    try {
      final user = await authRepository.signUpWithEmail(email, password);
      if (user != null) {
        final userModel = UserModel(
          uid: user.uid,
          firstName: firstName,
          lastName: lastName,
          email: email,
        );
        await authRepository.saveUserInformation(userModel);
        state = AsyncValue.data(userModel);
      } else {
        state = AsyncValue.error('Erreur d\'inscription', StackTrace.current);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signOut() async {
    try {
      await authRepository.signOut();  // Déconnexion avec le repository
      state = const AsyncValue.data(null);  // Réinitialisation de l'état (utilisateur déconnecté)
    } catch (e) {
      state = AsyncValue.error('Erreur de déconnexion', StackTrace.current);
    }
  }

  // Récupérer les informations de l'utilisateur connecté
  Future<void> fetchUserInformation(String uid) async {
    state = const AsyncValue.loading();
    print("ici fetchUserInformation");
    try {
      final userModel = await authRepository.getUserInformation(uid);
      if (userModel != null) {
        state = AsyncValue.data(userModel);
      } else {
        state = AsyncValue.error('Utilisateur non trouvé', StackTrace.current);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Mise à jour du profil utilisateur
  Future<void> updateUserInformation(UserModel userModel) async {
    try {
      await authRepository.updateUserInformation(userModel);
      state = AsyncValue.data(userModel);  // Mise à jour de l'utilisateur dans l'état
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }


  // Fonction pour obtenir l'UID de l'utilisateur courant
  String? getCurrentUserUid() {
    return authRepository.getUserId();
  }
  // Fonction pour obtenir l'email de l'utilisateur courant
  String? getCurrentUserEmail() {
    return authRepository.getUserEmail();
  }
}
