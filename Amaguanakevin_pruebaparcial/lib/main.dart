import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartgrade_ai/data/datasources/database_helper.dart';
import 'package:smartgrade_ai/data/repositories/student_repository_impl.dart';
import 'package:smartgrade_ai/data/repositories/teacher_repository_impl.dart';
import 'package:smartgrade_ai/data/repositories/subject_repository_impl.dart';
import 'package:smartgrade_ai/data/repositories/question_repository_impl.dart';
import 'package:smartgrade_ai/data/repositories/exam_repository_impl.dart';
import 'package:smartgrade_ai/data/repositories/result_repository_impl.dart';
import 'package:smartgrade_ai/presentation/providers/student_provider.dart';
import 'package:smartgrade_ai/presentation/providers/teacher_provider.dart';
import 'package:smartgrade_ai/presentation/providers/subject_provider.dart';
import 'package:smartgrade_ai/presentation/providers/question_provider.dart';
import 'package:smartgrade_ai/presentation/providers/exam_provider.dart';
import 'package:smartgrade_ai/presentation/providers/result_provider.dart';
import 'package:smartgrade_ai/presentation/pages/home_page.dart';
import 'package:smartgrade_ai/presentation/pages/students_page.dart';
import 'package:smartgrade_ai/presentation/pages/teachers_page.dart';
import 'package:smartgrade_ai/presentation/pages/subjects_page.dart';
import 'package:smartgrade_ai/presentation/pages/questions_page.dart';
import 'package:smartgrade_ai/presentation/pages/create_exam_page.dart';
import 'package:smartgrade_ai/presentation/pages/scan_exam_page.dart';
import 'package:smartgrade_ai/presentation/pages/results_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartGradeApp());
}

class SmartGradeApp extends StatelessWidget {
  const SmartGradeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dbHelper = DatabaseHelper.instance;

    final studentRepo = StudentRepositoryImpl(dbHelper);
    final teacherRepo = TeacherRepositoryImpl(dbHelper);
    final subjectRepo = SubjectRepositoryImpl(dbHelper);
    final questionRepo = QuestionRepositoryImpl(dbHelper);
    final examRepo = ExamRepositoryImpl(dbHelper);
    final resultRepo = ResultRepositoryImpl(dbHelper);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudentProvider(studentRepo)),
        ChangeNotifierProvider(create: (_) => TeacherProvider(teacherRepo)),
        ChangeNotifierProvider(create: (_) => SubjectProvider(subjectRepo)),
        ChangeNotifierProvider(create: (_) => QuestionProvider(questionRepo)),
        ChangeNotifierProvider(create: (_) => ExamProvider(examRepo)),
        ChangeNotifierProvider(create: (_) => ResultProvider(resultRepo)),
      ],
      child: MaterialApp(
        title: 'SmartGrade AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/students': (context) => const StudentsPage(),
          '/teachers': (context) => const TeachersPage(),
          '/subjects': (context) => const SubjectsPage(),
          '/questions': (context) => const QuestionsPage(),
          '/create-exam': (context) => const CreateExamPage(),
          '/scan-exam': (context) => const ScanExamPage(),
          '/results': (context) => const ResultsPage(),
        },
      ),
    );
  }
}
