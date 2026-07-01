class ReporteMascota {
  String? id;
  String usuarioId;
  String tipoReporte;
  String especie;
  String nombre;
  String descripcion;
  List<String> fotosUrl;
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
      },
      'ubicacion': {
        'localidad': localidad,
      },
      'estado': estado,
      'auditoria': {
        'fechaCreacion': fechaCreacion.toIso8601String(),
        'fechaActualizacion': fechaCreacion.toIso8601String(),
      }
    };
  }

  factory ReporteMascota.fromJson(Map<String, dynamic> json, String documentId) {
    return ReporteMascota(
      id: documentId,
      usuarioId: json['usuarioId'] ?? '',
      tipoReporte: json['tipoReporte'] ?? 'buscada',
      especie: json['mascota']['especie'] ?? 'Otro',
      nombre: json['mascota']['nombre'] ?? '',
      descripcion: json['mascota']['descripcion'] ?? '',
      fotosUrl: List<String>.from(json['mascota']['fotosUrl'] ?? []),
      localidad: json['ubicacion']['localidad'] ?? '',
      estado: json['estado'] ?? 'activo',
      fechaCreacion: DateTime.parse(json['auditoria']['fechaCreacion']),
    );
  }
}