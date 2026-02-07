import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/ws_colors.dart';
import '../../../core/i18n/locale_provider.dart';
import '../models/unified_timer_model.dart';

class ModuleEditDialog extends StatefulWidget {
  final ModuleModel? module;
  final ModuleType moduleType;
  final Function(ModuleModel) onSave;

  const ModuleEditDialog({
    super.key,
    this.module,
    required this.moduleType,
    required this.onSave,
  });

  @override
  State<ModuleEditDialog> createState() => _ModuleEditDialogState();
}

class _ModuleEditDialogState extends State<ModuleEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _customMinutesController;
  late int _selectedMinutes;
  late bool _allowCustomDuration;

  static const _durationOptions = [60, 90, 120, 180];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.module?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.module?.description ?? '',
    );
    _selectedMinutes =
        widget.module?.defaultDuration.inMinutes ?? 180;
    _allowCustomDuration =
        widget.module?.allowCustomDuration ?? false;
    _customMinutesController = TextEditingController(
      text: _selectedMinutes.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _customMinutesController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_nameController.text.trim().isEmpty) return;

    var minutes = _allowCustomDuration
        ? (int.tryParse(_customMinutesController.text) ?? _selectedMinutes)
        : _selectedMinutes;
    if (minutes < 1) minutes = 1;
    if (minutes > 3600) minutes = 3600;

    final module = widget.module != null
        ? widget.module!.copyWith(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            defaultDuration: Duration(minutes: minutes),
            allowCustomDuration: _allowCustomDuration,
          )
        : ModuleModel(
            id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            defaultDuration: Duration(minutes: minutes),
            status: ModuleStatus.upcoming,
            type: widget.moduleType,
            allowCustomDuration: _allowCustomDuration,
            tasks: [],
          );

    widget.onSave(module);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);
    final isEditMode = widget.module != null;

    return AlertDialog(
      backgroundColor: WsColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(
        isEditMode ? s.editModule : s.addModule,
        style: const TextStyle(
          color: WsColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Module name
            Text(
              s.moduleName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: WsColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              autofocus: true,
              style: const TextStyle(
                color: WsColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: s.enterModuleName,
                hintStyle: const TextStyle(
                  color: WsColors.textSecondary,
                ),
                filled: true,
                fillColor: WsColors.bgDeep.withAlpha(80),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: WsColors.accentCyan,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Module description
            Text(
              s.moduleDescription,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: WsColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              style: const TextStyle(
                color: WsColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: s.enterModuleDescription,
                hintStyle: const TextStyle(
                  color: WsColors.textSecondary,
                ),
                filled: true,
                fillColor: WsColors.bgDeep.withAlpha(80),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: WsColors.accentCyan,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Allow custom duration switch
            Row(
              children: [
                Expanded(
                  child: Text(
                    s.customDuration,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: WsColors.textSecondary,
                    ),
                  ),
                ),
                Switch(
                  value: _allowCustomDuration,
                  onChanged: (v) {
                    setState(() {
                      _allowCustomDuration = v;
                      if (v) {
                        _customMinutesController.text =
                            _selectedMinutes.toString();
                      }
                    });
                  },
                  activeThumbColor: WsColors.accentCyan,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Default duration
            Text(
              s.defaultDuration,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: WsColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            if (_allowCustomDuration)
              TextField(
                controller: _customMinutesController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _MaxValueInputFormatter(3600),
                ],
                style: const TextStyle(
                  color: WsColors.textPrimary,
                  fontSize: 14,
                  fontFamily: 'JetBrainsMono',
                ),
                decoration: InputDecoration(
                  suffixText: 'min',
                  suffixStyle: const TextStyle(
                    color: WsColors.textSecondary,
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: WsColors.bgDeep.withAlpha(80),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: WsColors.accentCyan,
                      width: 2,
                    ),
                  ),
                ),
              )
            else
              Row(
                children: _durationOptions.map((minutes) {
                  final isSelected = _selectedMinutes == minutes;
                  final label = minutes >= 60
                      ? '${minutes ~/ 60}h${minutes % 60 > 0 ? ' ${minutes % 60}m' : ''}'
                      : '${minutes}m';
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () =>
                              setState(() => _selectedMinutes = minutes),
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? WsColors.accentCyan.withAlpha(30)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected
                                    ? WsColors.accentCyan
                                    : WsColors.textSecondary
                                        .withAlpha(40),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? WsColors.accentCyan
                                      : WsColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            s.cancel,
            style: const TextStyle(
              color: WsColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: WsColors.accentCyan,
            foregroundColor: WsColors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            s.save,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _MaxValueInputFormatter extends TextInputFormatter {
  final int maxValue;
  _MaxValueInputFormatter(this.maxValue);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final value = int.tryParse(newValue.text);
    if (value == null) return oldValue;
    if (value > maxValue) {
      return TextEditingValue(
        text: maxValue.toString(),
        selection: TextSelection.collapsed(
          offset: maxValue.toString().length,
        ),
      );
    }
    return newValue;
  }
}
