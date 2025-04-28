import 'package:flutter/material.dart';
import 'package:flutter_application/core/navigation/custom_page_route.dart';
import 'package:flutter_application/presentation/screens/account/about_screen.dart';
import 'package:flutter_application/presentation/screens/account/change_password_screen.dart';
import 'package:flutter_application/presentation/screens/account/edit_profile_screen.dart';
import 'package:flutter_application/presentation/screens/account/settings_screen.dart';
import 'package:flutter_application/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    print("a $authState");

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Mon compte"),
          elevation: 0,
        ),
        body: authState.when(
          data: (userModel) {
            // Si l'utilisateur n'est pas connecté, afficher un message approprié
            if (userModel == null) {
              print("Utilisateur non connecté");
              return const Center(child: Text("Utilisateur non connecté"));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  // Photo de profil
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 15),
                  // Nom de l'utilisateur
                  Text(
                    "Bonjour : ${userModel.firstName} ${userModel.lastName}",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  // Email de l'utilisateur
                  Text(
                    "Email : ${userModel.email}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // Options du compte
                  _buildAccountOption(
                    icon: Icons.edit,
                    title: "Modifier le profil",
                    onTap: () {
                      Navigator.push(
                        context,
                        CustomPageRoute(page: const EditProfileScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildAccountOption(
                    icon: Icons.lock,
                    title: "Changer le mot de passe",
                    onTap: () {
                      Navigator.push(
                        context,
                        CustomPageRoute(page: const ChangePasswordScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildAccountOption(
                    icon: Icons.settings,
                    title: "Paramètres",
                    onTap: () {
                      Navigator.push(
                        context,
                        CustomPageRoute(page: const SettingsScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildAccountOption(
                    icon: Icons.info_outline,
                    title: "À propos de l'application",
                    onTap: () {
                      Navigator.push(
                        context,
                        CustomPageRoute(page: const AboutScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Bouton Déconnexion
                  ElevatedButton.icon(
                    onPressed: () async {
                      // Utiliser le ViewModel pour gérer la déconnexion
                      await ref.read(authViewModelProvider.notifier).signOut();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          CustomPageRoute(page: LoginScreen()),
                        );
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Se déconnecter"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()), // Affiche le loader pendant le chargement
          error: (error, stackTrace) => const Center(child: Text("Erreur de chargement de l'utilisateur")),
        ),
      ),
    );
  }

  // Petit widget pour construire les options proprement
  Widget _buildAccountOption({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tileColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
  }
}
