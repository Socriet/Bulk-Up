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
  bool _loading = true;

  static const List<int> _levelThresholds = [0, 1000, 3000, 6000, 10000, 15000];

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
    if (mounted) {
      setState(() {
        _totalXp = m['total_xp'] as int;
        _level = m['level'] as int;
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

  int get _xpForCurrentLevel =>
      _level <= 1 ? 0 : _levelThresholds[_level - 1];

  int get _xpForNextLevel => _level < _levelThresholds.length
      ? _levelThresholds[_level]
      : _levelThresholds.last + 5000;

  double get _levelProgress {
    final range = _xpForNextLevel - _xpForCurrentLevel;
    final earned = _totalXp - _xpForCurrentLevel;
    return (earned / range).clamp(0.0, 1.0);
  }

  int get _xpToNextLevel => _xpForNextLevel - _totalXp;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.greenAccent));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.pets, size: 100, color: Colors.greenAccent),
          const SizedBox(height: 16),
          Text('Level $_level',
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('$_totalXp XP total',
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 24),

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
                    Text('Level $_level',
                        style: const TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    Text('Level ${_level + 1}',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _levelProgress,
                    minHeight: 14,
                    backgroundColor: Colors.grey.shade800,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.greenAccent),
                  ),
                ),
                const SizedBox(height: 8),
                Text('$_xpToNextLevel XP to next level',
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                  child: _StatBox(
                      label: 'Total XP',
                      value: '$_totalXp',
                      color: Colors.greenAccent)),
              const SizedBox(width: 12),
              Expanded(
                  child: _StatBox(
                      label: 'Level',
                      value: '$_level',
                      color: Colors.orangeAccent)),
            ],
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
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color)),
          const SizedBox(height: 4),
          Text(label,
              style:
                  const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}
