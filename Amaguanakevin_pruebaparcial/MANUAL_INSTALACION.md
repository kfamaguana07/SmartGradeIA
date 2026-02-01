# 📱 Manual de Instalación - SmartGrade AI

> **Sistema de Calificación Automática con Inteligencia Artificial**

---

## 🎯 Objetivo

Facilitar la instalación del sistema SmartGrade AI mediante pasos claros y sencillos, permitiendo su rápida puesta en marcha para automatizar la calificación de exámenes.

---

## 📖 Introducción

SmartGrade AI es una aplicación móvil que utiliza **Inteligencia Artificial** para calificar exámenes automáticamente. El sistema escanea las hojas de respuesta y genera resultados en segundos, exportándolos a PDF y Excel.

### ¿Qué hace?
- 📸 Escanea exámenes con la cámara del móvil
- 🤖 Califica automáticamente usando IA
- 📊 Genera reportes en PDF y Excel
- 💾 Administra estudiantes, materias y resultados

---

## ⚙️ Requerimientos Técnicos

### Computadora

| Requisito | Especificación |
|-----------|---------------|
| **Sistema Operativo** | Windows 10/11, macOS, o Linux |
| **Procesador** | Intel Core i3 o superior |
| **RAM** | 8 GB mínimo (16 GB recomendado) |
| **Espacio en disco** | 10 GB libres |
| **Internet** | Conexión estable |

### Software Necesario

| Herramienta | Versión | Enlace de Descarga |
|-------------|---------|-------------------|
| **Flutter SDK** | 3.24+ | https://flutter.dev |
| **Android Studio** | 2023.1+ | https://developer.android.com/studio |
| **Java JDK** | 11 o 17 | https://adoptium.net |
| **Git** | 2.30+ | https://git-scm.com |

### Dispositivo Móvil (opcional)
- Android 5.0 o superior
- Cámara funcional

---

## 🚀 Instalación Paso a Paso

### Paso 1: Instalar Flutter

1. Descarga Flutter desde https://flutter.dev
2. Extrae el archivo en `C:\src\flutter`
3. Agrega `C:\src\flutter\bin` al PATH del sistema

**[IMAGEN: Captura de la carpeta de Flutter instalada]**

4. Abre PowerShell y verifica:
```bash
flutter --version
```

**[IMAGEN: Resultado de flutter --version]**

---

### Paso 2: Instalar Android Studio

1. Descarga desde https://developer.android.com/studio
2. Ejecuta el instalador
3. Durante la instalación, marca:
   - ✅ Android SDK
   - ✅ Android SDK Platform
   - ✅ Android Virtual Device

**[IMAGEN: Pantalla de instalación de Android Studio]**

4. Acepta las licencias del SDK:
```bash
flutter doctor --android-licenses
```

**[IMAGEN: Aceptación de licencias]**

---

### Paso 3: Instalar Java JDK

1. Descarga Java 17 desde https://adoptium.net
2. Ejecuta el instalador
3. Verifica la instalación:
```bash
java -version
```

**[IMAGEN: Resultado de java -version]**

---

### Paso 4: Clonar el Proyecto

1. Abre PowerShell en la carpeta donde quieras el proyecto
2. Ejecuta:
```bash
git clone https://github.com/tuusuario/smartgrade_ai.git
cd smartgrade_ai
```

**[IMAGEN: Clonación del repositorio]**

---

### Paso 5: Instalar Dependencias

Ejecuta en la carpeta del proyecto:
```bash
flutter pub get
```

**[IMAGEN: Resultado de flutter pub get exitoso]**

---

### Paso 6: Configurar API de Google Gemini

#### 6.1 Obtener la API Key

1. Ve a https://makersuite.google.com/app/apikey
2. Inicia sesión con tu cuenta de Google
3. Haz clic en **"Create API Key"**
4. Copia la clave generada

**[IMAGEN: Pantalla de Google AI Studio con API Key]**

#### 6.2 Configurar en el Proyecto

