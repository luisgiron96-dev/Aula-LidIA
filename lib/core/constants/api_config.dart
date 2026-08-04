// lib/core/constants/api_config.dart
//
// Centraliza la URL del proxy de LidIA. Cámbiala según dónde estés probando:
//
// - Chrome / Web en tu misma PC donde corre el proxy:      http://localhost:3000/chat
// - Emulador de Android (Android Studio):                  http://10.0.2.2:3000/chat
// - Dispositivo físico (Android/iOS) en la misma red Wi-Fi: http://TU_IP_LOCAL:3000/chat
//     (obtén tu IP local con `ipconfig` en Windows, busca "IPv4 Address")
// - Producción (proxy desplegado, ej. Render/Railway):      https://tu-proxy.onrender.com/chat
//
// La API key de Groq NUNCA debe estar aquí ni en ningún archivo de Flutter.
// Vive únicamente en el servidor proxy (proxy/.env), donde el usuario no puede verla.
class ApiConfig {
  static const String lidiaChatUrl = String.fromEnvironment(
    'LIDIA_API_URL',
    defaultValue: 'http://localhost:3000/chat',
  );
}