// Univerpos Remoto: colores, iconos SVG y piezas de interfaz propias.
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

const Color kUvGreen = Color(0xff1E6A38);
const Color kUvGreenBg = Color(0xffEDF5EF);
const Color kUvGreenLine = Color(0xffB9D6C1);
const Color kUvInk = Color(0xff0A0A0A);
const Color kUvMuted = Color(0xff737373);
const Color kUvLine = Color(0xffE5E5E5);

const String kUvLogoSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><rect width="24" height="24" rx="6" fill="#0A0A0A"/><path d="M8 7v6a4 4 0 0 0 8 0V7" fill="none" stroke="#fff" stroke-width="2.2" stroke-linecap="round"/></svg>';
const String kUvCheckSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10" fill="#1E6A38"/><path d="M7.5 12.3l3 3 6-6.3" fill="none" stroke="#fff" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/></svg>';
const String kUvCopySvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><rect x="9" y="9" width="11" height="11" rx="2" fill="none" stroke="#737373" stroke-width="1.8"/><path d="M5 15V6a2 2 0 0 1 2-2h8" fill="none" stroke="#737373" stroke-width="1.8" stroke-linecap="round"/></svg>';

Widget uvSvg(String svg, double size) =>
    SvgPicture.string(svg, width: size, height: size);

/// Datos del técnico que llegan en el nombre de la conexión.
/// Formato: "Nombre Apellido|Técnico · Nº 004". Sin "|" no está identificado.
class UvPeer {
  final String name;
  final String subtitle;
  final String ticket;
  final bool verified;
  UvPeer(this.name, this.subtitle, this.ticket, this.verified);

  /// Formato: "Nombre Apellido|Técnico · Nº 004|29308" (tiquet opcional).
  factory UvPeer.parse(String raw, String peerId) {
    final parts = raw.split('|').map((e) => e.trim()).toList();
    if (parts.length >= 2 && parts[0].isNotEmpty) {
      return UvPeer(parts[0], parts[1], parts.length > 2 ? parts[2] : '', true);
    }
    return UvPeer(raw.trim().isEmpty ? 'Desconocido' : raw.trim(),
        'Equipo $peerId', '', false);
  }

  String get initials {
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

Widget uvInitialsAvatar(String initials, {double size = 44}) => Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: kUvGreenBg,
        shape: BoxShape.circle,
        border: Border.all(color: kUvGreenLine, width: 1.5),
      ),
      child: Text(initials,
          style: TextStyle(
              color: kUvGreen,
              fontWeight: FontWeight.w600,
              fontSize: size * 0.34)),
    );

Widget uvVerifiedPill() => Container(
      padding: const EdgeInsets.fromLTRB(6, 5, 10, 5),
      decoration: BoxDecoration(
          color: kUvGreenBg, borderRadius: BorderRadius.circular(99)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        uvSvg(kUvCheckSvg, 15),
        const SizedBox(width: 6),
        const Text('Identificado por Univerpos',
            style: TextStyle(
                color: kUvGreen, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );

String uvFormatId(String id) {
  final clean = id.replaceAll(' ', '');
  if (clean.length < 7 || int.tryParse(clean) == null) return id;
  final b = StringBuffer();
  for (var i = 0; i < clean.length; i++) {
    if (i > 0 && (clean.length - i) % 3 == 0) b.write(' ');
    b.write(clean[i]);
  }
  return b.toString();
}

/// Ventana principal del cliente: logo, número de soporte y botón copiar.
class UvClientIdCard extends StatelessWidget {
  final TextEditingController serverId;
  const UvClientIdCard({Key? key, required this.serverId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 22),
      child: Column(
        children: [
          uvSvg(kUvLogoSvg, 40),
          const SizedBox(height: 20),
          const Text('Su número de soporte',
              style: TextStyle(color: kUvMuted, fontSize: 12)),
          const SizedBox(height: 6),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: serverId,
            builder: (context, value, _) => FittedBox(
              fit: BoxFit.scaleDown,
              child: SelectableText(
                uvFormatId(value.text),
                style: const TextStyle(
                    color: kUvInk,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    fontFeatures: [FontFeature.tabularFigures()]),
              ),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () {
              Clipboard.setData(
                  ClipboardData(text: serverId.text.replaceAll(' ', '')));
              ScaffoldMessenger.maybeOf(context)?.showSnackBar(const SnackBar(
                  content: Text('Copiado'), duration: Duration(seconds: 1)));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                uvSvg(kUvCopySvg, 14),
                const SizedBox(width: 6),
                const Text('Copiar',
                    style: TextStyle(color: kUvMuted, fontSize: 12)),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Díganos este número por teléfono.\nNadie entra sin su permiso.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kUvMuted, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

/// Aviso discreto para instalar (sustituye al recuadro rosa de RustDesk).
Widget uvInstallHint(VoidCallback onPressed) => Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kUvGreenBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          const Text(
            'Instale Univerpos para que el técnico pueda ayudarle también con las ventanas de administrador.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kUvGreen, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                backgroundColor: kUvGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Instalar',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
