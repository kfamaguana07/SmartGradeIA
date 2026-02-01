import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/subject.dart';
import '../providers/question_provider.dart';
import '../providers/subject_provider.dart';
import '../../core/utils/aiken_parser.dart';

class QuestionsPage extends StatefulWidget {
  const QuestionsPage({super.key});

  @override
  State<QuestionsPage> createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  Subject? _selectedSubject;
  bool _isSelectionMode = false;
  final Set<int> _selectedQuestionIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final questionProvider = context.read<QuestionProvider>();
    final subjectProvider = context.read<SubjectProvider>();

    await subjectProvider.loadSubjects();
    await questionProvider.loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selectedQuestionIds.length} seleccionadas')
            : const Text('Banco de Preguntas'),
        backgroundColor: AppColors.questionSimple,
        foregroundColor: Colors.white,
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSelectionMode = false;
                    _selectedQuestionIds.clear();
                  });
                },
              )
            : null,
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Eliminar seleccionadas',
                  onPressed: _selectedQuestionIds.isEmpty
                      ? null
                      : _deleteSelectedQuestions,
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  tooltip: 'Seleccionar para eliminar',
                  onPressed: () {
                    setState(() {
                      _isSelectionMode = true;
                      _selectedQuestionIds.clear();
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.upload_file),
                  tooltip: 'Importar AIKEN',
                  onPressed: _importAiken,
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'Filtrar por materia',
                  onPressed: _showSubjectFilter,
                ),
              ],
      ),
      body: Consumer<QuestionProvider>(
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

          final questions = _selectedSubject == null
              ? provider.questions
              : provider.questions
                  .where((q) => q.subjectId == _selectedSubject!.id)
                  .toList();

          if (questions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _selectedSubject == null
                        ? 'No hay preguntas registradas'
                        : 'No hay preguntas para ${_selectedSubject!.name}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Presiona + para agregar o importar',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: questions.length,
            itemBuilder: (context, index) =>
                _buildQuestionCard(questions[index]),
          );
        },
      ),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddQuestionDialog(),
              backgroundColor: AppColors.questionSimple,
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  Widget _buildQuestionCard(Question question) {
    final typeColors = {
      'simple': AppColors.questionSimple,
      'multiple': AppColors.questionMultiple,
      'true_false': Colors.purple,
      'complete': Colors.orange,
    };

    final typeLabels = {
      'simple': 'Selección Simple',
      'multiple': 'Selección Múltiple',
      'true_false': 'Verdadero/Falso',
      'complete': 'Completar',
    };

    final isSelected = _selectedQuestionIds.contains(question.id);

    if (_isSelectionMode) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        color:
            isSelected ? AppColors.questionSimple.withValues(alpha: 0.1) : null,
        child: CheckboxListTile(
          secondary: CircleAvatar(
            backgroundColor: typeColors[question.type] ?? Colors.grey,
            child: Icon(
              question.type == 'true_false'
                  ? Icons.check_circle_outline
                  : Icons.help_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(
            question.statement,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Row(
            children: [
              Text(typeLabels[question.type] ?? question.type),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.questionSimple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Valor: ${question.value}',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          value: isSelected,
          onChanged: (checked) {
            setState(() {
              if (checked == true) {
                _selectedQuestionIds.add(question.id!);
              } else {
                _selectedQuestionIds.remove(question.id!);
              }
            });
          },
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: typeColors[question.type] ?? Colors.grey,
          child: Icon(
            question.type == 'true_false'
                ? Icons.check_circle_outline
                : Icons.help_outline,
            color: Colors.white,
          ),
        ),
        title: Text(
          question.statement,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Row(
          children: [
            Text(typeLabels[question.type] ?? question.type),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.questionSimple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Valor: ${question.value}',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (question.options.isNotEmpty) ...[
                  const Text(
                    'Opciones:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  ...List<Widget>.generate(
                    question.options.length,
                    (i) => _buildOptionItem(question, i),
                  ),
                  const SizedBox(height: 12),
                ],
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Respuesta${question.correctAnswers.length > 1 ? "s" : ""}: ${question.correctAnswers.join(", ")}',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 20),
                      label: const Text('Editar'),
                      onPressed: () => _showEditQuestionDialog(question),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon:
                          const Icon(Icons.delete, color: Colors.red, size: 20),
                      label: const Text('Eliminar',
                          style: TextStyle(color: Colors.red)),
                      onPressed: () => _deleteQuestion(question),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(Question question, int index) {
    final optionLetter = String.fromCharCode(65 + index);
    final isCorrect = question.correctAnswers.contains(optionLetter);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCorrect ? AppColors.success : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$optionLetter) ${question.options[index]}',
              style: TextStyle(
                fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSubjectFilter() async {
    final subjectProvider = context.read<SubjectProvider>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por Materia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('Todas las materias'),
              selected: _selectedSubject == null,
              onTap: () {
                setState(() => _selectedSubject = null);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ...subjectProvider.subjects.map((subject) => ListTile(
                  leading: const Icon(Icons.book),
                  title: Text(subject.name),
                  selected: _selectedSubject?.id == subject.id,
                  onTap: () {
                    setState(() => _selectedSubject = subject);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showAddQuestionDialog({Question? editQuestion}) async {
    final formKey = GlobalKey<FormState>();
    final statementController =
        TextEditingController(text: editQuestion?.statement ?? '');
    final valueController =
        TextEditingController(text: editQuestion?.value.toString() ?? '1.0');

    String selectedType = editQuestion?.type ?? 'simple';
    Subject? selectedSubject;

    final subjectProvider = context.read<SubjectProvider>();
    if (editQuestion?.subjectId != null) {
      selectedSubject = subjectProvider.subjects.firstWhere(
        (s) => s.id == editQuestion!.subjectId,
        orElse: () => subjectProvider.subjects.first,
      );
    }

    final optionControllers = List.generate(4, (i) {
      if (editQuestion != null && i < editQuestion.options.length) {
        return TextEditingController(text: editQuestion.options[i]);
      }
      return TextEditingController();
    });

    Set<String> selectedAnswers =
        Set<String>.from(editQuestion?.correctAnswers ?? ['A']);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(
              editQuestion == null ? 'Agregar Pregunta' : 'Editar Pregunta'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Pregunta',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'simple', child: Text('Selección Simple')),
                      DropdownMenuItem(
                          value: 'multiple', child: Text('Selección Múltiple')),
                      DropdownMenuItem(
                          value: 'true_false', child: Text('Verdadero/Falso')),
                      DropdownMenuItem(
                          value: 'complete', child: Text('Completar')),
                    ],
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedType = value!;
                        if (selectedType == 'true_false') {
                          selectedAnswers = {'A'};
                        } else if (selectedType == 'simple') {
                          selectedAnswers = {selectedAnswers.first};
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Subject>(
                    initialValue: selectedSubject,
                    decoration: const InputDecoration(
                      labelText: 'Materia',
                      prefixIcon: Icon(Icons.book),
                    ),
                    items: subjectProvider.subjects.map((subject) {
                      return DropdownMenuItem(
                        value: subject,
                        child: Text(subject.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() => selectedSubject = value);
                    },
                    validator: (v) =>
                        v == null ? 'Seleccione una materia' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: statementController,
                    decoration: const InputDecoration(
                      labelText: 'Enunciado de la pregunta',
                      prefixIcon: Icon(Icons.question_mark),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: valueController,
                    decoration: const InputDecoration(
                      labelText: 'Valoración',
                      prefixIcon: Icon(Icons.star),
                      suffixText: 'puntos',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Requerido';
                      final val = double.tryParse(v!);
                      if (val == null || val <= 0) return 'Debe ser mayor a 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  if (selectedType != 'complete') ...[
                    const Text(
                      'Opciones de respuesta:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    if (selectedType == 'true_false') ...[
                      _buildTrueFalseOptions(selectedAnswers, setStateDialog),
                    ] else ...[
                      ...List.generate(4, (i) {
                        final letter = String.fromCharCode(65 + i);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Checkbox(
                                value: selectedAnswers.contains(letter),
                                onChanged: (checked) {
                                  setStateDialog(() {
                                    if (selectedType == 'simple') {
                                      selectedAnswers = {letter};
                                    } else {
                                      if (checked == true) {
                                        selectedAnswers.add(letter);
                                      } else {
                                        selectedAnswers.remove(letter);
                                      }
                                    }
                                  });
                                },
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: optionControllers[i],
                                  decoration: InputDecoration(
                                    labelText: 'Opción $letter',
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator: (v) =>
                                      v?.isEmpty ?? true ? 'Requerido' : null,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ] else ...[
                    const Text(
                      'La respuesta correcta debe proporcionarse:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: optionControllers[0],
                      decoration: const InputDecoration(
                        labelText: 'Respuesta correcta',
                        border: OutlineInputBorder(),
                        hintText: 'Escriba la respuesta correcta',
                      ),
                      validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                    ),
                  ],
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
                  if (selectedSubject == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Debe seleccionar una materia')),
                    );
                    return;
                  }

                  if (selectedType != 'complete' && selectedAnswers.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Debe marcar al menos una respuesta correcta')),
                    );
                    return;
                  }

                  final question = Question(
                    id: editQuestion?.id,
                    statement: statementController.text,
                    type: selectedType,
                    options: selectedType == 'complete'
                        ? []
                        : selectedType == 'true_false'
                            ? ['Verdadero', 'Falso']
                            : optionControllers.map((c) => c.text).toList(),
                    correctAnswers: selectedType == 'complete'
                        ? [optionControllers[0].text]
                        : selectedAnswers.toList(),
                    value: double.parse(valueController.text),
                    subjectId: selectedSubject!.id,
                    createdAt: editQuestion?.createdAt,
                  );

                  final provider = context.read<QuestionProvider>();

                  if (editQuestion == null) {
                    await provider.createQuestion(question);
                  } else {
                    await provider.updateQuestion(question);
                  }

                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(editQuestion == null
                          ? 'Pregunta agregada exitosamente'
                          : 'Pregunta actualizada exitosamente'),
                    ),
                  );
                }
              },
              child: Text(editQuestion == null ? 'Guardar' : 'Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrueFalseOptions(
      Set<String> selectedAnswers, StateSetter setStateDialog) {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('Verdadero'),
          value: 'A',
          groupValue: selectedAnswers.isNotEmpty ? selectedAnswers.first : null,
          onChanged: (value) {
            if (value != null) setStateDialog(() => selectedAnswers = {value});
          },
        ),
        RadioListTile<String>(
          title: const Text('Falso'),
          value: 'B',
          groupValue: selectedAnswers.isNotEmpty ? selectedAnswers.first : null,
          onChanged: (value) {
            if (value != null) setStateDialog(() => selectedAnswers = {value});
          },
        ),
      ],
    );
  }

  void _showEditQuestionDialog(Question question) {
    _showAddQuestionDialog(editQuestion: question);
  }

  void _deleteQuestion(Question question) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Pregunta'),
        content: const Text('¿Está seguro de eliminar esta pregunta?'),
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
      final provider = context.read<QuestionProvider>();
      await provider.deleteQuestion(question.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pregunta eliminada')),
        );
      }
    }
  }

  void _deleteSelectedQuestions() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Preguntas'),
        content: Text(
            '¿Está seguro de eliminar ${_selectedQuestionIds.length} preguntas seleccionadas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar todas'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = context.read<QuestionProvider>();
      int deletedCount = 0;

      for (final questionId in _selectedQuestionIds) {
        try {
          await provider.deleteQuestion(questionId);
          deletedCount++;
        } catch (e) {
          // Ignorar errores individuales y continuar con las siguientes preguntas
        }
      }

      if (mounted) {
        setState(() {
          _isSelectionMode = false;
          _selectedQuestionIds.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('$deletedCount preguntas eliminadas exitosamente')),
        );
      }
    }
  }

  Future<void> _importAiken() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'aiken'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();

      if (!mounted) return;
      final subjectProvider = context.read<SubjectProvider>();

      if (subjectProvider.subjects.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Debe crear al menos una materia primero')),
          );
        }
        return;
      }

      Subject? selectedSubject;

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Seleccionar Materia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: subjectProvider.subjects
                .map((subject) => ListTile(
                      title: Text(subject.name),
                      onTap: () {
                        selectedSubject = subject;
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
          ),
        ),
      );

      if (selectedSubject == null) return;

      final questions =
          AikenParser.parseAikenFile(content, subjectId: selectedSubject!.id);

      if (questions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('No se encontraron preguntas válidas en el archivo')),
          );
        }
        return;
      }

      if (!mounted) return;
      final provider = context.read<QuestionProvider>();
      int saved = 0;

      for (final question in questions) {
        try {
          await provider.createQuestion(question);
          saved++;
        } catch (e) {
          // Ignorar errores individuales y continuar con las siguientes preguntas
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '$saved de ${questions.length} preguntas importadas exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al importar archivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
