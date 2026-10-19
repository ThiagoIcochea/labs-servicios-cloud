#!/usr/bin/env python3
"""Herramienta para armar las evidencias de un lab con la marca personal del alumno.

  python3 scripts/evidencias.py captura <alumno> <lab> <origen.jpg|png> <NN-descripcion> "<pie de foto>"
  python3 scripts/evidencias.py video   <alumno> <lab>      -> genera video-resumen.mp4 con todas las capturas
  python3 scripts/evidencias.py gif     <alumno> <lab> <nombre> <frame1> <frame2> ...  -> recorrido animado

Cada captura recibe una franja inferior con: nombre · código · curso/sección · lab · fecha,
y se registra su pie de foto en evidencias/<lab>/capturas.md.
"""
import datetime
import os
import subprocess
import sys
import tempfile
import zoneinfo

from PIL import Image, ImageDraw, ImageFont

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
AZUL = (26, 115, 232)
FUENTE = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
FUENTE_B = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"


def fuente(tam, negrita=False):
    try:
        return ImageFont.truetype(FUENTE_B if negrita else FUENTE, tam)
    except OSError:
        return ImageFont.load_default()


def alumno(slug):
    for linea in open(os.path.join(RAIZ, "config/alumnos.csv"), encoding="utf-8"):
        if linea.startswith(slug + ";"):
            _, pref, nombre, codigo, _ = (linea.rstrip("\n").split(";") + [""] * 5)[:5]
            return {"prefijo": pref, "nombre": nombre, "codigo": codigo or "sin código"}
    raise SystemExit(f"Alumno {slug} no encontrado")


def carpeta(slug, lab):
    d = os.path.join(RAIZ, "alumnos", slug, "evidencias", lab)
    os.makedirs(d, exist_ok=True)
    return d


def ahora():
    return datetime.datetime.now(zoneinfo.ZoneInfo("America/Lima")).strftime("%Y-%m-%d %H:%M")


def marcar(img, a, lab, pie):
    """Agrega una franja superior con el pie de foto y una inferior con la marca personal."""
    img = img.convert("RGB")
    w, h = img.size
    alto_sup, alto_inf = 46, 40
    lienzo = Image.new("RGB", (w, h + alto_sup + alto_inf), "white")
    lienzo.paste(img, (0, alto_sup))
    d = ImageDraw.Draw(lienzo)
    d.rectangle([0, 0, w, alto_sup], fill=(32, 33, 36))
    d.text((16, 11), pie, font=fuente(20, True), fill="white")
    d.rectangle([0, h + alto_sup, w, h + alto_sup + alto_inf], fill=AZUL)
    marca = f"{a['nombre']}  ·  {a['codigo']}  ·  Servicios Cloud - Sección 45104  ·  {lab}  ·  {ahora()}"
    d.text((16, h + alto_sup + 9), marca, font=fuente(18), fill="white")
    # sello en la esquina superior derecha
    sello = f"{a['codigo']}"
    tw = d.textlength(sello, font=fuente(18, True))
    d.rounded_rectangle([w - tw - 34, 8, w - 12, alto_sup - 8], radius=8, fill=AZUL)
    d.text((w - tw - 23, 12), sello, font=fuente(18, True), fill="white")
    return lienzo


def captura(slug, lab, origen, nombre, pie):
    a = alumno(slug)
    d = carpeta(slug, lab)
    destino = os.path.join(d, f"{nombre}.png")
    marcar(Image.open(origen), a, lab, pie).save(destino, optimize=True)
    with open(os.path.join(d, "capturas.md"), "a", encoding="utf-8") as f:
        f.write(f"{nombre}.png|{pie}\n")
    print(destino)


def portada(a, lab, titulo, w=1536, h=822):
    img = Image.new("RGB", (w, h), AZUL)
    d = ImageDraw.Draw(img)
    d.text((80, 200), titulo, font=fuente(52, True), fill="white")
    d.text((80, 300), a["nombre"], font=fuente(40), fill="white")
    d.text((80, 360), f"Código {a['codigo']}  ·  Servicios Cloud - Sección 45104", font=fuente(30), fill="white")
    d.text((80, 410), "Docente: Eleodoro Orbegoso Carrera  ·  UTP", font=fuente(26), fill=(220, 230, 255))
    d.text((80, 520), f"Google Cloud Engineering Certificate  ·  {lab}", font=fuente(26), fill=(220, 230, 255))
    d.text((80, 560), f"Video de evidencia generado el {ahora()}", font=fuente(22), fill=(200, 215, 255))
    return img


def video(slug, lab):
    a = alumno(slug)
    d = carpeta(slug, lab)
    idx = os.path.join(d, "capturas.md")
    capturas = [l.rstrip("\n").split("|", 1) for l in open(idx, encoding="utf-8")] if os.path.exists(idx) else []
    titulo = open(os.path.join(RAIZ, "labs", lab, "README.md"), encoding="utf-8").readline().strip("# \n")
    with tempfile.TemporaryDirectory() as tmp:
        W, H = 1536, 822
        portada(a, lab, titulo, W, H).save(f"{tmp}/000.png")
        n = 1
        vistos = set()
        for archivo, _ in capturas:
            if archivo in vistos or not os.path.exists(os.path.join(d, archivo)):
                continue
            vistos.add(archivo)
            im = Image.open(os.path.join(d, archivo)).convert("RGB")
            im.thumbnail((W, H))
            fondo = Image.new("RGB", (W, H), (32, 33, 36))
            fondo.paste(im, ((W - im.width) // 2, (H - im.height) // 2))
            fondo.save(f"{tmp}/{n:03d}.png")
            n += 1
        cierre = portada(a, lab, "Recursos eliminados al terminar", W, H)
        cierre.save(f"{tmp}/{n:03d}.png")
        salida = os.path.join(d, "video-resumen.mp4")
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-framerate", "1/4", "-i", f"{tmp}/%03d.png",
                        "-vf", "fps=25,format=yuv420p", "-c:v", "libx264", "-crf", "28", salida], check=True)
    print(salida)


def gif(slug, lab, nombre, frames):
    a = alumno(slug)
    d = carpeta(slug, lab)
    imgs = []
    for i, f in enumerate(frames):
        im = marcar(Image.open(f), a, lab, f"Recorrido en la consola · paso {i + 1} de {len(frames)}")
        im.thumbnail((1100, 1100))
        imgs.append(im.convert("P", palette=Image.Palette.ADAPTIVE, colors=128))
    salida = os.path.join(d, f"{nombre}.gif")
    imgs[0].save(salida, save_all=True, append_images=imgs[1:], duration=1800, loop=0, optimize=True)
    print(salida)


if __name__ == "__main__":
    accion = sys.argv[1]
    if accion == "captura":
        captura(*sys.argv[2:7])
    elif accion == "video":
        video(*sys.argv[2:4])
    elif accion == "gif":
        gif(sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5:])
    else:
        print(__doc__)
