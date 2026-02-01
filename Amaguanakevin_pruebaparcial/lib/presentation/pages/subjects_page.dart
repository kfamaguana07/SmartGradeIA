import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/teacher.dart';
import '../providers/subject_provider.dart';
import '../providers/teacher_provider.dart';

class SubjectsPage extends StatefulWidget {
  const SubjectsPage({super.key});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final subjectProvider = context.read<SubjectProvider>();
    final teacherProvider = context.read<TeacherProvider>();

    await teacherProvider.loadTeachers();
    await subjectProvider.loadSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materias'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer<SubjectProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (provider.subjects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay materias registradas',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Presiona + para agregar una',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.subjects.length,
            itemBuilder: (context, index) =>
                _buildSubjectCard(provider.subjects[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSubjectDialog(),
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSubjectCard(Subject subject) {
    final teacherProvider = context.read<TeacherProvider>();
    Teacher? teacher;

    if (subject.teacherId != null) {
      teacher = teacherProvider.teachers.firstWhere(
        (t) => t.id == subject.teacherId,
        orElse: () => Teacher(
          firstName: 'Sin',
          lastName: 'Asignar',
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.secondary,
          child: Text(
            subject.nrc.isNotEmpty ? subject.nrc[0].toUpperCase() : 'M',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(subject.name),
        subtitle: Text(
          'NRC: ${subject.nrc}${teacher != null ? ' - Docente: ${teacher.fullName}' : ''}',
        ),
        isThreeLine: false,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.secondary),
              onPressed: () => _showSubjectDialog(editSubject: subject),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteSubject(subject),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubjectDialog({Subject? editSubject}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: editSubject?.name ?? '');
    final nrcController = TextEditingController(text: editSubject?.nrc ?? '');

    final teacherProvider = context.read<TeacherProvider>();
    Teacher? selectedTeacher;

    if (editSubject?.teacherId != null) {
      selectedTeacher = teacherProvider.teachers.firstWhere(
        (t) => t.id == editSubject!.teacherId,
        orElse: () => teacherProvider.teachers.isNotEmpty
            ? teacherProvider.teachers.first
            : Teacher(firstName: '', lastName: ''),
      );
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title:
              Text(editSubject == null ? 'Agregar Materia' : 'Editar Materia'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la Materia',
                      prefixIcon: Icon(Icons.book),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nrcController,
                    decoration: const InputDecoration(
                      labelText: 'NRC',
                      prefixIcon: Icon(Icons.tag),
                      border: OutlineInputBorder(),
                      hintText: 'Ej: 12345',
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  if (teacherProvider.teachers.isNotEmpty)
                    DropdownButtonFormField<Teacher>(
                      initialValue: selectedTeacher,
                      decoration: const InputDecoration(
                        labelText: 'Docente (opcional)',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Seleccionar docente'),
                      items: [
                        const DropdownMenuItem<Teacher>(
                          value: null,
                          child: Text('Sin asignar'),
                        ),
                        ...teacherProvider.teachers.map((teacher) {
                          return DropdownMenuItem(
                            value: teacher,
                            child: Text(teacher.fullName),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setStateDialog(() => selectedTeacher = value);
                      },
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange[700]),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Crea docentes primero para asignarlos',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final subject = Subject(
                    id: editSubject?.id,
                    name: nameController.text,
                    nrc: nrcController.text.toUpperCase(),
                    teacherId: selectedTeacher?.id,
                    createdAt: editSubject?.createdAt,
                  );

                  final provider = context.read<SubjectProvider>();

                  if (editSubject == null) {
                    await provider.createSubject(subject);
                  } else {
                    await provider.updateSubject(subject);
                  }

                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(editSubject == null
                          ? 'Materia agregada exitosamente'
                          : 'Materia actualizada exitosamente'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
              ),
              child: Text(editSubject == null ? 'Guardar' : 'Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteSubject(Subject subject) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Materia'),
        content: Text('¿Está seguro de eliminar la materia "${subject.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = context.read<SubjectProvider>();
      await provider.deleteSubject(subject.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Materia eliminada'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
