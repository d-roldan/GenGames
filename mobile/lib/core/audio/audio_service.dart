import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

/// Produces short original PCM effects locally; no network or licensed audio.
class AudioService {
  AudioService({AudioPlayer? player})
      : _effects = [player ?? AudioPlayer(), AudioPlayer(), AudioPlayer()],
        _music = AudioPlayer();
  AudioService.silent()
      : _effects = const [],
        _music = null;

  final List<AudioPlayer> _effects;
  final AudioPlayer? _music;
  int _nextEffect = 0;

  Future<void> playCat(String interaction) => _play(
        interaction == 'bed'
            ? 145
            : interaction == 'food'
                ? 310
                : 520,
        interaction == 'bed' ? .7 : .3,
        wobble: interaction == 'tail' ? 18 : 5,
      );

  Future<void> playAnimal(String animal) {
    final settings = switch (animal) {
      'dog' => (190.0, .24, 32.0),
      'cat' => (540.0, .34, 110.0),
      'cow' => (105.0, .72, 14.0),
      'horse' => (260.0, .42, 72.0),
      'duck' => (720.0, .22, 180.0),
      'sheep' => (330.0, .55, 45.0),
      _ => (440.0, .25, 10.0),
    };
    return _play(settings.$1, settings.$2, wobble: settings.$3);
  }

  /// Plays one note of the original Piano Tiles melody.
  Future<void> playPianoNote(int noteIndex) {
    const melody = <double>[
      261.63,
      329.63,
      392.00,
      523.25,
      440.00,
      392.00,
      329.63,
      293.66,
      261.63,
      329.63,
      392.00,
      659.25,
      523.25,
      440.00,
      392.00,
      329.63,
    ];
    return _play(melody[noteIndex % melody.length], .48,
        wobble: 1.5, volume: 1);
  }

  Future<void> startPianoMusic(String asset) async {
    final player = _music;
    if (player == null) return;
    await player.stop();
    await player.setReleaseMode(ReleaseMode.stop);
    await player.setVolume(.72);
    await player.setPlaybackRate(1);
    await player.play(AssetSource(asset));
  }

  Future<void> stopPianoMusic() async => _music?.stop();

  Future<void> _play(double frequency, double seconds,
      {double wobble = 0, double volume = .8}) async {
    if (_effects.isEmpty) return;
    final player = _effects[_nextEffect++ % _effects.length];
    await player.setAudioContext(AudioContext(
      android: const AudioContextAndroid(audioFocus: AndroidAudioFocus.none),
    ));
    await player.setVolume(volume);
    await player.play(BytesSource(_wave(frequency, seconds, wobble)));
  }

  Uint8List _wave(double frequency, double seconds, double wobble) {
    const sampleRate = 22050;
    final samples = (sampleRate * seconds).round();
    final dataSize = samples * 2;
    final bytes = ByteData(44 + dataSize);
    void text(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        bytes.setUint8(offset + i, value.codeUnitAt(i));
      }
    }

    text(0, 'RIFF');
    bytes.setUint32(4, 36 + dataSize, Endian.little);
    text(8, 'WAVEfmt ');
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, 1, Endian.little);
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(28, sampleRate * 2, Endian.little);
    bytes.setUint16(32, 2, Endian.little);
    bytes.setUint16(34, 16, Endian.little);
    text(36, 'data');
    bytes.setUint32(40, dataSize, Endian.little);
    var phase = 0.0;
    for (var i = 0; i < samples; i++) {
      final time = i / sampleRate;
      final attack = math.min(1.0, time / .012);
      final envelope = attack * math.exp(-4.2 * time / seconds);
      phase += 2 *
          math.pi *
          (frequency + math.sin(time * math.pi * 12) * wobble) /
          sampleRate;
      final harmonic = math.sin(phase) * .78 + math.sin(phase * 2) * .22;
      bytes.setInt16(
          44 + i * 2, (harmonic * envelope * 14000).round(), Endian.little);
    }
    return bytes.buffer.asUint8List();
  }

  Future<void> dispose() async {
    await _music?.dispose();
    for (final player in _effects) {
      await player.dispose();
    }
  }
}
