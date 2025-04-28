import 'package:flutter/material.dart';
import 'package:flutter_application/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../../domain/models/user_model.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final userAsync = ref.read(authViewModelProvider);

    userAsync.whenData((user) {
      if (user != null) {
        firstNameController.text = user.firstName ?? '';
        lastNameController.text = user.lastName ?? '';
        birthDateController.text = user.birthDate?.toLocal().toString().split(' ')[0] ?? '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authViewModelProvider);

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Modifier le profil"),
          centerTitle: true,
        ),
        body: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Erreur: $error')),
          data: (user) => user == null
              ? const Center(child: Text('Aucun utilisateur connecté'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Champ Prénom
                      TextField(
                        controller: firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'Prénom',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Champ Nom
                      TextField(
                        controller: lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Champ Date de naissance
                      TextField(
                        controller: birthDateController,
                        decoration: const InputDecoration(
                          labelText: 'Date de naissance',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: () async {
                          DateTime initialDate = DateTime.tryParse(birthDateController.text) ?? DateTime(2000);
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: initialDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            birthDateController.text = pickedDate.toLocal().toString().split(' ')[0];
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      // Bouton de sauvegarde
                      ElevatedButton(
                        onPressed: () async {
                          final firstName = firstNameController.text.trim();
                          final lastName = lastNameController.text.trim();
                          final birthDate = birthDateController.text.trim();

                          if (firstName.isEmpty || lastName.isEmpty || birthDate.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Veuillez remplir tous les champs')),
                            );
                            return;
                          }

                          try {
                            final updatedUser = UserModel(
                              uid: user!.uid,
                              email: user.email,
                              firstName: firstName,
                              lastName: lastName,
                              birthDate: DateTime.tryParse(birthDate),
                            );

                            await ref.read(authViewModelProvider.notifier).updateUserInformation(updatedUser);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profil mis à jour')),
                            );

                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur : $e')),
                            );
                          }
                        },
                        child: const Text("Sauvegarder"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
