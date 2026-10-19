# Insignia 2 · Lab 5 — Pub/Sub (línea de comandos)

**Equivale a:** *Google Cloud Pub/Sub: Qwik Start - Command Line* (opción 2 del Lab 5).

## Qué hace
1. Crea los tópicos `<prefijo>-i2l5-topico` y `<prefijo>-i2l5-temporal`, los lista y borra el temporal.
2. Crea la suscripción pull `<prefijo>-i2l5-suscripcion`.
3. Publica 4 mensajes con **tu nombre, curso, sección, docente y la hora**.
4. Lee 1 mensaje y luego el resto con `--limit`, mostrando el texto decodificado.

## Ejecutar
```bash
./lab <alumno> i2-l5 up
./lab <alumno> i2-l5 down
```

## Evidencias que debes capturar
- [ ] La tabla final con los mensajes leídos (tu nombre en la columna MENSAJE).
- [ ] **Pub/Sub → Temas** mostrando tu tópico y su suscripción.

## Costo
Dentro del nivel gratuito ≈ **US$ 0.00**.
