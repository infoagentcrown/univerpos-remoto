// Univerpos Remoto: panel del técnico (identificación + conectar + recientes).
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../common.dart';
import '../../models/platform_model.dart';
import '../../univerpos.dart';

const String _kIdentity = 'univerpos-identity'; // "Nombre|Técnico · Nº 004"
const String _kDisplay = 'univerpos-display'; // identidad + "|tiquet" al conectar

const String _svgMonitor =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="12" rx="2" fill="none" stroke="#000" stroke-width="1.8"/><path d="M8 20h8M12 16v4" fill="none" stroke="#000" stroke-width="1.8" stroke-linecap="round"/></svg>';
const String _svgFolder =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" fill="none" stroke="#000" stroke-width="1.8" stroke-linejoin="round"/></svg>';
const String _svgOut =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M15 4h3a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-3M10 16l-4-4 4-4M6 12h10" fill="none" stroke="#000" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>';
const String _svgArrow =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M5 12h14M13 6l6 6-6 6" fill="none" stroke="#000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>';

Widget _icon(String svg, Color color, double size) => SvgPicture.string(svg,
    width: size,
    height: size,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn));

InputDecoration _inputDeco(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xffA3A3A3)),
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kUvLine)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kUvGreen, width: 1.5)),
    );

const TextStyle _label = TextStyle(color: kUvMuted, fontSize: 12);

class UvTechHome extends StatefulWidget {
  const UvTechHome({Key? key}) : super(key: key);

  @override
  State<UvTechHome> createState() => _UvTechHomeState();
}

class _UvTechHomeState extends State<UvTechHome> {
  final _name = TextEditingController();
  final _number = TextEditingController();
  final _peerId = TextEditingController();
  final _ticket = TextEditingController();
  String _identity = '';

  @override
  void initState() {
    super.initState();
    _identity = bind.mainGetLocalOption(key: _kIdentity);
    bind.mainLoadRecentPeers();
  }

  @override
  void dispose() {
    _name.dispose();
    _number.dispose();
    _peerId.dispose();
    _ticket.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final name = _name.text.trim();
    final number = _number.text.trim();
    if (name.isEmpty || number.isEmpty) return;
    final value = '$name|Técnico · Nº $number';
    await bind.mainSetLocalOption(key: _kIdentity, value: value);
    await bind.mainSetLocalOption(key: _kDisplay, value: value);
    setState(() => _identity = value);
  }

  Future<void> _logout() async {
    await bind.mainSetLocalOption(key: _kIdentity, value: '');
    await bind.mainSetLocalOption(key: _kDisplay, value: '');
    setState(() => _identity = '');
  }

  Future<void> _connect({bool files = false, String? id}) async {
    final target = (id ?? _peerId.text).replaceAll(' ', '').trim();
    if (target.isEmpty) return;
    final ticket = _ticket.text.trim();
    await bind.mainSetLocalOption(
        key: _kDisplay,
        value: ticket.isEmpty ? _identity : '$_identity|$ticket');
    if (!mounted) return;
    connect(context, target, isFileTransfer: files);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: _identity.isEmpty ? _buildLogin() : _buildPanel(),
    );
  }

  Widget _buildLogin() {
    return Center(
      child: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            uvSvg(kUvLogoSvg, 36),
            const SizedBox(height: 20),
            const Text('Iniciar sesión',
                style: TextStyle(
                    color: kUvInk, fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('El cliente verá tu nombre y tu número al conectarte.',
                style: TextStyle(color: kUvMuted, fontSize: 12.5)),
            const SizedBox(height: 22),
            const Text('Nombre y apellido', style: _label),
            const SizedBox(height: 6),
            TextField(
                controller: _name,
                decoration: _inputDeco('Abel Ruiz'),
                style: const TextStyle(color: kUvInk)),
            const SizedBox(height: 14),
            const Text('Nº de empleado', style: _label),
            const SizedBox(height: 6),
            TextField(
                controller: _number,
                decoration: _inputDeco('004'),
                style: const TextStyle(color: kUvInk),
                onSubmitted: (_) => _login()),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: TextButton(
                onPressed: _login,
                style: TextButton.styleFrom(
                  backgroundColor: kUvInk,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Entrar',
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanel() {
    final peer = UvPeer.parse(_identity, '');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 200,
          decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Color(0xffF0F0F0)))),
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                uvInitialsAvatar(peer.initials, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(peer.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: kUvInk,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        Text(peer.subtitle.replaceFirst('Técnico · ', ''),
                            style: const TextStyle(
                                color: kUvMuted, fontSize: 11.5)),
                      ]),
                ),
              ]).paddingOnly(left: 6, bottom: 20),
              _navItem(_svgMonitor, 'Conectar', true, () {}),
              _navItem(_svgFolder, 'Archivos', false,
                  () => _connect(files: true)),
              const Spacer(),
              _navItem(_svgOut, 'Salir', false, _logout),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 28, 30, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Número del cliente', style: _label),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _peerId,
                      decoration: _inputDeco('000 000 000'),
                      style: const TextStyle(
                          color: kUvInk, fontSize: 17, letterSpacing: 1),
                      onSubmitted: (_) => _connect(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: TextButton(
                      onPressed: () => _connect(),
                      style: TextButton.styleFrom(
                        backgroundColor: kUvGreen,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _icon(_svgArrow, Colors.white, 18),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                const Text.rich(TextSpan(children: [
                  TextSpan(text: 'Tiquet ', style: _label),
                  TextSpan(
                      text: '(opcional)',
                      style: TextStyle(color: Color(0xffA3A3A3), fontSize: 12)),
                ])),
                const SizedBox(height: 6),
                SizedBox(
                  width: 160,
                  child: TextField(
                      controller: _ticket,
                      decoration: _inputDeco('29308'),
                      style: const TextStyle(color: kUvInk)),
                ),
                const SizedBox(height: 28),
                const Text('Recientes', style: _label),
                const SizedBox(height: 6),
                Expanded(child: _buildRecents()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _navItem(String svg, String text, bool active, VoidCallback onTap) {
    final color = active ? kUvGreen : kUvMuted;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: active ? kUvGreenBg : null,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(children: [
            _icon(svg, color, 16),
            const SizedBox(width: 10),
            Text(text,
                style: TextStyle(
                    color: active ? kUvGreen : kUvMuted,
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w500 : FontWeight.w400)),
          ]),
        ),
      ),
    );
  }

  Widget _buildRecents() {
    final model = gFFI.recentPeersModel;
    return AnimatedBuilder(
      animation: model,
      builder: (context, _) {
        final peers = model.peers;
        if (peers.isEmpty) {
          return const Text('Todavía no hay conexiones.',
              style: TextStyle(color: Color(0xffA3A3A3), fontSize: 12.5));
        }
        return ListView.builder(
          itemCount: peers.length > 20 ? 20 : peers.length,
          itemBuilder: (context, i) {
            final p = peers[i];
            final title = p.alias.isNotEmpty
                ? p.alias
                : (p.hostname.isNotEmpty ? p.hostname : uvFormatId(p.id));
            return InkWell(
              onTap: () {
                _peerId.text = uvFormatId(p.id);
                _connect(id: p.id);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: const BoxDecoration(
                    border:
                        Border(top: BorderSide(color: Color(0xffF2F2F2)))),
                child: Row(children: [
                  Expanded(
                      child: Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              const TextStyle(color: kUvInk, fontSize: 13))),
                  Text(uvFormatId(p.id),
                      style: const TextStyle(color: kUvMuted, fontSize: 12)),
                ]),
              ),
            );
          },
        );
      },
    );
  }
}
