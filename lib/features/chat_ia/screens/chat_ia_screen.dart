import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/constants/api_config.dart';
import '../../../core/constants/app_colors.dart';

class ChatIAScreen extends StatefulWidget {
  final String role; // 'student' o 'teacher'
  final VoidCallback? onBack;
  const ChatIAScreen({super.key, required this.role, this.onBack});
  @override
  State<ChatIAScreen> createState() => _ChatIAScreenState();
}

class _ChatIAScreenState extends State<ChatIAScreen> {
  final _msgCtrl    = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isTyping    = false;
  String _errorDetail = '';

  bool get _isTeacher => widget.role == 'teacher';

  late final List<Map<String, String>> _messages = [
    {
      'role': 'lidia',
      'text': _isTeacher
        ? '¡Hola! Soy LidIA, tu asistente de planeación 👋\n\n'
          'Cuéntame qué tema quieres dictar y te ayudo a armar el temario '
          'de la clase: subtemas, objetivos de aprendizaje y actividades '
          'sugeridas. Al final puedes descargar el temario en PDF.\n\n'
          '¿Qué tema vas a dictar?'
        : '¡Hola! Soy LidIA, tu tutora virtual 👋\n\n'
          'Estoy aquí para ayudarte a entender cualquier tema de tus materias. '
          'Te explico paso a paso para que tú mismo puedas resolver tus actividades.\n\n'
          '¿Qué tema quieres aprender hoy?',
      'time': '9:00 am',
    },
  ];

  static const _studentSystemPrompt =
    'Eres LidIA, una tutora virtual educativa para estudiantes rurales '
    'de Colombia de la plataforma Aula Lid-IA. '
    'Tu rol es ser TUTORA, no resolver tareas ni actividades directamente. '
    'REGLAS IMPORTANTES que SIEMPRE debes seguir:\n'
    '1. NUNCA des la respuesta directa a una tarea, ejercicio o actividad.\n'
    '2. Si un estudiante te pide que resuelva su tarea, explícale el concepto '
    'y guíalo para que él mismo lo resuelva.\n'
    '3. Usa ejemplos DIFERENTES a los de la tarea del estudiante.\n'
    '4. Explica paso a paso de forma clara y sencilla.\n'
    '5. Motiva al estudiante a pensar por sí mismo.\n'
    '6. Si el estudiante insiste en que le des la respuesta, '
    'recuérdale amablemente que tu rol es enseñarle, no hacer su tarea.\n'
    '7. Responde siempre en español colombiano, cálido y motivador.\n'
    '8. Usa emojis con moderación para hacer las respuestas más amigables.\n'
    '9. Cuando expliques un concepto, al final pregunta si entendió '
    'o si quiere que expliques algo de otra forma.\n'
    'Materias que cubres: Español, Inglés, Matemáticas, '
    'Ciencias Sociales, Ciencias Naturales, Cátedra de Paz, '
    'Religión, Informática y TelePsicología.';

  static const _teacherSystemPrompt =
    'Eres LidIA, una asistente de planeación pedagógica para docentes '
    'rurales de Colombia de la plataforma Aula Lid-IA. '
    'Tu rol es ayudar al docente a preparar el temario de una clase nueva. '
    'REGLAS IMPORTANTES que SIEMPRE debes seguir:\n'
    '1. Cuando el docente te diga un tema, genera un temario estructurado '
    'con TRES secciones claras: "Subtemas" (lista de puntos a cubrir), '
    '"Objetivos de aprendizaje" (qué debe lograr el estudiante al terminar), '
    'y "Actividades sugeridas" (ejercicios o dinámicas para la clase).\n'
    '2. Usa encabezados markdown (##) para cada sección y viñetas (-) '
    'para los puntos, de forma clara y organizada.\n'
    '3. Adapta el nivel al grado/edad que el docente mencione; si no lo '
    'menciona, pregúntale antes de generar el temario.\n'
    '4. Si el docente pide ajustes (más corto, más avanzado, otro enfoque), '
    'genera una versión nueva del temario completo.\n'
    '5. Responde siempre en español colombiano, profesional y claro.\n'
    'Materias que cubres: Español, Inglés, Matemáticas, '
    'Ciencias Sociales, Ciencias Naturales, Cátedra de Paz, '
    'Religión, Informática y TelePsicología.';

  late final List<Map<String, String>> _groqHistory = [
    {
      'role': 'system',
      'content': _isTeacher ? _teacherSystemPrompt : _studentSystemPrompt,
    }
  ];

