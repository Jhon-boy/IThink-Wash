import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithinkwash/core/theme_app.dart';
import 'package:ithinkwash/shared/widgets/custom_buttom.dart';

class TimePickerWidget extends ConsumerStatefulWidget {
  final String title;
  final TimeOfDay? selectedTime;
  final Function(TimeOfDay) onTimeSelected;
  final bool enabled;

  const TimePickerWidget({
    super.key,
    required this.title,
    required this.onTimeSelected,
    this.selectedTime,
    this.enabled = true,
  });

  static Future<TimeOfDay?> showTimePickerDialog({
    required BuildContext context,
    String title = 'Seleccionar Hora',
    TimeOfDay? initialTime,
  }) {
    return showDialog<TimeOfDay>(
      context: context,
      builder: (context) => _TimePickerDialog(
        title: title,
        initialTime: initialTime ?? const TimeOfDay(hour: 12, minute: 0),
      ),
    );
  }

  @override
  ConsumerState<TimePickerWidget> createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends ConsumerState<TimePickerWidget> {
  TimeOfDay? _selectedTime;
  int _hour = 12;
  int _minute = 0;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.selectedTime;
    if (widget.selectedTime != null) {
      _hour = widget.selectedTime!.hour;
      _minute = widget.selectedTime!.minute;
    }
  }

  @override
  void didUpdateWidget(TimePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTime != oldWidget.selectedTime) {
      _selectedTime = widget.selectedTime;
      if (widget.selectedTime != null) {
        _hour = widget.selectedTime!.hour;
        _minute = widget.selectedTime!.minute;
      }
    }
  }

  String get _horaDisplay =>
      '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: widget.enabled
          ? () async {
              final result = await showDialog<TimeOfDay>(
                context: context,
                builder: (context) => _TimePickerDialog(
                  title: widget.title,
                  initialTime: TimeOfDay(hour: _hour, minute: _minute),
                ),
              );
              if (result != null) {
                setState(() {
                  _selectedTime = result;
                  _hour = result.hour;
                  _minute = result.minute;
                });
                widget.onTimeSelected(result);
              }
            }
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: ThemeApp.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeApp.inputBorder),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time,
                size: 20, color: ThemeApp.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: ThemeApp.textSecondary,
                      fontFamily: ThemeApp.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _horaDisplay,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ThemeApp.textPrimary,
                      fontFamily: ThemeApp.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: ThemeApp.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _TimePickerDialog extends StatefulWidget {
  final String title;
  final TimeOfDay initialTime;

  const _TimePickerDialog({
    required this.title,
    required this.initialTime,
  });

  @override
  State<_TimePickerDialog> createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<_TimePickerDialog> {
  late int _hour;
  late int _minute;
  late FixedExtentScrollController _hourScrollCtrl;
  late FixedExtentScrollController _minuteScrollCtrl;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialTime.hour;
    _minute = widget.initialTime.minute;
    _hourScrollCtrl = FixedExtentScrollController(initialItem: _hour);
    _minuteScrollCtrl = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hourScrollCtrl.dispose();
    _minuteScrollCtrl.dispose();
    super.dispose();
  }

  Widget _buildWheel({
    required String label,
    required int value,
    required int max,
    required FixedExtentScrollController controller,
    required ValueChanged<int> onChanged,
  }) {
    final items = List.generate(max + 1, (i) => i.toString().padLeft(2, '0'));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: ThemeApp.textSecondary,
                fontFamily: ThemeApp.fontFamily)),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          height: 150,
          child: ListWheelScrollView(
            controller: controller,
            itemExtent: 42,
            diameterRatio: 1.5,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              onChanged(index);
              setState(() {});
            },
            children: items.map((item) {
              final isSelected = item == value.toString().padLeft(2, '0');
              return Container(
                alignment: Alignment.center,
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: isSelected ? 32 : 20,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color:
                        isSelected ? ThemeApp.primary : ThemeApp.textSecondary,
                    fontFamily: ThemeApp.fontFamily,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: ThemeApp.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeApp.inputBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: ThemeApp.fontFamily,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildWheel(
                  label: 'Hora',
                  value: _hour,
                  max: 23,
                  controller: _hourScrollCtrl,
                  onChanged: (v) => _hour = v,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(':',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: ThemeApp.fontFamily)),
                ),
                _buildWheel(
                  label: 'Minuto',
                  value: _minute,
                  max: 59,
                  controller: _minuteScrollCtrl,
                  onChanged: (v) => _minute = v,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                    child: CustomButton(
                  text: 'Cancelar',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  colorButton: ThemeApp.white,
                  colorText: ThemeApp.apple,
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: CustomButton(
                        text: 'Aceptar',
                        onPressed: () {
                          Navigator.pop(
                            context,
                            TimeOfDay(hour: _hour, minute: _minute),
                          );
                        })),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
