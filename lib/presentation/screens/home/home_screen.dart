import 'package:flutter/material.dart';
import 'package:flutter_application/core/navigation/custom_page_route.dart';
import 'package:flutter_application/presentation/screens/account/account_screen.dart';
import 'package:flutter_application/presentation/screens/home/dashboard_screen.dart';
import 'package:flutter_application/presentation/screens/search/search_screen.dart';
import 'package:flutter_application/presentation/screens/favorites/favorite_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application/providers/meal_provider.dart';
import 'package:flutter_application/domain/models/food_item.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String userId;
  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) async {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          CustomPageRoute(page: DashboardScreen(userId: widget.userId)),
        );
        break;

      case 1:
        final selectedFood = await Navigator.push(
          context,
          CustomPageRoute(page: SearchScreen(userId: widget.userId)),
        );

        if (selectedFood is Map) {
          final foodItem = selectedFood['foodItem'] as FoodItem;
          final mealType = selectedFood['mealType'] as String;

          ref.read(mealProvider(widget.userId).notifier).addFoodToMeal(
            mealType,
            foodItem,
            DateTime.now(),
          );

          setState(() {
            _selectedIndex = 0;
          });
        }
        break;

      case 2:
        Navigator.push(
          context,
          CustomPageRoute(page: FavoriteScreen(userId: widget.userId)),
        );
        break;

      case 3:
        Navigator.push(
          context,
          CustomPageRoute(page: const AccountScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardScreen(userId: widget.userId),
      SearchScreen(userId: widget.userId),
      FavoriteScreen(userId: widget.userId),
      const AccountScreen(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Rechercher"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favoris"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Compte"),
        ],
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
      ),
    );
  }
}
