import 'package:flutter/material.dart';

import 'package:mozambique_app/services/progress_service.dart';

/// Moderator controls for which group is using this tablet.
///
/// Progress is recorded per group rather than per person. The learners share
/// one tablet and cannot read a login screen, so individual accounts would be
/// both unusable and beside the point — the group is the unit that matters.
///
/// Lives on the Info screen alongside the sync button, which is already the
/// moderator-facing corner of the app. Text is acceptable here for the same
/// reason it is acceptable there: moderators can read.
class GroupControls extends StatefulWidget {
  const GroupControls({super.key});

  @override
  State<GroupControls> createState() => _GroupControlsState();
}

class _GroupControlsState extends State<GroupControls> {
  final ProgressService _progress = ProgressService();

  Future<void> _startNewGroup() async {
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
              'O progresso atual será guardado e um novo grupo começará do zero.',
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Novo grupo criado.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? name = _progress.groupName;
    final int categoriesTouched = _progress.all().length;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Text(
            'Grupo atual: ${name ?? "sem nome"}  ($categoriesTouched)',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3E50),
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: _startNewGroup,
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: const BorderSide(color: Color(0xFF2D3E50), width: 2),
              ),
              backgroundColor: const Color(0xFFECF0F1),
            ),
            child: const Text(
              'Novo grupo',
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
