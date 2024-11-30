import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/time_control.dart';
import '../utils/audio_manager.dart';

class SettingsDialog extends StatefulWidget {
  final TimeControl currentTimeControl;
  final String player1Name;
  final String player2Name;

  const SettingsDialog({
    super.key,
    required this.currentTimeControl,
    required this.player1Name,
    required this.player2Name,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TimeControl _selectedTimeControl;
  late TextEditingController _player1Controller;
  late TextEditingController _player2Controller;
  late TextEditingController _hoursController;
  late TextEditingController _minutesController;
  late TextEditingController _secondsController;
  late TextEditingController _incrementController;
  late bool _isSoundEnabled;
  late bool _isDelayMode;
  bool _isCustomTime = false;

  @override
  void initState() {
    super.initState();
    _selectedTimeControl = widget.currentTimeControl;
    _player1Controller = TextEditingController(text: widget.player1Name);
    _player2Controller = TextEditingController(text: widget.player2Name);
    _hoursController = TextEditingController(text: '0');
    _minutesController = TextEditingController(text: '5');
    _secondsController = TextEditingController(text: '0');
    _incrementController = TextEditingController(text: widget.currentTimeControl.increment.inSeconds.toString());
    _isSoundEnabled = !AudioManager.isMuted;
    _isDelayMode = widget.currentTimeControl.isDelayMode;
  }

  @override
  void dispose() {
    _player1Controller.dispose();
    _player2Controller.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    _incrementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Game Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Time Control', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildTimeControlSection(),
            const SizedBox(height: 16),
            _buildTextField(_player1Controller, 'Player 1 Name'),
            const SizedBox(height: 8),
            _buildTextField(_player2Controller, 'Player 2 Name'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _incrementController,
                    _isDelayMode ? 'Delay (seconds)' : 'Increment (seconds)',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: _isDelayMode,
                  onChanged: (value) {
                    setState(() {
                      _isDelayMode = value;
                    });
                  },
                ),
                const Text('Delay Mode'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Sound Effects'),
                const Spacer(),
                Switch(
                  value: _isSoundEnabled,
                  onChanged: (value) {
                    setState(() {
                      _isSoundEnabled = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveSettings,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildTimeControlSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Blitz'),
              selected: !_isCustomTime && _selectedTimeControl.initialTime == TimeControl.blitz().initialTime,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _isCustomTime = false;
                    _selectedTimeControl = TimeControl.blitz();
                    _incrementController.text = _selectedTimeControl.increment.inSeconds.toString();
                  });
                }
              },
            ),
            ChoiceChip(
              label: const Text('Rapid'),
              selected: !_isCustomTime && _selectedTimeControl.initialTime == TimeControl.rapid().initialTime,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _isCustomTime = false;
                    _selectedTimeControl = TimeControl.rapid();
                    _incrementController.text = _selectedTimeControl.increment.inSeconds.toString();
                  });
                }
              },
            ),
            ChoiceChip(
              label: const Text('Classical'),
              selected: !_isCustomTime && _selectedTimeControl.initialTime == TimeControl.classical().initialTime,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _isCustomTime = false;
                    _selectedTimeControl = TimeControl.classical();
                    _incrementController.text = _selectedTimeControl.increment.inSeconds.toString();
                  });
                }
              },
            ),
            ChoiceChip(
              label: const Text('Custom'),
              selected: _isCustomTime,
              onSelected: (selected) {
                setState(() {
                  _isCustomTime = selected;
                });
              },
            ),
          ],
        ),
        if (_isCustomTime) ...[
          const SizedBox(height: 8),
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
        ],
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _saveSettings() {
    TimeControl newTimeControl;

    if (_isCustomTime) {
      final hours = int.tryParse(_hoursController.text) ?? 0;
      final minutes = int.tryParse(_minutesController.text) ?? 0;
      final seconds = int.tryParse(_secondsController.text) ?? 0;

      if (hours == 0 && minutes == 0 && seconds == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please set a valid time control'),
          ),
        );
        return;
      }

      newTimeControl = TimeControl(
        initialTime: Duration(
          hours: hours,
          minutes: minutes,
          seconds: seconds,
        ),
        increment: Duration(seconds: int.tryParse(_incrementController.text) ?? 0),
        isDelayMode: _isDelayMode,
        delay: Duration(seconds: int.tryParse(_incrementController.text) ?? 0),
      );
    } else {
      newTimeControl = TimeControl(
        initialTime: _selectedTimeControl.initialTime,
        increment: Duration(seconds: int.tryParse(_incrementController.text) ?? 0),
        isDelayMode: _isDelayMode,
        delay: Duration(seconds: int.tryParse(_incrementController.text) ?? 0),
      );
    }

    if (_isSoundEnabled != !AudioManager.isMuted) {
      AudioManager.toggleMute();
    }

    Navigator.pop(context, {
      'timeControl': newTimeControl,
      'player1Name': _player1Controller.text,
      'player2Name': _player2Controller.text,
    });
  }
}
