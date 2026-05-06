import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../database_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalXp = 0;
  int _level = 1;
  double _totalVolume = 0;
  String _activePartner = '';
  Map<dynamic, dynamic> _partnerData = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = await DatabaseHelper.instance.database;
    db.listenable().addListener(_onDbChange);
    _read(db);
  }

  void _onDbChange() async {
    final db = await DatabaseHelper.instance.database;
    _read(db);
  }

  void _read(Box db) {
    final m = Map<dynamic, dynamic>.from(
        db.get('user_stats') ?? {'total_xp': 0, 'level': 1});
        
    final active = db.get('active_partner') as String? ?? '';
    final partners = Map<dynamic, dynamic>.from(db.get('partners') ?? {});
    
    // Calculate Total Volume from history
    final workouts = List<dynamic>.from(db.get('workouts') ?? []);
    double vol = 0;
    for(var w in workouts) {
      vol += (w['volume'] as num? ?? 0).toDouble();
    }

    if (mounted) {
      setState(() {
        _totalXp = m['total_xp'] as int;
        _level = m['level'] as int;
        _totalVolume = vol;
        _activePartner = active;
        if (active.isNotEmpty && partners.containsKey(active)) {
          _partnerData = Map<dynamic, dynamic>.from(partners[active]);
        } else {
          _partnerData = {};
        }
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    DatabaseHelper.instance.database
        .then((db) => db.listenable().removeListener(_onDbChange));
    super.dispose();
  }

  // --- TRAINER LEVEL MATH HELPERS ---
  int _getTrainerBaseXp(int level) {
    const thresholds = [0, 1000, 3000, 6000, 10000, 15000];
    if (level <= 6) return thresholds[level - 1];
    return 15000 + ((level - 6) * 5000);
  }

  int _getTrainerNextLevelXp(int level) {
    const thresholds = [0, 1000, 3000, 6000, 10000, 15000];
    if (level < 6) return thresholds[level];
    return 15000 + ((level - 5) * 5000);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.greenAccent));
    }

    // Partner EXP Math
    final pLevel = _partnerData['level'] as int? ?? 1;
    final pExp = _partnerData['exp'] as int? ?? 0;
    final pNext = pLevel * 100;
    final pProgress = (pExp / pNext).clamp(0.0, 1.0);
    final pToNext = pNext - pExp;

    // Trainer EXP Math
    final tBase = _getTrainerBaseXp(_level);
    final tNext = _getTrainerNextLevelXp(_level);
    final tCurrent = _totalXp - tBase;
    final tRange = tNext - tBase;
    final tProgress = (tCurrent / tRange).clamp(0.0, 1.0);
    final tToNext = tNext - _totalXp;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          
          // Partner Display Area
          if (_activePartner.isNotEmpty) ...[
            Image.asset(
              _partnerData['image'], 
              width: 150, 
              height: 150,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.pets, size: 100, color: Colors.greenAccent),
            ),
            const SizedBox(height: 16),
            Text(_activePartner,
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Partner Level $pLevel',
                style: const TextStyle(fontSize: 16, color: Colors.greenAccent)),
          ] else ...[
            const Icon(Icons.pets, size: 100, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No Partner Selected',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 6),
            const Text('Hatch an egg and set a partner to begin!',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
          
          const SizedBox(height: 24),

          // --- PARTNER EXP BAR ---
          if (_activePartner.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Partner Lv. $pLevel',
                          style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                      Text('Lv. ${pLevel + 1}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pProgress,
                      minHeight: 14,
                      backgroundColor: Colors.grey.shade800,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.greenAccent),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('$pToNext XP to next level',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
            
          // --- TRAINER EXP BAR ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F1F),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)), 
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Trainer Lv. $_level',
                        style: const TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    Text('Lv. ${_level + 1}',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: tProgress,
                    minHeight: 14,
                    backgroundColor: Colors.grey.shade800,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.orangeAccent),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$_totalXp Total XP',
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('$tToNext XP to level up',
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- FULL WIDTH KG LIFTED STAT ---
          SizedBox(
            width: double.infinity,
            child: _StatBox(
                label: 'Total KG Lifted',
                value: '${_totalVolume.toStringAsFixed(0)}',
                color: Colors.greenAccent),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatBox(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 28, // Made slightly larger to pop out more
                  fontWeight: FontWeight.bold,
                  color: color)),
          const SizedBox(height: 6),
          Text(label,
              style:
                  const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}