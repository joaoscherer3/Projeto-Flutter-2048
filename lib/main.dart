import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MaterialApp(home: Jogo2048(), debugShowCheckedModeBanner: false));
}

class Jogo2048 extends StatefulWidget {
  const Jogo2048({super.key});
  @override
  State<Jogo2048> createState() => _Jogo2048State();
}

class _Jogo2048State extends State<Jogo2048> {
  int size = 4;
  late List<List<int>> grid;
  final random = Random();
  int moves = 0;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    grid = List.generate(size, (_) => List.generate(size, (_) => 0));
    moves = 0;
    _addNew();
    _addNew();
  }

  void _setLevel(int newSize) {
    setState(() {
      size = newSize;
      _startGame();
    });
  }

  void _addNew() {
    var empty = <Point<int>>[];
    for (var i = 0; i < size; i++) {
      for (var j = 0; j < size; j++) {
        if (grid[i][j] == 0) empty.add(Point(i, j));
      }
    }
    if (empty.isNotEmpty) {
      var p = empty[random.nextInt(empty.length)];
      grid[p.x][p.y] = random.nextInt(10) < 9 ? 2 : 4;
    }
  }

  bool _move(List<List<int>> oldGrid) {
    bool moved = false;
    for (var i = 0; i < size; i++) {
      var row = oldGrid[i].where((v) => v != 0).toList();
      for (var j = 0; j < row.length - 1; j++) {
        if (row[j] == row[j + 1]) {
          row[j] *= 2;
          row[j + 1] = 0;
        }
      }
      row = row.where((v) => v != 0).toList();
      while (row.length < size) {
        row.add(0);
      }
      if (!listEquals(grid[i], row)) moved = true;
      grid[i] = row;
    }
    return moved;
  }

  void _moveLeft() {
    setState(() {
      if (_move(List.from(grid))) {
        _addNew();
        moves++;
      }
    });
  }

  void _moveRight() {
    setState(() {
      grid = grid.map((r) => r.reversed.toList()).toList();
      if (_move(List.from(grid))) {
        grid = grid.map((r) => r.reversed.toList()).toList();
        _addNew();
        moves++;
      } else {
        grid = grid.map((r) => r.reversed.toList()).toList();
      }
    });
  }

  void _moveUp() {
    setState(() {
      grid = _transpose(grid);
      if (_move(List.from(grid))) {
        grid = _transpose(grid);
        _addNew();
        moves++;
      } else {
        grid = _transpose(grid);
      }
    });
  }

  void _moveDown() {
    setState(() {
      grid = _transpose(grid).map((r) => r.reversed.toList()).toList();
      if (_move(List.from(grid))) {
        grid = _transpose(grid.map((r) => r.reversed.toList()).toList());
        _addNew();
        moves++;
      } else {
        grid = _transpose(grid.map((r) => r.reversed.toList()).toList());
      }
    });
  }

  List<List<int>> _transpose(List<List<int>> m) {
    return List.generate(size, (i) => List.generate(size, (j) => m[j][i]));
  }

  bool listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2048'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text('Movimentos: $moves', style: const TextStyle(fontSize: 20)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: () => _setLevel(4), child: const Text('Fácil')),
              ElevatedButton(onPressed: () => _setLevel(5), child: const Text('Médio')),
              ElevatedButton(onPressed: () => _setLevel(6), child: const Text('Difícil')),
            ],
          ),
          Expanded(
            child: GridView.builder(
              itemCount: size * size,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: size),
              itemBuilder: (context, index) {
                int x = index ~/ size, y = index % size;
                int val = grid[x][y];
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: val == 0 ? Colors.grey[300] : Colors.orange[100 * (log(val)/log(2)).floor()],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(val == 0 ? '' : '$val', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.arrow_upward), onPressed: _moveUp),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: _moveLeft),
              const SizedBox(width: 40),
              IconButton(icon: const Icon(Icons.arrow_forward), onPressed: _moveRight),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.arrow_downward), onPressed: _moveDown),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
