import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/exam.dart';
import '../../domain/entities/student.dart';
import '../../domain/entities/result.dart';
import '../../core/utils/gemini_service.dart';
import '../../data/repositories/exam_repository_impl.dart';
import '../../data/repositories/result_repository_impl.dart';
import '../../data/repositories/student_repository_impl.dart';
import '../../data/datasources/database_helper.dart';

class ScanExamPage extends StatefulWidget {
  const ScanExamPage({super.key});

  @override
  State<ScanExamPage> createState() => _ScanExamPageState();
}

class _ScanExamPageState extends State<ScanExamPage> {
  final ImagePicker _picker = ImagePicker();
  final GeminiService _geminiService = GeminiService();

  final List<File> _capturedImages = [];
  bool _isProcessing = false;
  String _statusMessage = '';
  String _scanMethod = 'full_exam'; // 'full_exam' o 'answer_sheet'

  Exam? _selectedExam;
  Student? _selectedStudent;

  List<Exam> _exams = [];
  List<Student> _students = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final examRepo = ExamRepositoryImpl(DatabaseHelper.instance);
    final studentRepo = StudentRepositoryImpl(DatabaseHelper.instance);

    final exams = await examRepo.getAllExams();
    final students = await studentRepo.getAllStudents();

    setState(() {
      _exams = exams;
      _students = students;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Prueba'),
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildExamSelector(),
            const SizedBox(height: 16),
            _buildStudentSelector(),
            const SizedBox(height: 16),
            _buildScanMethodSelector(),
            const SizedBox(height: 24),
            _buildCaptureSection(),
            const SizedBox(height: 24),
            if (_capturedImages.isNotEmpty) _buildImagePreview(),
            const SizedBox(height: 24),
            if (_statusMessage.isNotEmpty) _buildStatusMessage(),
            const SizedBox(height: 16),
            if (_capturedImages.isNotEmpty && !_isProcessing)
              _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildExamSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccionar Examen',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Exam>(
              initialValue: _selectedExam,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Elige el examen',
                prefixIcon: Icon(Icons.quiz),
              ),
              items: _exams.map((exam) {
                return DropdownMenuItem(
                  value: exam,
                  child: Text(exam.title),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedExam = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccionar Estudiante',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Student>(
              initialValue: _selectedStudent,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Elige el estudiante',
                prefixIcon: Icon(Icons.person),
              ),
              items: _students.map((student) {
                return DropdownMenuItem(
                  value: student,
                  child: Text('${student.firstName} ${student.lastName}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStudent = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanMethodSelector() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.document_scanner, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Método de Escaneo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: _scanMethod == 'full_exam'
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _scanMethod == 'full_exam'
                      ? AppColors.primary
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: RadioListTile<String>(
                title: Row(
                  children: [
                    Icon(
                      Icons.description,
                      color: _scanMethod == 'full_exam'
                          ? AppColors.primary
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Examen Completo',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(left: 40.0, top: 4),
                  child: Text(
                    'La IA leerá todas las páginas del examen',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                value: 'full_exam',
                groupValue: _scanMethod,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _scanMethod = value;
                      _capturedImages.clear();
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: _scanMethod == 'answer_sheet'
                    ? AppColors.success.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _scanMethod == 'answer_sheet'
                      ? AppColors.success
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: RadioListTile<String>(
                title: Row(
                  children: [
                    Icon(
                      Icons.fact_check,
                      color: _scanMethod == 'answer_sheet'
                          ? AppColors.success
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Hoja de Respuestas',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(left: 40.0, top: 4),
                  child: Text(
                    'Solo escanear la página final con las respuestas',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                value: 'answer_sheet',
                groupValue: _scanMethod,
                activeColor: AppColors.success,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _scanMethod = value;
                      _capturedImages.clear();
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _scanMethod == 'full_exam'
                          ? 'Escanea todas las páginas del examen con las preguntas y respuestas'
                          : 'Solo escanea la última página donde están marcadas todas las respuestas',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_camera, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Capturar Imágenes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _scanMethod == 'full_exam'
                  ? 'Captura todas las páginas del examen'
                  : 'Captura solo la hoja de respuestas',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing
                        ? null
                        : () => _captureImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Cámara'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing
                        ? null
                        : () => _captureImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galería'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            if (_capturedImages.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle,
                        color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${_capturedImages.length} ${_capturedImages.length == 1 ? "imagen capturada" : "imágenes capturadas"}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Vista Previa',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () {
                    setState(() {
                      _capturedImages.clear();
                      _statusMessage = '';
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _capturedImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _capturedImages[index],
                            width: 120,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _capturedImages.removeAt(index);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    return Card(
      elevation: 4,
      color: _isProcessing ? Colors.blue.shade50 : Colors.green.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            if (_isProcessing)
              const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(),
              ),
            if (!_isProcessing)
              Icon(Icons.check_circle, color: Colors.green.shade800, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _statusMessage,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _isProcessing
                      ? Colors.blue.shade900
                      : Colors.green.shade900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return ElevatedButton.icon(
      onPressed: _processImages,
      icon: const Icon(Icons.document_scanner),
      label: const Text('Procesar y Calificar'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _captureImage(ImageSource source) async {
    if (_isProcessing) return;

    if (_scanMethod == 'answer_sheet' && _capturedImages.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Solo puedes capturar una imagen para el método de hoja de respuestas.'),
        backgroundColor: AppColors.error,
      ));
      return;
    }

    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      setState(() {
        _capturedImages.add(imageFile);
      });
    }
  }

  Future<void> _processImages() async {
    if (_selectedExam == null || _selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona un examen y un estudiante.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Procesando imágenes...';
    });

    try {
      final examRepo = ExamRepositoryImpl(DatabaseHelper.instance);
      final questions = await examRepo.getExamQuestions(_selectedExam!.id!);

      if (questions.isEmpty) {
        throw Exception('No se encontraron preguntas para este examen');
      }

      Map<int, List<String>> studentAnswers;

      if (_scanMethod == 'answer_sheet' && _capturedImages.length == 1) {
        studentAnswers = await _geminiService.analyzeAnswerSheet(
          answerSheetImage: _capturedImages.first,
          totalQuestions: questions.length,
          questionType: questions.first.type,
        );
      } else {
        studentAnswers = await _geminiService.analyzeMultiplePages(
          imageFiles: _capturedImages,
          questions: questions,
        );
      }

      int correctCount = 0;
      double totalScore = 0.0;
      double earnedScore = 0.0;

      for (int i = 0; i < questions.length; i++) {
        final question = questions[i];
        final questionNum = i + 1;
        final studentAns = studentAnswers[questionNum] ?? [];

        totalScore += question.value;

        if (question.isCorrectAnswer(studentAns)) {
          correctCount++;
          earnedScore += question.value;
        }
      }

      final wrongCount = questions.length - correctCount;

      final newResult = Result(
        examId: _selectedExam!.id!,
        studentId: _selectedStudent!.id!,
        score: earnedScore,
        totalScore: totalScore,
        correctAnswers: correctCount,
        wrongAnswers: wrongCount,
        answers: studentAnswers,
        scanMethod: _scanMethod,
        completedAt: DateTime.now(),
      );

      final resultRepo = ResultRepositoryImpl(DatabaseHelper.instance);
      await resultRepo.createResult(newResult);

      setState(() {
        _statusMessage =
            '¡Examen calificado! Nota: ${newResult.score.toStringAsFixed(2)}/${totalScore.toStringAsFixed(2)}';
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_statusMessage),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al procesar el examen: ${e.toString()}';
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_statusMessage),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
        _capturedImages.clear();
      });
    }
  }
}
