import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/time_control.dart';

class CustomTimeDialog extends StatefulWidget {
  const CustomTimeDialog({super.key});

  @override
  State<CustomTimeDialog> createState() => _CustomTimeDialogState();
}

class _CustomTimeDialogState extends State<CustomTimeDialog> {
  final _hoursController = TextEditingController(text: '0');
  final _minutesController = TextEditingController(text: '5');
  final _secondsController = TextEditingController(text: '0');
  final _incrementController = TextEditingController(text: '0');

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    _incrementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Custom Time Control'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTimeField(_hoursController, 'Hours'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTimeField(_minutesController, 'Minutes'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTimeField(_secondsController, 'Seconds'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTimeField(_incrementController, 'Increment (seconds)'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveCustomTime,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildTimeField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      textAlign: TextAlign.center,
    );
  }

  void _saveCustomTime() {
    final hours = int.tryParse(_hoursController.text) ?? 0;
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final seconds = int.tryParse(_secondsController.text) ?? 0;
    final increment = int.tryParse(_incrementController.text) ?? 0;

    if (hours == 0 && minutes == 0 && seconds == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set a valid time control'),
        ),
      );
      return;
    }

    final customTimeControl = TimeControl(
      initialTime: Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
      ),
      increment: Duration(seconds: increment),
      isDelayMode: false,
      delay: const Duration(seconds: 0),
    );

    Navigator.pop(context, customTimeControl);
  }
}
