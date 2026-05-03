import 'package:flutter/material.dart';

class HatchScreen extends StatelessWidget {
  const HatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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

          // Egg display
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
                  child: const Center(
                    child: Text('🥚', style: TextStyle(fontSize: 72)),
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

          // Egg progress bar (placeholder)
          Container(
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
                    const Text(
                      'Hatch Progress',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '0 / 500 XP',
                      style: TextStyle(
                          color: Colors.grey.shade400, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: 0,
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade800,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.greenAccent),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Earn XP by completing exercises to hatch your egg.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Hatch button (disabled for now)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800,
                foregroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: null,
              icon: const Text('🥚', style: TextStyle(fontSize: 20)),
              label: const Text(
                'NOT READY YET',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Coming soon section
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