  late final List<String> _suggestions = _isTeacher
    ? [
        'Arma el temario de fracciones para 5°',
        'Temario de ciclo del agua para 4°',
        'Plan de clase sobre el sujeto y el predicado',
        'Temario de pasado simple en inglés',
      ]
    : [
        '¿Cómo se suman fracciones?',
        'Explícame el ciclo del agua',
        '¿Qué es un sujeto y predicado?',
        '¿Cómo se forma el pasado en inglés?',
      ];

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _msgCtrl.clear();

    _groqHistory.add({'role': 'user', 'content': text});

    setState(() {
      _messages.add({
        'role': 'user',
        'text': text,
        'time': _currentTime(),
      });
      _isTyping = true;
      _errorDetail = '';
    });

    _scrollToBottom();

    // En la web no podemos llamar a Groq directo (el navegador lo
    // bloquea por CORS), así que pasamos por la función de Vercel.
    // En móvil/escritorio sí podemos llamar a Groq directo.
    if (kIsWeb) {
      await _sendViaVercelProxy();
    } else {
      await _sendDirectToGroq();
    }

    _scrollToBottom();
  }

  Future<void> _sendViaVercelProxy() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.lidiaChatUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'messages': _groqHistory}),
      ).timeout(const Duration(seconds: 30));

      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String;
        _groqHistory.add({'role': 'assistant', 'content': reply});
        setState(() {
          _isTyping = false;
          _messages.add({
            'role': 'lidia', 'text': reply, 'time': _currentTime()});
        });
      } else {
        setState(() => _errorDetail = 'Status: ${response.statusCode} '
          '— ${response.body}');
        _showError();
      }
    } catch (e) {
      print('ERROR LidIA (proxy): $e');
      setState(() => _errorDetail = e.toString());
      _showError();
    }
  }

  Future<void> _sendDirectToGroq() async {
    if (ApiConfig.groqApiKey.isEmpty) {
      setState(() => _errorDetail =
        'Falta la clave de Groq. Compila con:\n'
        'flutter build ... --dart-define=GROQ_API_KEY=tu_key');
      _showError();
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.groqChatUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.groqApiKey}',
        },
        body: jsonEncode({
          'model': 'openai/gpt-oss-120b',
          'messages': _groqHistory,
          'max_tokens': 1024,
          'temperature': 0.7,
        }),
      ).timeout(const Duration(seconds: 30));

      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String;
        _groqHistory.add({'role': 'assistant', 'content': reply});
        setState(() {
          _isTyping = false;
          _messages.add({
            'role': 'lidia', 'text': reply, 'time': _currentTime()});
        });
      } else {
        setState(() => _errorDetail = 'Status: ${response.statusCode}');
        _showError();
      }
    } catch (e) {
      print('ERROR LidIA (directo): $e');
      setState(() => _errorDetail = e.toString());
      _showError();
    }
  }

  void _showError() {
    setState(() {
      _isTyping = false;
      _messages.add({
        'role': 'lidia',
        'text': 'Ups, tuve un problema 😕\n'
          'Error: $_errorDetail\n\n'
          'Verifica tu internet e intenta de nuevo.',
        'time': _currentTime(),
      });
    });
  }

  String _currentTime() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut);
      }
    });
  }

  Future<void> _downloadPdf(String content) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0,
            child: pw.Text('Temario de clase — Aula Lid-IA')),
          pw.SizedBox(height: 12),
          pw.Paragraph(text: content, style: const pw.TextStyle(
            fontSize: 12, lineSpacing: 3)),
        ],
      ),
    );
    final bytes = await doc.save();
    await Printing.sharePdf(bytes: bytes, filename: 'temario-clase.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: widget.onBack != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back,
                color: AppColors.textPrimary),
              onPressed: widget.onBack)
          : null,
        title: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1D9E75), Color(0xFF085041)]),
              borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.smart_toy,
              color: Colors.white, size: 20)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('LidIA — Tutora Virtual',
                style: TextStyle(fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary)),
              Text(_isTeacher
                  ? 'Te ayudo a planear tu clase 📋'
                  : 'Te enseño, tú aprendes 🌱',
                style: const TextStyle(fontSize: 10,
                  color: AppColors.primary)),
            ]),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined,
              color: AppColors.textSecondary),
            onPressed: () => setState(() {
              _messages.clear();
              _groqHistory.removeWhere((m) => m['role'] != 'system');
              _messages.add({
                'role': 'lidia',
                'text': _isTeacher
                  ? '¡Listo! ¿Qué tema quieres dictar ahora? 📋'
                  : '¡Hola de nuevo! ¿Qué tema quieres aprender hoy? 😊',
                'time': _currentTime(),
              });
            })),
        ],
      ),
      body: Column(children: [

        // Banner informativo
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8),
          color: const Color(0xFFE1F5EE),
          child: Row(children: [
            const Icon(Icons.info_outline,
              size: 14, color: AppColors.primaryDark),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _isTeacher
                  ? 'LidIA arma el temario de tu clase — puedes descargarlo en PDF'
                  : 'LidIA te explica los temas para que tú mismo resuelvas tus actividades',
                style: const TextStyle(fontSize: 11,
                  color: AppColors.primaryDark))),
          ])),

        // Mensajes
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (_, i) {
              if (_isTyping && i == _messages.length) {
                return _TypingIndicator();
              }
              final m = _messages[i];
              final isLidia = m['role'] == 'lidia';
              // La primera bienvenida no se puede descargar como temario
              final canDownload = _isTeacher && isLidia && i != 0;

              if (i == 0 && _messages.length == 1) {
                return Column(children: [
                  _MessageBubble(
                    text: m['text']!,
                    isLidia: true,
                    time: m['time']!,
                    isTeacher: _isTeacher),
                  const SizedBox(height: 12),
                  _SuggestionChips(
                    suggestions: _suggestions,
                    onTap: _sendMessage),
                ]);
              }

              return _MessageBubble(
                text: m['text']!,
                isLidia: isLidia,
                time: m['time']!,
                isTeacher: _isTeacher,
                onDownloadPdf: canDownload
                  ? () => _downloadPdf(m['text']!)
                  : null);
            }),
        ),

        // Input
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.shade200))),
          child: Row(children: [
            Expanded(
              child: Focus(
                onKeyEvent: (node, event) {
                  final isEnter = event.logicalKey == LogicalKeyboardKey.enter
                    || event.logicalKey == LogicalKeyboardKey.numpadEnter;
                  final isShiftPressed =
                    HardwareKeyboard.instance.isShiftPressed;
                  if (isEnter && !isShiftPressed
                      && event is KeyDownEvent) {
                    _sendMessage(_msgCtrl.text);
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: TextField(
                  controller: _msgCtrl,
                  maxLines: null,
                  onSubmitted: _sendMessage,
                  decoration: InputDecoration(
                  hintText: _isTeacher
                    ? '¿Qué tema vas a dictar?'
                    : '¿Qué tema quieres aprender?',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10))),
              )),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _sendMessage(_msgCtrl.text),
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.send,
                  color: Colors.white, size: 20))),
          ]),
        ),
      ]),
    );
  }
}

