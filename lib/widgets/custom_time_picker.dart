import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/time_control.dart';
import '../controllers/timer_controller.dart';

class CustomTimePicker extends StatefulWidget {
  const CustomTimePicker({super.key});

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  int _selectedMinutes = 5;
  int _selectedIncrement = 0;
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveCustomTime() {
    final controller = Get.find<TimerController>();

    // Auto-generate name if not provided
    String name = _nameController.text.trim();
    if (name.isEmpty) {
      name = 'Custom $_selectedMinutes+$_selectedIncrement';
    }

    final customControl = TimeControl(
      name,
      _selectedMinutes,
      _selectedIncrement,
      isCustom: true,
    );

    controller.addCustomControl(customControl);
    controller.resetTimer(customControl);

    Get.back();
    Get.back(); // Close both dialogs
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Custom Time Control',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name input (optional)
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name (Optional)',
                      hintText: 'e.g., My Custom Time',
                      prefixIcon: const Icon(Icons.edit),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Minutes selector
                  Text(
                    'Minutes per Player',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildMinuteSelector(),

                  const SizedBox(height: 32),

                  // Increment selector
                  Text(
                    'Increment (seconds)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildIncrementSelector(),

                  const SizedBox(height: 24),

                  // Preview
                  _buildPreview(),
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _saveCustomTime,
                    icon: const Icon(Icons.check),
                    label: const Text('Create & Use'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinuteSelector() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Decrease button
          IconButton(
            onPressed: () {
              if (_selectedMinutes > 1) {
                setState(() => _selectedMinutes--);
              }
            },
            icon: const Icon(Icons.remove_circle_outline),
            iconSize: 32,
          ),

          // Slider
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _selectedMinutes.toString(),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                Slider(
                  value: _selectedMinutes.toDouble(),
                  min: 1,
                  max: 180,
                  divisions: 179,
                  onChanged: (value) {
                    setState(() => _selectedMinutes = value.toInt());
                  },
                ),
              ],
            ),
          ),

          // Increase button
          IconButton(
            onPressed: () {
              if (_selectedMinutes < 180) {
                setState(() => _selectedMinutes++);
              }
            },
            icon: const Icon(Icons.add_circle_outline),
            iconSize: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildIncrementSelector() {
    final increments = [0, 1, 2, 3, 5, 10, 15, 20, 30, 45, 60];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: increments.map((increment) {
        final isSelected = _selectedIncrement == increment;
        return FilterChip(
          selected: isSelected,
          label: Text(
            increment == 0 ? 'None' : '+$increment',
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onSelected: (_) {
            setState(() => _selectedIncrement = increment);
          },
        );
      }).toList(),
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.visibility_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preview',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_selectedMinutes minutes + $_selectedIncrement seconds increment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
