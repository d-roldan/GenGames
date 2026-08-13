import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_game/core/audio/audio_service.dart';
import 'package:kids_game/games/animals_game/animals_game_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every animal has a packaged Ogg recording', () async {
    expect(animalSoundAssets.keys.toSet(),
        animals.map((animal) => animal.id).toSet());

    for (final asset in animalSoundAssets.values) {
      final data = await rootBundle.load('assets/$asset');
      final signature = String.fromCharCodes(data.buffer.asUint8List(0, 4));
      expect(signature, 'OggS', reason: '$asset must be a valid Ogg container');
    }
  });
}
