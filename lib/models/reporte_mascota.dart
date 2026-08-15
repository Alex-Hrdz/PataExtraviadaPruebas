class ReporteMascota {
  String? id;
  String usuarioId;
  String tipoReporte;
  String especie;
  String nombre;
  String descripcion;
  List<String> fotosUrl;
  String? fotoBase64; // <--- Agregamos el campo de tu compañero
  String localidad;
  String estado;
  DateTime fechaCreacion;

  ReporteMascota({
    this.id,
    required this.usuarioId,
    required this.tipoReporte,
    required this.especie,
    this.nombre = '',
    required this.descripcion,
    this.fotosUrl = const [],
    this.fotoBase64,
    required this.localidad,
    this.estado = 'activo',
    required this.fechaCreacion,
  });

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'tipoReporte': tipoReporte,
      'mascota': {
        'especie': especie,
        'nombre': nombre,
        'descripcion': descripcion,
        'fotosUrl': fotosUrl,
        'fotoBase64': fotoBase64, // <--- Lo guardamos en Firebase
      },
      'ubicacion': {'localidad': localidad},
      'estado': estado,
      'auditoria': {
        'fechaCreacion': fechaCreacion.toIso8601String(),
        'fechaActualizacion': fechaCreacion.toIso8601String(),
      },
    };
  }

  factory ReporteMascota.fromJson(
    Map<String, dynamic> json,
    String documentId,
  ) {
    final mascota = json['mascota'] as Map<String, dynamic>? ?? {};
    final ubicacion = json['ubicacion'] as Map<String, dynamic>? ?? {};
    final auditoria = json['auditoria'] as Map<String, dynamic>? ?? {};

    DateTime parsedDate = DateTime.now();
    if (auditoria['fechaCreacion'] != null) {
      try {
        parsedDate = DateTime.parse(auditoria['fechaCreacion'].toString());
      } catch (e) {}
    }

    return ReporteMascota(
      id: documentId,
      usuarioId: json['usuarioId'] ?? '',
      tipoReporte: json['tipoReporte'] ?? 'buscada',
      especie: mascota['especie'] ?? 'Otro',
      nombre: mascota['nombre'] ?? '',
      descripcion: mascota['descripcion'] ?? '',
      fotosUrl: mascota['fotosUrl'] != null
          ? List<String>.from(mascota['fotosUrl'])
          : [],
      fotoBase64: mascota['fotoBase64'], // <--- Lo leemos de Firebase
      localidad: ubicacion['localidad'] ?? '',
      estado: json['estado'] ?? 'activo',
      fechaCreacion: parsedDate,
    );
  }
}
