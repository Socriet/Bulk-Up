import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  Box? _box;

  DatabaseHelper._init();

  Future<Box> get database async {
    if (_box != null) return _box!;

    await Hive.initFlutter();
    _box = await Hive.openBox('bulkUpBox');

    if (!_box!.containsKey('user_stats')) {
      await _box!.put('user_stats', {'total_xp': 0, 'level': 1, 'available_pulls': 1});
    }
    if (!_box!.containsKey('workouts')) {
      await _box!.put('workouts', []);
    }
    if (!_box!.containsKey('routines')) {
      await _box!.put('routines', []);
    }
    if (!_box!.containsKey('partners')) {
      await _box!.put('partners', {});
    }
    if (!_box!.containsKey('active_partner')) {
      await _box!.put('active_partner', '');
    }

    return _box!;
  }

  static const Map<String, List<String>> pokemonTypes = {
    'Abra': ['Psychic'], 'Aerodactyl': ['Rock', 'Flying'], 'Articuno': ['Ice', 'Flying'],
    'Bellsprout': ['Grass', 'Poison'], 'Bulbasaur': ['Grass', 'Poison'], 'Caterpie': ['Bug'],
    'Chansey': ['Normal'], 'Charmander': ['Fire'], 'Clefairy': ['Fairy'],
    'Cubone': ['Ground'], 'Diglett': ['Ground'], 'Ditto': ['Normal'], 'Dratini': ['Dragon'],
    'Drowzee': ['Psychic'], 'Eevee': ['Normal'], 'Ekans': ['Poison'], 'Electabuzz': ['Electric'],
    'Exeggcute': ['Grass', 'Psychic'], 'Farfetchd': ['Normal', 'Flying'], 'Gastly': ['Ghost', 'Poison'],
    'Geodude': ['Rock', 'Ground'], 'Goldeen': ['Water'], 'Grimer': ['Poison'], 'Growlithe': ['Fire'],
    'Hitmonchan': ['Fighting'], 'Hitmonlee': ['Fighting'], 'Horsea': ['Water'], 'Jynx': ['Ice', 'Psychic'],
    'Kabuto': ['Rock', 'Water'], 'Kangaskhan': ['Normal'], 'Koffing': ['Poison'], 'Krabby': ['Water'],
    'Lapras': ['Water', 'Ice'], 'Lickitung': ['Normal'], 'Machop': ['Fighting'], 'Magikarp': ['Water'],
    'Magmar': ['Fire'], 'Magnemite': ['Electric', 'Steel'], 'Mankey': ['Fighting'], 'Meowth': ['Normal'],
    'Mew': ['Psychic'], 'Mewtwo': ['Psychic'], 'Moltres': ['Fire', 'Flying'], 'Mr.mime': ['Psychic', 'Fairy'],
    'Nidoran-f': ['Poison'], 'Nidoran-m': ['Poison'], 'Oddish': ['Grass', 'Poison'], 'Omanyte': ['Rock', 'Water'],
    'Onix': ['Rock', 'Ground'], 'Paras': ['Bug', 'Grass'], 'Pidgey': ['Normal', 'Flying'], 'Pikachu': ['Electric'],
    'Pinsir': ['Bug'], 'Poliwag': ['Water'], 'Ponyta': ['Fire'], 'Porygon': ['Normal'], 'Psyduck': ['Water'],
    'Rattata': ['Normal'], 'Rhyhorn': ['Ground', 'Rock'], 'Sandshrew': ['Ground'], 'Scyther': ['Bug', 'Flying'],
    'Seel': ['Water'], 'Shellder': ['Water'], 'Slowpoke': ['Water', 'Psychic'], 'Snorlax': ['Normal'],
    'Spearow': ['Normal', 'Flying'], 'Squirtle': ['Water'], 'Staryu': ['Water'], 'Tangela': ['Grass'],
    'Tauros': ['Normal'], 'Tentacool': ['Water', 'Poison'], 'Venonat': ['Bug', 'Poison'], 'Voltorb': ['Electric'],
    'Vulpix': ['Fire'], 'Weedle': ['Bug', 'Poison'], 'Zapdos': ['Electric', 'Flying'], 'Zubat': ['Poison', 'Flying']
  };


  static int calculateLevel(int xp) {
    const thresholds = [0, 1000, 3000, 6000, 10000, 15000];
  
    if (xp < 15000) {
      for (int i = thresholds.length - 1; i >= 0; i--) {
        if (xp >= thresholds[i]) return i + 1;
      }
    }
    
   
    int excessXp = xp - 15000;
    return 6 + (excessXp ~/ 5000);
  }

  Future<void> addXP(int xp, String exerciseName, double volume) async {
    final db = await database;

    final statsMap = Map<dynamic, dynamic>.from(
        db.get('user_stats') ?? {'total_xp': 0, 'level': 1, 'available_pulls': 1});
    
    final oldLevel = statsMap['level'] as int;
    final newXp = (statsMap['total_xp'] as int) + xp;
    final newLevel = calculateLevel(newXp);
    
    int pulls = statsMap['available_pulls'] ?? 0;
    
  
    if (newLevel > oldLevel) {
      int levelsGained = newLevel - oldLevel;
      pulls += levelsGained;
    }

    await db.put('user_stats', {
      'total_xp': newXp,
      'level': newLevel,
      'available_pulls': pulls,
    });

    final workouts = List<dynamic>.from(db.get('workouts') ?? []);
    workouts.add({
      'exercise': exerciseName,
      'xp_earned': xp,
      'volume': volume,
      'date': DateTime.now().toIso8601String(),
    });
    await db.put('workouts', workouts);

    final active = db.get('active_partner') as String? ?? '';
    if (active.isNotEmpty) {
      final partners = Map<dynamic, dynamic>.from(db.get('partners') ?? {});
      if (partners.containsKey(active)) {
        final pData = Map<dynamic, dynamic>.from(partners[active]);
        int pExp = pData['exp'] + xp;
        int pLevel = pData['level'];
        
        while (pExp >= pLevel * 100) {
          pExp -= pLevel * 100;
          pLevel++;
        }
        
        pData['exp'] = pExp;
        pData['level'] = pLevel;
        partners[active] = pData;
        await db.put('partners', partners);
      }
    }
  }

  Future<String> hatchPartner() async {
    final db = await database;
    
    final statsMap = Map<dynamic, dynamic>.from(
        db.get('user_stats') ?? {'total_xp': 0, 'level': 1, 'available_pulls': 0});
    int pulls = statsMap['available_pulls'] ?? 0;

    if (pulls <= 0) return 'NO_PULLS';

    final partners = Map<dynamic, dynamic>.from(db.get('partners') ?? {});
    final unlockedNames = partners.keys.cast<String>().toList();
    
    final AssetManifest assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final List<String> allAssets = assetManifest.listAssets();
    
    final unownedAssets = allAssets.where((String path) {
      if (!path.startsWith('assets/') || !path.endsWith('.gif')) return false;
      final rawName = path.split('/').last.replaceAll('.gif', '');
      final formattedName = rawName[0].toUpperCase() + rawName.substring(1);
      return !unlockedNames.contains(formattedName);
    }).toList();
        
    if (unownedAssets.isEmpty) return 'ALL_UNLOCKED';
    
    final randomPath = unownedAssets[Random().nextInt(unownedAssets.length)];
    final rawName = randomPath.split('/').last.replaceAll('.gif', '');
    final formattedName = rawName[0].toUpperCase() + rawName.substring(1);
    
    statsMap['available_pulls'] = pulls - 1;
    await db.put('user_stats', statsMap);

    partners[formattedName] = {
      'exp': 0,
      'level': 1,
      'image': randomPath 
    };
    await db.put('partners', partners);
    
    return formattedName;
  }

  Future<void> setActivePartner(String name) async {
    final db = await database;
    await db.put('active_partner', name);
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