@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul
title MediaFetch - yt-dlp + FFmpeg

rem ============================================================
rem MediaFetch: descarga multimedia con yt-dlp y FFmpeg.
rem Requiere yt-dlp.exe, ffmpeg.exe y ffprobe.exe.
rem No modifica los archivos originales ni exporta cookies.
rem ============================================================

set "SCRIPT_DIR=%~dp0"
set "YTDLP=%SCRIPT_DIR%yt-dlp.exe"

if not exist "%YTDLP%" set "YTDLP=yt-dlp.exe"
"%YTDLP%" --version >nul 2>&1
if errorlevel 1 goto MISSING_YTDLP

rem Ruta solicitada/preferida. Si no existe, busca junto al BAT y en PATH.
set "FFMPEG_DIR=C:\ffmpeg\bin"
if exist "%FFMPEG_DIR%\ffmpeg.exe" if exist "%FFMPEG_DIR%\ffprobe.exe" goto FFMPEG_OK

set "FFMPEG_DIR=%SCRIPT_DIR%"
if exist "%FFMPEG_DIR%\ffmpeg.exe" if exist "%FFMPEG_DIR%\ffprobe.exe" goto FFMPEG_OK

set "FFMPEG_PATH="
for /f "delims=" %%I in ('where ffmpeg.exe 2^>nul') do if not defined FFMPEG_PATH set "FFMPEG_PATH=%%I"
if defined FFMPEG_PATH for %%I in ("%FFMPEG_PATH%") do set "FFMPEG_DIR=%%~dpI"
if exist "%FFMPEG_DIR%\ffmpeg.exe" if exist "%FFMPEG_DIR%\ffprobe.exe" goto FFMPEG_OK

goto MISSING_FFMPEG

:FFMPEG_OK
echo.
echo ============================================================
echo  MEDIAFETCH - yt-dlp + FFmpeg
echo ============================================================
echo yt-dlp:  OK
echo FFmpeg:  "%FFMPEG_DIR%"
echo.
echo Destino predeterminado:
set "ROOT=%USERPROFILE%\Downloads\Multimedia"
echo "%ROOT%"
set "ROOT_INPUT="
set /p "ROOT_INPUT=Carpeta raiz alternativa (Enter = predeterminada): "
if defined ROOT_INPUT set "ROOT=%ROOT_INPUT%"

echo.
echo [1] Musica
echo [2] Videos
echo [3] Peliculas
set "CAT="
set /p "CAT=Categoria de descarga: "
if "%CAT%"=="1" set "CATEGORY=Musica"
if "%CAT%"=="2" set "CATEGORY=Videos"
if "%CAT%"=="3" set "CATEGORY=Peliculas"
if not defined CATEGORY goto INVALID_CATEGORY

set "DEST=%ROOT%\%CATEGORY%"
set "ARCHIVE_DIR=%ROOT%\_archives"
set "ARCHIVE=%ARCHIVE_DIR%\%CATEGORY%.txt"
md "%DEST%" 2>nul
md "%ARCHIVE_DIR%" 2>nul

echo.
echo [1] Un solo elemento (ignora la playlist si la URL la contiene)
echo [2] Playlist completa
echo [3] Seleccionar elementos de una playlist
set "MODE="
set /p "MODE=Modo de descarga: "

set "PLAYLIST_ARGS=--no-playlist"
set "OUT_TEMPLATE=%%(extractor_key)s\%%(uploader)s\%%(title)s [%%(id)s].%%(ext)s"

if "%MODE%"=="1" goto MODE_READY
if "%MODE%"=="2" goto MODE_ALL
if "%MODE%"=="3" goto MODE_ITEMS
goto INVALID_MODE

:MODE_ALL
set "PLAYLIST_ARGS=--yes-playlist"
set "OUT_TEMPLATE=%%(extractor_key)s\%%(uploader)s\%%(playlist_title)s\%%(playlist_index)03d - %%(title)s [%%(id)s].%%(ext)s"
goto MODE_READY

:MODE_ITEMS
set "ITEMS="
set /p "ITEMS=Elementos (ejemplo 1,3,5-10): "
if not defined ITEMS goto INVALID_ITEMS
set "PLAYLIST_ARGS=--yes-playlist --playlist-items %ITEMS%"
set "OUT_TEMPLATE=%%(extractor_key)s\%%(uploader)s\%%(playlist_title)s\%%(playlist_index)03d - %%(title)s [%%(id)s].%%(ext)s"
goto MODE_READY

:MODE_READY
echo.
set "URL="
set /p "URL=Pega la URL del video o playlist: "
if not defined URL goto INVALID_URL

echo.
echo Perfil de velocidad:
echo [1] Conservador  - 2 fragmentos simultaneos
echo [2] Equilibrado  - 4 fragmentos simultaneos
echo [3] Rapido       - 8 fragmentos simultaneos
set "SPEED="
set /p "SPEED=Selecciona perfil [2]: "
if not defined SPEED set "SPEED=2"
set "FRAGMENTS=4"
if "%SPEED%"=="1" set "FRAGMENTS=2"
if "%SPEED%"=="2" set "FRAGMENTS=4"
if "%SPEED%"=="3" set "FRAGMENTS=8"
if not "%SPEED%"=="1" if not "%SPEED%"=="2" if not "%SPEED%"=="3" goto INVALID_SPEED

