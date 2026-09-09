// lib/core/constants/api_config.dart
//
// LidIA usa dos caminos distintos según dónde corra la app:
//
// - MÓVIL / ESCRITORIO (Android/iOS/Windows/macOS): llama a Groq DIRECTO,
//   con la key pasada al compilar (--dart-define=GROQ_API_KEY=...).
//   No pasa por navegador, así que no hay problema de CORS.
//
// - WEB (Chrome/Safari/etc.): los navegadores bloquean por seguridad
//   (CORS) las llamadas directas a la API de Groq desde una página web.
//   Por eso la versión web usa la función serverless de Vercel en
//   api/chat.js como intermediario — no es opcional, es una regla que
//   impone el navegador, no algo que dependa de este código.
//
// El código en chat_ia_screen.dart detecta automáticamente en cuál de las
// dos plataformas está corriendo y usa el camino correspondiente.
class ApiConfig {
  // ── Para MÓVIL/ESCRITORIO: key directa a Groq ───────────────
  // Compila así para que esto no quede vacío:
  //   flutter build apk --dart-define=GROQ_API_KEY=tu_key_real
  static const String groqApiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '',
  );
  static const String groqChatUrl =
    'https://api.groq.com/openai/v1/chat/completions';

  // ── Para WEB: URL de la función serverless de Vercel ────────
  // "/api/chat" es una ruta RELATIVA: funciona sola apenas subas
  // el sitio a Vercel (siempre que exista el archivo api/chat.js
  // en la raíz del proyecto), sin que tengas que escribir tu
  // dominio a mano.
  static const String lidiaChatUrl = String.fromEnvironment(
    'LIDIA_API_URL',
    defaultValue: '/api/chat',
  );
}