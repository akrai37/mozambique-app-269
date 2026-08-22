import 'package:flutter/material.dart';

import 'package:mozambique_app/services/progress_service.dart';

/// Moderator controls for which group is using this tablet.
///
/// Progress is recorded per group rather than per person. The learners share
/// one tablet and cannot read a login screen, so individual accounts would be
/// both unusable and beside the point — the group is the unit that matters.
///
/// A picker rather than a one-way "new group" button, for two reasons. A group
/// that met on Monday may return on Wednesday, and creating a new id each time
/// would fragment their history. And picking from a list is much harder to
/// forget than remembering to press a button — forgetting silently folds one
/// group's answers into another's record.
///
/// Lives on the Info screen next to the sync button, which is already the
/// moderator-facing corner of the app. Text is fine here for the same reason it
/// is fine there: moderators can read.
class GroupControls extends StatefulWidget {
  const GroupControls({super.key});

  @override
  State<GroupControls> createState() => _GroupControlsState();
}

class _GroupControlsState extends State<GroupControls> {
  final ProgressService _progress = ProgressService();

  Future<void> _openPicker() async {
    final List<GroupInfo> groups = _progress.groups;
    final String currentId = _progress.groupId;

    final String? choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Qual grupo está aqui hoje?'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final GroupInfo group in groups)
                      ListTile(
                        leading: Icon(
                          group.id == currentId
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: const Color(0xFF2D3E50),
                        ),
                        title: Text(
                          group.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(_lastSeen(group)),
                        onTap: () => Navigator.pop(dialogContext, group.id),
                      ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add, color: Color(0xFF2D3E50)),
                title: const Text(
                  'Novo grupo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => Navigator.pop(dialogContext, _newGroupSentinel),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (choice == null) return;

    if (choice == _newGroupSentinel) {
      await _createGroup();
      return;
    }

    await _progress.switchToGroup(choice);
    if (!mounted) return;
    setState(() {});
    _toast('Grupo alterado.');
  }

  Future<void> _createGroup() async {
    final TextEditingController controller = TextEditingController();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Novo grupo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'O progresso do grupo atual fica guardado. '
              'O novo grupo começa do zero.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nome do grupo (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Começar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _progress.startNewGroup(name: controller.text);
    if (!mounted) return;
    setState(() {});
    _toast('Novo grupo criado.');
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  static String _lastSeen(GroupInfo group) {
    final DateTime? at = group.lastActive;
    if (at == null) return 'sem atividade';

    final Duration ago = DateTime.now().difference(at);
    if (ago.inMinutes < 60) return 'há ${ago.inMinutes} min';
    if (ago.inHours < 24) return 'há ${ago.inHours} h';
    return 'há ${ago.inDays} dias';
  }

  static const String _newGroupSentinel = '__new__';

  @override
  Widget build(BuildContext context) {
    final String label = _progress.groupName ??
        GroupInfo(id: _progress.groupId).displayName;
    final int categoriesTouched = _progress.all().length;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Text(
            'Grupo atual: $label  ($categoriesTouched categorias)',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3E50),
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: _openPicker,
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: const BorderSide(color: Color(0xFF2D3E50), width: 2),
              ),
              backgroundColor: const Color(0xFFECF0F1),
            ),
            child: const Text(
              'Mudar grupo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3E50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
