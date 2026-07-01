from firebase_functions import https_fn
from firebase_admin import initialize_app, firestore
import re

# Inicializa el SDK de administración de Firebase
initialize_app()
FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001)

def sanitizar_texto(texto):
    if not isinstance(texto, str):
        return ""
    texto_limpio = re.sub(r'<[^>]*>', '', texto)
    return texto_limpio.strip()

@https_fn.on_call()
def crear_reporte_seguro(req: https_fn.CallableRequest) -> dict:
    # 1. Validación de Autenticación (Mitiga Spoofing)
    if req.auth is None:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.UNAUTHENTICATED,
            message="El usuario debe estar autenticado para crear un reporte."
        )
    
    datos = req.data
    
    # 2. Validación mediante Listas Blancas
    especies_permitidas = ['Perro', 'Gato', 'Ave', 'Conejo', 'Otro']
    tipos_permitidos = ['buscada', 'encontrada']
    
    especie_recibida = datos.get('mascota', {}).get('especie', '')
    tipo_recibido = datos.get('tipoReporte', '')
    
    if especie_recibida not in especies_permitidas:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
            message="Especie no permitida por el sistema."
        )
        
    if tipo_recibido not in tipos_permitidos:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
            message="Tipo de reporte no válido."
        )

    # 3. Sanitización de Entradas (Mitiga Tampering / Inyección XSS)
    descripcion_limpia = sanitizar_texto(datos.get('mascota', {}).get('descripcion', ''))
    nombre_limpio = sanitizar_texto(datos.get('mascota', {}).get('nombre', ''))
    localidad_limpia = sanitizar_texto(datos.get('ubicacion', {}).get('localidad', ''))

    # 4. Construcción del objeto seguro (Se usa el UID del token, no del cliente)
    db = firestore.client()
    nuevo_reporte = {
        "usuarioId": req.auth.uid, 
        "tipoReporte": tipo_recibido,
        "mascota": {
            "especie": especie_recibida,
            "nombre": nombre_limpio,
            "descripcion": descripcion_limpia,
            "fotosUrl": datos.get('mascota', {}).get('fotosUrl', [])
        },
        "ubicacion": {
            "localidad": localidad_limpia,
        },
        "estado": "activo",
        "auditoria": {
            "fechaCreacion": firestore.SERVER_TIMESTAMP,
            "fechaActualizacion": firestore.SERVER_TIMESTAMP,
        }
    }

    # 5. Guardado exclusivo en Firestore desde el servidor
    _, doc_ref = db.collection("reportes_mascotas").add(nuevo_reporte)

    return {"mensaje": "Reporte limpio y guardado con éxito", "id": doc_ref.id}

