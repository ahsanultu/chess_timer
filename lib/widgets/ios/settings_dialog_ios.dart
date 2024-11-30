import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../models/time_control.dart';
import '../../utils/audio_manager.dart';

class SettingsDialogIos extends StatefulWidget {
  final TimeControl currentTimeControl;
  final String player1Name;
  final String player2Name;

  const SettingsDialogIos({
    super.key,
    required this.currentTimeControl,
    required this.player1Name,
    required this.player2Name,
  });

  @override
  State<SettingsDialogIos> createState() => _SettingsDialogIosState();
}

class _SettingsDialogIosState extends State<SettingsDialogIos> {
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
    return CupertinoAlertDialog(
      title: const Text('Game Settings'),
      content: SingleChildScrollView(
        child: Column(
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
                CupertinoSwitch(
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
                CupertinoSwitch(
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
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
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
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Text('Blitz'),
              onPressed: () {
                setState(() {
                  _isCustomTime = false;
                  _selectedTimeControl = TimeControl.blitz();
                  _incrementController.text = _selectedTimeControl.increment.inSeconds.toString();
                });
              },
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Text('Rapid'),
              onPressed: () {
                setState(() {
                  _isCustomTime = false;
                  _selectedTimeControl = TimeControl.rapid();
                  _incrementController.text = _selectedTimeControl.increment.inSeconds.toString();
                });
              },
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Text('Classical'),
              onPressed: () {
                setState(() {
                  _isCustomTime = false;
                  _selectedTimeControl = TimeControl.classical();
                  _incrementController.text = _selectedTimeControl.increment.inSeconds.toString();
                });
              },
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Text('Custom'),
              onPressed: () {
                setState(() {
                  _isCustomTime = !_isCustomTime;
                });
              },
            ),
          ],
        ),
        if (_isCustomTime) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildTimeField(_hoursController, 'Hours')),
              const SizedBox(width: 8),
              Expanded(child: _buildTimeField(_minutesController, 'Minutes')),
              const SizedBox(width: 8),
              Expanded(child: _buildTimeField(_secondsController, 'Seconds')),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTimeField(TextEditingController controller, String label) {
    return CupertinoTextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
      ],
      placeholder: label,
      textAlign: TextAlign.center,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
  }) {
    return CupertinoTextField(
      controller: controller,
      keyboardType: keyboardType,
      placeholder: label,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  void _saveSettings() {
    TimeControl newTimeControl;

    if (_isCustomTime) {
      final hours = int.tryParse(_hoursController.text) ?? 0;
      final minutes = int.tryParse(_minutesController.text) ?? 0;
      final seconds = int.tryParse(_secondsController.text) ?? 0;

      if (hours == 0 && minutes == 0 && seconds == 0) {
        showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: const Text('Invalid Time Control'),
              content: const Text('Please set a valid time control.'),
              actions: <CupertinoDialogAction>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () {
                    Navigator.pop(context); // Close the alert
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
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
