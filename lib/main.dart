import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const ShadowFightUltraApp());
}

class ShadowFightUltraApp extends StatelessWidget {
  const ShadowFightUltraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SHADOW FIGHT ARENA: ULTRA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF090A0F),
        colorScheme: const ColorScheme.dark(
          primary: Colors.redAccent,
          secondary: Colors.amber,
        ),
      ),
      home: const InitialCheckScreen(),
    );
  }
}

class InitialCheckScreen extends StatefulWidget {
  const InitialCheckScreen({super.key});

  @override
  State<InitialCheckScreen> createState() => _InitialCheckScreenState();
}

class _InitialCheckScreenState extends State<InitialCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    final prefs = await SharedPreferences.getInstance();
    bool isSetupComplete = prefs.getBool('is_setup_complete') ?? false;

    if (!mounted) return;
    if (isSetupComplete) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FreeFireLobbyScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegistrationScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Colors.amber)),
    );
  }
}

// 1. SKRIN PENDAFTARAN & NAMA ACAK & BAHASA
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedLanguage = "Indonesia";

  final List<String> _randomNames = [
    "SHADOW_KING", "DRAGON_SLAYER", "NINJA_PRO", "VIPER_STRIKE",
    "GHOST_WALKER", "PHANTOM_X", "ALPHA_KATANA", "RONIN_MASTER"
  ];

  void _generateRandomName() {
    final rand = Random();
    setState(() {
      _nameController.text = _randomNames[rand.nextInt(_randomNames.length)];
    });
  }

  Future<void> _saveAndContinue() async {
    if (_nameController.text.trim().isEmpty) {
      _generateRandomName();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('player_name', _nameController.text.trim());
    await prefs.setString('language', _selectedLanguage);
    await prefs.setBool('is_setup_complete', true);

    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FreeFireLobbyScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: 420,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B26).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("BUAT PROFIL KAMU", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: "Nama Pemain",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person, color: Colors.amber),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _generateRandomName,
                          icon: const Icon(Icons.casino, color: Colors.cyan, size: 32),
                          tooltip: "Acak Nama",
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedLanguage,
                      decoration: const InputDecoration(labelText: "Pilih Bahasa", border: OutlineInputBorder()),
                      items: ["Indonesia", "English"].map((lang) {
                        return DropdownMenuItem(value: lang, child: Text(lang));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedLanguage = val!),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveAndContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text("MASUK KE LOBI", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 2. LOBI UTAMA (FF STYLE)
class FreeFireLobbyScreen extends StatefulWidget {
  const FreeFireLobbyScreen({super.key});

  @override
  State<FreeFireLobbyScreen> createState() => _FreeFireLobbyScreenState();
}

class _FreeFireLobbyScreenState extends State<FreeFireLobbyScreen> {
  String _playerName = "SAMURAI MASTER";
  int _gems = 5000;
  int _coins = 25000;
  
  // Settings Grafis FF Style
  String _graphicsQuality = "HD ULTRA";
  bool _highFps = true;
  bool _bgmEnabled = true;

  // Selected Assets / Vault State
  Color _outfitColor = Colors.cyanAccent;
  String _outfitName = "Kostum Cyber Ninja";

  Color _weaponColor = Colors.orangeAccent;
  String _weaponName = "Flame Katana";
  int _weaponAtk = 40;

  String _fatalitySkill = "Dragon Flame Execution";

  // Data Vault
  final List<Map<String, dynamic>> _outfits = [
    {"name": "Kostum Cyber Ninja", "color": Colors.cyanAccent, "owned": true},
    {"name": "Baju Red Crimson", "color": Colors.redAccent, "owned": true},
    {"name": "Jubah Shadow Shogun", "color": Colors.purpleAccent, "owned": false, "price": 1000},
    {"name": "Zirah Emas Wushu", "color": Colors.amberAccent, "owned": false, "price": 1500},
  ];

  final List<Map<String, dynamic>> _weapons = [
    {"name": "Flame Katana", "color": Colors.orangeAccent, "bonus": 40, "owned": true},
    {"name": "Thunder Blade", "color": Colors.cyanAccent, "bonus": 60, "owned": false, "price": 1200},
    {"name": "Frost Spear", "color": Colors.lightBlue, "bonus": 55, "owned": false, "price": 1000},
  ];

  final List<Map<String, dynamic>> _fatalities = [
    {"name": "Dragon Flame Execution", "desc": "Tebasan Naga Api Vataliti", "owned": true},
    {"name": "Thunder Strike Finisher", "desc": "Sambaran Petir Mematikan", "owned": false, "price": 2000},
  ];

  @override
  void initState() {
    super.initState();
    _loadGameData();
  }

  Future<void> _loadGameData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _playerName = prefs.getString('player_name') ?? "SAMURAI MASTER";
      _gems = prefs.getInt('gems') ?? 5000;
      _coins = prefs.getInt('coins') ?? 25000;
      _graphicsQuality = prefs.getString('graphics') ?? "HD ULTRA";
    });
  }

  Future<void> _saveGameData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('player_name', _playerName);
    await prefs.setInt('gems', _gems);
    await prefs.setInt('coins', _coins);
    await prefs.setString('graphics', _graphicsQuality);
  }

  void _openSettings() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDlgState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF161B26),
            title: const Row(
              children: [
                Icon(Icons.settings, color: Colors.amber),
                SizedBox(width: 8),
                Text("PENGATURAN GRAFIK & SUARA", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("KUALITAS GRAFIK (Garena FF Style):", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ["Satu (Smooth)", "Standar", "HD", "HD ULTRA"].map((q) {
                      bool isSel = _graphicsQuality == q;
                      return ChoiceChip(
                        label: Text(q),
                        selected: isSel,
                        selectedColor: Colors.amber,
                        onSelected: (val) {
                          setDlgState(() => _graphicsQuality = q);
                          setState(() => _graphicsQuality = q);
                          _saveGameData();
                        },
                      );
                    }).toList(),
                  ),
                  const Divider(color: Colors.white24, height: 24),
                  SwitchListTile(
                    title: const Text("High FPS"),
                    value: _highFps,
                    onChanged: (val) => setDlgState(() => setState(() => _highFps = val)),
                  ),
                  SwitchListTile(
                    title: const Text("Musik BGM"),
                    value: _bgmEnabled,
                    onChanged: (val) => setDlgState(() => setState(() => _bgmEnabled = val)),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("TUTUP", style: TextStyle(color: Colors.cyan)),
              )
            ],
          );
        },
      ),
    );
  }

  void _openVault() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      isScrollControlled: true,
      builder: (context) => DefaultTabController(
        length: 3,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const TabBar(
                indicatorColor: Colors.amber,
                labelColor: Colors.amber,
                unselectedLabelColor: Colors.white60,
                tabs: [
                  Tab(icon: Icon(Icons.checkroom), text: "BAJU / SKIN"),
                  Tab(icon: Icon(Icons.security), text: "PEDANG"),
                  Tab(icon: Icon(Icons.bolt), text: "FATALITY"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Tab Baju
                    ListView.builder(
                      itemCount: _outfits.length,
                      itemBuilder: (ctx, i) {
                        var o = _outfits[i];
                        return Card(
                          color: const Color(0xFF1F2937),
                          child: ListTile(
                            leading: Icon(Icons.checkroom, color: o["color"], size: 32),
                            title: Text(o["name"]),
                            trailing: o["owned"]
                                ? ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _outfitName = o["name"];
                                        _outfitColor = o["color"];
                                      });
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    child: const Text("PAKAI"),
                                  )
                                : ElevatedButton(
                                    onPressed: () {
                                      if (_gems >= o["price"]) {
                                        setState(() {
                                          _gems -= (o["price"] as int);
                                          o["owned"] = true;
                                          _saveGameData();
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                                    child: Text("BELI (${o['price']} Gem)"),
                                  ),
                          ),
                        );
                      },
                    ),
                    // Tab Pedang
                    ListView.builder(
                      itemCount: _weapons.length,
                      itemBuilder: (ctx, i) {
                        var w = _weapons[i];
                        return Card(
                          color: const Color(0xFF1F2937),
                          child: ListTile(
                            leading: Icon(Icons.flash_on, color: w["color"], size: 32),
                            title: Text(w["name"]),
                            subtitle: Text("Damage ATK: +${w['bonus']}"),
                            trailing: w["owned"]
                                ? ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _weaponName = w["name"];
                                        _weaponColor = w["color"];
                                        _weaponAtk = w["bonus"];
                                      });
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    child: const Text("PAKAI"),
                                  )
                                : ElevatedButton(
                                    onPressed: () {
                                      if (_gems >= w["price"]) {
                                        setState(() {
                                          _gems -= (w["price"] as int);
                                          w["owned"] = true;
                                          _saveGameData();
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                                    child: Text("BELI (${w['price']} Gem)"),
                                  ),
                          ),
                        );
                      },
                    ),
                    // Tab Fatality
                    ListView.builder(
                      itemCount: _fatalities.length,
                      itemBuilder: (ctx, i) {
                        var f = _fatalities[i];
                        return Card(
                          color: const Color(0xFF1F2937),
                          child: ListTile(
                            leading: const Icon(Icons.local_fire_department, color: Colors.redAccent, size: 32),
                            title: Text(f["name"]),
                            subtitle: Text(f["desc"]),
                            trailing: f["owned"]
                                ? ElevatedButton(
                                    onPressed: () {
                                      setState(() => _fatalitySkill = f["name"]);
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    child: const Text("PAKAI"),
                                  )
                                : ElevatedButton(
                                    onPressed: () {
                                      if (_gems >= f["price"]) {
                                        setState(() {
                                          _gems -= (f["price"] as int);
                                          f["owned"] = true;
                                          _saveGameData();
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                                    child: Text("BELI (${f['price']} Gem)"),
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _openShop() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("TOKO DIAMOND / GEM", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.cyan)),
            const SizedBox(height: 16),
            ListTile(
              tileColor: const Color(0xFF1F2937),
              leading: const Icon(Icons.diamond, color: Colors.cyan, size: 32),
              title: const Text("1,000 Diamond"),
              subtitle: const Text("Rp 15.000"),
              trailing: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _gems += 1000;
                    _saveGameData();
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                child: const Text("BELI"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background Grafik
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A), Color(0xFF030712)],
                  radius: 1.2,
                ),
              ),
            ),

            // Podium & Character Rendering
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 180,
                        height: 36,
                        margin: const EdgeInsets.only(top: 140),
                        decoration: BoxDecoration(
                          color: _outfitColor.withOpacity(0.3),
                          borderRadius: const BorderRadius.all(Radius.elliptical(90, 18)),
                          boxShadow: [BoxShadow(color: _outfitColor, blurRadius: 20)],
                        ),
                      ),
                      HumanCharacterWidget(
                        color: _outfitColor,
                        weaponColor: _weaponColor,
                        height: 160,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(_outfitName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _outfitColor)),
                  Text("Pedang: $_weaponName | Jurus: $_fatalitySkill", style: const TextStyle(fontSize: 11, color: Colors.white70)),
                ],
              ),
            ),

            // Top Status Bar
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: _openSettings,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_playerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text("Grafik: $_graphicsQuality", style: const TextStyle(color: Colors.amber, fontSize: 10)),
                        ],
                      )
                    ],
                  ),
                  Row(
                    children: [
                      _buildChip(Icons.monetization_on, "$_coins", Colors.amber),
                      const SizedBox(width: 8),
                      _buildChip(Icons.diamond, "$_gems", Colors.cyan),
                    ],
                  )
                ],
              ),
            ),

            // Menu Kiri (FF Style)
            Positioned(
              left: 16,
              top: 70,
              child: Column(
                children: [
                  _buildLobbyBtn("VAULT", Icons.inventory_2, _openVault),
                  const SizedBox(height: 12),
                  _buildLobbyBtn("TOKO", Icons.shopping_cart, _openShop),
                ],
              ),
            ),

            // Tombol MULAI Pertarungan (FF Style)
            Positioned(
              bottom: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BattleArenaScreen(
                        playerName: _playerName,
                        outfitColor: _outfitColor,
                        weaponName: _weaponName,
                        weaponColor: _weaponColor,
                        weaponAtk: _weaponAtk,
                        fatalitySkill: _fatalitySkill,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 10,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.play_arrow, size: 28, color: Colors.black),
                    SizedBox(width: 6),
                    Text("MULAI", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.black)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String txt, Color col) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12), border: Border.all(color: col)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: col),
          const SizedBox(width: 4),
          Text(txt, style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLobbyBtn(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.amber, size: 22),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

// 3. WIDGET VISUAL KARAKTER MANUSIA
class HumanCharacterWidget extends StatelessWidget {
  final Color color;
  final Color weaponColor;
  final double height;
  final bool isEnemy;

  const HumanCharacterWidget({
    super.key,
    required this.color,
    required this.weaponColor,
    this.height = 100,
    this.isEnemy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(isEnemy ? pi : 0),
      child: SizedBox(
        height: height,
        width: height * 0.6,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              child: Container(
                width: height * 0.22,
                height: height * 0.22,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
            Positioned(
              top: height * 0.24,
              child: Container(
                width: height * 0.28,
                height: height * 0.38,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
              ),
            ),
            Positioned(
              top: height * 0.28,
              right: 0,
              child: Transform.rotate(
                angle: -0.5,
                child: Container(
                  width: height * 0.08,
                  height: height * 0.45,
                  decoration: BoxDecoration(color: weaponColor, borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: height * 0.08,
              child: Container(width: height * 0.1, height: height * 0.38, color: color),
            ),
            Positioned(
              bottom: 0,
              right: height * 0.08,
              child: Container(width: height * 0.1, height: height * 0.38, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// 4. ARENA PERTARUNGAN
class BattleArenaScreen extends StatefulWidget {
  final String playerName;
  final Color outfitColor;
  final String weaponName;
  final Color weaponColor;
  final int weaponAtk;
  final String fatalitySkill;

  const BattleArenaScreen({
    super.key,
    required this.playerName,
    required this.outfitColor,
    required this.weaponName,
    required this.weaponColor,
    required this.weaponAtk,
    required this.fatalitySkill,
  });

  @override
  State<BattleArenaScreen> createState() => _BattleArenaScreenState();
}

class _BattleArenaScreenState extends State<BattleArenaScreen> {
  int _playerHp = 100;
  int _enemyHp = 130;
  bool _isBattleActive = true;
  String _logText = "FIGHT!";

  void _playerAttack(bool isFatality) {
    if (!_isBattleActive) return;

    int dmg = 12 + widget.weaponAtk ~/ 3;
    if (isFatality) dmg += 25;

    setState(() {
      _enemyHp = max(0, _enemyHp - dmg);
      _logText = isFatality ? "JURUS VATALITI (${widget.fatalitySkill.toUpperCase()})! -$dmg HP!" : "TEBASAN ${widget.weaponName.toUpperCase()}! -$dmg HP!";

      if (_enemyHp <= 0) {
        _isBattleActive = false;
        _logText = "VICTORY! MUSUH DIKALAHKAN!";
      } else {
        _enemyTurn();
      }
    });
  }

  void _enemyTurn() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!_isBattleActive || !mounted) return;
      setState(() {
        _playerHp = max(0, _playerHp - 12);
        _logText = "MUSUH MEMBALAS SERANGAN!";
        if (_playerHp <= 0) {
          _isBattleActive = false;
          _logText = "DEFEAT! KAMU DIKALAHKAN!";
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(color: const Color(0xFF0F172A)),
            Positioned(
              top: 12,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.playerName, style: TextStyle(color: widget.outfitColor, fontWeight: FontWeight.bold)),
                        LinearProgressIndicator(value: _playerHp / 100, color: widget.outfitColor, minHeight: 8),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("VS", style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text("SHADOW SHOGUN (PRO AI)", style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
                        LinearProgressIndicator(value: 120 / 130, color: Colors.purpleAccent, minHeight: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Center(child: Text(_logText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber))),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.2,
              bottom: 60,
              child: HumanCharacterWidget(color: widget.outfitColor, weaponColor: widget.weaponColor, height: 120),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.7,
              bottom: 60,
              child: const HumanCharacterWidget(color: Colors.purpleAccent, weaponColor: Colors.red, height: 120, isEnemy: true),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _playerAttack(false),
                    style: ElevatedButton.styleFrom(backgroundColor: widget.weaponColor, foregroundColor: Colors.black),
                    child: const Text("TEBASAN"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _playerAttack(true),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    child: const Text("VATALITI"),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            )
          ],
        ),
      ),
    );
  }
}
