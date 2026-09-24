import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Pantalla de "Autorización para el tratamiento de datos personales"
/// que se muestra durante el registro de un usuario, antes de abrir
/// el formulario de creación de cuenta.
///
/// Al pulsar "ACEPTAR Y CONTINUAR" hace `Navigator.pop(context, true)`
/// para que la pantalla que la abrió (LoginScreen) continúe con el
/// flujo de registro. Si el usuario retrocede sin autorizar, hace
/// pop con `false`/`null` y el registro no continúa.
class DataConsentScreen extends StatefulWidget {
  /// 'student' o 'teacher'. Determina qué datos, finalidades y
  /// secciones se muestran (por ejemplo, la sección de menores de
  /// edad solo aplica a estudiantes).
  final String role;

  const DataConsentScreen({super.key, required this.role});

  @override
  State<DataConsentScreen> createState() => _DataConsentScreenState();
}

class _DataConsentScreenState extends State<DataConsentScreen> {
  bool get _isTeacher => widget.role == 'teacher';
  String get _roleLabel => _isTeacher ? 'Docente' : 'Estudiante';

  // 'mayor'     -> quien se registra autoriza por sí mismo.
  // 'acudiente' -> un padre/madre/representante autoriza en nombre
  //                de un estudiante menor de edad.
  String _tipoAutorizante = 'mayor';

  bool _autorizacionObligatoria = false;
  bool _comunicaciones = false;
  bool _enviando = false;

  String get _textoAutorizacion => _tipoAutorizante == 'mayor'
    ? 'Autorizo a Aula LidIA para realizar el tratamiento de mis '
      'datos personales de acuerdo con las finalidades informadas '
      'y la Política de Tratamiento de Datos Personales.'
    : 'Autorizo, en representación del estudiante menor de edad, el '
      'tratamiento de sus datos personales por parte de Aula LidIA '
      'de acuerdo con las finalidades informadas y la Política de '
      'Tratamiento de Datos Personales.';

  Future<void> _continuar() async {
    if (!_autorizacionObligatoria) return;

    setState(() => _enviando = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Autorización registrada correctamente.'),
        backgroundColor: AppColors.primary,
      ),
    );

