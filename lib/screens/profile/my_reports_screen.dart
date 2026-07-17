import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_colors.dart';
import '../feed/add_report_screen.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Mis Reportes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('publicaciones')
            .where('userId', isEqualTo: currentUserId)
            .orderBy('fechaPublicacion', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Error al cargar tus reportes.'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No has creado ningún reporte aún.'),
            );
          }

          final reportes = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reportes.length,
            itemBuilder: (context, index) {
              final doc = reportes[index];
              final data = doc.data() as Map<String, dynamic>;
              final mascota = data['mascota'] as Map<String, dynamic>? ?? {};
              final ubicacion = data['ubicacion'] as Map<String, dynamic>? ?? {};
              final fotoBase64 = mascota['fotoBase64'];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    ListTile(
                      leading: SizedBox(
                        width: 60,
                        height: 60,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: fotoBase64 != null && fotoBase64.isNotEmpty
                              ? Image.memory(
                                  base64Decode(fotoBase64),
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: AppColors.background,
                                  child: const Icon(
                                    Icons.pets,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                        ),
                      ),
                      title: Text(
                        mascota['especie'] ?? 'Desconocida',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        ubicacion['localidad'] ?? 'Sin ubicación',
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: data['tipoReporte'] == 'encontrada'
                              ? AppColors.found
                              : AppColors.lost,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          data['tipoReporte'] == 'encontrada'
                              ? 'ENCONTRADA'
                              : 'BUSCADA',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddReportScreen(
                                  reportId: doc.id,
                                  reportData: data,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.edit,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          label: const Text(
                            'Editar',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () => _confirmarEliminacion(
                            context,
                            doc.id,
                          ),
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AppColors.lost,
                          ),
                          label: const Text(
                            'Borrar',
                            style: TextStyle(color: AppColors.lost),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmarEliminacion(
    BuildContext context,
    String docId,
  ) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar reporte?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.lost),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseFirestore.instance
                    .collection('publicaciones')
                    .doc(docId)
                    .delete();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reporte eliminado'),
                      backgroundColor: AppColors.found,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error al eliminar'),
                      backgroundColor: AppColors.lost,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}