import 'dart:math' as math;

class PianoTile {
  const PianoTile({required this.id, required this.lane, required this.y});

  final int id;
  final int lane;
  final double y;

  PianoTile copyWith({double? y}) =>
      PianoTile(id: id, lane: lane, y: y ?? this.y);
}

enum PianoGameStatus { ready, playing, gameOver }

class PianoTilesEngine {
  PianoTilesEngine({math.Random? random}) : _random = random ?? math.Random();

  static const laneCount = 4;
  static const pointsPerLevel = 10;
  static const tileHeight = 126.0;
  static const hitLine = 0.76;
  static const hitTolerance = 0.13;

  final math.Random _random;
  PianoGameStatus status = PianoGameStatus.ready;
  PianoTile? tile;
  int score = 0;
  int bestScore = 0;
  int _nextId = 0;

  int get level => score ~/ pointsPerLevel + 1;
  double get speed => 0.28 + (level - 1) * 0.045;

  void start({int previousBest = 0}) {
    score = 0;
    bestScore = previousBest;
    status = PianoGameStatus.playing;
    tile = _newTile(-tileHeight);
  }

  /// Advances by a fraction of the board height per second.
  bool tick(double elapsedSeconds, double boardHeight) {
    final current = tile;
    if (status != PianoGameStatus.playing || current == null) return false;
    final nextY = current.y + boardHeight * speed * elapsedSeconds;
    tile = current.copyWith(y: nextY);
    if (nextY > boardHeight * (hitLine + hitTolerance)) {
      miss();
      return true;
    }
    return false;
  }

  bool tap(int lane, double boardHeight) {
    final current = tile;
    if (status != PianoGameStatus.playing || current == null) return false;
    final center = current.y + tileHeight / 2;
    final target = boardHeight * hitLine;
    if (lane != current.lane ||
        (center - target).abs() > boardHeight * hitTolerance) {
      miss();
      return false;
    }
    score++;
    if (score > bestScore) bestScore = score;
    tile = _newTile(-tileHeight);
    return true;
  }

  void miss() {
    if (status == PianoGameStatus.playing) status = PianoGameStatus.gameOver;
  }

  PianoTile _newTile(double y) => PianoTile(
        id: _nextId++,
        lane: _random.nextInt(laneCount),
        y: y,
      );
}
