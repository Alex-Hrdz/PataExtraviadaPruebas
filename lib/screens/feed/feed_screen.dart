import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_colors.dart';
import 'add_report_screen.dart';

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
              'PataExtraviada',
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
          
          // Feed en Tiempo Real
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Escuchamos la colección 'publicaciones' ordenada por fecha de publicación (los más nuevos primero)
              stream: FirebaseFirestore.instance
                  .collection('publicaciones')
                  .orderBy('fechaPublicacion', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // 1. Mientras carga la petición
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                // 2. Si ocurre algún error de conexión o de permisos
                if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar las publicaciones.'));
                }

                // 3. Si la base de datos está vacía
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay reportes activos.\n¡Sé el primero en publicar!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                // 4. Extraemos los documentos de la base de datos
                final reportes = snapshot.data!.docs;

                // 5. Construimos el GridView dinámico
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
                    // Convertimos el documento de Firestore a un mapa de Dart
                    final data = reportes[index].data() as Map<String, dynamic>;
                    
                    // Extraemos los mapas anidados con seguridad por si falta algún dato
                    final mascota = data['mascota'] as Map<String, dynamic>? ?? {};
                    final ubicacion = data['ubicacion'] as Map<String, dynamic>? ?? {};
                    final fotos = mascota['fotosUrl'] as List<dynamic>? ?? [];

                    return _PetCard(
                      tipo: data['tipoReporte'] ?? 'buscada',
                      especie: mascota['especie'] ?? 'Desconocida',
                      localidad: ubicacion['localidad'] ?? 'Sin ubicación',
                      descripcion: mascota['descripcion'] ?? 'Sin descripción',
                      fotoUrl: fotos.isNotEmpty ? fotos.first.toString() : null,
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
            MaterialPageRoute(
              builder: (context) => const AddReportScreen(),
            ),
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
        selectedColor: AppColors.primary.withOpacity(0.2),
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
  final String? fotoUrl; // Agregamos la URL

  const _PetCard({
    required this.tipo,
    required this.especie,
    required this.localidad,
    required this.descripcion,
    this.fotoUrl, // Hacemos que sea opcional
  });

  @override
  Widget build(BuildContext context) {
    final bool isFound = tipo == 'encontrada';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen dinámica desde Firebase Storage
          Expanded(
            child: Container(
              width: double.infinity,
              color: AppColors.background,
              child: fotoUrl != null && fotoUrl!.isNotEmpty
                  ? Image.network(
                      fotoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                          Icon(Icons.broken_image, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
                    )
                  : Icon(Icons.pets, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
            ),
          ),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: isFound ? AppColors.found : AppColors.lost,
            child: Text(
              isFound ? 'ENCONTRADA' : 'BUSCADA',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(especie, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14)),
                const SizedBox(height: 2),
                Text(localidad, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(descripcion, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}