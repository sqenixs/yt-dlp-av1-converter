# yt-dlp-av1-converter
Covert yt-dlp output from av1 to h264

## Batch Video Post-Processor for Playnite Trailers
This Windows Batch script acts as an extension for yt-dlp in your video management pipeline. It works directly in tandem with [yt-dlp-hd](https://github.com/Britman72/yt-dlp-hd), a Go-based wrapper designed to force Playnite's Extra Metadata Loader add-on to pull high-resolution (up to 4K) YouTube trailers.
Because high-resolution YouTube downloads frequently use the AV1 codec, this script automatically steps in post-download. It sweeps your Playnite directories, finds those newly downloaded high-res AV1 files, and transcodes them into standard H.264 MP4 format to ensure perfect compatibility with your Playnite themes and media players.
## Features

* Transparent Wrapper: Forwards 100% of arguments (%*) to your real yt-dlp.exe.
* yt-dlp-hd Integration: Handles the AV1 video streams generated when forcing high-resolution YouTube downloads.
* Automatic Scanning: Recursively searches the Playnite game metadata directory for videotrailer.mp4 files.
* Smart Codec Detection: Uses ffprobe to check the video stream codec, skipping files that are already compressed in acceptable formats.
* In-Place H.264 Conversion: Converts AV1 video to H.264 (using libx264, fast preset, and CRF 18) while preserving the original audio stream.
* Web Optimization: Applies the -movflags +faststart flag so trailers can stream instantly without downloading the whole file first.

## Prerequisites
The script requires the following tools to be present on your system. By default, the script expects them in the relative paths structured below:

* yt-dlp: Command-line video downloader.
* yt-dlp-hd: Configured to point to this script or your master tool directory.
* FFmpeg & FFprobe: Version 8.0 or newer (Essentials Build recommended) for media analysis and transcoding.

## Configuration & Environment Setup

## 1. Batch Script Configuration
Before running the script, open YoutubeVideoDownloadHook.bat in a text editor and adjust the paths to match your system environment:

set gamespath=D:
:: Configure tool paths
set "tools=%gamespath%\saved games\tools"
set "realytdlp=%tools%\yt-dlp\yt-dlp.exe"
set "ffmpeg=%tools%\ffmpeg-8.0-essentials_build\bin\ffmpeg.exe"
set "ffprobe=%tools%\ffmpeg-8.0-essentials_build\bin\ffprobe.exe"

:: Playnite extra metadata root
set "gamesroot=%gamespath%\saved games\playnite\extrametadata\games"

## 2. yt-dlp-hd INI Configuration
To ensure yt-dlp-hd forces 4K downloads and correctly triggers this post-processing script, update your yt-dlp.ini file located inside the yt-dlp-hd folder to the following settings:

maxres=4k
yt-dlp-path=D:\Saved Games\tools\yt-dlp
ffmpeg-path=D:\Saved Games\tools\ffmpeg-8.0-essentials_build\bin
debug=true
postRunScript=D:\Saved Games\tools\YoutubeVideoDownloadHook.bat

## 3. Playnite Extra Metadata Loader Setup
To link everything into Playnite, follow these steps within the Extra Metadata Loader add-on configuration menu:

   1. Open Playnite and navigate to your Add-ons Settings.
   2. Locate the Extra Metadata Loader configurations panel.
   3. Important: Point the YT-DLP Path exclusively to your yt-dlp-hd executable folder (do not point it directly to the real yt-dlp.exe or this batch script). yt-dlp-hd needs to intercept Playnite's download request first.
   4. Set the FFmpeg Path and FFprobe Path fields in the add-on settings to your actual FFmpeg binary directory (D:\Saved Games\tools\ffmpeg-8.0-essentials_build\bin).
   5. Click Save and Restart Playnite to apply the path overrides.

## Expected Directory Layout
Based on your configuration, your files should be structured like this:

D:\Saved Games\
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
    ├── yt-dlp\
    │   └── yt-dlp.exe              <-- Real yt-dlp binary targeted by .ini
    ├── yt-dlp-hd\
    │   ├── yt-dlp-hd.exe           <-- Targeted by Playnite Extra Metadata Loader
    │   └── yt-dlp.ini              <-- Update this file with the INI settings above
    └── YoutubeVideoDownloadHook.bat <-- This script triggered via postRunScript

## Setup & Deployment Flowchart
When a video download request is initiated inside Playnite:

[Playnite Extra Metadata Loader] 
              │
              ▼
    [yt-dlp-hd.exe (Wrapper)] ──(Enforces 4K Settings via ini)──► [Real yt-dlp.exe]
              │                                                            │
              │                                                     (Downloads AV1 Stream)
              ▼                                                            │
 [YoutubeVideoDownloadHook.bat] ◄──────(Triggers postRunScript)────────────┘
              │
              ▼
   (FFmpeg scans & updates 
    AV1 -> H.264 in-place)

## Usage
You can call this script exactly how you would call standard yt-dlp. Replace your standard execution path with this batch file.
## Basic Download

YoutubeVideoDownloadHook.bat "https://youtube.com"

## Advanced Arguments (Passed Directly)

YoutubeVideoDownloadHook.bat --format "bestvideo+bestaudio" --output "D:\Saved Games\playnite\extrametadata\games\mygame\videotrailer.mp4" "URL"

## How It Works

   1. Passthrough Execution: The script invokes yt-dlp.exe with your specified flags.
   2. Error Catching: If yt-dlp exits with an error code other than 0, the conversion process is safely skipped.
   3. Target Analysis: The script loops through all subdirectories of your configured %gamesroot% looking specifically for files named videotrailer.mp4.
   4. Stream Probing: ffprobe extracts the string value of the video codec name.
   5. Transcode & Swap: If the codec is explicitly identified as av1, FFmpeg creates a .tmp.mp4 version using H.264 video profiles, deletes the original AV1 file, and renames the temporary item to videotrailer.mp4.

------------------------------
Would you like help testing this pipeline with a specific sample YouTube URL to verify the path routing, or would you like to add a custom notification popup to Windows whenever a trailer successfully transcodes?

