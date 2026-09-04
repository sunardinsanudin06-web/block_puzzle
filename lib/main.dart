import 'package:flutter/material.dart';

void main() {
  runApp(const BlockPuzzleApp());
}

class BlockPuzzleApp extends StatelessWidget {
  const BlockPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Block Puzzle',
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
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

  // Bentuk balok sederhana (1x1, 2x2, 3x1)
  List<List<List<int>>> availableBlocks = [
    [[1]],
    [[1, 1], [1, 1]],
    [[1, 1, 1]],
    [[1], [1], [1]],
  ];

  void _placeBlock(int row, int col, List<List<int>> block, Color color) {
    setState(() {
      for (int r = 0; r < block.length; r++) {
        for (int c = 0; c < block[r].length; c++) {
          if (block[r][c] == 1) {
            grid[row + r][col + c] = color;
          }
        }
      }
      score += 10;
      _checkLines();
    });
  }

  void _checkLines() {
    // Cek Baris Lengkap
    for (int r = 0; r < gridSize; r++) {
      if (grid[r].every((cell) => cell != null)) {
        for (int c = 0; c < gridSize; c++) {
          grid[r][c] = null;
        }
        score += 100;
      }
    }

    // Cek Kolom Lengkap
    for (int c = 0; c < gridSize; c++) {
      bool full = true;
      for (int r = 0; r < gridSize; r++) {
        if (grid[r][c] == null) full = false;
      }
      if (full) {
        for (int r = 0; r < gridSize; r++) {
          grid[r][c] = null;
        }
        score += 100;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text('Block Puzzle 3D'),
        centerTitle: true,
        backgroundColor: const Color(0xFF2D2D44),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Papan Skor
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D44),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'SKOR: $score',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ),

          // Papan Game (Grid 8x8)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D44),
              borderRadius: BorderRadius.circular(12),
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: gridSize * gridSize,
                itemBuilder: (context, index) {
                  int row = index ~/ gridSize;
                  int col = index % gridSize;
                  Color? cellColor = grid[row][col];

                  return DragTarget<List<List<int>>>(
                    onAcceptWithDetails: (details) {
                      _placeBlock(row, col, details.data, Colors.cyanAccent);
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        decoration: BoxDecoration(
                          color: cellColor ?? const Color(0xFF13131D),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Area Balok yang Bisa Ditarik (Draggable)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: availableBlocks.map((block) {
              return Draggable<List<List<int>>>(
                data: block,
                feedback: Material(
                  color: Colors.transparent,
                  child: _buildBlockWidget(block, Colors.cyanAccent.withOpacity(0.8)),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: _buildBlockWidget(block, Colors.cyanAccent),
                ),
                child: _buildBlockWidget(block, Colors.cyanAccent),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockWidget(List<List<int>> block, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: block.map((row) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: row.map((cell) {
            return Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: cell == 1 ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
