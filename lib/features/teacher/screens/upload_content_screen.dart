import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_service.dart';

class UploadContentScreen extends StatefulWidget {
  const UploadContentScreen({super.key});
  @override
  State<UploadContentScreen> createState() =>
    _UploadContentScreenState();
}

class _UploadContentScreenState extends State<UploadContentScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  String _selectedMateria = 'Matemáticas';
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  double _uploadProgress = 0;
  String _statusMsg = '';

  final List<String> _materias = [
    'Español', 'Inglés', 'Matemáticas',
    'Cs. Sociales', 'Cs. Naturales',
    'Cátedra de Paz', 'Religión',
    'Informática', 'TelePsicología',
  ];

  final List<Map<String, dynamic>> _uploadedContent = [];

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final data = await SupabaseService.client
        .from('contenido')
        .select()
        .eq('teacher_id', SupabaseService.currentUser!.id)
        .order('created_at', ascending: false);

      setState(() {
        _uploadedContent.clear();
        _uploadedContent.addAll(
          List<Map<String, dynamic>>.from(data));
      });
    } catch (e) {
      print('Error cargando contenido: $e');
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'avi', 'mov', 'pdf', 'pptx'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  String _getTipo(String extension) {
    switch (extension.toLowerCase()) {
      case 'mp4':
      case 'avi':
      case 'mov': return 'video';
      case 'pdf': return 'pdf';
      case 'pptx': return 'pptx';
      default: return 'otro';
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) {
      _showSnack('Selecciona un archivo primero', isError: true);
      return;
    }
    if (_titleCtrl.text.trim().isEmpty) {
      _showSnack('Escribe un título', isError: true);
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
      _statusMsg = 'Preparando archivo...';
    });

    try {
      final file = _selectedFile!;
      final ext = file.extension ?? 'bin';
      final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final storagePath =
        '${SupabaseService.currentUser!.id}/$fileName';

      setState(() => _statusMsg = 'Subiendo archivo...');

      // Subir al Storage de Supabase
      await SupabaseService.client.storage
        .from('contenido')
        .uploadBinary(
          storagePath,
          file.bytes!,
          fileOptions: FileOptions(
            contentType: _getContentType(ext),
            upsert: false,
          ),
        );

      setState(() {
        _uploadProgress = 0.7;
        _statusMsg = 'Guardando información...';
      });

      // Obtener URL pública
      final url = SupabaseService.client.storage
        .from('contenido')
        .getPublicUrl(storagePath);

      // Guardar en tabla contenido
      await SupabaseService.client.from('contenido').insert({
        'titulo': _titleCtrl.text.trim(),
        'descripcion': _descCtrl.text.trim(),
        'materia': _selectedMateria,
        'tipo': _getTipo(ext),
        'url': url,
        'storage_path': storagePath,
        'teacher_id': SupabaseService.currentUser!.id,
      });

      setState(() {
        _uploadProgress = 1.0;
        _statusMsg = '¡Subido exitosamente!';
        _isUploading = false;
        _selectedFile = null;
        _titleCtrl.clear();
        _descCtrl.clear();
      });

      _showSnack('✅ Contenido subido exitosamente');
      _loadContent();

    } catch (e) {
      setState(() {
        _isUploading = false;
        _statusMsg = 'Error: $e';
      });
      _showSnack('Error al subir: $e', isError: true);
    }
  }

  String _getContentType(String ext) {
    switch (ext.toLowerCase()) {
      case 'mp4': return 'video/mp4';
      case 'avi': return 'video/avi';
      case 'mov': return 'video/quicktime';
      case 'pdf': return 'application/pdf';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument'
          '.presentationml.presentation';
      default: return 'application/octet-stream';
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : AppColors.primary));
  }

  Future<void> _deleteContent(
    String id, String storagePath) async {
    try {
      await SupabaseService.client.storage
        .from('contenido')
        .remove([storagePath]);
      await SupabaseService.client
        .from('contenido')
        .delete()
        .eq('id', id);
      _showSnack('Contenido eliminado');
      _loadContent();
    } catch (e) {
      _showSnack('Error al eliminar', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Subir contenido',
          style: TextStyle(fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Formulario de subida
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Título
                  const Text('Título del contenido',
                    style: TextStyle(fontSize: 12,
                      color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _titleCtrl,
                    decoration: InputDecoration(
                      hintText: 'Ej: Fracciones — Clase 1',
                      hintStyle: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10))),
                  const SizedBox(height: 12),

                  // Descripción
                  const Text('Descripción (opcional)',
                    style: TextStyle(fontSize: 12,
                      color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Describe brevemente el contenido',
                      hintStyle: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10))),
                  const SizedBox(height: 12),

                  // Materia
                  const Text('Materia',
                    style: TextStyle(fontSize: 12,
                      color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedMateria,
                        isExpanded: true,
                        items: _materias.map((m) =>
                          DropdownMenuItem(
                            value: m,
                            child: Text(m,
                              style: const TextStyle(
                                fontSize: 13)))).toList(),
                        onChanged: (v) => setState(
                          () => _selectedMateria = v!)))),
                  const SizedBox(height: 16),

                  // Zona de archivo
                  GestureDetector(
                    onTap: _isUploading ? null : _pickFile,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _selectedFile != null
                          ? const Color(0xFFE1F5EE)
                          : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedFile != null
                            ? AppColors.primary
                            : Colors.grey.shade300,
                          style: BorderStyle.solid)),
                      child: Column(children: [
                        Icon(
                          _selectedFile != null
                            ? Icons.check_circle_outline
                            : Icons.cloud_upload_outlined,
                          size: 36,
                          color: _selectedFile != null
                            ? AppColors.primary
                            : AppColors.textSecondary),
                        const SizedBox(height: 8),
                        Text(
                          _selectedFile != null
                            ? _selectedFile!.name
                            : 'Toca para seleccionar archivo',
                          style: TextStyle(
                            fontSize: 13,
                            color: _selectedFile != null
                              ? AppColors.primary
                              : AppColors.textSecondary,
                            fontWeight: _selectedFile != null
                              ? FontWeight.w500
                              : FontWeight.normal)),
                        if (_selectedFile != null)
                          Text(
                            '${(_selectedFile!.size / 1024 / 1024).toStringAsFixed(1)} MB',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary)),
                        if (_selectedFile == null)
                          const Text(
                            'MP4 · AVI · MOV · PDF · PPTX',
                            style: TextStyle(fontSize: 11,
                              color: AppColors.textSecondary)),
                      ]))),
                  const SizedBox(height: 16),

                  // Progreso
                  if (_isUploading) ...[
                    Text(_statusMsg,
                      style: const TextStyle(fontSize: 12,
                        color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _uploadProgress,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary))),
                    const SizedBox(height: 12),
                  ],

                  // Botón subir
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: _isUploading ? null : _uploadFile,
                      icon: _isUploading
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2))
                        : const Icon(Icons.upload, size: 18),
                      label: Text(_isUploading
                        ? 'Subiendo...'
                        : 'Subir contenido'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white))),
                ])),
            const SizedBox(height: 20),

            // Contenido subido
            const Text('Contenido subido',
              style: TextStyle(fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
            const SizedBox(height: 10),

            if (_uploadedContent.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200)),
                child: const Column(children: [
                  Icon(Icons.video_library_outlined,
                    size: 36, color: AppColors.textSecondary),
                  SizedBox(height: 8),
                  Text('No has subido contenido aún',
                    style: TextStyle(fontSize: 13,
                      color: AppColors.textSecondary)),
                ]))
            else
              ...(_uploadedContent.map((c) => _ContentCard(
                content: c,
                onDelete: () => _deleteContent(
                  c['id'], c['storage_path']),
              ))).toList(),
          ],
        ),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final Map<String, dynamic> content;
  final VoidCallback onDelete;
  const _ContentCard({required this.content,
    required this.onDelete});

  IconData get _icon {
    switch (content['tipo']) {
      case 'video': return Icons.play_circle_outline;
      case 'pdf': return Icons.picture_as_pdf_outlined;
      case 'pptx': return Icons.slideshow_outlined;
      default: return Icons.insert_drive_file_outlined;
    }
  }

  Color get _color {
    switch (content['tipo']) {
      case 'video': return AppColors.primary;
      case 'pdf': return Colors.red;
      case 'pptx': return Colors.orange;
      default: return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: _color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8)),
          child: Icon(_icon, color: _color, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content['titulo'] ?? '',
              style: const TextStyle(fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
            Text(content['materia'] ?? '',
              style: const TextStyle(fontSize: 11,
                color: AppColors.textSecondary)),
          ])),
        IconButton(
          icon: const Icon(Icons.delete_outline,
            color: Colors.red, size: 20),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('¿Eliminar contenido?'),
              content: const Text(
                'Esta acción no se puede deshacer.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red),
                  child: const Text('Eliminar')),
              ]))),
      ]),
    );
  }
}