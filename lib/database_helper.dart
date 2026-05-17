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
    

    if (!_box!.containsKey('unlocked_history')) {
      final existingPartners = Map<dynamic, dynamic>.from(_box!.get('partners') ?? {});
      await _box!.put('unlocked_history', existingPartners.keys.toList());
    }
 
    return _box!;
  }
 
 
  static const Map<String, Map<String, dynamic>> evolutions = {
  
    'Bulbasaur': {'target': 'Ivysaur', 'level': 16},
    'Ivysaur': {'target': 'Venusaur', 'level': 32},
    'Bellsprout': {'target': 'Weepinbell', 'level': 21},
    'Weepinbell': {'target': 'Victreebel', 'level': 32},
    'Oddish': {'target': 'Gloom', 'level': 21},
    'Gloom': {'target': 'Vileplume', 'level': 32},
    
  
    'Charmander': {'target': 'Charmeleon', 'level': 16},
    'Charmeleon': {'target': 'Charizard', 'level': 36},
    'Vulpix': {'target': 'Ninetales', 'level': 16},
    'Growlithe': {'target': 'Arcanine', 'level': 16},
    'Ponyta': {'target': 'Rapidash', 'level': 40},
    'Magnemite': {'target': 'Magneton', 'level': 30},
    

    'Squirtle': {'target': 'Wartortle', 'level': 16},
    'Wartortle': {'target': 'Blastoise', 'level': 36},
    'Psyduck': {'target': 'Golduck', 'level': 33},
    'Poliwag': {'target': 'Poliwhirl', 'level': 25},
    'Poliwhirl': {'target': 'Poliwrath', 'level': 36},
    'Shellder': {'target': 'Cloyster', 'level': 30},
    'Seel': {'target': 'Dewgong', 'level': 34},
    'Horsea': {'target': 'Seadra', 'level': 32},
    'Goldeen': {'target': 'Seaking', 'level': 33},
    'Staryu': {'target': 'Starmie', 'level': 30},
    'Magikarp': {'target': 'Gyarados', 'level': 20},
    
 
    'Pikachu': {'target': 'Raichu', 'level': 16},
    'Voltorb': {'target': 'Electrode', 'level': 30},
    'Electabuzz': {'target': 'Electivire', 'level': 42},
    
   
    'Abra': {'target': 'Kadabra', 'level': 16},
    'Kadabra': {'target': 'Alakazam', 'level': 42},
    'Drowzee': {'target': 'Hypno', 'level': 26},
    'Slowpoke': {'target': 'Slowbro', 'level': 37},
    
    
    'Weedle': {'target': 'Kakuna', 'level': 7},
    'Kakuna': {'target': 'Beedrill', 'level': 10},
    'Paras': {'target': 'Parasect', 'level': 24},
    'Venonat': {'target': 'Venomoth', 'level': 30},
    
   
    'Pidgey': {'target': 'Pidgeotto', 'level': 18},
    'Pidgeotto': {'target': 'Pidgeot', 'level': 36},
    'Spearow': {'target': 'Fearow', 'level': 20},
    

    'Machop': {'target': 'Machoke', 'level': 28},
    'Machoke': {'target': 'Machamp', 'level': 42},
    'Mankey': {'target': 'Primeape', 'level': 28},
    'Cubone': {'target': 'Marowak', 'level': 28},
    
    'Geodude': {'target': 'Graveler', 'level': 25},
    'Graveler': {'target': 'Golem', 'level': 42},
    'Rhyhorn': {'target': 'Rhydon', 'level': 42},
    'Sandshrew': {'target': 'Sandslash', 'level': 22},
    'Diglett': {'target': 'Dugtrio', 'level': 26},
    
    'Gastly': {'target': 'Haunter', 'level': 25},
    'Haunter': {'target': 'Gengar', 'level': 42},
    'Grimer': {'target': 'Muk', 'level': 38},
    'Koffing': {'target': 'Weezing', 'level': 35},
    
    'Clefairy': {'target': 'Clefable', 'level': 30},
    'Rattata': {'target': 'Raticate', 'level': 20},
    'Zubat': {'target': 'Golbat', 'level': 16},
    'Ekans': {'target': 'Arbok', 'level': 22},
    'Tentacool': {'target': 'Tentacruel', 'level': 30},
    'Exeggcute': {'target': 'Exeggutor', 'level': 30},
    'Tangela': {'target': 'Tangrowth', 'level': 30},
    
    'Nidoran-f': {'target': 'Nidorina', 'level': 16},
    'Nidorina': {'target': 'Nidoqueen', 'level': 32},
    'Nidoran-m': {'target': 'Nidorino', 'level': 16},
    'Nidorino': {'target': 'Nidoking', 'level': 32},
    
    'Omanyte': {'target': 'Omastar', 'level': 40},
    'Kabuto': {'target': 'Kabutops', 'level': 40},
  };
 
  static const Map<String, List<String>> pokemonTypes = {
    'Bellsprout': ['Grass', 'Poison'], 'Weepinbell': ['Grass', 'Poison'], 'Victreebel': ['Grass', 'Poison'],
    'Bulbasaur': ['Grass', 'Poison'], 'Ivysaur': ['Grass', 'Poison'], 'Venusaur': ['Grass', 'Poison'],
    'Oddish': ['Grass', 'Poison'], 'Gloom': ['Grass', 'Poison'], 'Vileplume': ['Grass', 'Poison'],
    'Exeggcute': ['Grass', 'Psychic'], 'Exeggutor': ['Grass', 'Psychic'],
    'Tangela': ['Grass'], 'Tangrowth': ['Grass'],
    
    'Charmander': ['Fire'], 'Charmeleon': ['Fire'], 'Charizard': ['Fire', 'Flying'],
    'Vulpix': ['Fire'], 'Ninetales': ['Fire'],
    'Growlithe': ['Fire'], 'Arcanine': ['Fire'],
    'Ponyta': ['Fire'], 'Rapidash': ['Fire'],
    'Magmar': ['Fire'],
    
    'Squirtle': ['Water'], 'Wartortle': ['Water'], 'Blastoise': ['Water'],
    'Psyduck': ['Water'], 'Golduck': ['Water'],
    'Poliwag': ['Water'], 'Poliwhirl': ['Water'], 'Poliwrath': ['Water', 'Fighting'],
    'Shellder': ['Water'], 'Cloyster': ['Water', 'Ice'],
    'Seel': ['Water'], 'Dewgong': ['Water', 'Ice'],
    'Horsea': ['Water'], 'Seadra': ['Water'],
    'Goldeen': ['Water'], 'Seaking': ['Water'],
    'Staryu': ['Water'], 'Starmie': ['Water', 'Psychic'],
    'Magikarp': ['Water'], 'Gyarados': ['Water', 'Flying'],
    'Lapras': ['Water', 'Ice'],
    'Krabby': ['Water'], 'Kingler': ['Water'],
    'Tentacool': ['Water', 'Poison'], 'Tentacruel': ['Water', 'Poison'],
    
    'Pikachu': ['Electric'], 'Raichu': ['Electric'],
    'Voltorb': ['Electric'], 'Electrode': ['Electric'],
    'Magnemite': ['Electric', 'Steel'], 'Magneton': ['Electric', 'Steel'],
    'Electabuzz': ['Electric'],
    
    'Abra': ['Psychic'], 'Kadabra': ['Psychic'], 'Alakazam': ['Psychic'],
    'Drowzee': ['Psychic'], 'Hypno': ['Psychic'],
    'Slowpoke': ['Water', 'Psychic'], 'Slowbro': ['Water', 'Psychic'],
    'Jynx': ['Ice', 'Psychic'],
    'Mew': ['Psychic'], 'Mewtwo': ['Psychic'],
    
    'Weedle': ['Bug', 'Poison'], 'Kakuna': ['Bug', 'Poison'], 'Beedrill': ['Bug', 'Poison'],
    'Paras': ['Bug', 'Grass'], 'Parasect': ['Bug', 'Grass'],
    'Venonat': ['Bug', 'Poison'], 'Venomoth': ['Bug', 'Poison'],
    'Scyther': ['Bug', 'Flying'],
    'Pinsir': ['Bug'],
    
    'Pidgey': ['Normal', 'Flying'], 'Pidgeotto': ['Normal', 'Flying'], 'Pidgeot': ['Normal', 'Flying'],
    'Spearow': ['Normal', 'Flying'], 'Fearow': ['Normal', 'Flying'],
    'Farfetchd': ['Normal', 'Flying'],
    
    'Machop': ['Fighting'], 'Machoke': ['Fighting'], 'Machamp': ['Fighting'],
    'Mankey': ['Fighting'], 'Primeape': ['Fighting'],
    'Cubone': ['Ground'], 'Marowak': ['Ground'],
    'Hitmonchan': ['Fighting'], 'Hitmonlee': ['Fighting'],
    
    'Geodude': ['Rock', 'Ground'], 'Graveler': ['Rock', 'Ground'], 'Golem': ['Rock', 'Ground'],
    'Rhyhorn': ['Ground', 'Rock'], 'Rhydon': ['Ground', 'Rock'],
    'Sandshrew': ['Ground'], 'Sandslash': ['Ground'],
    'Diglett': ['Ground'], 'Dugtrio': ['Ground'],
    'Onix': ['Rock', 'Ground'],
    'Aerodactyl': ['Rock', 'Flying'],
    
    'Gastly': ['Ghost', 'Poison'], 'Haunter': ['Ghost', 'Poison'], 'Gengar': ['Ghost', 'Poison'],
    'Grimer': ['Poison'], 'Muk': ['Poison'],
    'Koffing': ['Poison'], 'Weezing': ['Poison'],
    
    'Clefairy': ['Fairy'], 'Clefable': ['Fairy'],
    'Rattata': ['Normal'], 'Raticate': ['Normal'],
    'Zubat': ['Poison', 'Flying'], 'Golbat': ['Poison', 'Flying'],
    'Ekans': ['Poison'], 'Arbok': ['Poison'],
    'Meowth': ['Normal'], 'Persian': ['Normal'],
    'Ditto': ['Normal'],
    'Chansey': ['Normal'],
    'Kangaskhan': ['Normal'],
    'Snorlax': ['Normal'],
    'Tauros': ['Normal'],
    'Lickitung': ['Normal'],
    'Porygon': ['Normal'],
    'Mr.mime': ['Psychic', 'Fairy'],
    
    'Articuno': ['Ice', 'Flying'],

    'Dratini': ['Dragon'],
    
    'Moltres': ['Fire', 'Flying'],
    
    'Zapdos': ['Electric', 'Flying'],
    
    'Nidoran-f': ['Poison'], 'Nidorina': ['Poison'], 'Nidoqueen': ['Poison', 'Ground'],
    'Nidoran-m': ['Poison'], 'Nidorino': ['Poison'], 'Nidoking': ['Poison', 'Ground'],
    
    'Omanyte': ['Rock', 'Water'], 'Omastar': ['Rock', 'Water'],
    'Kabuto': ['Rock', 'Water'], 'Kabutops': ['Rock', 'Water'],
    
    'Eevee': ['Normal'], 'Vaporeon': ['Water'], 'Jolteon': ['Electric'], 'Flareon': ['Fire'],
  };
 
  static Set<String> getEvolvedForms() {
    final evolved = evolutions.values.map((e) => e['target'] as String).toSet();
    evolved.addAll(['Vaporeon', 'Jolteon', 'Flareon']);
    return evolved;
  }
 
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
 
  Future<Map<String, dynamic>> addXP(int xp, String exerciseName, double volume) async {
    final db = await database;
 
    final statsMap = Map<dynamic, dynamic>.from(
        db.get('user_stats') ?? {'total_xp': 0, 'level': 1, 'available_pulls': 1});
    
    final oldLevel = statsMap['level'] as int;
    final newXp = (statsMap['total_xp'] as int) + xp;
    final newLevel = calculateLevel(newXp);
    
    int pulls = statsMap['available_pulls'] ?? 0;
    if (newLevel > oldLevel) {
      pulls += (newLevel - oldLevel);
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
 
    Map<String, dynamic> evolutionResult = {
      'hasEvolved': false,
      'oldName': '',
      'newName': '',
      'newLevel': 0,
    };
 
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
 
        bool hasEvolved = false;
        String currentName = active;
        String newName = currentName;
 
        final eeveeCycle = ['Eevee', 'Vaporeon', 'Jolteon', 'Flareon'];
        if (eeveeCycle.contains(currentName)) {
          int cycleStage = pLevel ~/ 10; 
          if (cycleStage > 0) {
            int targetIndex = ((cycleStage - 1) % 3) + 1;
            String calculatedName = eeveeCycle[targetIndex];
            if (calculatedName != currentName) {
              newName = calculatedName;
              hasEvolved = true;
            }
          }
        } 
        else if (evolutions.containsKey(currentName)) {
          final evoData = evolutions[currentName]!;
          if (pLevel >= evoData['level']) {
            newName = evoData['target'];
            hasEvolved = true;
          }
        }
 
        if (hasEvolved) {
          partners[newName] = {
            'exp': pExp,
            'level': pLevel,
            'image': 'assets/${newName.toLowerCase()}.gif' 
          };
          
          pData['exp'] = pExp;
          pData['level'] = pLevel;
          partners[currentName] = pData;
          
          await db.put('active_partner', newName);
 
          final history = List<dynamic>.from(db.get('unlocked_history') ?? []);
          if (!history.contains(newName)) {
            history.add(newName);
            await db.put('unlocked_history', history);
          }
 
          evolutionResult = {
            'hasEvolved': true,
            'oldName': currentName,
            'newName': newName,
            'newLevel': pLevel,
          };
 
        } else {
          pData['exp'] = pExp;
          pData['level'] = pLevel;
          partners[currentName] = pData;
        }
        
        await db.put('partners', partners);
      }
    }
 
    return evolutionResult;
  }
 
  Future<String> hatchPartner() async {
    final db = await database;
    
    final statsMap = Map<dynamic, dynamic>.from(
        db.get('user_stats') ?? {'total_xp': 0, 'level': 1, 'available_pulls': 0});
    int pulls = statsMap['available_pulls'] ?? 0;
 
    if (pulls <= 0) return 'NO_PULLS';
 
    final partners = Map<dynamic, dynamic>.from(db.get('partners') ?? {});
    final history = List<dynamic>.from(db.get('unlocked_history') ?? []);
    
    final evolvedForms = getEvolvedForms();
 
    final AssetManifest assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final List<String> allAssets = assetManifest.listAssets();
    
    final unownedAssets = allAssets.where((String path) {
      if (!path.startsWith('assets/') || !path.endsWith('.gif')) return false;
      final rawName = path.split('/').last.replaceAll('.gif', '');
      final formattedName = rawName[0].toUpperCase() + rawName.substring(1);
      
      return !history.contains(formattedName) && !evolvedForms.contains(formattedName);
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
 
  
    history.add(formattedName);
    await db.put('unlocked_history', history);
    
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
 