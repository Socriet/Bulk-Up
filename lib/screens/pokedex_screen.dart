import 'package:flutter/material.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key});

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar: My Pokémon / All Pokémon
        Container(
          color: const Color(0xFF1F1F1F),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.greenAccent,
            labelColor: Colors.greenAccent,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'My Pokémon'),
              Tab(text: 'Catalog'),
            ],
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _MyPokemonTab(),
              _CatalogTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ── My Pokémon tab ────────────────────────────────────────────────────────────

class _MyPokemonTab extends StatelessWidget {
  const _MyPokemonTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('❓', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            const Text(
              'No Pokémon yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hatch eggs to add Pokémon to your collection.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Partner selector placeholder
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.greenAccent.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text(
                    'ACTIVE PARTNER',
                    style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text('❓', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  const Text(
                    'No partner selected',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Hatch a Pokémon and set it as your partner\nto start leveling it up.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        foregroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: null,
                      child: const Text('Choose Partner'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Catalog tab ───────────────────────────────────────────────────────────────

class _CatalogTab extends StatelessWidget {
  const _CatalogTab();

  // Placeholder Pokémon slots — locked until hatched
  static const int _totalSlots = 12;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Text(
                '0 / $_totalSlots discovered',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.greenAccent.withOpacity(0.3)),
                ),
                child: const Text(
                  'More coming soon',
                  style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 11,
                      letterSpacing: 0.5),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: _totalSlots,
            itemBuilder: (context, index) {
              return _LockedSlot(number: index + 1);
            },
          ),
        ),
      ],
    );
  }
}

class _LockedSlot extends StatelessWidget {
  final int number;
  const _LockedSlot({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, color: Colors.grey, size: 28),
          const SizedBox(height: 6),
          Text(
            '#${number.toString().padLeft(3, '0')}',
            style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
