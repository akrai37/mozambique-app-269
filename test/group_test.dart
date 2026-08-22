import 'package:flutter_test/flutter_test.dart';

import 'package:mozambique_app/services/progress_service.dart';

/// Written before GroupInfo and the list helpers existed.

GroupInfo g(String id, {String? name, DateTime? active}) =>
    GroupInfo(id: id, name: name, lastActive: active);

void main() {
  group('GroupInfo display name', () {
    test('uses the name the moderator set', () {
      expect(g('gabc123', name: 'Namaacha Terça').displayName, 'Namaacha Terça');
    });

    test('falls back to a short id when unnamed', () {
      // Naming is optional — a moderator mid-session should not be forced to
      // type before the group can exist. The fallback still has to be
      // distinguishable from other groups in a list.
      final name = g('gabc123def456').displayName;
      expect(name, isNotEmpty);
      expect(name, isNot(contains('gabc123def456')),
          reason: 'the full id is noise; show something short');
    });

    test('treats a blank name as unnamed', () {
      expect(g('gabc123', name: '   ').displayName,
          g('gabc123').displayName);
    });
  });

  group('serialisation', () {
    test('round-trips', () {
      final original = GroupInfo(
        id: 'gabc',
        name: 'Manhiça',
        lastActive: DateTime.utc(2026, 8, 22, 10, 30),
      );
      final restored = GroupInfo.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.lastActive, original.lastActive);
    });

    test('survives a partial record', () {
      final restored = GroupInfo.fromMap({'id': 'gabc'});
      expect(restored.id, 'gabc');
      expect(restored.name, isNull);
      expect(restored.lastActive, isNull);
    });
  });

  group('upsertGroup', () {
    test('adds a group that is not there yet', () {
      final result = upsertGroup([], g('g1', name: 'A'));
      expect(result.map((x) => x.id), ['g1']);
    });

    test('updates in place rather than duplicating', () {
      final existing = [g('g1', name: 'A'), g('g2', name: 'B')];
      final result = upsertGroup(existing, g('g1', name: 'A renamed'));

      expect(result.length, 2);
      expect(result.firstWhere((x) => x.id == 'g1').name, 'A renamed');
    });

    test('puts the most recently active first', () {
      final existing = [
        g('old', active: DateTime.utc(2026, 1, 1)),
        g('newer', active: DateTime.utc(2026, 6, 1)),
      ];
      final result = upsertGroup(existing, g('newest', active: DateTime.utc(2026, 8, 1)));

      expect(result.map((x) => x.id), ['newest', 'newer', 'old']);
    });

    test('groups with no timestamp sort last, not first', () {
      // A missing timestamp should not outrank a real one — otherwise an
      // incomplete record jumps to the top of the moderator's list.
      final existing = [g('nodate'), g('dated', active: DateTime.utc(2026, 5, 1))];
      final result = upsertGroup(existing, g('other', active: DateTime.utc(2026, 4, 1)));

      expect(result.first.id, 'dated');
      expect(result.last.id, 'nodate');
    });

    test('does not mutate the list it was given', () {
      final existing = [g('g1')];
      upsertGroup(existing, g('g2'));
      expect(existing.length, 1);
    });
  });
}
