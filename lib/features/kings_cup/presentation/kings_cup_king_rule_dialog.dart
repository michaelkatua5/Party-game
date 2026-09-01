import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class KingsCupKingRuleDialog extends StatefulWidget {
  final void Function(String ruleText) onRuleAdded;

  const KingsCupKingRuleDialog({super.key, required this.onRuleAdded});

  @override
  State<KingsCupKingRuleDialog> createState() => _KingsCupKingRuleDialogState();
}

class _KingsCupKingRuleDialogState extends State<KingsCupKingRuleDialog> {
  final TextEditingController _ruleController = TextEditingController(text: 'No saying "bro"');

  @override
  void dispose() {
    _ruleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1736),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Crown & Title
            const Text('👑', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 10),
            const Text(
              'K  KING',
              style: TextStyle(
                color: AppColors.savannaGold,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Make a rule!\nAdd some of your drink to the King\'s Cup.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
            ),

            const SizedBox(height: 24),

            // Input field
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ADD YOUR RULE',
                style: TextStyle(
                  color: AppColors.savannaGold,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ruleController,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF0F0B1E),
                hintText: 'e.g. Clap before speaking',
                hintStyle: const TextStyle(color: Colors.white38),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF3B2F63)),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // DONE button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.savannaGold,
                  foregroundColor: AppColors.textDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  final text = _ruleController.text.trim();
                  if (text.isNotEmpty) {
                    widget.onRuleAdded(text);
                  }
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'DONE',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