echo.
echo Cookies del navegador (solo si necesitas acceder a contenido autorizado):
echo [0] No usar cookies
echo [1] Microsoft Edge
echo [2] Google Chrome
echo [3] Firefox
set "BROWSER="
set /p "BROWSER=Selecciona navegador [0]: "
if not defined BROWSER set "BROWSER=0"
set "COOKIE_ARGS="
if "%BROWSER%"=="1" set "COOKIE_ARGS=--cookies-from-browser edge"
if "%BROWSER%"=="2" set "COOKIE_ARGS=--cookies-from-browser chrome"
if "%BROWSER%"=="3" set "COOKIE_ARGS=--cookies-from-browser firefox"
if not "%BROWSER%"=="0" if not "%BROWSER%"=="1" if not "%BROWSER%"=="2" if not "%BROWSER%"=="3" goto INVALID_BROWSER

if "%CATEGORY%"=="Musica" goto AUDIO_SETUP
goto VIDEO_SETUP

:AUDIO_SETUP
echo.
echo Formato de audio:
echo [1] MP3
echo [2] Opus
echo [3] M4A/AAC
echo [4] FLAC (sin perdida)
echo [5] WAV (sin compresion)
set "AF="
set /p "AF=Formato: "
set "AUDIO_FORMAT="
if "%AF%"=="1" set "AUDIO_FORMAT=mp3"
if "%AF%"=="2" set "AUDIO_FORMAT=opus"
if "%AF%"=="3" set "AUDIO_FORMAT=m4a"
if "%AF%"=="4" set "AUDIO_FORMAT=flac"
if "%AF%"=="5" set "AUDIO_FORMAT=wav"
if not defined AUDIO_FORMAT goto INVALID_AUDIO_FORMAT

set "AUDIO_Q_ARGS="
if "%AUDIO_FORMAT%"=="flac" goto AUDIO_QUALITY_DONE
if "%AUDIO_FORMAT%"=="wav" goto AUDIO_QUALITY_DONE

echo.
echo Bitrate objetivo para el archivo convertido:
echo [1] 128 kb/s
echo [2] 192 kb/s (equilibrado)
echo [3] 256 kb/s
echo [4] 320 kb/s
set "AB="
set /p "AB=Bitrate [2]: "
if not defined AB set "AB=2"
set "AUDIO_QUALITY=192K"
if "%AB%"=="1" set "AUDIO_QUALITY=128K"
if "%AB%"=="2" set "AUDIO_QUALITY=192K"
if "%AB%"=="3" set "AUDIO_QUALITY=256K"
if "%AB%"=="4" set "AUDIO_QUALITY=320K"
if not "%AB%"=="1" if not "%AB%"=="2" if not "%AB%"=="3" if not "%AB%"=="4" goto INVALID_BITRATE
set "AUDIO_Q_ARGS=--audio-quality %AUDIO_QUALITY%"

:AUDIO_QUALITY_DONE
goto RUN_AUDIO

:VIDEO_SETUP
echo.
echo Limite de resolucion:
echo [1] Mejor disponible
echo [2] Hasta 2160p (4K)
echo [3] Hasta 1440p
echo [4] Hasta 1080p
echo [5] Hasta 720p
echo [6] Hasta 480p
set "RES="
set /p "RES=Resolucion [4]: "
if not defined RES set "RES=4"
set "HEIGHT_FILTER="
if "%RES%"=="2" set "HEIGHT_FILTER=[height<=2160]"
if "%RES%"=="3" set "HEIGHT_FILTER=[height<=1440]"
if "%RES%"=="4" set "HEIGHT_FILTER=[height<=1080]"
if "%RES%"=="5" set "HEIGHT_FILTER=[height<=720]"
if "%RES%"=="6" set "HEIGHT_FILTER=[height<=480]"
if not "%RES%"=="1" if not "%RES%"=="2" if not "%RES%"=="3" if not "%RES%"=="4" if not "%RES%"=="5" if not "%RES%"=="6" goto INVALID_RESOLUTION

echo.
echo Perfil de contenedor/codec:
echo [1] MP4: prioriza H.264/AAC; remux a MP4
echo [2] MKV: conserva los codecs disponibles; remux a MKV
set "VC="
set /p "VC=Perfil de video [1]: "
if not defined VC set "VC=1"
if "%VC%"=="1" goto VIDEO_MP4
if "%VC%"=="2" goto VIDEO_MKV
goto INVALID_VIDEO_PROFILE

:VIDEO_MP4
set "CONTAINER=mp4"
set "SORT_ARGS=--format-sort vcodec:h264,lang,quality,res,fps,hdr:12,acodec:aac"
set "FORMAT=bv*%HEIGHT_FILTER%+ba/b%HEIGHT_FILTER%"
goto VIDEO_SUBS

