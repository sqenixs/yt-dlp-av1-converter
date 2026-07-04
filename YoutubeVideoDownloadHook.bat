@echo off
setlocal enabledelayedexpansion
set GAMESPATH=D:
:: Configure tool paths
set "TOOLS=%GAMESPATH%\Saved Games\tools"
set "REALYTDLP=%TOOLS%\yt-dlp\yt-dlp.exe"
set "FFMPEG=%TOOLS%\ffmpeg-8.0-essentials_build\bin\ffmpeg.exe"
set "FFPROBE=%TOOLS%\ffmpeg-8.0-essentials_build\bin\ffprobe.exe"

:: Playnite Extra Metadata root
set "GAMESROOT=%GAMESPATH%\Saved Games\Playnite\ExtraMetadata\games"

:: --- 1) Forward ALL arguments to the real yt-dlp ---
:: %* forwards any number of args exactly as received
"%REALYTDLP%" %*
set "YTDLP_CODE=%ERRORLEVEL%"
if not "%YTDLP_CODE%"=="0" (
  echo yt-dlp failed with code %YTDLP_CODE%. Skipping conversion.
)

:: --- 2) Post-process: convert AV1 trailers to H.264 in-place ---
for /R "%GAMESROOT%" %%F in (VideoTrailer.mp4) do (
  echo Checking: "%%F"
  set "CODEC="
  for /F "delims=" %%A in ('""%FFPROBE%" -hide_banner -v error -select_streams v:0 -show_entries stream^=codec_name -of default^=noprint_wrappers^=1:nokey^=1 "%%F"" 2^>nul') do set "CODEC=%%A"

  if /i "!CODEC!"=="av1" (
    echo Converting AV1 -> H.264: "%%F"
    set "TMP=%%~dpnF.tmp.mp4"
    "%FFMPEG%" -i "%%F" -c:v libx264 -preset fast -crf 18 -pix_fmt yuv420p -c:a copy -movflags +faststart "!TMP!"
    del /f /q "%%F"
    ren "!TMP!" "%%~nxF"
    echo Replaced with H.264: "%%F"
  ) else (
    REM echo Skipping (codec=!CODEC!)
  )
)

:end
endlocal