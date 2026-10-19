"""Desafío Insignia 2: genera una miniatura 64x64 (con el nombre del alumno)
cuando se sube una imagen al bucket y publica un mensaje en Pub/Sub."""
import io
import json
import os

import functions_framework
from google.cloud import pubsub_v1, storage
from PIL import Image, ImageDraw

TOPICO = os.environ["TOPICO"]
NOMBRE = os.environ.get("NOMBRE", "")
storage_client = storage.Client()
publisher = pubsub_v1.PublisherClient()


@functions_framework.cloud_event
def crear_miniatura(evento):
    datos = evento.data
    bucket_nombre, archivo = datos["bucket"], datos["name"]
    if "_miniatura" in archivo or not archivo.lower().endswith((".png", ".jpg", ".jpeg")):
        print(f"Se ignora {archivo}")
        return
    bucket = storage_client.bucket(bucket_nombre)
    original = Image.open(io.BytesIO(bucket.blob(archivo).download_as_bytes())).convert("RGB")
    original.thumbnail((256, 256))
    lienzo = Image.new("RGB", (256, 296), "white")
    lienzo.paste(original, ((256 - original.width) // 2, 0))
    ImageDraw.Draw(lienzo).text((6, 262), NOMBRE[:40], fill="black")
    miniatura = lienzo.resize((64, 74))
    salida = io.BytesIO()
    miniatura.save(salida, format="PNG")
    base = archivo.rsplit(".", 1)[0]
    destino = f"{base}64x64_miniatura.png"
    bucket.blob(destino).upload_from_string(salida.getvalue(), content_type="image/png")
    mensaje = {"alumno": NOMBRE, "original": archivo, "miniatura": destino, "bucket": bucket_nombre}
    publisher.publish(TOPICO, json.dumps(mensaje, ensure_ascii=False).encode("utf-8")).result()
    print(json.dumps({"severity": "INFO", "message": f"Miniatura creada para {NOMBRE}: {destino}"}))
