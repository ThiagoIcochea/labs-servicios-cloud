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


SENSIBLE = ("thicorodrig", "@hotmail", "@gmail", "gmail.com", "hotmail.com", "eduko500", "ceggax96")


def _difuminar(img, caja, radio=9):
    from PIL import ImageFilter
    x0, y0, x1, y1 = [int(v) for v in caja]
    x0, y0 = max(0, x0), max(0, y0)
    x1, y1 = min(img.width, x1), min(img.height, y1)
    if x1 > x0 and y1 > y0:
        img.paste(img.crop((x0, y0, x1, y1)).filter(ImageFilter.GaussianBlur(radio)), (x0, y0))


def privacidad(img):
    """Difumina el avatar (ícono con la inicial) de la cuenta en la barra superior."""
    w, h = img.size
    # 1) Avatar: círculo morado en la barra superior
    px = img.load()
    pts = [(x, y) for y in range(0, min(60, h)) for x in range(w)
           if px[x, y][0] > 120 and px[x, y][1] < 90 and px[x, y][2] > 140]
    if len(pts) > 80:
        xs, ys = [p[0] for p in pts], [p[1] for p in pts]
        _difuminar(img, (min(xs) - 8, min(ys) - 8, max(xs) + 8, max(ys) + 8), 12)
    return img


def hora_de(archivo):
    """Hora exacta en que se tomó la captura (fecha de modificación del archivo original)."""
    t = datetime.datetime.fromtimestamp(os.path.getmtime(archivo), zoneinfo.ZoneInfo("America/Lima"))
    return t.strftime("%d/%m/%Y %H:%M:%S")


def marcar(img, a, lab, pie, hora=None):
    """Agrega una franja superior con el pie de foto y una inferior con los datos del alumno y la hora."""
    img = img.convert("RGB")
    w, h = img.size
    img = privacidad(img)
    alto_sup, alto_inf = 46, 66
    lienzo = Image.new("RGB", (w, h + alto_sup + alto_inf), "white")
    lienzo.paste(img, (0, alto_sup))
    d = ImageDraw.Draw(lienzo)
    d.rectangle([0, 0, w, alto_sup], fill=(32, 33, 36))
    d.text((16, 11), pie, font=fuente(20, True), fill="white")
    y0 = h + alto_sup
    d.rectangle([0, y0, w, y0 + alto_inf], fill=AZUL)
    # Fila 1: datos del alumno · Fila 2: lab y fecha/hora exacta de la captura
    d.text((16, y0 + 8), f"{a['nombre']}  ·  Código {a['codigo']}  ·  Servicios Cloud - Sección 45104",
           font=fuente(18, True), fill="white")
    d.text((16, y0 + 37), f"Lab: {lab}", font=fuente(16), fill=(220, 230, 255))
    reloj = f"Fecha y hora: {hora or ahora()} (Lima)"
    rw = d.textlength(reloj, font=fuente(16, True))
    d.text((w - rw - 16, y0 + 37), reloj, font=fuente(16, True), fill="white")
    return lienzo


def captura(slug, lab, origen, nombre, pie):
    a = alumno(slug)
    d = carpeta(slug, lab)
    destino = os.path.join(d, f"{nombre}.png")
    hora = hora_de(origen)
    marcar(Image.open(origen), a, lab, pie, hora).save(destino, optimize=True)
    idx = os.path.join(d, "capturas.md")
    previas = [l for l in open(idx, encoding="utf-8")] if os.path.exists(idx) else []
    previas = [l for l in previas if not l.startswith(f"{nombre}.png|")]
    previas.append(f"{nombre}.png|{pie}|{hora}|{os.path.abspath(origen)}\n")
    open(idx, "w", encoding="utf-8").writelines(sorted(previas))
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
    capturas = [l.rstrip("\n").split("|") for l in open(idx, encoding="utf-8")] if os.path.exists(idx) else []
    titulo = open(os.path.join(RAIZ, "labs", lab, "README.md"), encoding="utf-8").readline().strip("# \n")
    with tempfile.TemporaryDirectory() as tmp:
        W, H = 1536, 822
        portada(a, lab, titulo, W, H).save(f"{tmp}/000.png")
        n = 1
        vistos = set()
        for archivo, *_ in capturas:
            if archivo in vistos or not os.path.exists(os.path.join(d, archivo)):
                continue
            vistos.add(archivo)
            im = Image.open(os.path.join(d, archivo)).convert("RGB")
            im.thumbnail((W, H))
            fondo = Image.new("RGB", (W, H), (32, 33, 36))
            fondo.paste(im, ((W - im.width) // 2, (H - im.height) // 2))
            fondo.save(f"{tmp}/{n:03d}.png")
            n += 1
        salida = os.path.join(d, "video-resumen.mp4")
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-framerate", "1/4", "-i", f"{tmp}/%03d.png",
                        "-vf", "fps=25,format=yuv420p", "-c:v", "libx264", "-crf", "28", salida], check=True)
    print(salida)


def gif(slug, lab, nombre, frames):
    a = alumno(slug)
    d = carpeta(slug, lab)
    imgs = []
    for i, f in enumerate(frames):
        im = marcar(Image.open(f), a, lab, f"Recorrido en la consola · paso {i + 1} de {len(frames)}", hora_de(f))
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
