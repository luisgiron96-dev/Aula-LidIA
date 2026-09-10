import 'package:flutter/material.dart';

/// Guarda la URL de la foto de perfil actual para mostrarla en toda
/// la app (barra superior, menú lateral, Configuración) sin tener
/// que volver a consultarla en cada pantalla.
class AvatarController extends ChangeNotifier {
  AvatarController._();
  static final AvatarController instance = AvatarController._();

  String? avatarUrl;

  void setAvatarUrl(String? url) {
    avatarUrl = url;
    notifyListeners();
  }
}
