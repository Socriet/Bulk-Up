import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'database_helper.dart';
import 'screens/dashboard_screen.dart';
import 'screens/log_workout_screen.dart';
import 'screens/history_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  
  // Boot up the local database
  await Hive.initFlutter();
  await DatabaseHelper.instance.database;
  
  runApp(const BulkUpApp());
}

class BulkUpApp extends StatelessWidget {
  const BulkUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bulk Up',
      debugShowCheckedModeBanner: false, // Removes the debug banner
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1F1F1F),
          selectedItemColor: Colors.greenAccent,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    LogWorkoutScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Up', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Log',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}