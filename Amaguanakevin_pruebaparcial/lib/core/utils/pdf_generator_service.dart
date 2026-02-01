import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/exam.dart';
import '../../domain/entities/question.dart';
import '../../core/constants/app_constants.dart';

/// PDFGeneratorService
/// Servicio para generar PDFs de exámenes para impresión y lectura OCR
class PDFGeneratorService {
  /// Genera PDF de examen completo con enunciados
  Future<File> generateExamPDF({
    required Exam exam,
    required List<Question> questions,
    required String subjectName,
    required String teacherName,
  }) async {
    final pdf = pw.Document();

    // Fuente para soporte de caracteres especiales
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: pw.EdgeInsets.all(AppConstants.pdfMargin),
        build: (context) => [
          // Encabezado
          _buildHeader(
            institution: exam.institution ?? AppConstants.pdfDefaultInstitution,
            subject: subjectName,
            teacher: teacherName,
            examDate: exam.examDate,
            examTitle: exam.title,
            qrCode: exam.qrCode,
            font: font,
            fontBold: fontBold,
          ),

          pw.SizedBox(height: 20),

          // Instrucciones
          _buildInstructions(font: font),

          pw.SizedBox(height: 20),

          // Preguntas
          ...questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            return _buildQuestion(
              questionNumber: index + 1,
              question: question,
              font: font,
              fontBold: fontBold,
            );
          }),
        ],
      ),
    );

    // Guardar archivo
    return await _savePDF(pdf, 'examen_${exam.qrCode}');
  }

  /// Genera PDF solo con hoja de respuestas (optimizado para OCR)
  Future<File> generateAnswerSheetPDF({
    required Exam exam,
    required int numberOfQuestions,
    required int optionsPerQuestion,
  }) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: pw.EdgeInsets.all(AppConstants.pdfMargin),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Encabezado simplificado
              _buildSimpleHeader(
                examTitle: exam.title,
                qrCode: exam.qrCode,
                font: font,
                fontBold: fontBold,
              ),

              pw.SizedBox(height: 30),

              // Campo para datos del estudiante
              pw.Text('DATOS DEL ESTUDIANTE:',
                  style: pw.TextStyle(font: fontBold, fontSize: 12)),
              pw.SizedBox(height: 10),
              pw.Text(
                  'Nombre: _________________________________________________',
                  style: pw.TextStyle(font: font)),
              pw.SizedBox(height: 8),
              pw.Text('Identificación: _________________',
                  style: pw.TextStyle(font: font)),

              pw.SizedBox(height: 30),

              // Hoja de respuestas
              pw.Text('HOJA DE RESPUESTAS:',
                  style: pw.TextStyle(font: fontBold, fontSize: 12)),
              pw.SizedBox(height: 15),

              // Grilla de respuestas OCR-friendly
              ...List.generate(numberOfQuestions, (index) {
                return _buildAnswerRow(
                  questionNumber: index + 1,
                  numberOfOptions: optionsPerQuestion,
                  font: font,
                );
              }),
            ],
          );
        },
      ),
    );

    return await _savePDF(pdf, 'respuestas_${exam.qrCode}');
  }

  /// Construye encabezado completo
  pw.Widget _buildHeader({
    required String institution,
    required String subject,
    required String teacher,
    required DateTime examDate,
    required String examTitle,
    required String qrCode,
    required pw.Font font,
    required pw.Font fontBold,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          institution.toUpperCase(),
          style: pw.TextStyle(font: fontBold, fontSize: 16),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          examTitle,
          style: pw.TextStyle(font: fontBold, fontSize: 14),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Materia: $subject',
                    style: pw.TextStyle(font: font, fontSize: 10)),
                pw.Text('Docente: $teacher',
                    style: pw.TextStyle(font: font, fontSize: 10)),
                pw.Text('Fecha: ${DateFormat('dd/MM/yyyy').format(examDate)}',
                    style: pw.TextStyle(font: font, fontSize: 10)),
              ],
            ),
            // QR Code placeholder (simplificado - en producción usar paquete real)
            pw.Container(
              width: 60,
              height: 60,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 1),
              ),
              child: pw.Center(
                child: pw.Text(qrCode,
                    style: pw.TextStyle(font: font, fontSize: 6)),
              ),
            ),
          ],
        ),
        pw.Divider(thickness: 2),
      ],
    );
  }

  /// Construye encabezado simple para hoja de respuestas
  pw.Widget _buildSimpleHeader({
    required String examTitle,
    required String qrCode,
    required pw.Font font,
    required pw.Font fontBold,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          child: pw.Text(
            examTitle,
            style: pw.TextStyle(font: fontBold, fontSize: 14),
          ),
        ),
        pw.Container(
          width: 50,
          height: 50,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 1),
          ),
          child: pw.Center(
            child:
                pw.Text(qrCode, style: pw.TextStyle(font: font, fontSize: 5)),
          ),
        ),
      ],
    );
  }

  /// Construye instrucciones del examen
  pw.Widget _buildInstructions({required pw.Font font}) {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1),
        color: PdfColors.grey200,
      ),
      child: pw.Text(
        'INSTRUCCIONES:\n'
        '• Lea cuidadosamente cada pregunta antes de responder.\n'
        '• Marque su respuesta con una X clara en el paréntesis correspondiente.\n'
        '• Solo una respuesta es correcta a menos que se indique lo contrario.\n'
        '• No se permiten borrones ni tachaduras.',
        style: pw.TextStyle(font: font, fontSize: 9),
      ),
    );
  }

  /// Construye una pregunta con sus opciones
  pw.Widget _buildQuestion({
    required int questionNumber,
    required Question question,
    required pw.Font font,
    required pw.Font fontBold,
  }) {
    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: 15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Enunciado
          pw.Text(
            '$questionNumber. ${question.statement}',
            style: pw.TextStyle(font: fontBold, fontSize: 11),
          ),
          pw.SizedBox(height: 8),

          // Opciones
          ...question.options.asMap().entries.map((entry) {
            final optionLetter =
                String.fromCharCode(65 + entry.key); // A, B, C...
            final optionText = entry.value;
            return pw.Padding(
              padding: pw.EdgeInsets.only(left: 20, bottom: 5),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 15,
                    height: 15,
                    margin: pw.EdgeInsets.only(right: 8, top: 2),
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      border: pw.Border.all(width: 1),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      '$optionLetter) $optionText',
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Construye una fila de respuestas (formato OCR-friendly)
  pw.Widget _buildAnswerRow({
    required int questionNumber,
    required int numberOfOptions,
    required pw.Font font,
  }) {
    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        children: [
          // Número de pregunta
          pw.Container(
            width: 30,
            child: pw.Text(
              '$questionNumber.',
              style: pw.TextStyle(font: font, fontSize: 11),
            ),
          ),

          // Opciones (A, B, C, D, E...)
          ...List.generate(numberOfOptions, (index) {
            final optionLetter = String.fromCharCode(65 + index);
            return pw.Container(
              margin: pw.EdgeInsets.only(right: 15),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 18,
                    height: 18,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      border: pw.Border.all(width: 1.5),
                    ),
                  ),
                  pw.SizedBox(width: 5),
                  pw.Text(
                    optionLetter,
                    style: pw.TextStyle(font: font, fontSize: 11),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Guarda el PDF en el dispositivo
  Future<File> _savePDF(pw.Document pdf, String baseName) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = '${baseName}_$timestamp.pdf';
    final file = File('${directory.path}/$fileName');

    final bytes = await pdf.save();
    await file.writeAsBytes(bytes);

    return file;
  }

  /// Imprime directamente el PDF
  Future<void> printPDF(pw.Document pdf) async {
    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
    );
  }

  /// Comparte el PDF
  Future<void> sharePDF(File pdfFile) async {
    await Printing.sharePdf(
      bytes: await pdfFile.readAsBytes(),
      filename: pdfFile.path.split('/').last,
    );
  }
}
