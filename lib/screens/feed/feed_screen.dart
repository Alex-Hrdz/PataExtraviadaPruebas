import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_colors.dart';
import 'add_report_screen.dart';
import 'dart:convert';
import '../profile/profile_screen.dart';
import 'pet_detail_screen.dart';
import '../../models/reporte_mascota.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.pets, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              'Pets Amber',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros (Se mantienen visuales por ahora)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  _FilterChip(label: 'Todos', selected: true),
                  _FilterChip(label: 'Perro', selected: false),
                  _FilterChip(label: 'Gato', selected: false),
                  _FilterChip(label: 'Ave', selected: false),
                  _FilterChip(label: 'Conejo', selected: false),
                  _FilterChip(label: 'Otro', selected: false),
                ],
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('publicaciones')
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
                    child: Text('Error al cargar las publicaciones.'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay reportes activos.\n¡Sé el primero en publicar!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                final reportes = snapshot.data!.docs;
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: reportes.length,
                  itemBuilder: (context, index) {
                    final data = reportes[index].data() as Map<String, dynamic>;

                    final mascota =
                        data['mascota'] as Map<String, dynamic>? ?? {};
                    final ubicacion =
                        data['ubicacion'] as Map<String, dynamic>? ?? {};

                    final reporteMascotaObj = ReporteMascota.fromJson(
                      data,
                      reportes[index].id,
                    );

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PetDetailScreen(reporte: reporteMascotaObj),
                          ),
                        );
                      },
                      child: _PetCard(
                        tipo: data['tipoReporte'] ?? 'se busca',
                        especie: mascota['especie'] ?? 'Desconocida',
                        localidad: ubicacion['localidad'] ?? 'Sin ubicación',
                        descripcion:
                            mascota['descripcion'] ?? 'Sin descripción',
                        fotoBase64: mascota['fotoBase64'],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navegación conectada hacia nuestra pantalla segura
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddReportScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Reportar', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

// =====================================================================
// WIDGETS AUXILIARES
// =====================================================================

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _FilterChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {},
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: selected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  final String tipo;
  final String especie;
  final String localidad;
  final String descripcion;
  final String? fotoBase64;

  const _PetCard({
    required this.tipo,
    required this.especie,
    required this.localidad,
    required this.descripcion,
    this.fotoBase64,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFound = tipo == 'encontrado';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: AppColors.background,
              child: fotoBase64 != null && fotoBase64!.isNotEmpty
                  ? Image.memory(
                      base64Decode(fotoBase64!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.broken_image,
                        size: 64,
                        color: AppColors.textSecondary.withValues(alpha: 0.3),
                      ),
                    )
                  : Icon(
                      Icons.pets,
                      size: 64,
                      color: AppColors.textSecondary.withValues(alpha: 0.3),
                    ),
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: isFound ? AppColors.found : AppColors.lost,
            child: Text(
              isFound ? 'ENCONTRADO' : 'SE BUSCA',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  especie,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  localidad,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  descripcion,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