1. Abre el archivo `lib/core/constants/api_keys.dart`
2. Reemplaza `TU_API_KEY_AQUI` con tu clave:

```dart
static const String geminiApiKey = 'AIzaSyB...tu-clave-aquí...';
```

**[IMAGEN: Archivo api_keys.dart configurado]**

> ⚠️ **IMPORTANTE**: Nunca compartas tu API Key públicamente

---

### Paso 7: Ejecutar la Aplicación

#### 7.1 Conectar Dispositivo o Emulador

**Opción A - Dispositivo Físico:**
1. Conecta tu móvil Android por USB
2. Activa "Depuración USB" en Opciones de Desarrollador

**Opción B - Emulador:**
1. Abre Android Studio
2. Ve a Device Manager
3. Crea un nuevo Virtual Device

**[IMAGEN: Dispositivo/emulador conectado]**

#### 7.2 Verificar Dispositivo

```bash
flutter devices
```

**[IMAGEN: Lista de dispositivos disponibles]**

#### 7.3 Ejecutar

```bash
flutter run
```

**[IMAGEN: Aplicación corriendo en el dispositivo]**

---

## ✅ Verificación de Instalación

Después de ejecutar, deberías ver:

1. ✅ La aplicación abre sin errores
2. ✅ Aparece la pantalla principal con 4 opciones
3. ✅ Puedes navegar entre las secciones

**[IMAGEN: Pantalla principal de SmartGrade AI]**

---

## 🔧 Solución de Problemas

### Error: "Flutter no se reconoce"
**Solución:** Verifica que Flutter esté en el PATH
```bash
echo $env:Path
```

### Error: "SDK licenses not accepted"
**Solución:**
```bash
flutter doctor --android-licenses
```
Presiona `y` para aceptar todas

### Error: "Gradle build failed"
**Solución:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Error: "API Key no configurada"
**Solución:** Verifica que `api_keys.dart` contenga tu clave real de Gemini

---

## 📊 Estructura del Proyecto

```
SmartGrade AI/
├── lib/
│   ├── main.dart              # Punto de entrada
│   ├── core/                  # Configuración y utilidades
│   ├── data/                  # Base de datos y modelos
│   ├── domain/                # Lógica de negocio
│   └── presentation/          # Interfaces de usuario
├── android/                   # Configuración Android
└── pubspec.yaml              # Dependencias
```

---

## 💡 Conclusiones

SmartGrade AI es una solución moderna que:

- ✅ **Ahorra tiempo**: Califica exámenes en segundos
- ✅ **Aumenta precisión**: Minimiza errores humanos
- ✅ **Facilita gestión**: Centraliza información académica
- ✅ **Genera reportes**: Exporta resultados automáticamente

La instalación es directa siguiendo estos pasos, y en menos de 30 minutos tendrás el sistema funcionando.

---

## 🎯 Recomendaciones

### Antes de usar en producción:

1. **Seguridad de la API**
   - Guarda tu API Key de forma segura
   - Monitorea el uso mensual en Google Cloud

2. **Respaldos**
   - Exporta la base de datos regularmente
   - Mantén copias de los resultados en Excel/PDF

3. **Capacitación**
   - Entrena a los docentes en el uso básico
   - Realiza pruebas con exámenes de práctica

4. **Rendimiento**
   - Usa imágenes de buena calidad al escanear
   - Limpia la caché periódicamente

### Próximos pasos:

- 📱 Prueba con exámenes reales
- 📊 Explora las opciones de exportación
- 🔄 Actualiza regularmente el sistema
- 📝 Documenta procedimientos específicos de tu institución

---

## 📞 Soporte

¿Necesitas ayuda?

- 📧 Email: soporte@smartgradeai.com
- 💬 Issues: https://github.com/tuusuario/smartgrade_ai/issues
- 📚 Documentación completa: Ver `README.md`

---

**Versión del Manual**: 1.0  
**Fecha**: Enero 2026  
**Tiempo estimado de instalación**: 20-30 minutos