// ── WIDGETS ───────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isLidia;
  final String time;
  final bool isTeacher;
  final VoidCallback? onDownloadPdf;
  const _MessageBubble({required this.text,
    required this.isLidia, required this.time,
    this.isTeacher = false, this.onDownloadPdf});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isLidia
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
        children: [
          if (isLidia) ...[
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D9E75), Color(0xFF085041)]),
                borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.smart_toy,
                color: Colors.white, size: 16)),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isLidia
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isLidia
                      ? Colors.white
                      : AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(
                        isLidia ? 0 : 12),
                      bottomRight: Radius.circular(
                        isLidia ? 12 : 0)),
                    border: isLidia
                      ? Border.all(color: Colors.grey.shade200)
                      : null),
                  child: Text(text,
                    style: TextStyle(
                      fontSize: 13,
                      color: isLidia
                        ? AppColors.textPrimary
                        : Colors.white,
                      height: 1.4))),
                const SizedBox(height: 4),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(time,
                    style: const TextStyle(fontSize: 10,
                      color: AppColors.textSecondary)),
                  if (onDownloadPdf != null) ...[
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: onDownloadPdf,
                      child: Row(mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.picture_as_pdf_outlined,
                            size: 13, color: AppColors.primary),
                          SizedBox(width: 3),
                          Text('Descargar PDF',
                            style: TextStyle(fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary)),
                        ])),
                  ],
                ]),
              ])),
          if (!isLidia) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: isTeacher
                ? AppColors.teacherColor
                : AppColors.studentColor,
              child: Text(isTeacher ? 'MP' : 'VA',
                style: const TextStyle(fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryDark))),
          ],
        ]),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1D9E75), Color(0xFF085041)]),
            borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.smart_toy,
            color: Colors.white, size: 16)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12)),
            border: Border.all(color: Colors.grey.shade200)),
          child: Row(children: [
            _Dot(delay: 0),
            const SizedBox(width: 4),
            _Dot(delay: 200),
            const SizedBox(width: 4),
            _Dot(delay: 400),
          ])),
      ]),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot>
  with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay),
      () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 7, height: 7,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle)));
  }
}

class _SuggestionChips extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onTap;
  const _SuggestionChips({required this.suggestions,
    required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: suggestions.map((s) => GestureDetector(
        onTap: () => onTap(s),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3))),
          child: Text(s,
            style: const TextStyle(fontSize: 12,
              color: AppColors.primaryDark))),
      )).toList(),
    );
  }
}