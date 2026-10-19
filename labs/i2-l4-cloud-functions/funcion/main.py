"""Cloud Function HTTP (2.ª gen) que responde con los datos del alumno."""
import datetime
import json
import os

import functions_framework


@functions_framework.http
def hola(request):
    datos = {
        "mensaje": f"Hola {request.args.get('nombre', 'mundo')} desde Cloud Functions",
        "alumno": os.environ.get("NOMBRE"),
        "codigo": os.environ.get("CODIGO"),
        "curso": os.environ.get("CURSO"),
        "seccion": os.environ.get("SECCION"),
        "docente": os.environ.get("DOCENTE"),
        "funcion": os.environ.get("K_SERVICE"),
        "hora_servidor_utc": datetime.datetime.utcnow().isoformat(timespec="seconds") + "Z",
    }
    print(json.dumps({"severity": "INFO", "message": f"Invocación del lab i2-l4 de {datos['alumno']}"}))
    return datos
