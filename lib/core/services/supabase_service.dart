import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl =
    'https://vstbyfehktgqypujkfgt.supabase.co';
  static const String supabaseKey =
    'sb_publishable_CkAMHhG1JYEPyeNdWq0hsQ_Vy8jdKQb';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
  }

  // Login
  static Future<AuthResponse> login(
    String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Registro
  static Future<AuthResponse> register(
    String email, String password,
    String fullName, String role) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role,
      },
    );
  }

  // Logout
  static Future<void> logout() async {
    await client.auth.signOut();
  }

  // Recuperar contraseña
  static Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'https://aula-lidia.vercel.app',
    );
  }

  // Usuario actual
  static User? get currentUser => client.auth.currentUser;

  // Rol desde la tabla profiles
  static Future<String> getUserRole() async {
    try {
      final user = currentUser;
      if (user == null) return 'student';

      final data = await client
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .single();

      return data['role'] ?? 'student';
    } catch (e) {
      return currentUser?.userMetadata?['role'] ?? 'student';
    }
  }

  // Nombre desde la tabla profiles
  static Future<String> getUserName() async {
    try {
      final user = currentUser;
      if (user == null) return '';

      final data = await client
        .from('profiles')
        .select('full_name')
        .eq('id', user.id)
        .single();

      return data['full_name'] ?? '';
    } catch (e) {
      return currentUser?.userMetadata?['full_name'] ?? '';
    }
  }
}