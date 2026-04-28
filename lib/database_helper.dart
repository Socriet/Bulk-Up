import 'package:hive_flutter/hive_flutter.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  Box? _box;

  DatabaseHelper._init();

  Future<Box> get database async {
    if (_box != null) return _box!;

    await Hive.initFlutter();
    _box = await Hive.openBox('bulkUpBox');

    if (!_box!.containsKey('user_stats')) {
      await _box!.put('user_stats', {'total_xp': 0, 'level': 1});
    }
    if (!_box!.containsKey('workouts')) {
      await _box!.put('workouts', []);
    }
    if (!_box!.containsKey('routines')) {
      await _box!.put('routines', []);
    }

    return _box!;
  }

  static int calculateLevel(int xp) {
    if (xp < 1000) return 1;
    if (xp < 3000) return 2;
    if (xp < 6000) return 3;
    if (xp < 10000) return 4;
    if (xp < 15000) return 5;
    return 6;
  }

  Future<void> addXP(int xp, String exerciseName, double volume) async {
    final db = await database;

    final statsMap = Map<dynamic, dynamic>.from(
        db.get('user_stats') ?? {'total_xp': 0, 'level': 1});
    final newXp = (statsMap['total_xp'] as int) + xp;
    await db.put('user_stats', {
      'total_xp': newXp,
      'level': calculateLevel(newXp),
    });

    final workouts = List<dynamic>.from(db.get('workouts') ?? []);
    workouts.add({
      'exercise': exerciseName,
      'xp_earned': xp,
      'volume': volume,
      'date': DateTime.now().toIso8601String(),
    });
    await db.put('workouts', workouts);
  }

  Future<List<Map<dynamic, dynamic>>> getRoutines() async {
    final db = await database;
    final raw = List<dynamic>.from(db.get('routines') ?? []);
    return raw.map((e) => Map<dynamic, dynamic>.from(e)).toList();
  }

  Future<void> saveRoutines(List<Map<dynamic, dynamic>> routines) async {
    final db = await database;
    await db.put('routines', routines);
  }
}
