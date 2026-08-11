import 'package:flutter/material.dart';
import '../../core/services/app_services.dart';
import 'parent_screen.dart';

class ParentGateButton extends StatelessWidget {
  const ParentGateButton({super.key, this.services, this.onAuthorized})
      : assert(services != null || onAuthorized != null);
  final AppServices? services;
  final VoidCallback? onAuthorized;

  Future<void> _challenge(BuildContext context) async {
    final passed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Área para adultos'),
              content: const Text('¿Cuánto es 3 + 4?'),
              actions: [
                for (final answer in [6, 8, 7])
                  FilledButton(
                      onPressed: () => Navigator.pop(context, answer == 7),
                      child: Text('$answer'))
              ],
            ));
    if (passed == true && context.mounted) {
      if (onAuthorized != null) {
        onAuthorized!();
      } else {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ParentScreen(services: services!)));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Semantics(
      label: 'Mantener presionado para adultos',
      button: true,
      child: GestureDetector(
          onLongPress: () => _challenge(context),
          child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Icon(Icons.lock_outline, size: 28))));
}
