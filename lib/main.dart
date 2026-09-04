import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const BlockPuzzleApp());
}

class BlockPuzzleApp extends StatelessWidget {
  const BlockPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Block Puzzle Modern',
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}

class GamePiece {
  final List<List<int>> shape;
  final Color color;

  GamePiece({required this.shape, required this.color});
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int gridSize = 8;
  List<List<Color?>> grid = List.generate(
    gridSize,
    (_) => List.generate(gridSize, (_) => null),
  );

  int score = 0;
  int highScore = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Daftar Balok Tren Berwarna-warni
  final List<GamePiece> _allPieces = [
    GamePiece(shape: [[1]], color: Colors.amber),
    GamePiece(shape: [[1, 1], [1, 1]], color: Colors.blueAccent),
    GamePiece(shape: [[1, 1, 1]], color: Colors.purpleAccent),
    GamePiece(shape: [[1], [1], [1]], color: Colors.greenAccent),
    GamePiece(shape: [[1, 1, 1], [0, 1, 0]], color: Colors.orangeAccent),
    GamePiece(shape: [[1, 1], [0, 1]], color: Colors.pinkAccent),
  ];

  late List<GamePiece?> currentPieces;

  @override
  void initState() {
    super.initState();
    _generateNewPieces();
  }

  void _generateNewPieces() {
    currentPieces = [
      (_allPieces..shuffle()).first,
      (_allPieces..shuffle()).first,
      (_allPieces..shuffle()).first,
    ];
  }

  // Efek Suara
  void _playSound(String type) async {
    // Memakai nada sintetis sederhana melalui AudioPlayer
    try {
      if (type == 'place') {
        await _audioPlayer.play(UrlSource('https://actions.google.com/sounds/v1/cartoon/pop.ogg'));
      } else if (type == 'clear') {
        await _audioPlayer.play(UrlSource('https://actions.google.com/sounds/v1/touches/glass_ping.ogg'));
      } else if (type == 'gameover') {
        await _audioPlayer.play(UrlSource('https://actions.google.com/sounds/v1/human_voices/applause.ogg'));
      }
    } catch (_) {}
  }

  // Validasi Tabrakan (Anti-Overlap)
  bool _canPlacePiece(int row, int col, GamePiece piece) {
    for (int r = 0; r < piece.shape.length; r++) {
      for (int c = 0; c < piece.shape[r].length; c++) {
        if (piece.shape[r][c] == 1) {
          int targetRow = row + r;
          int targetCol = col + c;

          if (targetRow >= gridSize || targetCol >= gridSize) return false;
          if (grid[targetRow][targetCol] != null) return false; // Bertabrakan!
        }
      }
    }
    return true;
  }

  void _placePiece(int row, int col, GamePiece piece, int pieceIndex) {
    if (!_canPlacePiece(row, col, piece)) return;

    setState(() {
      for (int r = 0; r < piece.shape.length; r++) {
        for (int c = 0; c < piece.shape[r].length; c++) {
          if (piece.shape[r][c] == 1) {
            grid[row + r][col + c] = piece.color;
          }
        }
      }

      currentPieces[pieceIndex] = null;
      score += 15;
      _playSound('place');

      _checkLines();

      if (currentPieces.every((p) => p == null)) {
        _generateNewPieces();
      }

      _checkGameOver();
    });
  }

  void _checkLines() {
    List<int> rowsToClear = [];
    List<int> colsToClear = [];

    for (int r = 0; r < gridSize; r++) {
      if (grid[r].every((cell) => cell != null)) rowsToClear.add(r);
    }

    for (int c = 0; c < gridSize; c++) {
      bool full = true;
      for (int r = 0; r < gridSize; r++) {
        if (grid[r][c] == null) full = false;
      }
      if (full) colsToClear.add(c);
    }

    if (rowsToClear.isNotEmpty || colsToClear.isNotEmpty) {
      _playSound('clear');
      setState(() {
        for (int r in rowsToClear) {
          for (int c = 0; c < gridSize; c++) {
            grid[r][c] = null;
          }
        }
        for (int c in colsToClear) {
          for (int r = 0; r < gridSize; r++) {
            grid[r][c] = null;
          }
        }
        score += (rowsToClear.length + colsToClear.length) * 100;
        if (score > highScore) highScore = score;
      });
    }
  }

  void _checkGameOver() {
    bool hasValidMove = false;

    for (var piece in currentPieces) {
      if (piece == null) continue;
      for (int r = 0; r < gridSize; r++) {
        for (int c = 0; c < gridSize; c++) {
          if (_canPlacePiece(r, c, piece)) {
            hasValidMove = true;
            break;
          }
        }
      }
    }

    if (!hasValidMove && currentPieces.any((p) => p != null)) {
      _playSound('gameover');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF2D2D44),
          title: const Text('GAME OVER 💥', textAlign: TextAlign.center),
          content: Text('Skor Akhir Kamu: $score', textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetGame();
              },
              child: const Text('MAIN LAGI'),
            )
          ],
        ),
      );
    }
  }

  void _resetGame() {
    setState(() {
      grid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => null));
      score = 0;
      _generateNewPieces();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13131D),
      appBar: AppBar(
        title: const Text('BLOCK PUZZLE PRO'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E1E2C),
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Papan Skor
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildScoreCard('SKOR', score, Colors.amber),
              _buildScoreCard('TERTINGGI', highScore, Colors.cyanAccent),
            ],
          ),

          // Papan Game (Grid 8x8)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF232334),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black45, blurRadius: 10)
              ],
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: gridSize * gridSize,
                itemBuilder: (context, index) {
                  int row = index ~/ gridSize;
                  int col = index % gridSize;
                  Color? cellColor = grid[row][col];

                  return DragTarget<Map<String, dynamic>>(
                    onWillAcceptWithDetails: (details) {
                      return _canPlacePiece(row, col, details.data['piece']);
                    },
                    onAcceptWithDetails: (details) {
                      _placePiece(row, col, details.data['piece'], details.data['index']);
                    },
                    builder: (context, candidateData, rejectedData) {
                      bool isHovered = candidateData.isNotEmpty;
                      return Container(
                        decoration: BoxDecoration(
                          color: cellColor ?? (isHovered ? Colors.white24 : const Color(0xFF1A1A28)),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: cellColor != null
                              ? [BoxShadow(color: cellColor.withOpacity(0.6), blurRadius: 4)]
                              : [],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Pilihan Balok Tren
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (i) {
              final piece = currentPieces[i];
              if (piece == null) return const SizedBox(width: 80, height: 80);

              return Draggable<Map<String, dynamic>>(
                data: {'piece': piece, 'index': i},
                feedback: Material(
                  color: Colors.transparent,
                  child: _buildBlockWidget(piece.shape, piece.color, size: 24),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.2,
                  child: _buildBlockWidget(piece.shape, piece.color),
                ),
                child: _buildBlockWidget(piece.shape, piece.color),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF232334),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
          Text(
            '$value',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockWidget(List<List<int>> shape, Color color, {double size = 18}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: shape.map((row) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: row.map((cell) {
            return Container(
              width: size,
              height: size,
              margin: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                color: cell == 1 ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                boxShadow: cell == 1
                    ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 3)]
                    : [],
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
