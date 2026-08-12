import 'dart:math' as math;

class PianoTile {
  const PianoTile({required this.id, required this.lane, required this.y});

  final int id;
  final int lane;
  final double y;

  PianoTile copyWith({double? y}) =>
      PianoTile(id: id, lane: lane, y: y ?? this.y);
}

enum PianoGameStatus { ready, playing, songComplete }

class PianoTickResult {
  const PianoTickResult({
    this.missed = 0,
    this.levelAdvanced = false,
    this.songCompleted = false,
  });

  final int missed;
  final bool levelAdvanced;
  final bool songCompleted;
}

class PianoTilesEngine {
  PianoTilesEngine({math.Random? random}) : _random = random ?? math.Random();

  static const laneCount = 4;
  static const tileHeight = 154.0;
  static const tilesPerLevel = 24;
  static const levelCount = 3;
  static const songTileCount = tilesPerLevel * levelCount;
  static const hitZoneStart = .47;
  static const initialTileCount = 7;

  final math.Random _random;
  final List<PianoTile> tiles = [];
  PianoGameStatus status = PianoGameStatus.ready;
  int score = 0;
  int bestScore = 0;
  int combo = 0;
  int bestCombo = 0;
  int hits = 0;
  int misses = 0;
  int mistakes = 0;
  int processed = 0;
  int _spawned = 0;
  int _nextId = 0;
  int? _lastLane;
  double _spacing = 185;

  int get level => math.min(processed ~/ tilesPerLevel + 1, levelCount);
  double get progress => processed / songTileCount;
  double get accuracy => processed == 0 ? 1 : hits / processed;
  double get speed => .235 + (level - 1) * .045;

  void start(double boardHeight, {int previousBest = 0}) {
    score = 0;
    bestScore = previousBest;
    combo = 0;
    bestCombo = 0;
    hits = 0;
    misses = 0;
    mistakes = 0;
    processed = 0;
    _spawned = 0;
    _nextId = 0;
    _lastLane = null;
    _spacing = math.max(tileHeight + 30, boardHeight * .13);
    tiles.clear();
    status = PianoGameStatus.playing;

    final firstY = boardHeight * .68 - tileHeight / 2;
    for (var index = 0;
        index < initialTileCount && _spawned < songTileCount;
        index++) {
      _spawn(firstY - index * _spacing);
    }
  }

  PianoTickResult tick(double elapsedSeconds, double boardHeight) {
    if (status != PianoGameStatus.playing) return const PianoTickResult();
    final previousLevel = level;
    final movement = boardHeight * speed * elapsedSeconds;
    for (var index = 0; index < tiles.length; index++) {
      tiles[index] = tiles[index].copyWith(y: tiles[index].y + movement);
    }

    var missedNow = 0;
    while (tiles.isNotEmpty && tiles.first.y > boardHeight) {
      tiles.removeAt(0);
      misses++;
      processed++;
      combo = 0;
      missedNow++;
      _fillQueue();
    }
    final complete = _completeIfFinished();
    return PianoTickResult(
      missed: missedNow,
      levelAdvanced: !complete && level > previousLevel,
      songCompleted: complete,
    );
  }

  bool tap(int lane, double boardHeight) {
    if (status != PianoGameStatus.playing) return false;
    final index = tiles.indexWhere((tile) =>
        tile.lane == lane &&
        tile.y + tileHeight >= boardHeight * hitZoneStart &&
        tile.y < boardHeight);
    if (index < 0) {
      mistakes++;
      combo = 0;
      return false;
    }

    tiles.removeAt(index);
    hits++;
    processed++;
    combo++;
    bestCombo = math.max(bestCombo, combo);
    score += 10 + math.min(combo - 1, 10);
    bestScore = math.max(bestScore, score);
    _fillQueue();
    _completeIfFinished();
    return true;
  }

  bool registerMistake() {
    if (status != PianoGameStatus.playing) return false;
    mistakes++;
    combo = 0;
    return true;
  }

  bool _completeIfFinished() {
    if (processed < songTileCount) return false;
    status = PianoGameStatus.songComplete;
    tiles.clear();
    return true;
  }

  void _fillQueue() {
    while (tiles.length < initialTileCount && _spawned < songTileCount) {
      final highestY = tiles.isEmpty
          ? -tileHeight
          : tiles.map((tile) => tile.y).reduce(math.min);
      _spawn(highestY - _spacing);
    }
  }

  void _spawn(double y) {
    var lane = _random.nextInt(laneCount);
    if (lane == _lastLane) lane = (lane + 1 + _random.nextInt(3)) % laneCount;
    _lastLane = lane;
    tiles.add(PianoTile(id: _nextId++, lane: lane, y: y));
    tiles.sort((a, b) => b.y.compareTo(a.y));
    _spawned++;
  }
}
