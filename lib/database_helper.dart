import 'package:hive_flutter/hive_flutter.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  Box? _box;

  DatabaseHelper._init();

  Future<Box> get database async {
    if (_box != null) return _box!;
    
    // Initialize Hive for local device storage
    await Hive.initFlutter();
    
    // Open a box named 'bulkUpBox'
    _box = await Hive.openBox('bulkUpBox');
    
    // Initialize default user data if it doesn't exist yet
    if (!_box!.containsKey('user_stats')) {
      await _box!.put('user_stats', {'total_xp': 0, 'level': 1});
    }
    
    if (!_box!.containsKey('workouts')) {
      await _box!.put('workouts', []);
    }
    
    return _box!;
  }
}