:VIDEO_MKV
set "CONTAINER=mkv"
set "SORT_ARGS="
set "FORMAT=bv*%HEIGHT_FILTER%+ba/b%HEIGHT_FILTER%"
goto VIDEO_SUBS

:VIDEO_SUBS
echo.
set "SUB_ARGS="
set /p "SUBS=Incluir subtitulos disponibles en espanol/ingles? (1=Si, 0=No) [0]: "
if "%SUBS%"=="1" set "SUB_ARGS=--write-subs --write-auto-subs --sub-langs es,en --embed-subs"
if not "%SUBS%"=="" if not "%SUBS%"=="0" if not "%SUBS%"=="1" goto INVALID_SUBS
goto RUN_VIDEO

:RUN_AUDIO
echo.
echo ============================================================
echo  Descarga de audio
echo  Destino: "%DEST%"
echo  Origen y canal se organizaran en subcarpetas.
echo ============================================================
"%YTDLP%" --ignore-errors --continue --no-overwrites --download-archive "%ARCHIVE%" --retries 10 --fragment-retries 10 --retry-sleep 5 --concurrent-fragments %FRAGMENTS% --ffmpeg-location "%FFMPEG_DIR%" %COOKIE_ARGS% %PLAYLIST_ARGS% -P "%DEST%" -o "%OUT_TEMPLATE%" -f "bestaudio/best" --extract-audio --audio-format "%AUDIO_FORMAT%" %AUDIO_Q_ARGS% --embed-metadata --embed-thumbnail --write-info-json "%URL%"
set "RESULT=%ERRORLEVEL%"
goto FINISH

:RUN_VIDEO
echo.
echo ============================================================
echo  Descarga de video
echo  Destino: "%DEST%"
echo  Contenedor: %CONTAINER%
echo  Formato seleccionado: %FORMAT%
echo ============================================================
echo Nota: remux cambia el contenedor, no vuelve a codificar el video.
if "%CONTAINER%"=="mp4" echo Si el codec de origen no es compatible con MP4, el remux puede fallar. En ese caso elige MKV.
"%YTDLP%" --ignore-errors --continue --no-overwrites --download-archive "%ARCHIVE%" --retries 10 --fragment-retries 10 --retry-sleep 5 --concurrent-fragments %FRAGMENTS% --ffmpeg-location "%FFMPEG_DIR%" %COOKIE_ARGS% %PLAYLIST_ARGS% -P "%DEST%" -o "%OUT_TEMPLATE%" -f "%FORMAT%" %SORT_ARGS% --merge-output-format "%CONTAINER%" --remux-video "%CONTAINER%" --embed-metadata --embed-chapters --write-info-json %SUB_ARGS% "%URL%"
set "RESULT=%ERRORLEVEL%"
goto FINISH

:FINISH
echo.
if "%RESULT%"=="0" (
    echo [OK] Proceso finalizado.
) else (
    echo [AVISO] yt-dlp termino con codigo %RESULT%.
    echo Revisa la URL, los permisos, las cookies y el log mostrado arriba.
)
echo.
echo Los elementos descargados se registran en:
echo "%ARCHIVE%"
echo.
pause
exit /b %RESULT%

:MISSING_YTDLP
echo [ERROR] No se encuentra yt-dlp.exe.
echo Coloca yt-dlp.exe junto a este BAT o agrega su carpeta al PATH.
echo Descarga oficial: https://github.com/yt-dlp/yt-dlp/releases/latest
pause
exit /b 1

:MISSING_FFMPEG
echo [ERROR] No se encuentran ffmpeg.exe y ffprobe.exe.
echo Se busco en C:\ffmpeg\bin, junto al BAT y en PATH.
echo Instala ambos ejecutables en una misma carpeta.
echo Descarga: https://ffmpeg.org/download.html
pause
exit /b 1

:INVALID_CATEGORY
echo [ERROR] Categoria no valida.
pause
exit /b 2

:INVALID_MODE
echo [ERROR] Modo de descarga no valido.
pause
exit /b 2

:INVALID_ITEMS
echo [ERROR] No se indico ningun elemento de playlist.
pause
exit /b 2

:INVALID_URL
echo [ERROR] URL vacia.
pause
exit /b 2

:INVALID_SPEED
echo [ERROR] Perfil de velocidad no valido.
pause
exit /b 2

:INVALID_BROWSER
echo [ERROR] Seleccion de navegador no valida.
pause
exit /b 2

:INVALID_AUDIO_FORMAT
echo [ERROR] Formato de audio no valido.
pause
exit /b 2

:INVALID_BITRATE
echo [ERROR] Bitrate no valido.
pause
exit /b 2

:INVALID_RESOLUTION
echo [ERROR] Resolucion no valida.
pause
exit /b 2

:INVALID_VIDEO_PROFILE
echo [ERROR] Perfil de video no valido.
pause
exit /b 2

:INVALID_SUBS
echo [ERROR] Seleccion de subtitulos no valida.
pause
exit /b 2