    // Pequeña pausa para que el usuario vea la confirmación antes
    // de continuar con el proceso de registro.
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) Navigator.pop(context, true);
  }

  void _showFullPolicyInfo() {
    _showInfoSheet(
      title: 'Información completa',
      body:
        'Aula LidIA trata tus datos personales para permitirte crear '
        'una cuenta, acceder a la plataforma, personalizar tu '
        'experiencia educativa, dar seguimiento a tu proceso de '
        'aprendizaje y mejorar nuestras herramientas basadas en '
        'inteligencia artificial.\n\n'
        'Solo solicitamos la información necesaria para estas '
        'finalidades y la conservamos de forma segura mientras '
        'mantengas tu cuenta activa o de acuerdo con lo exigido por '
        'la normativa aplicable.\n\n'
        'Puedes conocer, actualizar, rectificar o solicitar la '
        'eliminación de tus datos en cualquier momento desde '
        'Configuración > Privacidad, o escribiéndonos a través de '
        'los canales de soporte de la plataforma.\n\n'
        'Cuando el usuario sea menor de edad, el tratamiento de sus '
        'datos requiere la autorización de su padre, madre o '
        'representante legal.',
    );
  }

  void _showRightsInfo() {
    _showInfoSheet(
      title: 'Tus derechos sobre tus datos',
      body:
        'Como titular de tus datos personales, en cualquier momento '
        'puedes:\n\n'
        '• Conocer qué datos tuyos tenemos y para qué se usan.\n'
        '• Solicitar la actualización o corrección de tus datos.\n'
        '• Solicitar la eliminación de tus datos cuando corresponda.\n'
        '• Revocar esta autorización, salvo que exista un deber '
        'legal o contractual que impida su eliminación inmediata.\n\n'
        'Para ejercer estos derechos, ingresa a Configuración > '
        'Privacidad o contáctanos a través de los canales de '
        'soporte de Aula LidIA.',
    );
  }

  void _showPolicyDialog(String titulo) {
    // TODO(Luis): cuando tengas el documento definitivo, cambia este
    // diálogo por la navegación a la página real (por ejemplo con
    // url_launcher hacia la URL publicada de cada política).
    _showInfoSheet(
      title: titulo,
      body:
        'Aquí se mostrará el contenido completo de "$titulo". '
        'Reemplaza este texto por el documento definitivo o '
        'conecta este enlace con la URL publicada de la política.',
    );
  }

  void _showInfoSheet({required String title, required String body}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tc = AppThemeColors(isDark);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: tc.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (ctx, scrollController) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: tc.border,
                    borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text(title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: tc.textPrimary)),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(body,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.5,
                      color: tc.textSecondary)))),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Entendido'))),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tc = AppThemeColors(isDark);

    return Scaffold(
      backgroundColor: tc.background,
      appBar: AppBar(
        backgroundColor: tc.surface,
        foregroundColor: tc.textPrimary,
        elevation: 0,
        title: const Text('Datos personales',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            _buildHeader(tc),
            const SizedBox(height: 20),
            _buildIntro(tc),
            const SizedBox(height: 24),
            _SectionTitle(
              icon: Icons.badge_outlined,
              text: '¿Qué información podemos solicitar?',
              color: tc.textPrimary),
            const SizedBox(height: 10),
            _buildDataGrid(tc),
            const SizedBox(height: 24),
            _SectionTitle(
              icon: Icons.flag_outlined,
              text: '¿Para qué utilizaremos tu información?',
              color: tc.textPrimary),
            const SizedBox(height: 10),
            _buildPurposeCard(tc),
            if (!_isTeacher) ...[
              const SizedBox(height: 24),
              _buildMinorsSection(tc),
            ],
            const SizedBox(height: 24),
            _SectionTitle(
              icon: Icons.verified_user_outlined,
              text: 'Tu autorización',
              color: tc.textPrimary),
            const SizedBox(height: 10),
            _buildAuthorizationCard(tc),
            const SizedBox(height: 24),
            _buildTrustFooter(tc),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(tc),
    );
  }

  Widget _buildHeader(AppThemeColors tc) {
    return Column(
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16)),
          child: Icon(_isTeacher ? Icons.co_present : Icons.school,
            color: Colors.white, size: 30)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: _isTeacher
              ? AppColors.accent.withValues(alpha: 0.15)
              : AppColors.primaryLight.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(20)),
          child: Text('Cuenta de $_roleLabel',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: _isTeacher
                ? AppColors.accent : AppColors.primaryDark))),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.privacy_tip_outlined,
              size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Autorización para el tratamiento\nde datos personales',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                  color: tc.textPrimary))),
          ]),
        const SizedBox(height: 6),
        Text(
          'Protegemos tu información y te explicamos cómo será '
          'utilizada.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: tc.textSecondary)),
      ],
    );
  }

  Widget _buildIntro(AppThemeColors tc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkAware(tc)
          ? AppColors.primary.withValues(alpha: 0.12)
          : const Color(0xFFE1F5EE),
        borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Antes de continuar con tu registro, necesitamos tu '
            'autorización para realizar el tratamiento de tus datos '
            'personales. Esta información será utilizada únicamente '
            'para las finalidades informadas y de acuerdo con nuestra '
            'Política de Tratamiento de Datos Personales.',
            style: TextStyle(
              fontSize: 13, height: 1.45, color: tc.textPrimary)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _showFullPolicyInfo,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Leer información completa',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                    decoration: TextDecoration.underline)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward,
                  size: 14, color: AppColors.primaryDark),
              ])),
        ],
      ),
    );
  }

  bool isDarkAware(AppThemeColors tc) => tc.isDark;

  Widget _buildDataGrid(AppThemeColors tc) {
    final items = _isTeacher
      ? const [
          (Icons.person_outline, 'Nombre completo'),
          (Icons.badge_outlined, 'Documento de identificación'),
          (Icons.email_outlined, 'Correo electrónico'),
          (Icons.phone_outlined, 'Número de teléfono'),
          (Icons.work_outline, 'Información profesional y académica'),
          (Icons.menu_book_outlined, 'Asignaturas y cursos a cargo'),
          (Icons.upload_file_outlined, 'Contenidos y materiales publicados'),
          (Icons.apartment_outlined, 'Información de contacto institucional'),
        ]
      : const [
          (Icons.person_outline, 'Nombre completo'),
          (Icons.badge_outlined, 'Documento de identificación'),
          (Icons.cake_outlined, 'Fecha de nacimiento'),
          (Icons.email_outlined, 'Correo electrónico'),
          (Icons.phone_outlined, 'Número de teléfono'),
          (Icons.school_outlined, 'Información académica'),
          (Icons.menu_book_outlined, 'Proceso educativo'),
          (Icons.tune, 'Personalización del aprendizaje'),
        ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final item in items)
          _DataChip(icon: item.$1, label: item.$2, tc: tc),
      ],
    );
  }

  Widget _buildPurposeCard(AppThemeColors tc) {
    final purposes = _isTeacher
      ? const [
          'Crear y administrar la cuenta del usuario.',
          'Permitir el acceso a Aula LidIA.',
          'Gestionar tus asignaturas, clases y contenidos.',
          'Facilitar la comunicación con tus estudiantes.',
          'Dar soporte a las herramientas de inteligencia artificial '
            'que utilices para preparar tus clases.',
          'Enviar comunicaciones relacionadas con la plataforma.',
          'Mejorar los servicios y funcionalidades de Aula LidIA.',
          'Generar estadísticas educativas cuando corresponda y de '
            'acuerdo con las políticas aplicables.',
        ]
      : const [
          'Crear y administrar la cuenta del usuario.',
          'Permitir el acceso a Aula LidIA.',
          'Personalizar la experiencia educativa.',
          'Realizar seguimiento del proceso de aprendizaje.',
          'Facilitar herramientas educativas basadas en inteligencia '
            'artificial.',
          'Enviar comunicaciones relacionadas con la plataforma.',
          'Mejorar los servicios y funcionalidades de Aula LidIA.',
          'Generar estadísticas educativas cuando corresponda y de '
            'acuerdo con las políticas aplicables.',
        ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tc.border)),
      child: Column(
        children: [
          for (final p in purposes) _PurposeRow(text: p, tc: tc),
        ],
      ),
    );
  }

  Widget _buildMinorsSection(AppThemeColors tc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          icon: Icons.family_restroom_outlined,
          text: 'Información importante para menores de edad',
          color: tc.textPrimary),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4E5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.4))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline,
                color: AppColors.warning, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cuando el usuario sea menor de edad, el tratamiento '
                  'de sus datos debe contar con las autorizaciones y '
                  'garantías correspondientes de acuerdo con la '
                  'normativa aplicable.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: Color(0xFF7A4A00)))),
            ])),
        const SizedBox(height: 12),
        Text('¿Quién está autorizando?',
          style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500,
            color: tc.textPrimary)),
        const SizedBox(height: 8),
        Row(children: [
          _UserTypeTab(
            label: 'Soy mayor de edad',
            icon: Icons.person,
            active: _tipoAutorizante == 'mayor',
            onTap: () => setState(() => _tipoAutorizante = 'mayor')),
          const SizedBox(width: 8),
          _UserTypeTab(
            label: 'Autorizo como\nacudiente de un menor',
            icon: Icons.escalator_warning_outlined,
            active: _tipoAutorizante == 'acudiente',
            onTap: () =>
              setState(() => _tipoAutorizante = 'acudiente')),
        ]),
        if (_tipoAutorizante == 'acudiente') ...[
          const SizedBox(height: 10),
          Text(
            'Al continuar, confirmas que autorizas el tratamiento de '
            'datos en representación del estudiante menor de edad '
            'que estás registrando.',
            style: TextStyle(
              fontSize: 12, color: tc.textSecondary, height: 1.4)),
        ],
      ],
    );
  }

  Widget _buildAuthorizationCard(AppThemeColors tc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tc.border)),
      child: Column(
        children: [
          CheckboxListTile(
            value: _autorizacionObligatoria,
            onChanged: (v) =>
              setState(() => _autorizacionObligatoria = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
            title: Text(_textoAutorizacion,
              style: TextStyle(
                fontSize: 13, height: 1.4, color: tc.textPrimary))),
          Divider(color: tc.border, height: 1),
          CheckboxListTile(
            value: _comunicaciones,
            onChanged: (v) =>
              setState(() => _comunicaciones = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Acepto recibir comunicaciones informativas y '
              'novedades de Aula LidIA. (Opcional)',
              style: TextStyle(
                fontSize: 13, height: 1.4, color: tc.textSecondary))),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                _PolicyLink(
                  text: 'Política de Tratamiento de Datos Personales',
                  onTap: () => _showPolicyDialog(
                    'Política de Tratamiento de Datos Personales')),
                Text('  •  ',
                  style: TextStyle(color: tc.textSecondary)),
                _PolicyLink(
                  text: 'Política de Privacidad',
                  onTap: () =>
                    _showPolicyDialog('Política de Privacidad')),
                Text('  •  ',
                  style: TextStyle(color: tc.textSecondary)),
                _PolicyLink(
                  text: 'Términos y condiciones',
                  onTap: () =>
                    _showPolicyDialog('Términos y condiciones')),
              ])),
        ],
      ),
    );
  }

  Widget _buildTrustFooter(AppThemeColors tc) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: tc.isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const Text('🔒', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tu privacidad es importante para nosotros.',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: tc.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                      'Consulta nuestra Política de Tratamiento de '
                      'Datos Personales para conocer cómo protegemos '
                      'y utilizamos tu información.',
                      style: TextStyle(
                        fontSize: 11.5, color: tc.textSecondary)),
                  ])),
            ])),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _showRightsInfo,
          child: Text('¿Quieres conocer tus derechos sobre tus datos?',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
              decoration: TextDecoration.underline))),
      ],
    );
  }

  Widget _buildBottomBar(AppThemeColors tc) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: BoxDecoration(
          color: tc.surface,
          border: Border(top: BorderSide(color: tc.border))),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: (_autorizacionObligatoria && !_enviando)
              ? _continuar : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: tc.isDark
                ? Colors.white12
                : Colors.grey.shade300,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
            child: _enviando
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
              : const Text('ACEPTAR Y CONTINUAR',
                  style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600))),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _SectionTitle(
    {required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 18, color: AppColors.primary),
      const SizedBox(width: 8),
      Expanded(
        child: Text(text,
          style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600, color: color))),
    ]);
  }
}

class _DataChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppThemeColors tc;
  const _DataChip(
    {required this.icon, required this.label, required this.tc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tc.border)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label,
            style: TextStyle(fontSize: 12, color: tc.textPrimary)),
        ]),
    );
  }
}

class _PurposeRow extends StatelessWidget {
  final String text;
  final AppThemeColors tc;
  const _PurposeRow({required this.text, required this.tc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle,
            size: 16, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
              style: TextStyle(
                fontSize: 12.5, height: 1.4, color: tc.textPrimary))),
        ]),
    );
  }
}

class _UserTypeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _UserTypeTab({required this.label, required this.icon,
    required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: active
            ? AppColors.primaryLight.withValues(alpha: 0.3)
            : Colors.grey.shade100,
          border: Border.all(
            color: active ? AppColors.primary : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18,
              color: active
                ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(height: 4),
            Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active
                  ? FontWeight.w600 : FontWeight.normal,
                color: active
                  ? AppColors.primary : AppColors.textSecondary)),
          ]),
      ),
    ));
  }
}

class _PolicyLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _PolicyLink({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(text,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
          decoration: TextDecoration.underline)));
  }
}