import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:ui'; // <-- Necesario para el efecto visual de desenfoque
import '../../models/reporte_mascota.dart';
import '../chat/chat_room_screen.dart';

class PetDetailScreen extends StatelessWidget {
  final ReporteMascota reporte;

  const PetDetailScreen({super.key, required this.reporte});

  @override
  Widget build(BuildContext context) {
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
                    // 1. Imagen de fondo estirada para llenar los huecos
                    Image.memory(
                      base64Decode(reporte.fotoBase64!),
                      fit: BoxFit.cover,
                    ),
                    // 2. Filtro de desenfoque elegante con un toque oscuro
                    ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                        child: Container(color: Colors.black.withOpacity(0.4)),
                      ),
                    ),
                    // 3. Imagen original completa al frente
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
                    'Descripción',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    reporte.descripcion,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatRoomScreen(
                              userName: 'Usuario Contacto',
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
