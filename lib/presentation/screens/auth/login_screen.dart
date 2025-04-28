import 'package:flutter/material.dart';
import 'package:flutter_application/presentation/screens/home/home_screen.dart';
import 'package:flutter_application/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/auth_provider.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Connexion'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Logo ou titre attractif
                const SizedBox(height: 40),
                const Text(
                  'Bienvenue Back 👋',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),

                // Champ Email
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Adresse Email",
                    labelStyle: const TextStyle(color: Colors.grey),
                    hintText: "Entrez votre email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    prefixIcon: Icon(Icons.email, color: Colors.blue),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Champ Mot de passe
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Mot de passe",
                    labelStyle: const TextStyle(color: Colors.grey),
                    hintText: "Entrez votre mot de passe",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    prefixIcon: Icon(Icons.lock, color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 24),

                // Affichage de l'état de connexion
                authState.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stackTrace) => Text(
                    "Erreur de connexion : $error",
                    style: const TextStyle(color: Colors.red),
                  ),
                  data: (userModel) {
                    // Si l'utilisateur est déjà authentifié
                    if (userModel != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen(userId: userModel.uid)),
                        );
                      });
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Bouton de connexion
                ElevatedButton(
                  onPressed: () async {
                    final email = emailController.text.trim();
                    final password = passwordController.text.trim();

                    // Vérifier que l'email et le mot de passe ne sont pas vides
                    if (email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
                      );
                      return;
                    }

                    try {
                      // Tenter de se connecter avec les informations fournies
                      await ref.read(authViewModelProvider.notifier).signIn(email, password);
                    } catch (e) {
                      // Gérer les erreurs potentielles
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Erreur de connexion : $e")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Se connecter",
                    style: TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(height: 16),

                // Lien vers l'écran d'inscription
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Pas de compte ? "),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupScreen()),
                      ),
                      child: const Text("Créer un compte", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
