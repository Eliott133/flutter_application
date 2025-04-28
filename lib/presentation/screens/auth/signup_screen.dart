import 'package:flutter/material.dart';
import 'package:flutter_application/domain/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import 'login_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final List<GlobalKey<FormState>> _formKeys = List.generate(4, (_) => GlobalKey<FormState>());

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  DateTime? _birthDate;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  final List<String> _stepMessages = [
    "Bienvenue 👋 \nDis-nous comment te joindre.",
    "Faisons connaissance 👋\nComment t'appelles-tu ?",
    "Quand est ton anniversaire 🎉\nOn adore fêter ça !",
    "Sécurise ton compte 🔒\nChoisis un mot de passe solide.",
  ];

  @override
  void initState() {
    super.initState();
    // Demander automatiquement le focus après un petit délai
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
      FocusScope.of(context).requestFocus(_emailFocusNode);
      }
    });

    _firstNameFocusNode.addListener(() {
      if (_firstNameFocusNode.hasFocus) {
      FocusScope.of(context).requestFocus(_firstNameFocusNode);
      }
    });

    _lastNameFocusNode.addListener(() {
      if (_lastNameFocusNode.hasFocus) {
      FocusScope.of(context).requestFocus(_lastNameFocusNode);
      }
    });

    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
      FocusScope.of(context).requestFocus(_passwordFocusNode);
      }
    });

    _confirmPasswordFocusNode.addListener(() {
      if (_confirmPasswordFocusNode.hasFocus) {
      FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
      }
    });
  }

  Future<void> _signUp() async {
    final authRepository = ref.read(authRepositoryProvider);

    setState(() => _isLoading = true);

    try {
      final user = await authRepository.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        final userModel = UserModel(
          uid: user.uid,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          birthDate: _birthDate,
        );

        await authRepository.saveUserInformation(userModel);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Compte créé avec succès !")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Échec de l'inscription")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _nextStep() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      if (_currentStep < 3) {
        setState(() {
          _currentStep++;
          _pageController.nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        });
        
        // Demander le focus sur le champ correspondant à la nouvelle étape
        _requestFocusForStep(_currentStep);
      } else {
        _signUp();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _pageController.previousPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _requestFocusForStep(int step) {
    switch (step) {
      case 0:
        FocusScope.of(context).requestFocus(_emailFocusNode);
        break;
      case 1:
        FocusScope.of(context).requestFocus(_firstNameFocusNode);
        break;
      case 2:
        FocusScope.of(context).requestFocus(_lastNameFocusNode);
        break;
      case 3:
        FocusScope.of(context).requestFocus(_passwordFocusNode);
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildProgressIndicator() {
    List<String> steps = ['Email', 'Nom', 'Naissance', 'Mot de passe'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(steps.length, (index) {
        bool isSelected = _currentStep == index;
        return Column(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: isSelected ? Colors.blue : Colors.grey.shade300,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              steps[index],
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Créer un compte'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              // Swipe vers la droite => retour
              _previousStep();
            }
          },
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildProgressIndicator(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  _stepMessages[_currentStep],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildEmailStep(),
                        _buildNameStep(),
                        _buildBirthdateStep(),
                        _buildPasswordStep(),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (_currentStep > 0)
                      TextButton(
                        onPressed: _previousStep,
                        child: const Text(
                          "Retour",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    const SizedBox(height: 8),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _nextStep,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(_currentStep == 3 ? "S'inscrire" : "Suivant"),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildEmailStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _formKeys[0],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Adresse Email",
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || !value.contains("@")) ? "Entrez un email valide" : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _formKeys[1],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: "Prénom",
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || value.isEmpty) ? "Entrez votre prénom" : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: "Nom",
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || value.isEmpty) ? "Entrez votre nom" : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthdateStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _formKeys[2],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _birthDate = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey.shade700),
                    const SizedBox(width: 12),
                    Text(
                      _birthDate == null
                          ? "Sélectionnez votre date de naissance"
                          : "${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}",
                      style: TextStyle(
                        color: _birthDate == null ? Colors.grey : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_birthDate == null)
              const Text("Veuillez choisir une date", style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _formKeys[3],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "Mot de passe",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (value) =>
                  (value == null || value.length < 6) ? "6 caractères minimum" : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: "Confirmer mot de passe",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              validator: (value) =>
                  (value != _passwordController.text) ? "Les mots de passe ne correspondent pas" : null,
            ),
          ],
        ),
      ),
    );
  }
}
