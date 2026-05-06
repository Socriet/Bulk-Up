import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../database_helper.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key});

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<dynamic, dynamic> _partners = {};
  String _activePartner = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    if (mounted) {
      setState(() {
        _partners = Map<dynamic, dynamic>.from(db.get('partners') ?? {});
        _activePartner = db.get('active_partner') as String? ?? '';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    DatabaseHelper.instance.database
        .then((db) => db.listenable().removeListener(_onDbChange));
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _setActive(String name) async {
    await DatabaseHelper.instance.setActivePartner(name);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
    }

    return Column(
      children: [
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
            children: [
              _MyPokemonTab(
                partners: _partners,
                activePartner: _activePartner,
                onSetActive: _setActive,
              ),
              _CatalogTab(
                partners: _partners,
                activePartner: _activePartner,
                onSetActive: _setActive,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── My Pokémon tab ────────────────────────────────────────────────────────────

class _MyPokemonTab extends StatelessWidget {
  final Map<dynamic, dynamic> partners;
  final String activePartner;
  final Function(String) onSetActive;

  const _MyPokemonTab({
    required this.partners, 
    required this.activePartner, 
    required this.onSetActive
  });

  @override
  Widget build(BuildContext context) {
    if (partners.isEmpty) {
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
                'Head over to the Hatch tab to open your first egg!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: partners.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final name = partners.keys.elementAt(index);
        final data = partners[name];
        final isActive = name == activePartner;
        
        final types = DatabaseHelper.pokemonTypes[name] ?? ['Unknown'];

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PokemonDetailScreen(
                  name: name,
                  data: data,
                  types: types,
                  isActive: isActive,
                  onSetActive: () {
                    onSetActive(name);
                    Navigator.pop(context);
                  },
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F1F),
              borderRadius: BorderRadius.circular(12),
              border: isActive ? Border.all(color: Colors.greenAccent) : null,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Image.asset(data['image'], errorBuilder: (c, e, s) => const Icon(Icons.pets, color: Colors.grey)),
              ),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Level ${data['level']}  •  Exp: ${data['exp']}'),
              trailing: isActive
                ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                : const Icon(Icons.chevron_right, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}

// ── Pokémon Detail Screen ───────────────────────────────────────────────────

class PokemonDetailScreen extends StatelessWidget {
  final String name;
  final Map<dynamic, dynamic> data;
  final List<String> types;
  final bool isActive;
  final VoidCallback onSetActive;

  const PokemonDetailScreen({
    super.key,
    required this.name,
    required this.data,
    required this.types,
    required this.isActive,
    required this.onSetActive,
  });

  @override
  Widget build(BuildContext context) {
    final int pLevel = data['level'] ?? 1;
    final int pExp = data['exp'] ?? 0;
    final int pNext = pLevel * 100;
    final double pProgress = (pExp / pNext).clamp(0.0, 1.0);
    final int pToNext = pNext - pExp;

    return Scaffold(
      appBar: AppBar(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Image.asset(
                data['image'], 
                height: 200,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.pets, size: 100, color: Colors.greenAccent),
              ),
            ),
            const SizedBox(height: 24),
            
            // Types Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: types.map((type) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Text(
                    type.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),

            // Independent Partner XP bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Level $pLevel',
                          style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      Text('Level ${pLevel + 1}',
                          style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: pProgress,
                      minHeight: 18,
                      backgroundColor: Colors.grey.shade800,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text('$pToNext XP to next level',
                        style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Set Active Button
            if (!isActive)
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade700,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onSetActive,
                  icon: const Icon(Icons.favorite),
                  label: const Text(
                    'SET AS ACTIVE PARTNER',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.greenAccent),
                    SizedBox(width: 8),
                    Text(
                      'CURRENT ACTIVE PARTNER',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
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
  final Map<dynamic, dynamic> partners;
  final String activePartner;
  final Function(String) onSetActive;
  
  const _CatalogTab({
    required this.partners,
    required this.activePartner,
    required this.onSetActive,
  });

  @override
  Widget build(BuildContext context) {
    // Automatically generates an alphabetical list from the database typings
    final List<String> catalogOrder = DatabaseHelper.pokemonTypes.keys.toList()..sort();
    final int totalCollected = partners.length;
    final int totalSlots = catalogOrder.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(
                '$totalCollected / $totalSlots discovered',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                ),
                child: const Text(
                  'Generation 1',
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: totalSlots,
            itemBuilder: (context, index) {
              final pokemonName = catalogOrder[index];
              final isUnlocked = partners.containsKey(pokemonName);

              if (isUnlocked) {
                return _UnlockedSlot(
                  name: pokemonName,
                  data: partners[pokemonName],
                  isActive: pokemonName == activePartner,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PokemonDetailScreen(
                          name: pokemonName,
                          data: partners[pokemonName],
                          types: DatabaseHelper.pokemonTypes[pokemonName] ?? ['Unknown'],
                          isActive: pokemonName == activePartner,
                          onSetActive: () {
                            onSetActive(pokemonName);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                );
              } else {
                return _LockedSlot(number: index + 1);
              }
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
          const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
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

class _UnlockedSlot extends StatelessWidget {
  final String name;
  final Map<dynamic, dynamic> data;
  final bool isActive;
  final VoidCallback onTap;

  const _UnlockedSlot({
    required this.name,
    required this.data,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(12),
          border: isActive 
              ? Border.all(color: Colors.greenAccent, width: 2) 
              : Border.all(color: Colors.greenAccent.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  data['image'], 
                  errorBuilder: (c, e, s) => const Icon(Icons.pets, color: Colors.greenAccent)
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: const BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12), 
                  bottomRight: Radius.circular(12)
                ),
              ),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.greenAccent : Colors.white
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}