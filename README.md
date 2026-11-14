# MediaFetch — yt-dlp + FFmpeg para Windows

Script interactivo `.bat` para descargar elementos individuales o playlists, convertir audio y organizar el resultado en carpetas por categoría y origen.

## 1. Dependencias

Coloca estos ejecutables:

- `yt-dlp.exe`
- `ffmpeg.exe`
- `ffprobe.exe`

El script busca `yt-dlp.exe` junto al BAT o en `PATH`. Para FFmpeg busca, en este orden:

1. `C:\ffmpeg\bin`
2. La carpeta del BAT
3. `PATH`

La ruta `C:\ffmpeg\bin` es la predeterminada, pero no es obligatoria si FFmpeg está disponible en otra ubicación.

Descargas oficiales:
- yt-dlp: https://github.com/yt-dlp/yt-dlp/releases/latest
- FFmpeg: https://ffmpeg.org/download.html

## 2. Estructura de salida

Por defecto guarda en `%USERPROFILE%\Downloads\Multimedia`. La estructura generada será similar a:

```text
Multimedia/
├── Musica/
│   └── Youtube/
│       └── Nombre-del-canal/
│           └── Nombre-de-playlist/
├── Videos/
│   └── Youtube/
│       └── Nombre-del-canal/
└── Peliculas/
    └── Youtube/
        └── Nombre-del-canal/
_archives/
├── Musica.txt
├── Videos.txt
└── Peliculas.txt
```

El nombre exacto de la carpeta de origen depende del extractor y de los metadatos que proporcione cada plataforma. Si el sitio no facilita el canal/uploader o el título de playlist, yt-dlp puede usar un valor genérico.

## 3. Perfiles y decisiones

1. **Categoría:** Música, Videos o Películas.
2. **Selección:** un elemento, playlist completa o elementos concretos.
3. **Velocidad:** 2, 4 u 8 fragmentos simultáneos.
4. **Cookies:** ninguna, Edge, Chrome o Firefox.
5. **Música:** MP3, Opus, M4A, FLAC o WAV; bitrate para formatos con pérdida.
6. **Video:** límite de resolución y perfil MP4/H.264 preferido o MKV con codecs disponibles.
7. **Subtítulos:** opcionalmente intenta descargar e incrustar subtítulos en español e inglés.

Ejemplo de selección de elementos de playlist:

```text
1,3,5-10
```

## 4. Metadatos y duplicados

El script activa:

- `--embed-metadata`: incrusta metadatos cuando el formato lo permite.
- `--embed-thumbnail`: incrusta la miniatura en los archivos de audio cuando es compatible.
- `--embed-chapters`: incrusta capítulos en video cuando están disponibles.
- `--write-info-json`: guarda un archivo JSON lateral con información de cada elemento.
- `--download-archive`: registra los identificadores descargados y evita volver a descargarlos en ejecuciones posteriores de la misma categoría.
- `--continue` y `--no-overwrites`: permite reanudar y evita sobrescribir archivos existentes.

## 5. MP4, MKV y códecs

El perfil MP4 usa el orden de selección de yt-dlp para priorizar H.264 y AAC cuando la plataforma ofrece esos formatos. Luego solicita a FFmpeg un remux a MP4.

El perfil MKV deja más libertad a la selección de formatos y remuxa a MKV. Suele ser la opción más tolerante con combinaciones de codecs.

**Importante:** remux significa cambiar el contenedor sin volver a codificar los flujos. No convierte VP9/AV1 a H.264 ni Opus a AAC. Si el codec de origen no es compatible con el contenedor elegido, el remux puede fallar. En ese caso, vuelve a ejecutar y selecciona MKV. Una recodificación real requiere elegir codecs de salida y consume bastante más CPU/tiempo.

Para música, `--audio-format` solicita a FFmpeg la conversión al formato elegido. Los bitrates 128/192/256/320 kb/s se ofrecen para MP3, Opus y M4A. FLAC y WAV se tratan como formatos sin pérdida/sin compresión y no reciben un bitrate objetivo.

## 6. Velocidad y estabilidad

- 2 fragmentos: perfil conservador para conexiones inestables.
- 4 fragmentos: perfil equilibrado recomendado.
- 8 fragmentos: más concurrencia; puede aumentar la carga o provocar límites del servidor.
- 10 reintentos generales y 10 de fragmentos.
- El archivo de archivo (`_archives`) evita trabajo repetido en descargas posteriores.

Más fragmentos no garantizan más velocidad: depende del servidor, la conexión y el tipo de streaming.

## 7. Cookies

Usa cookies solo para contenido al que tienes autorización de acceso. El script utiliza `--cookies-from-browser` y no exporta las cookies a un archivo. Si aparece un error al leer el almacén del navegador, cierra completamente ese navegador y vuelve a probar. No compartas cookies ni archivos de sesión.

## 8. Errores frecuentes

- **No encuentra yt-dlp:** coloca `yt-dlp.exe` junto al BAT o agrega su carpeta al `PATH`.
- **No encuentra FFmpeg:** comprueba que `ffmpeg.exe` y `ffprobe.exe` estén juntos en `C:\ffmpeg\bin`, junto al BAT o en `PATH`.
- **Falla el remux MP4:** vuelve a ejecutar con el perfil MKV. No todo codec cabe en todos los contenedores.
- **HTTP 403/429 o CAPTCHA:** comprueba el acceso desde el navegador, reduce la concurrencia y actualiza yt-dlp. No intentes eludir controles de acceso.
- **Falla la descarga de una playlist:** actualiza yt-dlp, comprueba que la playlist sea accesible y vuelve a ejecutar. El script usa `--ignore-errors` para continuar con otros elementos cuando uno falla.
- **Metadatos o miniatura no incrustados:** depende de las etiquetas que entregue la plataforma, del contenedor y de los componentes disponibles en la compilación de FFmpeg/yt-dlp.

Para actualizar el binario oficial de yt-dlp, ejecuta en una consola:

```bat
yt-dlp.exe -U
```

## 9. Uso responsable

Respeta los derechos de autor, las condiciones de la plataforma y las leyes aplicables. Descarga únicamente material que tengas derecho a guardar. El script no elimina DRM ni debe utilizarse para acceder a contenido restringido sin autorización.
