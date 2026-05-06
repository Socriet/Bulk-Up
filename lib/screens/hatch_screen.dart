import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../database_helper.dart';

class HatchScreen extends StatefulWidget {
  const HatchScreen({super.key});

  @override
  State<HatchScreen> createState() => _HatchScreenState();
}

class _HatchScreenState extends State<HatchScreen> {
  bool _isHatching = false;
  int _availablePulls = 0;

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
    final m = Map<dynamic, dynamic>.from(db.get('user_stats') ?? {});
    if (mounted) {
      setState(() {
        _availablePulls = m['available_pulls'] ?? 0;
      });
    }
  }

  @override
  void dispose() {
    DatabaseHelper.instance.database
        .then((db) => db.listenable().removeListener(_onDbChange));
    super.dispose();
  }

  Future<void> _hatchEgg() async {
    if (_availablePulls <= 0) return;
    
    setState(() => _isHatching = true);
    
    await Future.delayed(const Duration(milliseconds: 600));
    final hatchedName = await DatabaseHelper.instance.hatchPartner();
    
    if (mounted) {
      setState(() => _isHatching = false);

      if (hatchedName == 'NO_PULLS') return;

      if (hatchedName == 'ALL_UNLOCKED') {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1F1F1F),
            title: const Text('Pokédex Complete! 🏆', textAlign: TextAlign.center),
            content: const Text(
              'Incredible work! You have hatched every single Pokémon currently available.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade700,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          )
        );
        return;
      }

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1F1F1F),
          title: const Text('Egg Hatched! 🥚✨', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/${hatchedName.toLowerCase()}.gif', 
                height: 120, 
                errorBuilder: (c, e, s) => const Icon(Icons.pets, size: 80, color: Colors.greenAccent)
              ),
              const SizedBox(height: 16),
              Text('You hatched a $hatchedName!', 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Check your Pokédex to set them as your active partner.', 
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.shade700,
                  foregroundColor: Colors.black,
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Awesome', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hatch an Egg',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Use your available pulls to open an egg.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 28),
          Center(
            child: Column(
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F1F),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _availablePulls > 0 ? Colors.greenAccent : Colors.grey.shade800,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: _isHatching 
                      ? const CircularProgressIndicator(color: Colors.greenAccent)
                      : Text('$_availablePulls', style: TextStyle(fontSize: 64, color: _availablePulls > 0 ? Colors.white : Colors.grey.shade700)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Available Pulls',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Complete workouts to level up!',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _availablePulls > 0 ? Colors.greenAccent.shade700 : Colors.grey.shade800,
                foregroundColor: _availablePulls > 0 ? Colors.black : Colors.grey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: (_isHatching || _availablePulls <= 0) ? null : _hatchEgg,
              icon: const Icon(Icons.egg),
              label: Text(
                _availablePulls > 0 ? 'OPEN LOOTBOX (1 PULL)' : 'NOT ENOUGH PULLS',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'HOW IT WORKS',
            style: TextStyle(
                color: Colors.grey, fontSize: 12, letterSpacing: 1.5),
          ),
          const SizedBox(height: 12),
          // Replaced the text exactly as requested
          const _InfoTile(
            icon: '🆙',
            title: 'Level Up',
            subtitle: 'Every time you level up you get the option to open an egg.',
          ),
          const SizedBox(height: 8),
          const _InfoTile(
            icon: '🎲',
            title: 'Random hatch',
            subtitle: 'Spend a pull to hatch a random Pokémon.',
          ),
          const SizedBox(height: 8),
          const _InfoTile(
            icon: '📖',
            title: 'Collect them all',
            subtitle: 'Hatched Pokémon appear in your Pokédex.',
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}