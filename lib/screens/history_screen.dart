import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../database_helper.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<dynamic, dynamic>> _workouts = [];
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
    final raw = List<dynamic>.from(db.get('workouts') ?? []);
    if (mounted) {
      setState(() {
        _workouts = raw
            .map((e) => Map<dynamic, dynamic>.from(e))
            .toList()
            .reversed
            .toList();
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

  String _formatDate(String iso) {
    final d = DateTime.parse(iso);
    return '${d.day}/${d.month}/${d.year}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.greenAccent));
    }

    if (_workouts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('No activity yet',
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Complete exercises in your routines to see history here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _workouts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final w = _workouts[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1F1F1F),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle,
                  color: Colors.greenAccent, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(w['exercise'] as String,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(
                      '${(w['volume'] as num).toStringAsFixed(0)} kg volume',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 13),
                    ),
                    Text(_formatDate(w['date'] as String),
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${w['xp_earned']} XP',
                  style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
