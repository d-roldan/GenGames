import 'dart:math' as math;

import 'piano_song.dart';

enum PianoGameStatus { ready, playing, songComplete }

enum PianoNoteState { pending, holding, hit, missed }

enum PianoJudgment { perfect, great, good, miss }

class PianoRuntimeNote {
  PianoRuntimeNote(this.beat);

  final PianoBeatNote beat;
  PianoNoteState state = PianoNoteState.pending;
  PianoJudgment? judgment;
  double? holdStartedAt;

  bool get isActive =>
      state == PianoNoteState.pending || state == PianoNoteState.holding;
}

class PianoInputResult {
  const PianoInputResult({
    required this.accepted,
    required this.judgment,
    this.points = 0,
    this.holdStarted = false,
  });

  const PianoInputResult.miss()
      : accepted = false,
        judgment = PianoJudgment.miss,
        points = 0,
        holdStarted = false;

  final bool accepted;
  final PianoJudgment judgment;
  final int points;
  final bool holdStarted;
}

class PianoTickResult {
  const PianoTickResult({
    this.missed = 0,
    this.points = 0,
    this.judgment,
    this.songCompleted = false,
  });

  final int missed;
  final int points;
  final PianoJudgment? judgment;
  final bool songCompleted;
}

class PianoTilesEngine {
  PianoTilesEngine(this.song);

  static const laneCount = 4;
  static const hitLine = .82;
  static const tapHeight = 142.0;
  static const perfectWindow = .075;
  static const greatWindow = .145;
  static const goodWindow = .24;

  final PianoSong song;
  final List<PianoRuntimeNote> notes = [];
  PianoGameStatus status = PianoGameStatus.ready;
  double time = 0;
  int score = 0;
  int bestScore = 0;
  int combo = 0;
  int bestCombo = 0;
  int perfects = 0;
  int greats = 0;
  int goods = 0;
  int misses = 0;
  int mistakes = 0;
  int processed = 0;
  double earnedAccuracy = 0;

  double get progress => (time / song.duration).clamp(0, 1);
  double get accuracy =>
      processed == 0 ? 1 : (earnedAccuracy / processed).clamp(0, 1);
  Iterable<PianoRuntimeNote> get activeNotes =>
      notes.where((note) => note.isActive);

  void start({int previousBest = 0}) {
    notes
      ..clear()
      ..addAll(song.notes.map(PianoRuntimeNote.new));
    status = PianoGameStatus.playing;
    time = 0;
    score = 0;
    bestScore = previousBest;
    combo = 0;
    bestCombo = 0;
    perfects = 0;
    greats = 0;
    goods = 0;
    misses = 0;
    mistakes = 0;
    processed = 0;
    earnedAccuracy = 0;
  }

  PianoTickResult tick(double elapsedSeconds) {
    if (status != PianoGameStatus.playing) return const PianoTickResult();
    time += elapsedSeconds;
    var missedNow = 0;
    var pointsNow = 0;
    PianoJudgment? judgment;
    for (final note in activeNotes.toList()) {
      if (note.state == PianoNoteState.pending &&
          time - note.beat.time > goodWindow) {
        _miss(note);
        missedNow++;
      } else if (note.state == PianoNoteState.holding &&
          time >= note.beat.time + note.beat.duration) {
        judgment = note.judgment ?? PianoJudgment.good;
        pointsNow += _complete(note, judgment);
      }
    }
    final complete = _completeIfFinished();
    return PianoTickResult(
      missed: missedNow,
      points: pointsNow,
      judgment: judgment,
      songCompleted: complete,
    );
  }

  PianoInputResult press(int lane) {
    if (status != PianoGameStatus.playing) {
      return const PianoInputResult.miss();
    }
    PianoRuntimeNote? closest;
    var closestDistance = double.infinity;
    for (final note in notes) {
      if (note.state != PianoNoteState.pending || note.beat.lane != lane) {
        continue;
      }
      final distance = (note.beat.time - time).abs();
      if (distance < closestDistance) {
        closest = note;
        closestDistance = distance;
      }
    }
    if (closest == null || closestDistance > goodWindow) {
      mistakes++;
      combo = 0;
      return const PianoInputResult.miss();
    }

    final judgment = _judgment(closestDistance);
    if (closest.beat.kind == PianoNoteKind.hold) {
      closest.state = PianoNoteState.holding;
      closest.judgment = judgment;
      closest.holdStartedAt = time;
      return PianoInputResult(
        accepted: true,
        judgment: judgment,
        holdStarted: true,
      );
    }
    final points = _complete(closest, judgment);
    _completeIfFinished();
    return PianoInputResult(accepted: true, judgment: judgment, points: points);
  }

  PianoInputResult release(int lane) {
    final holding = notes.where((note) =>
        note.state == PianoNoteState.holding && note.beat.lane == lane);
    if (holding.isEmpty) return const PianoInputResult.miss();
    final note = holding.first;
    final end = note.beat.time + note.beat.duration;
    if (time < end - .16) {
      _miss(note);
      return const PianoInputResult.miss();
    }
    final judgment = note.judgment ?? PianoJudgment.good;
    final points = _complete(note, judgment);
    _completeIfFinished();
    return PianoInputResult(accepted: true, judgment: judgment, points: points);
  }

  int _complete(PianoRuntimeNote note, PianoJudgment judgment) {
    if (!note.isActive) return 0;
    note.state = PianoNoteState.hit;
    note.judgment = judgment;
    processed++;
    combo++;
    bestCombo = math.max(bestCombo, combo);
    final base = switch (judgment) {
      PianoJudgment.perfect => 100,
      PianoJudgment.great => 70,
      PianoJudgment.good => 40,
      PianoJudgment.miss => 0,
    };
    final holdBonus = note.beat.kind == PianoNoteKind.hold ? 80 : 0;
    final points = base + holdBonus + math.min(combo, 50) * 2;
    score += points;
    bestScore = math.max(bestScore, score);
    switch (judgment) {
      case PianoJudgment.perfect:
        perfects++;
        earnedAccuracy += 1;
        break;
      case PianoJudgment.great:
        greats++;
        earnedAccuracy += .75;
        break;
      case PianoJudgment.good:
        goods++;
        earnedAccuracy += .45;
        break;
      case PianoJudgment.miss:
        break;
    }
    return points;
  }

  void _miss(PianoRuntimeNote note) {
    if (!note.isActive) return;
    note.state = PianoNoteState.missed;
    note.judgment = PianoJudgment.miss;
    processed++;
    misses++;
    combo = 0;
  }

  bool _completeIfFinished() {
    if (time < song.duration) return false;
    for (final note in activeNotes.toList()) {
      _miss(note);
    }
    status = PianoGameStatus.songComplete;
    return true;
  }

  PianoJudgment _judgment(double distance) {
    if (distance <= perfectWindow) return PianoJudgment.perfect;
    if (distance <= greatWindow) return PianoJudgment.great;
    return PianoJudgment.good;
  }
}
