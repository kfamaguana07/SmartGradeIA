import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/student_model.dart';
import '../models/teacher_model.dart';
import '../models/subject_model.dart';
import '../models/question_model.dart';
import '../models/exam_model.dart';
import '../models/result_model.dart';

/// DatabaseHelper - Gestión de base de datos SQLite
/// Implementa patrón Singleton para mantener una única instancia
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smartgrade.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Eliminar todas las tablas antiguas
      await db.execute('DROP TABLE IF EXISTS results');
      await db.execute('DROP TABLE IF EXISTS exam_questions');
      await db.execute('DROP TABLE IF EXISTS exams');
      await db.execute('DROP TABLE IF EXISTS questions');
      await db.execute('DROP TABLE IF EXISTS subjects');
      await db.execute('DROP TABLE IF EXISTS teachers');
      await db.execute('DROP TABLE IF EXISTS students');

      // Recrear todas las tablas con nombres de columnas correctos
      await _createDB(db, newVersion);
    }

    if (oldVersion < 4) {
      // Agregar nuevas columnas a la tabla results
      await db.execute('ALTER TABLE results ADD COLUMN image_pages TEXT');
      await db.execute(
          'ALTER TABLE results ADD COLUMN scan_method TEXT DEFAULT "full_exam"');
      await db.execute('ALTER TABLE results ADD COLUMN ai_analysis_notes TEXT');
    }

    if (oldVersion < 5) {
      // Recrear tabla teachers y subjects por cambios estructurales
      await db.execute('DROP TABLE IF EXISTS results');
      await db.execute('DROP TABLE IF EXISTS exam_questions');
      await db.execute('DROP TABLE IF EXISTS exams');
      await db.execute('DROP TABLE IF EXISTS questions');
      await db.execute('DROP TABLE IF EXISTS subjects');
      await db.execute('DROP TABLE IF EXISTS teachers');

      // Recrear tablas con nueva estructura
      await db.execute('''
        CREATE TABLE teachers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          first_name TEXT NOT NULL,
          last_name TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE subjects (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          nrc TEXT NOT NULL UNIQUE,
          teacher_id INTEGER,
          created_at TEXT NOT NULL,
          FOREIGN KEY (teacher_id) REFERENCES teachers (id) ON DELETE SET NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE questions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          statement TEXT NOT NULL,
          type TEXT NOT NULL,
          options TEXT NOT NULL,
          correct_answers TEXT NOT NULL,
          value REAL NOT NULL DEFAULT 1.0,
          subject_id INTEGER,
          created_at TEXT NOT NULL,
          FOREIGN KEY (subject_id) REFERENCES subjects (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE exams (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          subject_id INTEGER NOT NULL,
          teacher_id INTEGER NOT NULL,
          exam_date TEXT NOT NULL,
          institution TEXT,
          qr_code TEXT NOT NULL UNIQUE,
          created_at TEXT NOT NULL,
          FOREIGN KEY (subject_id) REFERENCES subjects (id) ON DELETE CASCADE,
          FOREIGN KEY (teacher_id) REFERENCES teachers (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE exam_questions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          exam_id INTEGER NOT NULL,
          question_id INTEGER NOT NULL,
          order_number INTEGER NOT NULL,
          value REAL NOT NULL DEFAULT 1.0,
          FOREIGN KEY (exam_id) REFERENCES exams (id) ON DELETE CASCADE,
          FOREIGN KEY (question_id) REFERENCES questions (id) ON DELETE CASCADE,
          UNIQUE (exam_id, question_id)
        )
      ''');

      await db.execute('''
        CREATE TABLE results (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          exam_id INTEGER NOT NULL,
          student_id INTEGER NOT NULL,
          score REAL NOT NULL,
          total_score REAL NOT NULL,
          correct_answers INTEGER NOT NULL,
          wrong_answers INTEGER NOT NULL,
          answers TEXT NOT NULL,
          image_path TEXT,
          image_pages TEXT,
          scan_method TEXT DEFAULT 'full_exam',
          ai_analysis_notes TEXT,
          completed_at TEXT NOT NULL,
          FOREIGN KEY (exam_id) REFERENCES exams (id) ON DELETE CASCADE,
          FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabla de estudiantes
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        identification TEXT NOT NULL UNIQUE,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Tabla de profesores
    await db.execute('''
      CREATE TABLE teachers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Tabla de materias
    await db.execute('''
      CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        nrc TEXT NOT NULL UNIQUE,
        teacher_id INTEGER,
        created_at TEXT NOT NULL,
        FOREIGN KEY (teacher_id) REFERENCES teachers (id) ON DELETE SET NULL
      )
    ''');

    // Tabla de preguntas
    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        statement TEXT NOT NULL,
        type TEXT NOT NULL,
        options TEXT NOT NULL,
        correct_answers TEXT NOT NULL,
        value REAL NOT NULL DEFAULT 1.0,
        subject_id INTEGER,
        created_at TEXT NOT NULL,
        FOREIGN KEY (subject_id) REFERENCES subjects (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de exámenes
    await db.execute('''
      CREATE TABLE exams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        subject_id INTEGER NOT NULL,
        teacher_id INTEGER NOT NULL,
        exam_date TEXT NOT NULL,
        institution TEXT,
        qr_code TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        FOREIGN KEY (subject_id) REFERENCES subjects (id) ON DELETE CASCADE,
        FOREIGN KEY (teacher_id) REFERENCES teachers (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de relación examen-pregunta
    await db.execute('''
      CREATE TABLE exam_questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exam_id INTEGER NOT NULL,
        question_id INTEGER NOT NULL,
        order_number INTEGER NOT NULL,
        value REAL NOT NULL DEFAULT 1.0,
        FOREIGN KEY (exam_id) REFERENCES exams (id) ON DELETE CASCADE,
        FOREIGN KEY (question_id) REFERENCES questions (id) ON DELETE CASCADE,
        UNIQUE (exam_id, question_id)
      )
    ''');

    // Tabla de resultados
    await db.execute('''
      CREATE TABLE results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exam_id INTEGER NOT NULL,
        student_id INTEGER NOT NULL,
        score REAL NOT NULL,
        total_score REAL NOT NULL,
        correct_answers INTEGER NOT NULL,
        wrong_answers INTEGER NOT NULL,
        answers TEXT NOT NULL,
        image_path TEXT,
        image_pages TEXT,
        scan_method TEXT DEFAULT 'full_exam',
        ai_analysis_notes TEXT,
        completed_at TEXT NOT NULL,
        FOREIGN KEY (exam_id) REFERENCES exams (id) ON DELETE CASCADE,
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
        UNIQUE (exam_id, student_id)
      )
    ''');

    // Crear índices para mejorar rendimiento
    await db
        .execute('CREATE INDEX idx_subjects_teacher ON subjects(teacher_id)');
    await db
        .execute('CREATE INDEX idx_questions_subject ON questions(subject_id)');
    await db.execute('CREATE INDEX idx_exams_subject ON exams(subject_id)');
    await db.execute('CREATE INDEX idx_exams_teacher ON exams(teacher_id)');
    await db.execute('CREATE INDEX idx_results_exam ON results(exam_id)');
    await db.execute('CREATE INDEX idx_results_student ON results(student_id)');
  }

  // ==================== CRUD STUDENTS ====================

  Future<int> createStudent(StudentModel student) async {
    final db = await database;
    return await db.insert('students', student.toJson());
  }

  Future<StudentModel?> getStudent(int id) async {
    final db = await database;
    final maps = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return StudentModel.fromJson(maps.first);
  }

  Future<List<StudentModel>> getAllStudents() async {
    final db = await database;
    final maps = await db.query('students', orderBy: 'first_name ASC');
    return maps.map((map) => StudentModel.fromJson(map)).toList();
  }

  Future<int> updateStudent(StudentModel student) async {
    final db = await database;
    return await db.update(
      'students',
      student.toJson(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(int id) async {
    final db = await database;
    return await db.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== CRUD TEACHERS ====================

  Future<int> createTeacher(TeacherModel teacher) async {
    final db = await database;
    return await db.insert('teachers', teacher.toJson());
  }

  Future<TeacherModel?> getTeacher(int id) async {
    final db = await database;
    final maps = await db.query(
      'teachers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return TeacherModel.fromJson(maps.first);
  }

  Future<List<TeacherModel>> getAllTeachers() async {
    final db = await database;
    final maps = await db.query('teachers', orderBy: 'first_name ASC');
    return maps.map((map) => TeacherModel.fromJson(map)).toList();
  }

  Future<int> updateTeacher(TeacherModel teacher) async {
    final db = await database;
    return await db.update(
      'teachers',
      teacher.toJson(),
      where: 'id = ?',
      whereArgs: [teacher.id],
    );
  }

  Future<int> deleteTeacher(int id) async {
    final db = await database;
    return await db.delete(
      'teachers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== CRUD SUBJECTS ====================

  Future<int> createSubject(SubjectModel subject) async {
    final db = await database;
    return await db.insert('subjects', subject.toJson());
  }

  Future<SubjectModel?> getSubject(int id) async {
    final db = await database;
    final maps = await db.query(
      'subjects',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return SubjectModel.fromJson(maps.first);
  }

  Future<List<SubjectModel>> getAllSubjects() async {
    final db = await database;
    final maps = await db.query('subjects', orderBy: 'name ASC');
    return maps.map((map) => SubjectModel.fromJson(map)).toList();
  }

  Future<List<SubjectModel>> getSubjectsByTeacher(int teacherId) async {
    final db = await database;
    final maps = await db.query(
      'subjects',
      where: 'teacher_id = ?',
      whereArgs: [teacherId],
      orderBy: 'name ASC',
    );
    return maps.map((map) => SubjectModel.fromJson(map)).toList();
  }

  Future<int> updateSubject(SubjectModel subject) async {
    final db = await database;
    return await db.update(
      'subjects',
      subject.toJson(),
      where: 'id = ?',
      whereArgs: [subject.id],
    );
  }

  Future<int> deleteSubject(int id) async {
    final db = await database;
    return await db.delete(
      'subjects',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== CRUD QUESTIONS ====================

  Future<int> createQuestion(QuestionModel question) async {
    final db = await database;
    return await db.insert('questions', question.toJson());
  }

  Future<QuestionModel?> getQuestion(int id) async {
    final db = await database;
    final maps = await db.query(
      'questions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return QuestionModel.fromJson(maps.first);
  }

  Future<List<QuestionModel>> getAllQuestions() async {
    final db = await database;
    final maps = await db.query('questions', orderBy: 'created_at DESC');
    return maps.map((map) => QuestionModel.fromJson(map)).toList();
  }

  Future<List<QuestionModel>> getQuestionsBySubject(int subjectId) async {
    final db = await database;
    final maps = await db.query(
      'questions',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => QuestionModel.fromJson(map)).toList();
  }

  Future<int> updateQuestion(QuestionModel question) async {
    final db = await database;
    return await db.update(
      'questions',
      question.toJson(),
      where: 'id = ?',
      whereArgs: [question.id],
    );
  }

  Future<int> deleteQuestion(int id) async {
    final db = await database;
    return await db.delete(
      'questions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== CRUD EXAMS ====================

  Future<int> createExam(ExamModel exam) async {
    final db = await database;
    return await db.insert('exams', exam.toJson());
  }

  Future<ExamModel?> getExam(int id) async {
    final db = await database;
    final maps = await db.query(
      'exams',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return ExamModel.fromJson(maps.first);
  }

  Future<List<ExamModel>> getAllExams() async {
    final db = await database;
    final maps = await db.query('exams', orderBy: 'exam_date DESC');
    return maps.map((map) => ExamModel.fromJson(map)).toList();
  }

  Future<List<ExamModel>> getExamsBySubject(int subjectId) async {
    final db = await database;
    final maps = await db.query(
      'exams',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
      orderBy: 'exam_date DESC',
    );
    return maps.map((map) => ExamModel.fromJson(map)).toList();
  }

  Future<int> updateExam(ExamModel exam) async {
    final db = await database;
    return await db.update(
      'exams',
      exam.toJson(),
      where: 'id = ?',
      whereArgs: [exam.id],
    );
  }

  Future<int> deleteExam(int id) async {
    final db = await database;

    await db.delete(
      'exam_questions',
      where: 'exam_id = ?',
      whereArgs: [id],
    );

    await db.delete(
      'results',
      where: 'exam_id = ?',
      whereArgs: [id],
    );

    return await db.delete(
      'exams',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== EXAM QUESTIONS ====================

  Future<void> addQuestionsToExam(int examId, List<int> questionIds) async {
    final db = await database;
    final batch = db.batch();

    for (int i = 0; i < questionIds.length; i++) {
      batch.insert('exam_questions', {
        'exam_id': examId,
        'question_id': questionIds[i],
        'order_number': i + 1,
      });
    }

    await batch.commit(noResult: true);
  }

  Future<List<QuestionModel>> getExamQuestions(int examId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT q.* FROM questions q
      INNER JOIN exam_questions eq ON q.id = eq.question_id
      WHERE eq.exam_id = ?
      ORDER BY eq.order_number ASC
    ''', [examId]);

    return maps.map((map) => QuestionModel.fromJson(map)).toList();
  }

  Future<void> removeQuestionFromExam(int examId, int questionId) async {
    final db = await database;
    await db.delete(
      'exam_questions',
      where: 'exam_id = ? AND question_id = ?',
      whereArgs: [examId, questionId],
    );
  }

  Future<void> removeAllQuestionsFromExam(int examId) async {
    final db = await database;
    await db.delete(
      'exam_questions',
      where: 'exam_id = ?',
      whereArgs: [examId],
    );
  }

  // ==================== CRUD RESULTS ====================

  Future<int> createResult(ResultModel result) async {
    final db = await database;
    return await db.insert('results', result.toJson());
  }

  Future<ResultModel?> getResult(int id) async {
    final db = await database;
    final maps = await db.query(
      'results',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return ResultModel.fromJson(maps.first);
  }

  Future<List<ResultModel>> getAllResults() async {
    final db = await database;
    final maps = await db.query('results', orderBy: 'completed_at DESC');
    return maps.map((map) => ResultModel.fromJson(map)).toList();
  }

  Future<List<ResultModel>> getResultsByExam(int examId) async {
    final db = await database;
    final maps = await db.query(
      'results',
      where: 'exam_id = ?',
      whereArgs: [examId],
      orderBy: 'completed_at DESC',
    );
    return maps.map((map) => ResultModel.fromJson(map)).toList();
  }

  Future<List<ResultModel>> getResultsByStudent(int studentId) async {
    final db = await database;
    final maps = await db.query(
      'results',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'completed_at DESC',
    );
    return maps.map((map) => ResultModel.fromJson(map)).toList();
  }

  Future<int> updateResult(ResultModel result) async {
    final db = await database;
    return await db.update(
      'results',
      result.toJson(),
      where: 'id = ?',
      whereArgs: [result.id],
    );
  }

  Future<int> deleteResult(int id) async {
    final db = await database;
    return await db.delete(
      'results',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== UTILIDADES ====================

  Future<void> close() async {
    final db = await database;
    db.close();
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smartgrade.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
