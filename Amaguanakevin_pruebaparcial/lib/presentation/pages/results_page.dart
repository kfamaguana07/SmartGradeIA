import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/result.dart';
import '../../domain/entities/exam.dart';
import '../../domain/entities/student.dart';
import '../providers/result_provider.dart';
import '../providers/exam_provider.dart';
import '../providers/student_provider.dart';
import '../../core/utils/excel_export_service.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  Exam? _selectedExam;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResultProvider>().loadResults();
      context.read<ExamProvider>().loadExams();
      context.read<StudentProvider>().loadStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados'),
        backgroundColor: AppColors.questionMultiple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _selectedExam != null ? _exportToPDF : null,
            tooltip: 'Exportar a PDF',
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _selectedExam != null ? _exportToExcel : null,
            tooltip: 'Exportar a Excel',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer<ExamProvider>(
              builder: (context, provider, _) {
                if (provider.exams.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No hay exámenes registrados'),
                    ),
                  );
                }
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonFormField<Exam>(
                      decoration: const InputDecoration(
                        labelText: 'Filtrar por Examen',
                        border: InputBorder.none,
                      ),
                      initialValue: _selectedExam,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Todos los exámenes'),
                        ),
                        ...provider.exams.map((exam) {
                          return DropdownMenuItem(
                            value: exam,
                            child: Text(exam.title),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedExam = value);
                        if (value != null) {
                          context
                              .read<ResultProvider>()
                              .loadResultsByExam(value.id!);
                        } else {
                          context.read<ResultProvider>().loadResults();
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<ResultProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(provider.error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.loadResults(),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.results.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.analytics_outlined,
                            size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No hay resultados registrados',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Los resultados aparecerán después de escanear exámenes',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.results.length,
                  itemBuilder: (context, index) {
                    final result = provider.results[index];
                    return _buildResultCard(result);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(Result result) {
    final studentProvider = context.watch<StudentProvider>();
    final examProvider = context.watch<ExamProvider>();

    final student = studentProvider.students.firstWhere(
      (s) => s.id == result.studentId,
      orElse: () => Student(
        identification: 'N/A',
        firstName: 'Estudiante',
        lastName: 'Desconocido',
      ),
    );

    final exam = examProvider.exams.firstWhere(
      (e) => e.id == result.examId,
      orElse: () => Exam(
        title: 'Examen Desconocido',
        subjectId: 0,
        teacherId: 0,
        examDate: DateTime.now(),
        qrCode: '',
      ),
    );

    final percentage = (result.score / result.totalScore) * 100;
    final passed = percentage >= 70;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: passed ? AppColors.success : AppColors.error,
          child: Icon(
            passed ? Icons.check : Icons.close,
            color: Colors.white,
          ),
        ),
        title: Text(student.fullName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Examen: ${exam.title}'),
            Text(
                'Calificación: ${result.score.toStringAsFixed(2)}/${result.totalScore}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteResult(result),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Porcentaje',
                      '${percentage.toStringAsFixed(1)}%',
                      passed ? AppColors.success : AppColors.error,
                    ),
                    _buildStatItem(
                      'Correctas',
                      '${result.correctAnswers}',
                      AppColors.success,
                    ),
                    _buildStatItem(
                      'Incorrectas',
                      '${result.wrongAnswers}',
                      AppColors.error,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Fecha: ${result.completedAt.toString().split('.')[0]}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Future<void> _exportToExcel() async {
    if (_selectedExam == null) return;

    try {
      final resultProvider = context.read<ResultProvider>();
      final studentProvider = context.read<StudentProvider>();

      final excelService = ExcelExportService();
      await excelService.exportResultsToExcel(
        results: resultProvider.results,
        examTitle: _selectedExam!.title,
        students: studentProvider.students,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Excel guardado correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().contains('No se seleccionó')
            ? 'Exportación cancelada'
            : 'Error al exportar: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: e.toString().contains('No se seleccionó')
                ? Colors.orange
                : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportToPDF() async {
    if (_selectedExam == null) return;

    try {
      final resultProvider = context.read<ResultProvider>();
      final studentProvider = context.read<StudentProvider>();

      final pdf = await _generateResultsPDF(
        results: resultProvider.results,
        exam: _selectedExam!,
        students: studentProvider.students,
      );

      await Printing.layoutPdf(
        onLayout: (format) => pdf.save(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF generado exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar PDF: $e')),
        );
      }
    }
  }

  Future<pw.Document> _generateResultsPDF({
    required List<Result> results,
    required Exam exam,
    required List<Student> students,
  }) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'REPORTE DE RESULTADOS',
                  style: pw.TextStyle(font: fontBold, fontSize: 20),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Examen: ${exam.title}',
                  style: pw.TextStyle(font: font, fontSize: 14),
                ),
                pw.Text(
                  'Fecha: ${exam.examDate.toString().split(' ')[0]}',
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
                pw.Divider(),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Estudiante',
                        style: pw.TextStyle(font: fontBold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Nota', style: pw.TextStyle(font: fontBold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('%', style: pw.TextStyle(font: fontBold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Correctas',
                        style: pw.TextStyle(font: fontBold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Incorrectas',
                        style: pw.TextStyle(font: fontBold)),
                  ),
                ],
              ),
              ...results.map((result) {
                final student = students.firstWhere(
                  (s) => s.id == result.studentId,
                  orElse: () => Student(
                    identification: 'N/A',
                    firstName: 'Desconocido',
                    lastName: '',
                  ),
                );
                final percentage = (result.score / result.totalScore) * 100;

                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(student.fullName,
                          style: pw.TextStyle(font: font)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        '${result.score.toStringAsFixed(2)}/${result.totalScore}',
                        style: pw.TextStyle(font: font),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: pw.TextStyle(font: font),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${result.correctAnswers}',
                          style: pw.TextStyle(font: font)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${result.wrongAnswers}',
                          style: pw.TextStyle(font: font)),
                    ),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('ESTADÍSTICAS',
              style: pw.TextStyle(font: fontBold, fontSize: 14)),
          pw.SizedBox(height: 10),
          pw.Text(
            'Total de estudiantes: ${results.length}',
            style: pw.TextStyle(font: font),
          ),
          pw.Text(
            'Promedio: ${_calculateAverage(results).toStringAsFixed(2)}',
            style: pw.TextStyle(font: font),
          ),
          pw.Text(
            'Aprobados: ${_countPassed(results)}',
            style: pw.TextStyle(font: font),
          ),
          pw.Text(
            'Reprobados: ${results.length - _countPassed(results)}',
            style: pw.TextStyle(font: font),
          ),
        ],
      ),
    );

    return pdf;
  }

  double _calculateAverage(List<Result> results) {
    if (results.isEmpty) return 0;
    final sum = results.fold(0.0, (sum, r) => sum + r.score);
    return sum / results.length;
  }

  int _countPassed(List<Result> results) {
    return results.where((r) => (r.score / r.totalScore) * 100 >= 70).length;
  }

  Future<void> _deleteResult(Result result) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar este resultado?'),
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
        final success =
            await context.read<ResultProvider>().deleteResult(result.id!);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Resultado eliminado exitosamente'),
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
