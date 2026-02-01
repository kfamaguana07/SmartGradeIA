import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/teacher.dart';
import '../providers/teacher_provider.dart';
import '../molecules/loading_indicator.dart';
import '../molecules/error_state.dart';
import '../molecules/confirmation_dialog.dart';
import '../atoms/custom_button.dart';
import '../organisms/entity_list.dart';
import '../organisms/entity_form_dialog.dart';

class TeachersPage extends StatefulWidget {
  const TeachersPage({super.key});

  @override
  State<TeachersPage> createState() => _TeachersPageState();
}

class _TeachersPageState extends State<TeachersPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () {
        if (mounted) context.read<TeacherProvider>().loadTeachers();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Docentes'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TeacherProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingIndicator();
          }

          if (provider.error != null) {
            return ErrorState(
              errorMessage: provider.error!,
              onRetry: () => provider.loadTeachers(),
            );
          }

          return EntityList<Teacher>(
            items: provider.teachers,
            leadingBuilder: (teacher) => CircleAvatar(
              backgroundColor: AppColors.secondary,
              child: Text(
                teacher.firstName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            titleBuilder: (teacher) => teacher.fullName,
            subtitleBuilder: (_) => 'Docente',
            emptyMessage: 'No hay docentes registrados',
            emptyIcon: Icons.school_outlined,
            onEdit: (teacher) => _editTeacher(context, teacher),
            onDelete: (teacher) => _deleteTeacher(context, teacher),
          );
        },
      ),
      floatingActionButton: CustomFAB(
        icon: Icons.add,
        onPressed: () => _addTeacher(context),
        backgroundColor: AppColors.secondary,
        tooltip: 'Agregar docente',
      ),
    );
  }

  void _addTeacher(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => EntityFormDialog<Teacher>(
        title: 'Agregar Docente',
        fields: [
          const FormFieldConfig(
            key: 'firstName',
            label: 'Nombre',
            type: FormFieldType.text,
            icon: Icons.person,
            isRequired: true,
          ),
          const FormFieldConfig(
            key: 'lastName',
            label: 'Apellido',
            type: FormFieldType.text,
            icon: Icons.person_outline,
            isRequired: true,
          ),
        ],
        onSave: (data) async {
          final teacher = Teacher(
            firstName: data['firstName'],
            lastName: data['lastName'],
          );
          final success =
              await context.read<TeacherProvider>().createTeacher(teacher);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    success ? 'Docente agregado' : 'Error al agregar docente'),
              ),
            );
          }
          return success;
        },
      ),
    );
  }

  void _editTeacher(BuildContext context, Teacher teacher) {
    showDialog(
      context: context,
      builder: (dialogContext) => EntityFormDialog<Teacher>(
        title: 'Editar Docente',
        fields: [
          FormFieldConfig(
            key: 'firstName',
            label: 'Nombre',
            type: FormFieldType.text,
            icon: Icons.person,
            isRequired: true,
            initialValue: teacher.firstName,
          ),
          FormFieldConfig(
            key: 'lastName',
            label: 'Apellido',
            type: FormFieldType.text,
            icon: Icons.person_outline,
            isRequired: true,
            initialValue: teacher.lastName,
          ),
        ],
        onSave: (data) async {
          final updatedTeacher = teacher.copyWith(
            firstName: data['firstName'],
            lastName: data['lastName'],
          );
          final success = await context
              .read<TeacherProvider>()
              .updateTeacher(updatedTeacher);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success
                    ? 'Docente actualizado'
                    : 'Error al actualizar docente'),
              ),
            );
          }
          return success;
        },
      ),
    );
  }

  void _deleteTeacher(BuildContext context, Teacher teacher) async {
    final confirm = await ConfirmationDialog.show(
      context,
      title: 'Eliminar Docente',
      message: '¿Está seguro de eliminar a ${teacher.fullName}?',
      confirmText: 'Eliminar',
      isDanger: true,
    );

    if (confirm == true && context.mounted) {
      final success =
          await context.read<TeacherProvider>().deleteTeacher(teacher.id!);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                success ? 'Docente eliminado' : 'Error al eliminar docente'),
          ),
        );
      }
    }
  }
}
