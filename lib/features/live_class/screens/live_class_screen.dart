import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LiveClassScreen extends StatefulWidget {
  const LiveClassScreen({super.key});
  @override
  State<LiveClassScreen> createState() => _LiveClassScreenState();
}

class _LiveClassScreenState extends State<LiveClassScreen> {
  bool _micOn      = true;
  bool _camOn      = true;
  bool _screenShare = false;
  bool _chatOpen   = false;
  bool _handRaised = false;
  int  _participants = 18;
  final List<Map<String, String>> _messages = [
    {'name': 'Valentina A.', 'msg': '¡Buenas profe! 👋', 'time': '9:02'},
    {'name': 'Carlos R.',    'msg': 'Ya entendí la fracción ✅', 'time': '9:05'},
    {'name': 'Luisa M.',     'msg': '¿Puede repetir el ejemplo?', 'time': '9:07'},
    {'name': 'Juan T.',      'msg': '¡Gracias profe! 🙌', 'time': '9:08'},
  ];
  final _chatCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(children: [

        // ── TOP BAR ──────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 10),
          color: const Color(0xFF111111),
          child: Row(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6)),
              child: const Icon(Icons.school,
                color: Colors.white, size: 16)),
            const SizedBox(width: 8),
            const Text('Aula Lid-IA',
              style: TextStyle(color: Colors.white,
                fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4)),
              child: const Row(children: [
                Icon(Icons.circle, size: 6, color: Colors.white),
                SizedBox(width: 4),
                Text('EN VIVO', style: TextStyle(
                  color: Colors.white, fontSize: 10,
                  fontWeight: FontWeight.w600)),
              ])),
            const SizedBox(width: 12),
            const Text('Matemáticas — Fracciones',
              style: TextStyle(color: Colors.white70,
                fontSize: 13)),
            const Spacer(),
            const Icon(Icons.people_outline,
              color: Colors.white54, size: 16),
            const SizedBox(width: 4),
            Text('$_participants participantes',
              style: const TextStyle(color: Colors.white54,
                fontSize: 12)),
            const SizedBox(width: 16),
            // Temporizador
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(6)),
              child: const Text('00:42:17',
                style: TextStyle(color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'monospace'))),
          ]),
        ),

        // ── CUERPO PRINCIPAL ──────────────────────────
        Expanded(child: Row(children: [

          // Área de video principal
          Expanded(child: Column(children: [

            // Video principal (docente)
            Expanded(child: Stack(children: [
              Container(
                width: double.infinity,
                color: const Color(0xFF2A2A2A),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Color(0xFF185FA5),
                      child: Text('MP',
                        style: TextStyle(fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.w500))),
                    SizedBox(height: 12),
                    Text('Prof. Mariela Prado',
                      style: TextStyle(color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
                    SizedBox(height: 4),
                    Text('Cámara apagada',
                      style: TextStyle(color: Colors.white38,
                        fontSize: 12)),
                  ])),

              // Nombre abajo izquierda
              Positioned(
                bottom: 12, left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6)),
                  child: const Text('Prof. Mariela Prado',
                    style: TextStyle(color: Colors.white,
                      fontSize: 11)))),

              // Miniatura propia (esquina)
              Positioned(
                bottom: 12, right: 12,
                child: Container(
                  width: 120, height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary, width: 1.5)),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.studentColor,
                        child: Text('VA',
                          style: TextStyle(fontSize: 12,
                            color: AppColors.primaryDark))),
                      SizedBox(height: 4),
                      Text('Tú', style: TextStyle(
                        color: Colors.white70, fontSize: 10)),
                    ]))),
            ])),

            // Grid de participantes
            Container(
              height: 90,
              color: const Color(0xFF111111),
              padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _ParticipantThumb(initials: 'CR',
                    name: 'Carlos R.',
                    color: const Color(0xFFB5D4F4),
                    textColor: const Color(0xFF185FA5)),
                  _ParticipantThumb(initials: 'LM',
                    name: 'Luisa M.',
                    color: const Color(0xFFEEEDFE),
                    textColor: const Color(0xFF534AB7)),
                  _ParticipantThumb(initials: 'JT',
                    name: 'Juan T.',
                    color: const Color(0xFFFAEEDA),
                    textColor: const Color(0xFF633806)),
                  _ParticipantThumb(initials: 'SR',
                    name: 'Sara R.',
                    color: const Color(0xFFFAECE7),
                    textColor: const Color(0xFF993C1D)),
                  _ParticipantThumb(initials: 'DG',
                    name: 'Diego G.',
                    color: const Color(0xFFE1F5EE),
                    textColor: AppColors.primaryDark),
                  _ParticipantThumb(initials: '+13',
                    name: 'más',
                    color: Colors.white12,
                    textColor: Colors.white54),
                ],
              ),
            ),
          ])),

          // ── PANEL DE CHAT ─────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: _chatOpen ? 280 : 0,
            color: const Color(0xFF111111),
            child: _chatOpen
              ? Column(children: [

                  // Header chat
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.white12))),
                    child: const Row(children: [
                      Icon(Icons.chat_outlined,
                        color: Colors.white70, size: 16),
                      SizedBox(width: 8),
                      Text('Chat de clase',
                        style: TextStyle(color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                    ])),

                  // Mensajes
                  Expanded(child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final m = _messages[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text(m['name']!,
                                style: const TextStyle(
                                  color: AppColors.primaryLight,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500)),
                              const Spacer(),
                              Text(m['time']!,
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10)),
                            ]),
                            const SizedBox(height: 2),
                            Text(m['msg']!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12)),
                          ]));
                    })),

                  // Input chat
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.white12))),
                    child: Row(children: [
                      Expanded(child: TextField(
                        controller: _chatCtrl,
                        style: const TextStyle(
                          color: Colors.white, fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Escribe un mensaje...',
                          hintStyle: const TextStyle(
                            color: Colors.white38, fontSize: 12),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8)),
                      )),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          if (_chatCtrl.text.isNotEmpty) {
                            setState(() {
                              _messages.add({
                                'name': 'Tú',
                                'msg': _chatCtrl.text,
                                'time': '9:10',
                              });
                              _chatCtrl.clear();
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.send,
                            color: Colors.white, size: 16))),
                    ])),
                ])
              : null,
          ),
        ])),

        // ── BARRA DE CONTROLES ────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24, vertical: 14),
          color: const Color(0xFF111111),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              _ControlBtn(
                icon: _micOn
                  ? Icons.mic_outlined
                  : Icons.mic_off_outlined,
                label: _micOn ? 'Micrófono' : 'Silenciado',
                active: _micOn,
                onTap: () => setState(() => _micOn = !_micOn)),

              const SizedBox(width: 12),

              _ControlBtn(
                icon: _camOn
                  ? Icons.videocam_outlined
                  : Icons.videocam_off_outlined,
                label: _camOn ? 'Cámara' : 'Cam. apagada',
                active: _camOn,
                onTap: () => setState(() => _camOn = !_camOn)),

              const SizedBox(width: 12),

              _ControlBtn(
                icon: Icons.screen_share_outlined,
                label: 'Compartir',
                active: _screenShare,
                onTap: () =>
                  setState(() => _screenShare = !_screenShare)),

              const SizedBox(width: 12),

              _ControlBtn(
                icon: Icons.pan_tool_outlined,
                label: 'Levantar mano',
                active: _handRaised,
                onTap: () =>
                  setState(() => _handRaised = !_handRaised)),

              const SizedBox(width: 12),

              _ControlBtn(
                icon: Icons.chat_outlined,
                label: 'Chat',
                active: _chatOpen,
                onTap: () =>
                  setState(() => _chatOpen = !_chatOpen)),

              const SizedBox(width: 24),

              // Botón terminar
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8)),
                  child: const Row(children: [
                    Icon(Icons.call_end,
                      color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text('Terminar',
                      style: TextStyle(color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                  ]))),
            ]),
        ),
      ]),
    );
  }
}

// ── WIDGETS ───────────────────────────────────────────

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ControlBtn({required this.icon, required this.label,
    required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: active
              ? Colors.white12
              : Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10)),
          child: Icon(icon,
            color: active ? Colors.white : Colors.red,
            size: 20)),
        const SizedBox(height: 4),
        Text(label,
          style: const TextStyle(color: Colors.white54,
            fontSize: 10)),
      ]),
    );
  }
}

class _ParticipantThumb extends StatelessWidget {
  final String initials;
  final String name;
  final Color color;
  final Color textColor;
  const _ParticipantThumb({required this.initials,
    required this.name, required this.color,
    required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color,
            child: Text(initials,
              style: TextStyle(fontSize: 11,
                fontWeight: FontWeight.w500,
                color: textColor))),
          const SizedBox(height: 4),
          Text(name,
            style: const TextStyle(color: Colors.white60,
              fontSize: 9),
            overflow: TextOverflow.ellipsis),
        ]),
    );
  }
}