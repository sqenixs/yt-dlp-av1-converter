# yt-dlp-av1-converter
Covert yt-dlp output from av1 to h264

## Batch Video Post-Processor for Playnite Trailers
This Windows Batch script acts as a wrapper for yt-dlp. It forwards all command-line arguments directly to the real yt-dlp executable to download videos. Once the download finishes, the script automatically scans your Playnite extra metadata directory, identifies any downloaded trailers using the AV1 codec, and converts them to H.264 MP4 in-place using ffmpeg and ffprobe.
This ensures compatibility with media players or interfaces (like Playnite themes) that do not natively support AV1 hardware acceleration or software decoding.
## Features

* Transparent Wrapper: Forwards 100% of arguments (%*) to your real yt-dlp.exe.
* Automatic Scanning: Recursively searches the Playnite game metadata directory for videotrailer.mp4 files.
* Smart Codec Detection: Uses ffprobe to check the video stream codec, skipping files that are already compressed in acceptable formats.
* In-Place H.264 Conversion: Converts AV1 video to H.264 (using libx264, fast preset, and CRF 18) while preserving the original audio stream.
* Web Optimization: Applies the -movflags +faststart flag so trailers can stream instantly without downloading the whole file first.

## Prerequisites
The script requires the following tools to be present on your system. By default, the script expects them in the relative paths structured below:

* yt-dlp: Command-line video downloader.
* FFmpeg & FFprobe: Version 8.0 or newer (Essentials Build recommended) for media analysis and transcoding.

## Configuration
Before running the script, open it in a text editor and adjust the paths to match your system environment:

set gamespath=D:
:: Configure tool paths
set "tools=%gamespath%\saved games\tools"
set "realytdlp=%tools%\yt-dlp\yt-dlp.exe"
set "ffmpeg=%tools%\ffmpeg-8.0-essentials_build\bin\ffmpeg.exe"
set "ffprobe=%tools%\ffmpeg-8.0-essentials_build\bin\ffprobe.exe"

:: Playnite extra metadata root
set "gamesroot=%gamespath%\saved games\playnite\extrametadata\games"

## Expected Directory Layout
Based on the default configuration, your files should be structured like this:

D:\text\saved games\
│
├── playnite\
│   └── extrametadata\
│       └── games\                  <-- Script scans here for videotrailer.mp4
│
└── tools\
    ├── ffmpeg-8.0-essentials_build\
    │   └── bin\
    │       ├── ffmpeg.exe
    │       └── ffprobe.exe
    └── yt-dlp\
        └── yt-dlp.exe

## Usage
You can call this script exactly how you would call standard yt-dlp. Replace your standard execution path with this batch file.
## Basic Download

myscript.bat "https://youtube.com"

## Advanced Arguments (Passed Directly)

myscript.bat --format "bestvideo+bestaudio" --output "D:\saved games\playnite\extrametadata\games\mygame\videotrailer.mp4" "URL"

## How It Works

   1. Passthrough Execution: The script invokes yt-dlp.exe with your specified flags.
   2. Error Catching: If yt-dlp exits with an error code other than 0, the conversion process is safely skipped.
   3. Target Analysis: The script loops through all subdirectories of your configured %gamesroot% looking specifically for files named videotrailer.mp4.
   4. Stream Probing: ffprobe extracts the string value of the video codec name.
   5. Transcode & Swap: If the codec is explicitly identified as av1, FFmpeg creates a .tmp.mp4 version using H.264 video profiles, deletes the original AV1 file, and renames the temporary item to videotrailer.mp4.


