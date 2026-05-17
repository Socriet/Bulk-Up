import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'database_helper.dart';
import 'screens/dashboard_screen.dart';
import 'screens/hatch_screen.dart';
import 'screens/history_screen.dart';
import 'screens/pokedex_screen.dart';
import 'screens/routines_screen.dart';
 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  

  await DatabaseHelper.instance.database;
  
  runApp(const BulkUpApp());
}
 
class BulkUpApp extends StatelessWidget {
  const BulkUpApp({Key? key}) : super(key: key);
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BulkUp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.greenAccent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          elevation: 0,
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}
 
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);
 
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}
 
class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
 
  
  static const List<Widget> _screens = <Widget>[
    DashboardScreen(),      
    RoutinesScreen(),       
    PokedexScreen(),       
    HatchScreen(),          
    HistoryScreen(),        
  ];
 
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BulkUp',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFF1F1F1F),
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Routines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Pokédex',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.egg),
            label: 'Hatch',
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