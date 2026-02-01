import 'package:flutter/material.dart';
import '../atoms/custom_text_field.dart';
import '../atoms/custom_button.dart';

class EntityFormDialog<T> extends StatefulWidget {
  final String title;
  final List<FormFieldConfig> fields;
  final T? initialData;
  final Future<bool> Function(Map<String, dynamic> data) onSave;

  const EntityFormDialog({
    super.key,
    required this.title,
    required this.fields,
    this.initialData,
    required this.onSave,
  });

  @override
  State<EntityFormDialog<T>> createState() => _EntityFormDialogState<T>();
}

class _EntityFormDialogState<T> extends State<EntityFormDialog<T>> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;
  late Map<String, dynamic> _dropdownValues;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controllers = {};
    _dropdownValues = {};

    for (var field in widget.fields) {
      if (field.type == FormFieldType.text ||
          field.type == FormFieldType.number) {
        _controllers[field.key] = TextEditingController(
          text: field.initialValue?.toString() ?? '',
        );
      } else if (field.type == FormFieldType.dropdown) {
        _dropdownValues[field.key] = field.initialValue;
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.fields.map((field) {
              if (field.type == FormFieldType.text) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CustomTextField(
                    controller: _controllers[field.key],
                    labelText: field.label,
                    prefixIcon: field.icon,
                    isRequired: field.isRequired,
                    maxLines: field.maxLines,
                    validator: field.validator,
                  ),
                );
              } else if (field.type == FormFieldType.number) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: NumberTextField(
                    controller: _controllers[field.key],
                    labelText: field.label,
                    prefixIcon: field.icon,
                    isRequired: field.isRequired,
                  ),
                );
              } else if (field.type == FormFieldType.dropdown) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DropdownButtonFormField<dynamic>(
                    initialValue: _dropdownValues[field.key],
                    decoration: InputDecoration(
                      labelText:
                          field.isRequired ? '${field.label}*' : field.label,
                      prefixIcon: field.icon != null ? Icon(field.icon) : null,
                      border: const OutlineInputBorder(),
                    ),
                    items: field.dropdownItems,
                    onChanged: (value) {
                      setState(() {
                        _dropdownValues[field.key] = value;
                      });
                    },
                    validator: field.isRequired
                        ? (value) => value == null ? 'Campo requerido' : null
                        : null,
                  ),
                );
              }
              return const SizedBox.shrink();
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextOnlyButton(
          text: 'Cancelar',
          onPressed: () => Navigator.pop(context),
        ),
        PrimaryButton(
          text: 'Guardar',
          isLoading: _isSaving,
          onPressed: _handleSave,
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final data = <String, dynamic>{};
      for (var field in widget.fields) {
        if (field.type == FormFieldType.text ||
            field.type == FormFieldType.number) {
          data[field.key] = _controllers[field.key]!.text;
        } else if (field.type == FormFieldType.dropdown) {
          data[field.key] = _dropdownValues[field.key];
        }
      }

      final success = await widget.onSave(data);
      if (success && mounted) {
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class FormFieldConfig {
  final String key;
  final String label;
  final FormFieldType type;
  final IconData? icon;
  final bool isRequired;
  final dynamic initialValue;
  final int? maxLines;
  final String? Function(String?)? validator;
  final List<DropdownMenuItem>? dropdownItems;

  const FormFieldConfig({
    required this.key,
    required this.label,
    required this.type,
    this.icon,
    this.isRequired = false,
    this.initialValue,
    this.maxLines = 1,
    this.validator,
    this.dropdownItems,
  });
}

enum FormFieldType { text, number, dropdown }
