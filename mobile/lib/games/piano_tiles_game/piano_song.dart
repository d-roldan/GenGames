import 'package:flutter/material.dart';

enum PianoNoteKind { tap, hold }

class PianoBeatNote {
  const PianoBeatNote({
    required this.id,
    required this.lane,
    required this.time,
    this.kind = PianoNoteKind.tap,
    this.duration = 0,
    this.doubleGroup,
  });

  final int id;
  final int lane;
  final double time;
  final PianoNoteKind kind;
  final double duration;
  final int? doubleGroup;

  bool get isDouble => doubleGroup != null;
}

class PianoSong {
  const PianoSong({
    required this.id,
    required this.title,
    required this.genre,
    required this.subtitle,
    required this.bpm,
    required this.difficulty,
    required this.asset,
    required this.duration,
    required this.approachTime,
    required this.colors,
    required this.notes,
  });

  final String id;
  final String title;
  final String genre;
  final String subtitle;
  final int bpm;
  final int difficulty;
  final String asset;
  final double duration;
  final double approachTime;
  final List<Color> colors;
  final List<PianoBeatNote> notes;
}

// The generated tracks place their first downbeat at 1.5 seconds. Keeping the
// chart on the same lead-in makes every tile cross the hit line on the beat.
const _leadIn = 1.5;

final _wildSparkRests = <int>{
  for (var index = 1; index < 128; index += 2)
    if (index % 8 != 7) index,
  31,
  63,
  95,
  127,
};

List<PianoBeatNote> _buildMap({
  required int bpm,
  required int beats,
  required List<int> lanes,
  required Set<int> rests,
  required Map<int, int> holds,
  required Map<int, int> doubles,
  required bool eighthNotes,
}) {
  final secondsPerBeat = 60 / bpm;
  final step = eighthNotes ? .5 : 1.0;
  final totalSteps = (beats / step).round();
  final result = <PianoBeatNote>[];
  var id = 0;
  for (var index = 0; index < totalSteps; index++) {
    if (rests.contains(index)) continue;
    final beat = index * step;
    final lane = lanes[index % lanes.length];
    final holdSteps = holds[index];
    final doubleLane = doubles[index];
    final group = doubleLane == null ? null : index;
    result.add(PianoBeatNote(
      id: id++,
      lane: lane,
      time: _leadIn + beat * secondsPerBeat,
      kind: holdSteps == null ? PianoNoteKind.tap : PianoNoteKind.hold,
      duration: holdSteps == null ? 0 : holdSteps * step * secondsPerBeat,
      doubleGroup: group,
    ));
    if (doubleLane != null) {
      result.add(PianoBeatNote(
        id: id++,
        lane: doubleLane,
        time: _leadIn + beat * secondsPerBeat,
        doubleGroup: group,
      ));
    }
  }
  return result;
}

final pianoSongs = <PianoSong>[
  PianoSong(
    id: 'neon_heart',
    title: 'Neon Heart',
    genre: 'POP',
    subtitle: 'Melodía brillante • ritmo relajado',
    bpm: 96,
    difficulty: 1,
    asset: 'music/neon_heart.wav',
    duration: 43,
    approachTime: 2.25,
    colors: const [Color(0xFFFF5FA2), Color(0xFF7657FF)],
    notes: _buildMap(
      bpm: 96,
      beats: 64,
      lanes: const [0, 1, 2, 1, 3, 2, 1, 0],
      rests: const {7, 15, 23, 31, 39, 47, 55, 63},
      holds: const {12: 2, 28: 2, 44: 2, 60: 2},
      doubles: const {18: 0, 34: 0, 50: 0},
      eighthNotes: false,
    ),
  ),
  PianoSong(
    id: 'wild_spark',
    title: 'Wild Spark',
    genre: 'ROCK',
    subtitle: 'Guitarras y batería • velocidad media',
    bpm: 124,
    difficulty: 2,
    asset: 'music/wild_spark.wav',
    duration: 34,
    approachTime: 1.78,
    colors: const [Color(0xFFFF7B36), Color(0xFFB51F43)],
    notes: _buildMap(
      bpm: 124,
      beats: 64,
      lanes: const [0, 2, 1, 3, 1, 2, 0, 3, 2, 1, 3, 0],
      rests: _wildSparkRests,
      holds: const {20: 3, 52: 3, 84: 3, 116: 3},
      doubles: const {8: 3, 40: 0, 72: 3, 104: 0, 124: 2},
      eighthNotes: true,
    ),
  ),
  PianoSong(
    id: 'pixel_rush',
    title: 'Pixel Rush',
    genre: 'ELECTROPOP',
    subtitle: 'Beat viral • reflejos rápidos',
    bpm: 148,
    difficulty: 3,
    asset: 'music/pixel_rush.wav',
    duration: 29,
    approachTime: 1.4,
    colors: const [Color(0xFF00D7D7), Color(0xFF6547F5)],
    notes: _buildMap(
      bpm: 148,
      beats: 64,
      lanes: const [0, 1, 3, 2, 0, 2, 1, 3, 1, 0, 2, 3],
      rests: const {13, 29, 45, 61, 77, 93, 109},
      holds: const {16: 4, 48: 4, 80: 4, 112: 4},
      doubles: const {
        6: 3,
        22: 0,
        38: 3,
        54: 0,
        70: 3,
        86: 0,
        102: 3,
        118: 0,
      },
      eighthNotes: true,
    ),
  ),
];
