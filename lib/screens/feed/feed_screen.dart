import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

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
          // Filtros
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
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
          // Feed
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
              itemCount: 10,
              itemBuilder: (context, index) {
                return _PetCard(
                  tipo: index % 2 == 0 ? 'encontrada' : 'buscada',
                  especie: 'Perro',
                  localidad: 'Pachuca, Hidalgo',
                  descripcion: 'Labrador color café, sin collar',
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Reportar', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

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

  const _PetCard({
    required this.tipo,
    required this.especie,
    required this.localidad,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFound = tipo == 'encontrada';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen placeholder
          Expanded(
            child: Container(
              width: double.infinity,
              color: AppColors.background,
              child: Icon(
                Icons.pets,
                size: 64,
                color: AppColors.textSecondary.withOpacity(0.3),
              ),
            ),
          ),
          // Badge tipo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: isFound ? AppColors.found : AppColors.lost,
            child: Text(
              isFound ? 'ENCONTRADA' : 'BUSCADA',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Info
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
