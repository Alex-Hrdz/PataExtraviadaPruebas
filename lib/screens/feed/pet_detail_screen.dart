import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/reporte_mascota.dart';
import '../chat/chat_room_screen.dart';

class PetDetailScreen extends StatelessWidget {
  final ReporteMascota reporte;

  const PetDetailScreen({super.key, required this.reporte});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isMyReport = currentUserId == reporte.usuarioId;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          reporte.nombre.isNotEmpty ? reporte.nombre : 'Detalle de mascota',
        ),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reporte.fotoBase64 != null && reporte.fotoBase64!.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 300,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(
                      base64Decode(reporte.fotoBase64!),
                      fit: BoxFit.cover,
                    ),
                    ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    Image.memory(
                      base64Decode(reporte.fotoBase64!),
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 300,
                color: Colors.grey[300],
                child: const Icon(Icons.pets, size: 100, color: Colors.white),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reporte: ${reporte.tipoReporte == 'encontrada' ? 'RESCATADO' : 'SE BUSCA'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Especie: ${reporte.especie}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Localidad: ${reporte.localidad}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Descripción:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    reporte.descripcion,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  if (!isMyReport)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatRoomScreen(
                                receiverId: reporte.usuarioId,
                                receiverName: 'Contacto del reporte',
                                // --- NUEVO: Pasamos los datos del reporte al chat ---
                                reportId: reporte.id ?? 'sin_id',
                                tituloReporte: reporte.nombre.isNotEmpty
                                    ? reporte.nombre
                                    : reporte.especie,
                                fotoBase64Reporte: reporte.fotoBase64,
                                // ----------------------------------------------------
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat),
                        label: const Text('Contactar por Chat'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
