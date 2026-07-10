import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_colors.dart';

class AddReportScreen extends StatefulWidget {
  const AddReportScreen({super.key});

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _localidadController = TextEditingController();
  final _descripcionController = TextEditingController();

  String _tipoReporte = 'buscada';
  String _especie = 'Perro';
  bool _isLoading = false;

  XFile? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();

  Future<void> _seleccionarImagen() async {
    final XFile? imagen = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      imageQuality: 50,
    );
    if (imagen != null) {
      setState(() => _imagenSeleccionada = imagen);
    }
  }

  Future<void> _enviarReporteSeguro() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imagenSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una foto de la mascota.'),
        ),
      );
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      // (Base64)
      final bytes = await _imagenSeleccionada!.readAsBytes();
      final String base64Image = base64Encode(bytes);

      await FirebaseFirestore.instance.collection('publicaciones').add({
        'userId': currentUser.uid,
        'tipoReporte': _tipoReporte,
        'mascota': {
          'especie': _especie,
          'descripcion': _descripcionController.text.trim(),
          'fotoBase64': base64Image,
        },
        'ubicacion': {'localidad': _localidadController.text.trim()},
        'estado': 'activo',
        'fechaPublicacion': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reporte publicado con éxito'),
            backgroundColor: AppColors.found,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error de seguridad o imagen muy pesada.'),
            backgroundColor: AppColors.lost,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _localidadController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Crear Reporte',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información de la mascota',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('BUSCADA')),
                      selected: _tipoReporte == 'buscada',
                      selectedColor: AppColors.lost,
                      onSelected: (val) {
                        if (val) setState(() => _tipoReporte = 'buscada');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('ENCONTRADA')),
                      selected: _tipoReporte == 'encontrada',
                      selectedColor: AppColors.found,
                      onSelected: (val) {
                        if (val) setState(() => _tipoReporte = 'encontrada');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: _seleccionarImagen,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.textSecondary.withValues(alpha: 0.3),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _imagenSeleccionada == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 48,
                              color: AppColors.primary.withValues(alpha: 0.6),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Toca para subir foto',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        )
                      : kIsWeb
                      ? Image.network(
                          _imagenSeleccionada!.path,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(_imagenSeleccionada!.path),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: _especie,
                decoration: const InputDecoration(
                  labelText: 'Especie',
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                ),
                items: ['Perro', 'Gato', 'Ave', 'Conejo', 'Otro']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _especie = val);
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _localidadController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación / Localidad',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on, color: AppColors.primary),
                  fillColor: Colors.white,
                  filled: true,
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descripcionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripción y señas particulares',
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _enviarReporteSeguro,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Publicar Reporte',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
