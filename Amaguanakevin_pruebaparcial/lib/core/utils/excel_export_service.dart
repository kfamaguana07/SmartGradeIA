import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import '../../domain/entities/result.dart';
import '../../domain/entities/exam.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/teacher.dart';
import '../../domain/entities/student.dart';

/// ExcelExportService
/// Servicio para exportar resultados a archivos Excel
class ExcelExportService {
  /// Exporta resultados de un examen específico a Excel
  Future<File> exportExamResults({
    required Exam exam,
    required Subject subject,
    required Teacher teacher,
    required List<Result> results,
    required List<Student> students,
  }) async {
    try {
      // Crear Excel
      final excel = Excel.createExcel();
      final sheet = excel['Resultados'];

      // Título del examen en la primera fila
      final titleCell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
      titleCell.value = TextCellValue('RESULTADOS: ${exam.title}');
      titleCell.cellStyle = CellStyle(
        bold: true,
        fontSize: 14,
      );

      // Información del examen
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
          .value = TextCellValue('Materia: ${subject.name}');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
          .value = TextCellValue('Docente: ${teacher.fullName}');
      sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3))
              .value =
          TextCellValue(
              'Fecha: ${DateFormat('dd/MM/yyyy').format(exam.createdAt)}');

      // Encabezados en la fila 5
      final headers = [
        'Identificación',
        'Nombre Completo',
        'Nota',
        'Aciertos',
        'Errores',
        'Porcentaje',
      ];

      for (int i = 0; i < headers.length; i++) {
        final cell =
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 5));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.blue,
          fontColorHex: ExcelColor.white,
        );
      }

      // Crear mapa de estudiantes por ID para búsqueda rápida
      final studentMap = {for (var s in students) s.id!: s};

      // Datos desde la fila 6
      for (int rowIndex = 0; rowIndex < results.length; rowIndex++) {
        final result = results[rowIndex];
        final student = studentMap[result.studentId];
        final dataRow = rowIndex + 6;

        // Identificación
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: dataRow))
            .value = TextCellValue(student?.identification ?? 'N/A');

        // Nombre completo
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: dataRow))
            .value = TextCellValue(student?.fullName ?? 'N/A');

        // Nota
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: dataRow))
            .value = DoubleCellValue(result.score);

        // Aciertos
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: dataRow))
            .value = IntCellValue(result.correctAnswers);

        // Errores
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: dataRow))
            .value = IntCellValue(result.wrongAnswers);

        // Porcentaje
        final percentage = (result.score / result.totalScore) * 100;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: dataRow))
            .value = TextCellValue('${percentage.toStringAsFixed(1)}%');
      }

      // Ajustar ancho de columnas
      for (int i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 20.0);
      }

      // Guardar archivo
      final bytes = excel.encode();
      if (bytes == null) {
        throw Exception('Error al generar archivo Excel');
      }

      // Generar nombre de archivo con timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final safeName = exam.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final fileName = 'resultados_${safeName}_$timestamp.xlsx';

      // Permitir al usuario elegir dónde guardar el archivo
      final savedPath = await FileSaver.instance.saveAs(
        name: fileName,
        bytes: Uint8List.fromList(bytes),
        ext: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );

      if (savedPath == null) {
        throw Exception('No se seleccionó una ubicación para guardar');
      }

      return File(savedPath);
    } catch (e) {
      throw Exception('Error al exportar resultados de examen: $e');
    }
  }

  /// Método simplificado para exportar solo resultados
  Future<File> exportResultsToExcel({
    required List<Result> results,
    required String examTitle,
    required List<Student> students,
  }) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Resultados'];

      // Título
      final titleCell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
      titleCell.value = TextCellValue('RESULTADOS: $examTitle');
      titleCell.cellStyle = CellStyle(bold: true, fontSize: 14);

      // Encabezados
      final headers = [
        'Estudiante',
        'Nota',
        'Total',
        'Porcentaje',
        'Correctas',
        'Incorrectas',
      ];

      for (int i = 0; i < headers.length; i++) {
        final cell =
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 2));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.blue,
          fontColorHex: ExcelColor.white,
        );
      }

      final studentMap = {for (var s in students) s.id!: s};

      for (int rowIndex = 0; rowIndex < results.length; rowIndex++) {
        final result = results[rowIndex];
        final student = studentMap[result.studentId];
        final dataRow = rowIndex + 3;

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: dataRow))
            .value = TextCellValue(student?.fullName ?? 'N/A');
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: dataRow))
            .value = DoubleCellValue(result.score);
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: dataRow))
            .value = DoubleCellValue(result.totalScore);

        final percentage = (result.score / result.totalScore) * 100;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: dataRow))
            .value = TextCellValue('${percentage.toStringAsFixed(1)}%');
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: dataRow))
            .value = IntCellValue(result.correctAnswers);
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: dataRow))
            .value = IntCellValue(result.wrongAnswers);
      }

      for (int i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 20.0);
      }

      // Guardar archivo
      final bytes = excel.encode();
      if (bytes == null) {
        throw Exception('Error al generar archivo Excel');
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'resultados_$timestamp.xlsx';

      // Permitir al usuario elegir dónde guardar el archivo
      final savedPath = await FileSaver.instance.saveAs(
        name: fileName,
        bytes: Uint8List.fromList(bytes),
        ext: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );

      if (savedPath == null) {
        throw Exception('No se seleccionó una ubicación para guardar');
      }

      return File(savedPath);
    } catch (e) {
      throw Exception('Error al exportar a Excel: $e');
    }
  }
}
