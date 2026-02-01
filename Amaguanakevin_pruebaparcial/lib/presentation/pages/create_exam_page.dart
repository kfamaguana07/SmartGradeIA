import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/exam.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/teacher.dart';
import '../../domain/entities/question.dart';
import '../providers/exam_provider.dart';
import '../providers/subject_provider.dart';
import '../providers/teacher_provider.dart';
import '../providers/question_provider.dart';
import '../../core/utils/pdf_generator_service.dart';
import 'package:printing/printing.dart';

class CreateExamPage extends StatefulWidget {
  const CreateExamPage({super.key});

  @override
  State<CreateExamPage> createState() => _CreateExamPageState();
}

class _CreateExamPageState extends State<CreateExamPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _institutionController = TextEditingController(text: 'ESPE');

  Subject? _selectedSubject;
  Teacher? _selectedTeacher;
  DateTime _examDate = DateTime.now();
  List<Question> _selectedQuestions = [];
  bool _isGenerating = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubjectProvider>().loadSubjects();
      context.read<TeacherProvider>().loadTeachers();
      context.read<QuestionProvider>().loadQuestions();
      context.read<ExamProvider>().loadExams();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _institutionController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Pruebas'),
        backgroundColor: AppColors.info,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.add_circle), text: 'Crear Prueba'),
            Tab(icon: Icon(Icons.list), text: 'Mis Pruebas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCreateExamTab(),
          _buildExamListTab(),
        ],
      ),
    );
  }

  Widget _buildCreateExamTab() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información del Examen',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título del Examen*',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _institutionController,
                    decoration: const InputDecoration(
                      labelText: 'Institución*',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Materia y Docente',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Consumer<SubjectProvider>(
                    builder: (context, provider, _) {
                      if (provider.subjects.isEmpty) {
                        return const Text('No hay materias registradas');
                      }
                      return DropdownButtonFormField<Subject>(
                        decoration: const InputDecoration(
                          labelText: 'Materia*',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _selectedSubject,
                        items: provider.subjects.map((subject) {
                          return DropdownMenuItem(
                            value: subject,
                            child: Text('${subject.nrc} - ${subject.name}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSubject = value;
                            _loadQuestionsForSubject(value?.id);
                          });
                        },
                        validator: (v) =>
                            v == null ? 'Seleccione una materia' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Consumer<TeacherProvider>(
                    builder: (context, provider, _) {
                      if (provider.teachers.isEmpty) {
                        return const Text('No hay docentes registrados');
                      }
                      return DropdownButtonFormField<Teacher>(
                        decoration: const InputDecoration(
                          labelText: 'Docente*',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _selectedTeacher,
                        items: provider.teachers.map((teacher) {
                          return DropdownMenuItem(
                            value: teacher,
                            child: Text(teacher.fullName),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedTeacher = value),
                        validator: (v) =>
                            v == null ? 'Seleccione un docente' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: const Text('Fecha del Examen'),
                    subtitle: Text(_examDate.toString().split(' ')[0]),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _examDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => _examDate = date);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Preguntas Seleccionadas',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_selectedQuestions.length} preguntas',
                        style: const TextStyle(color: AppColors.info),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_selectedSubject != null)
                    ElevatedButton.icon(
                      onPressed: _showQuestionSelector,
                      icon: const Icon(Icons.add),
                      label: const Text('Seleccionar Preguntas'),
                    ),
                  if (_selectedQuestions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No hay preguntas seleccionadas',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ..._selectedQuestions.asMap().entries.map((entry) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${entry.key + 1}'),
                        ),
                        title: Text(
                          entry.value.statement,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text('Valor: ${entry.value.value} puntos'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _selectedQuestions.removeAt(entry.key);
                            });
                          },
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isGenerating ? null : _resetForm,
                  icon: const Icon(Icons.clear),
                  label: const Text('Limpiar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _createExam,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isGenerating ? 'Creando...' : 'Crear Prueba'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _loadQuestionsForSubject(int? subjectId) {
    if (subjectId == null) return;
    setState(() {
      _selectedQuestions.clear();
    });
  }

  void _showQuestionSelector() {
    final questionProvider = context.read<QuestionProvider>();
    final availableQuestions = questionProvider.questions
        .where((q) => q.subjectId == _selectedSubject?.id)
        .toList();

    if (availableQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay preguntas para esta materia')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _QuestionSelectorDialog(
        availableQuestions: availableQuestions,
        selectedQuestions: _selectedQuestions,
        onSelect: (questions) {
          setState(() {
            _selectedQuestions = questions;
          });
        },
      ),
    );
  }

  Future<void> _createExam() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar al menos una pregunta')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final qrCode = _generateQRCode();

      final exam = Exam(
        title: _titleController.text,
        description: _descriptionController.text,
        subjectId: _selectedSubject!.id!,
        teacherId: _selectedTeacher!.id!,
        examDate: _examDate,
        institution: _institutionController.text,
        qrCode: qrCode,
      );

      final examProvider = context.read<ExamProvider>();
      final examId = await examProvider.createExam(
          exam, _selectedQuestions.map((q) => q.id!).toList());

      if (examId > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prueba creada exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );

        _resetForm();
        _tabController.animateTo(1);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  String _generateQRCode() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNum = random.nextInt(9999);
    return 'EXAM-$timestamp-$randomNum';
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _institutionController.text = 'ESPE';
    setState(() {
      _selectedSubject = null;
      _selectedTeacher = null;
      _examDate = DateTime.now();
      _selectedQuestions.clear();
    });
  }

  Widget _buildExamListTab() {
    return Consumer<ExamProvider>(
      builder: (context, examProvider, _) {
        if (examProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (examProvider.exams.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No hay pruebas creadas',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _tabController.animateTo(0),
                  icon: const Icon(Icons.add),
                  label: const Text('Crear Primera Prueba'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: examProvider.exams.length,
          itemBuilder: (context, index) {
            final exam = examProvider.exams[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.info,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  exam.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fecha: ${exam.examDate.toString().split(' ')[0]}'),
                    Text('QR: ${exam.qrCode}'),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (exam.description != null &&
                            exam.description!.isNotEmpty) ...[
                          const Text(
                            'Descripción:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(exam.description!),
                          const SizedBox(height: 12),
                        ],
                        if (exam.institution != null) ...[
                          Text('Institución: ${exam.institution}'),
                          const SizedBox(height: 12),
                        ],
                        FutureBuilder<List<Question>>(
                          future: context
                              .read<ExamProvider>()
                              .getExamQuestionsById(exam.id!),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                'Preguntas: ${snapshot.data!.length}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              );
                            }
                            return const Text('Preguntas: Cargando...');
                          },
                        ),
                        const Divider(height: 24),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _exportExamPDF(exam, 'full'),
                              icon: const Icon(Icons.description, size: 18),
                              label: const Text('Examen Completo'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.info,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _exportExamPDF(exam, 'answer_sheet'),
                              icon: const Icon(Icons.fact_check, size: 18),
                              label: const Text('Hoja Respuestas'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _editExam(exam),
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Editar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _deleteExam(exam),
                              icon: const Icon(Icons.delete, size: 18),
                              label: const Text('Eliminar'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _exportExamPDF(Exam exam, String type) async {
    try {
      setState(() => _isGenerating = true);

      final questions =
          await context.read<ExamProvider>().getExamQuestionsById(exam.id!);

      if (questions.isEmpty) {
        throw Exception('No se encontraron preguntas para este examen');
      }

      if (!mounted) return;
      final subjectProvider = context.read<SubjectProvider>();
      final teacherProvider = context.read<TeacherProvider>();

      final subject = subjectProvider.subjects.firstWhere(
        (s) => s.id == exam.subjectId,
        orElse: () => Subject(name: 'N/A', nrc: 'N/A'),
      );

      final teacher = teacherProvider.teachers.firstWhere(
        (t) => t.id == exam.teacherId,
        orElse: () => Teacher(firstName: 'N/A', lastName: ''),
      );

      if (!mounted) return;

      final pdfService = PDFGeneratorService();
      final File pdfFile;

      if (type == 'answer_sheet') {
        final maxOptions = questions
            .map((q) => q.options.length)
            .reduce((a, b) => a > b ? a : b);

        pdfFile = await pdfService.generateAnswerSheetPDF(
          exam: exam,
          numberOfQuestions: questions.length,
          optionsPerQuestion: maxOptions,
        );
      } else {
        pdfFile = await pdfService.generateExamPDF(
          exam: exam,
          questions: questions,
          subjectName: subject.name,
          teacherName: teacher.fullName,
        );
      }

      await Printing.layoutPdf(
        onLayout: (format) => pdfFile.readAsBytes(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              type == 'answer_sheet'
                  ? 'Hoja de respuestas exportada exitosamente'
                  : 'Examen exportado exitosamente',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _editExam(Exam exam) async {
    try {
      if (!mounted) return;
      final questions =
          await context.read<ExamProvider>().getExamQuestionsById(exam.id!);

      if (questions.isEmpty) {
        throw Exception('No se encontraron preguntas para este examen');
      }

      if (!mounted) return;
      final questionProvider = context.read<QuestionProvider>();
      final availableQuestions = questionProvider.questions
          .where((q) => q.subjectId == exam.subjectId)
          .toList();

      if (!mounted) return;

      final updatedQuestions = await showDialog<List<Question>>(
        context: context,
        builder: (context) => _QuestionSelectorDialog(
          availableQuestions: availableQuestions,
          selectedQuestions: questions,
          onSelect: (selected) => Navigator.pop(context, selected),
        ),
      );

      if (updatedQuestions != null && mounted) {
        final success = await context.read<ExamProvider>().updateExamQuestions(
              exam.id!,
              updatedQuestions.map((q) => q.id!).toList(),
            );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Prueba actualizada exitosamente'),
              backgroundColor: AppColors.success,
            ),
          );
          await context.read<ExamProvider>().loadExams();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al actualizar la prueba'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteExam(Exam exam) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar la prueba "${exam.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final success = await context.read<ExamProvider>().deleteExam(exam.id!);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Prueba eliminada exitosamente'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _QuestionSelectorDialog extends StatefulWidget {
  final List<Question> availableQuestions;
  final List<Question> selectedQuestions;
  final Function(List<Question>) onSelect;

  const _QuestionSelectorDialog({
    required this.availableQuestions,
    required this.selectedQuestions,
    required this.onSelect,
  });

  @override
  State<_QuestionSelectorDialog> createState() =>
      _QuestionSelectorDialogState();
}

class _QuestionSelectorDialogState extends State<_QuestionSelectorDialog> {
  late List<Question> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selectedQuestions);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Seleccionar Preguntas'),
          Text(
            '${_tempSelected.length}/${widget.availableQuestions.length}',
            style: const TextStyle(fontSize: 14, color: AppColors.info),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _tempSelected = List.from(widget.availableQuestions);
                      });
                    },
                    icon: const Icon(Icons.select_all, size: 18),
                    label: const Text('Todas'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _tempSelected.clear();
                      });
                    },
                    icon: const Icon(Icons.deselect, size: 18),
                    label: const Text('Ninguna'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.availableQuestions.length,
                itemBuilder: (context, index) {
                  final question = widget.availableQuestions[index];
                  final isSelected =
                      _tempSelected.any((q) => q.id == question.id);
                  return CheckboxListTile(
                    title: Text(
                      question.statement,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text('${question.type} - ${question.value} pts'),
                    value: isSelected,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _tempSelected.add(question);
                        } else {
                          _tempSelected.removeWhere((q) => q.id == question.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSelect(_tempSelected);
            Navigator.pop(context);
          },
          child: Text('Seleccionar (${_tempSelected.length})'),
        ),
      ],
    );
  }
}
