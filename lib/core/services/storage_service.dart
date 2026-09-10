import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Maneja la subida de archivos al Storage de Supabase.
/// Por ahora se usa para la foto de perfil (bucket `avatars`).
class StorageService {
  static const String avatarsBucket = 'avatars';

  /// Sube (o reemplaza) la foto de perfil del usuario actual y
  /// devuelve la URL pública para guardarla en `profiles.avatar_url`.
  ///
  /// Requiere que en Supabase exista un bucket público llamado
  /// `avatars` (ver SUPABASE_SETUP.md).
  static Future<String> uploadAvatar(
      Uint8List bytes, String extension) async {
    final user = SupabaseService.currentUser;
    if (user == null) {
      throw Exception('No hay una sesión activa.');
    }

    final ext = extension.trim().isEmpty
      ? 'jpg' : extension.trim().toLowerCase();
    final storagePath = '${user.id}/avatar.$ext';

    await SupabaseService.client.storage
      .from(avatarsBucket)
      .uploadBinary(
        storagePath,
        bytes,
        fileOptions: FileOptions(
          contentType: _contentTypeFor(ext),
          upsert: true,
        ),
      );

    final publicUrl = SupabaseService.client.storage
      .from(avatarsBucket)
      .getPublicUrl(storagePath);

    // Se agrega un parámetro de versión para que la app no muestre
    // una copia en caché de la foto anterior con el mismo nombre.
    return '$publicUrl?v=${DateTime.now().millisecondsSinceEpoch}';
  }

  static String _contentTypeFor(String ext) {
    switch (ext) {
      case 'png':  return 'image/png';
      case 'webp': return 'image/webp';
      case 'gif':  return 'image/gif';
      case 'jpg':
      case 'jpeg':
      default:     return 'image/jpeg';
    }
  }
}
