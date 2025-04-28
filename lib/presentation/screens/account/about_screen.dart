import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("À propos"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "À propos de l'application",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                "Cette application mobile a été développée dans le cadre du projet DevOps à l'université du Mans. "
                "Elle vise à démontrer les compétences acquises en développement logiciel, gestion de projet et déploiement continu, "
                "en s'appuyant sur les meilleures pratiques du développement agile et des outils modernes de gestion de versions et d'intégration continue.",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              const Text(
                "Le projet est basé sur l'application mobile de gestion de la nutrition, permettant aux utilisateurs de suivre leur alimentation "
                "en ajoutant des aliments et des recettes tout en calculant les calories et macronutriments. L'application inclut également une fonctionnalité de favoris "
                "qui permet de sauvegarder les aliments préférés et d'y accéder rapidement. Ce projet a permis d'explorer et d'implémenter différentes technologies "
                "de développement mobile, telles que Flutter, ainsi que des outils DevOps comme Git, GitHub, Jenkins, et Docker pour la gestion et le déploiement de l'application.",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              const Text(
                "Cette application est un exemple de projet DevOps complet, où le cycle de vie du développement logiciel a été optimisé grâce à "
                "l'intégration de pratiques de déploiement continu et de gestion de la qualité du code. Le projet a été conçu pour répondre aux besoins des utilisateurs tout en assurant une "
                "expérience fluide et une architecture robuste, permettant ainsi un suivi efficace de l'alimentation tout au long de la journée.",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              const Text(
                "Développeurs : \n \t Eliott MAUBERT\n \t Emmanuel \n\n"
                "Université du Mans - Projet DevOps\n"
                "Version : 2.2.0\n"
                "Date de lancement : 29/04/2025\n",
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
