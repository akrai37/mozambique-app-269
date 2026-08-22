import 'package:audioplayers/audioplayers.dart';

/// Ensures only one clip is audible at a time.
///
/// Every card in this app owns its own AudioPlayer and called resume()
/// directly, so nothing stopped anything else. Tapping three words in quick
/// succession played three Portuguese words simultaneously.
///
/// That matters more here than in most apps: the learners cannot read, so audio
/// is not a supplement to the content, it *is* the content. And the tablet is
/// shared in a group, so several people reaching for it at once is the normal
/// case rather than an edge case.
class AudioCoordinator {
  static AudioPlayer? _current;

  /// Stops whatever is playing, then plays [player] from the start.
  static Future<void> play(AudioPlayer player) async {
    final AudioPlayer? previous = _current;

    if (previous != null && !identical(previous, player)) {
      // Failure here should never block the clip the user actually asked for.
      try {
        await previous.stop();
      } catch (_) {}
    }

    _current = player;

    // seek(0) so that re-tapping the same card restarts it rather than
    // resuming from wherever it was stopped.
    try {
      await player.seek(Duration.zero);
    } catch (_) {}

    await player.resume();
  }

  /// Called when a player is disposed, so a dead player is never referenced.
  static void forget(AudioPlayer player) {
    if (identical(_current, player)) _current = null;
  }
}
