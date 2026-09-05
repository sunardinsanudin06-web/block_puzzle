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
      home: const MainDashboardScreen(),
    );
  }
}

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  String _playerName = "SAMURAI MASTER";
  int _gems = 2500;
  int _coins = 15000;
  
  bool _bgmEnabled = true;
  bool _sfxEnabled = true;
  
  String _selectedWeapon = "Flame Katana";
  Color _weaponEffectColor = Colors.orangeAccent;
  int _weaponAtkBonus = 35;
  
  final List<Map<String, dynamic>> _weaponsVault = [
    {"name": "Flame Katana", "color": Colors.orangeAccent, "bonus": 35, "price": 0, "owned": true, "type": "Fire"},
    {"name": "Thunder Blade", "color": Colors.cyanAccent, "bonus": 50, "price": 1000, "owned": false, "type": "Thunder"},
    {"name": "Frost Spear", "color": Colors.lightBlue, "bonus": 45, "price": 800, "owned": false, "type": "Ice"},
    {"name": "Venom Dagger", "color": Colors.greenAccent, "bonus": 60, "price": 1500, "owned": false, "type": "Poison"},
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
      _gems = prefs.getInt('gems') ?? 2500;
      _coins = prefs.getInt('coins') ?? 15000;
      _bgmEnabled = prefs.getBool('bgm') ?? true;
      _sfxEnabled = prefs.getBool('sfx') ?? true;
    });
  }

  Future<void> _saveGameData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('player_name', _playerName);
    await prefs.setInt('gems', _gems);
    await prefs.setInt('coins', _coins);
    await prefs.setBool('bgm', _bgmEnabled);
    await prefs.setBool('sfx', _sfxEnabled);
  }

  void _resetGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _loadGameData();
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data permainan berhasil direset!")),
      );
    }
  }

  void _showSettingsDialog() {
    TextEditingController nameController = TextEditingController(text: _playerName);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF161B26),
            title: const Row(
              children: [
                Icon(Icons.settings, color: Colors.redAccent),
                SizedBox(width: 8),
                Text("PENGATURAN GAME", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Nama Pemain", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text("Musik BGM (Kungfu Theme)"),
                    value: _bgmEnabled,
                    onChanged: (val) {
                      setDialogState(() => _bgmEnabled = val);
                      setState(() => _bgmEnabled = val);
                      _saveGameData();
                    },
                  ),
                  SwitchListTile(
                    title: const Text("Efek Suara Perkelahian (SFX)"),
                    value: _sfxEnabled,
                    onChanged: (val) {
                      setDialogState(() => _sfxEnabled = val);
                      setState(() => _sfxEnabled = val);
                      _saveGameData();
                    },
                  ),
                  const Divider(color: Colors.white24),
                  ElevatedButton.icon(
                    onPressed: _resetGame,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text("Mengulang Permainan (Reset)"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _playerName = nameController.text;
                    _saveGameData();
                  });
                  Navigator.pop(context);
                },
                child: const Text("SIMPAN", style: TextStyle(color: Colors.cyan)),
              )
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF4338CA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _weaponEffectColor.withOpacity(0.2),
                          border: Border.all(color: _weaponEffectColor, width: 3),
                        ),
                      ),
                      Icon(Icons.person_outline, size: 100, color: _weaponEffectColor),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_playerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  Text("Pedang: $_selectedWeapon (+$_weaponAtkBonus ATK)", style: TextStyle(color: _weaponEffectColor, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
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
                        onPressed: _showSettingsDialog,
                      ),
                      const SizedBox(width: 4),
                      Text("LV. 50 $_playerName", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
            Positioned(
              bottom: 16,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showVaultModal(),
                    icon: const Icon(Icons.shield),
                    label: const Text("VAULT"),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BattleArenaScreen(
                            playerName: _playerName,
                            weaponName: _selectedWeapon,
                            weaponColor: _weaponEffectColor,
                            weaponAtk: _weaponAtkBonus,
                            sfxEnabled: _sfxEnabled,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.sports_kabaddi, size: 24),
                    label: const Text("BERTARUNG", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showShopModal(),
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text("TOKO"),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
                  ),
                ],
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

  void _showVaultModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      builder: (context) => StatefulBuilder(
        builder: (context, setVaultState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("VAULT KOLEKSI PEDANG ELEMEN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: _weaponsVault.length,
                    itemBuilder: (context, idx) {
                      var w = _weaponsVault[idx];
                      return Card(
                        color: const Color(0xFF1F2937),
                        child: ListTile(
                          leading: Icon(Icons.flash_on, color: w["color"]),
                          title: Text(w["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Bonus ATK: +${w['bonus']} | Elemen: ${w['type']}"),
                          trailing: w["owned"]
                              ? ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedWeapon = w["name"];
                                      _weaponEffectColor = w["color"];
                                      _weaponAtkBonus = w["bonus"];
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
                                      setVaultState(() {});
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                                  child: Text("BELI (${w['price']} Gem)"),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showShopModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("TOKO PEMBELIAN DIAMOND", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.cyan)),
            const SizedBox(height: 16),
            ListTile(
              tileColor: const Color(0xFF1F2937),
              leading: const Icon(Icons.diamond, color: Colors.cyan),
              title: const Text("Peti 1,000 Diamond"),
              subtitle: const Text("Rp 15.000"),
              trailing: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _gems += 1000;
                    _saveGameData();
                  });
                  Navigator.pop(context);
                },
                child: const Text("BELI"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BattleArenaScreen extends StatefulWidget {
  final String playerName;
  final String weaponName;
  final Color weaponColor;
  final int weaponAtk;
  final bool sfxEnabled;

  const BattleArenaScreen({
    super.key,
    required this.playerName,
    required this.weaponName,
    required this.weaponColor,
    required this.weaponAtk,
    required this.sfxEnabled,
  });

  @override
  State<BattleArenaScreen> createState() => _BattleArenaScreenState();
}

class _BattleArenaScreenState extends State<BattleArenaScreen> {
  final double _playerX = 0.2;
  final double _enemyX = 0.8;
  
  int _playerHp = 100;
  int _enemyHp = 120;
  
  String _playerStatus = "IDLE";
  String _enemyStatus = "IDLE";
  
  bool _isBattleActive = true;
  String _logText = "FIGHT!";

  void _playerAttack(String type) {
    if (!_isBattleActive) return;

    double dist = (_enemyX - _playerX).abs();
    int dmg = 10 + widget.weaponAtk ~/ 3;

    setState(() {
      _playerStatus = type;
      
      bool enemyBlocked = Random().nextDouble() < 0.3;

      if (dist <= 0.25) {
        if (enemyBlocked) {
          _enemyStatus = "BLOCK";
          dmg = 2;
          _logText = "MUSUH MENANGKIS SERANGANMU!";
        } else {
          if (type == 'SHADOW') dmg += 20;
          _enemyHp = max(0, _enemyHp - dmg);
          _logText = "TEBASAN EFEK ${widget.weaponName.toUpperCase()}! -$dmg HP!";
        }

        if (_enemyHp <= 0) {
          _isBattleActive = false;
          _logText = "VICTORY! MUSUH PRO DIKALAHKAN!";
        } else {
          _triggerEnemyAI();
        }
      }
    });

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _playerStatus = "IDLE");
    });
  }

  void _triggerEnemyAI() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!_isBattleActive || !mounted) return;
      setState(() {
        _enemyStatus = "ATTACK";
        _playerHp = max(0, _playerHp - 12);
        _logText = "MUSUH MEMBALAS DENGAN COMBO COUNTER!";
        if (_playerHp <= 0) {
          _isBattleActive = false;
          _logText = "DEFEAT! KAMU DIKALAHKAN AI PRO!";
        }
      });

      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) setState(() => _enemyStatus = "IDLE");
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
                        Text(widget.playerName, style: TextStyle(color: widget.weaponColor, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: _playerHp / 100, 
                          color: widget.weaponColor, 
                          backgroundColor: Colors.white12,
                          minHeight: 10,
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("VS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.red)),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("SHADOW SHOGUN (PRO AI)", style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: _enemyHp / 120, 
                          color: Colors.purpleAccent, 
                          backgroundColor: Colors.white12,
                          minHeight: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Center(
              child: Text(_logText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
            ),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              left: MediaQuery.of(context).size.width * _playerX,
              bottom: 80,
              child: Icon(Icons.person, size: 80, color: _playerStatus == 'SHADOW' ? widget.weaponColor : Colors.white),
            ),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              left: MediaQuery.of(context).size.width * _enemyX,
              bottom: 80,
              child: Icon(
                _enemyStatus == 'BLOCK' ? Icons.shield : Icons.person_outline,
                size: 80,
                color: Colors.purpleAccent,
              ),
            ),

            Positioned(
              bottom: 20,
              right: 20,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _playerAttack('SLASH'),
                    style: ElevatedButton.styleFrom(backgroundColor: widget.weaponColor, foregroundColor: Colors.black),
                    child: const Text("TEBASAN"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _playerAttack('SHADOW'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                    child: const Text("SHADOW"),
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
