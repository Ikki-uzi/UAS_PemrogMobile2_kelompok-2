import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'stats_screen.dart';
import 'about_screen.dart';
import 'transaction_form.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const HomeScreen(),
    const HistoryScreen(),
    const SizedBox(), // Placeholder untuk tombol tengah
    const StatsScreen(),
    const AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      floatingActionButton: Container(
        height: 65,
        width: 65,
        child: FloatingActionButton(
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (c) => const TransactionForm(),
          ),
          backgroundColor: Colors.black,
          elevation: 5,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 35),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home_rounded, 0),
              _buildNavItem(Icons.history_rounded, 1),
              const SizedBox(width: 40), // Space for FAB
              _buildNavItem(Icons.bar_chart_rounded, 3),
              _buildNavItem(Icons.person_outline_rounded, 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return IconButton(
      icon: Icon(
        icon,
        color: _currentIndex == index ? Colors.black : Colors.grey[400],
      ),
      onPressed: () => setState(() => _currentIndex = index),
    );
  }
}
