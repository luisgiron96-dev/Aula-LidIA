// lib/core/constants/api_config.dart
//
// LidIA usa dos caminos distintos según dónde corra la app:
//
// - MÓVIL (Android/iOS): llama a Groq DIRECTO, con la key embebida al
//   compilar. No necesita proxy ni servidor propio.
//
// - WEB (Chrome/navegador): los navegadores bloquean por seguridad (CORS)
//   las llamadas directas a la API de Groq desde una página web. Por eso
//   la versión web sigue necesitando el proxy (proxy/server.js) como
//   intermediario — no es opcional, es una regla que impone el navegador,
//   no algo que dependa de este código.
//
// El código en chat_ia_screen.dart detecta automáticamente en cuál de las
// dos plataformas está corriendo y usa el camino correspondiente.
class ApiConfig {
  // ── Para MÓVIL: key directa a Groq ──────────────────────────
  static const String groqApiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '',
  );
  static const String groqChatUrl =
    'https://api.groq.com/openai/v1/chat/completions';

  // ── Para WEB: URL del proxy ──────────────────────────────────
  // - Probando en tu PC (proxy corriendo local): http://localhost:3000/chat
  // - Ya desplegado en Render:                   https://tu-proxy.onrender.com/chat
  static const String lidiaChatUrl = String.fromEnvironment(
    'LIDIA_API_URL',
    defaultValue: 'http://localhost:3000/chat',
  );
}