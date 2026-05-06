import 'package:flutter/material.dart';
import '../database_helper.dart';

class HatchScreen extends StatefulWidget {
  const HatchScreen({super.key});

  @override
  State<HatchScreen> createState() => _HatchScreenState();
}

class _HatchScreenState extends State<HatchScreen> {
  bool _isHatching = false;

  Future<void> _hatchEgg() async {
    setState(() => _isHatching = true);
    
    await Future.delayed(const Duration(milliseconds: 600));
    final hatchedName = await DatabaseHelper.instance.hatchPartner();
    
    if (mounted) {
      setState(() => _isHatching = false);
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
            'Complete workouts to fill your egg meter and hatch a new Pokémon.',
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
                      color: Colors.greenAccent.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: _isHatching 
                      ? const CircularProgressIndicator(color: Colors.greenAccent)
                      : const Text('🥚', style: TextStyle(fontSize: 72)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Mystery Egg',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Who could be inside?',
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
                backgroundColor: Colors.greenAccent.shade700,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isHatching ? null : _hatchEgg,
              icon: const Icon(Icons.egg),
              label: const Text(
                'OPEN LOOTBOX (TEST)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
          _InfoTile(
            icon: '💪',
            title: 'Complete exercises',
            subtitle: 'Every Done tap fills your egg meter with XP.',
          ),
          const SizedBox(height: 8),
          _InfoTile(
            icon: '🎲',
            title: 'Random hatch',
            subtitle: 'When the meter is full, a random Pokémon hatches.',
          ),
          const SizedBox(height: 8),
          _InfoTile(
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