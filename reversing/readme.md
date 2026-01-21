Here is a comprehensive README documenting the file formats found in *The Simpsons: Road Rage* (PS2), based on analysis of the extracted files.

-----

# The Simpsons: Road Rage (PS2) - File Format Documentation

## Overview

This document details the file formats used in the PlayStation 2 release of *The Simpsons: Road Rage*. The game runs on Radical Entertainment's proprietary **Pure3D** engine. Most assets are packed into **RCF** (Radical Cement File) archives.

## 📦 Archives & Containers

| Extension | Format Name | Description |
| :--- | :--- | :--- |
| **.RCF** | **Radical Cement File** | The primary archive format used to pack game assets (levels, sounds, textures). The game loads data directly from these "cement" libraries. |
| **.IMG** | **Disk Image / Container** | (`IOPRP214.IMG`) A standard PS2 container file, likely containing IOP (Input/Output Processor) modules and drivers required for the game to boot specific hardware features. |

## 🎨 Visuals & 3D Assets (Pure3D Engine)

| Extension | Format Name | Description |
| :--- | :--- | :--- |
| **.P3D** | **Pure3D File** | The core format of the Pure3D engine. These are "chunk-based" binary files (similar to RIFF) that can contain almost anything: 3D meshes, textures, animations, collision data, and scene hierarchy. <br>**Header:** `P3D.` (Hex: `50 33 44 FF`) <br>**Note:** Files may contain version strings like `p3dexplorer version 14.8.0.0`. |
| **.PSS** | **PlayStation Stream** | Multiplexed video and audio files used for cutscenes (e.g., `FRONTEND.PSS`, `ROADRAGE.PSS`). This is the standard FMV format for the PS2. |
| **.PNG** | **Portable Network Graphic** | Standard image files. Found in `ART/DEST` and `ART/GUI`, these appear to be loose source assets (mostly UI elements and icons) extracted from the archives. |
| **.ICO** | **PS2 Save Icon** | **Format:** PS2 Icon (3D Model + Texture) <br>Found in `ALWAYS_rcf` (e.g., `copy.ico`, `delete.ico`, `list.ico`). <br>⚠️ **Not standard Windows ICO files.** <br>These are probably 3D animated icons displayed in the PS2 memory card browser. <br>**Header:** `00 00 01 00` (Version 1.00). <br> |

## 🔊 Audio System

| Extension | Format Name | Description |
| :--- | :--- | :--- |
| **.RSP** | **Radical Sound Project** | The standard container for audio streams in Radical games. <br>**Header:** `RSD2VAG` (Hex: `52 53 44 32 56 41 47 20`) <br>These files contain the actual audio data (voice lines, music tracks, sfx), encoded in VAG format wrapped with a Radical header. |
| **.DLG** | **Dialog Index** | **Format:** Binary <br>Found in `SOUND/DIALOG`. These are binary index files (no clear ASCII header) that likely map game events or conversation trees to specific `.rsp` audio files. |
| **.CAR** | **Car Sound Definition** | **Format:** Binary <br>Found in `SOUND/INGAME/CAR_rcf`. These are binary configuration files containing float values (e.g., `1.0`, `100.0`) that define how a vehicle sounds (engine pitch modulation, horn, skid sounds). |
| **.SPT** | **Sound Script** | **Format:** Text Script <br>Found in `SOUND/MUSIC/scripts`. <br>Script files used to sequence music or audio events. <br>**Example:** <br>`create soundPlayer named TOGGLEPlayer { SetFileName ( "sound\soundfx\frontend\toggle.rsp" ) }` |

## ⚙️ Gameplay Data & Logic

| Extension | Format Name | Description |
| :--- | :--- | :--- |
| **.TDB** | **Tuning Data Base** | **Format:** Text <br>Found next to car/character P3Ds (e.g., `apu.tdb`). <br>These are text files containing physics and gameplay statistics. <br>**Example:** <br>`vehicle_id 9` <br>`vehicle_name "Firebird"` |
| **.SEQ** | **Sequence Script** | **Format:** Text Script <br>Found in `STECHNG_rcf` (e.g., `ai.seq`). <br>These are script files defining AI behavior or event sequences. <br>**Example:** <br>`driverscript { name bus actions { ... } }` |
| **.CFG** | **Configuration File** | **Format:** Text <br>Plain text configuration files (e.g., `traffic.cfg`) for initializing game systems. <br>**Example:** `addtrafficaheadradius 300` |
| **.TS** | **TextStyle (XML)** | **Format:** XML <br>Found in `ART/GUI/.../Resource/TxtStyle`. <br>XML files defining font rendering properties. <br>**Example:** <br>`<TextStyle><Font name="AdLib BT" data="Fonts\Adlibn.ttf"></Font>...</TextStyle>` |
| **.TYP** | **Type/Text Definition** | **Format:** Binary <br>(`TIBLD.TYP`) Binary file with header starting with `C...` and strings like `IRefCount`, `AddRef`. Likely related to type information or symbol tables. |
| **.DAT** | **Generic Data** | **Format:** Binary <br>Found in `ART` (e.g., `DATA1.DAT`, `DATA2.DAT`). These appear to be raw data blobs or placeholders (some contain repeating patterns like all zeros or all 'e's). |

## 💻 System & Executables

| Extension | Format Name | Description |
| :--- | :--- | :--- |
| **.IRX** | **IOP Relocatable Executable** | PlayStation 2 driver modules. These handle low-level hardware interaction for audio (`LIBSD.IRX`), controllers (`PADMAN.IRX`), and USB (`USBD.IRX`). |
| **.28** | **Game Executable** | (`SLES_506.28`) This is the main game executable (ELF) for the PlayStation 2. The extension `.28` corresponds to the last digits of the game's Serial ID (SLES-50628). |
| **.CNF** | **System Config** | (`SYSTEM.CNF`) A standard text file required by the PS2 to know which file to execute (`SLES_506.28`) and what video mode to use (PAL/NTSC) upon boot. |

## 📂 Directory Structures Explained

This section details the purpose of the base directories and key files found on the game disc (`GameFiles/Source`).

### Root Directory
*   **`ALWAYS.RCF`**: Core assets that are "always" loaded in memory. Likely contains global scripts, common UI elements, shared models, and the PS2 save icons.
*   **`LOADING.RCF`**: Assets specific to loading screens (images, simple animations).
*   **`NIS.RCF`**: **Non-Interactive Sequence**. Contains assets for in-engine cutscenes (animations, scripted events) that are not pre-rendered videos.
*   **`STECHNG.RCF`**: Likely **"Streaming Technology"** or **"State Change"**. This is the largest archive (approx. 100MB) and contains the main game world data, level chunks, and character/vehicle physics data (`.p3d`, `.tdb`, `.seq`).
*   **`SLES_506.28`**: The main PS2 executable (ELF).
*   **`IOPRP214.IMG`**: Input/Output Processor Image. A container for PS2 hardware drivers.

### `ART/` (Visual Assets)
*   **`GUI/`**: Graphical User Interface assets. The file naming convention suggests language and context separation:
    *   **Prefixes:** `E` (English), `F` (French), `G` (German), `I` (Italian), `S` (Spanish).
    *   **`xFEy.RCF`**: **Front End** assets (Main Menu, Options). e.g., `EFE1.RCF` (English Front End).
    *   **`xIG.RCF`**: **In Game** assets (HUD, Pause Menu). e.g., `EIG.RCF` (English In Game).
*   **`DEST/`**: Likely **"Destination"** or level-specific art assets. Contains `DEST0.RCF` through `DEST5.RCF`.
*   **`DATA1.DAT` / `DATA2.DAT`**: Large binary blobs (approx. 1GB each). Their purpose is currently unconfirmed; they may be raw streamed data or padding.

### `SOUND/` (Audio Assets)
*   **`DIALOG/`**: Voice-over assets.
    *   **`ENGLISH/DIALOG.RCF`**: Contains all English character dialogue (`.rsp` audio and `.dlg` indexes).
*   **`MUSIC/`**:
    *   **`MUSIC.RCF`**: Background music tracks and sequencing scripts (`.spt`).
*   **`SOUNDFX/`**: Sound effects.
    *   **`FRONTEND/`**: UI sounds (menu beeps, clicks).
    *   **`INGAME/`**:
        *   **`CAR.RCF`**: Vehicle-specific sounds (engine, horn) and configuration (`.car` files).
        *   **`INGAME.RCF`**: General gameplay SFX (collisions, powerups, ambience).

### `MOVIES/` (FMV)
*   **`PAL/`**: Region-specific Full Motion Video files (`.PSS`).
    *   `FRONTEND.PSS`: Likely the attract mode or main menu background video.
    *   `ROADRAGE.PSS`: Intro cinematic.

### `IRX/` (Drivers)
*   Contains `.IRX` files (IOP Relocatable Executable). These are standard PS2 drivers for hardware functionality:
    *   `LIBSD.IRX`: Sound driver.
    *   `USBD.IRX`: USB driver.
    *   `PADMAN.IRX`: Controller (Gamepad) manager.
    *   `MCMAN.IRX`: Memory Card manager.

### `TYP/`
*   **`TIBLD.TYP`**: A binary file likely related to text input, font definitions, or symbol tables (`TYP` = Type/Typography?).

### Relevant Tools

  * **Lucas' Radcore Cement Library Builder**: The tool referenced in your Lua script, used for extracting and rebuilding `.rcf` archives.
  * **Pure3D Editor**: A common community tool used to view and edit `.p3d` files.

## 🛠️ Tools & Conversion

We have verified the following tools can process the game's assets:

| Format | Tool | Status | Notes |
| :--- | :--- | :--- | :--- |
| **.RSP** | **vgmstream** | ✅ Supported | Decodes as `Playstation 4-bit ADPCM` with `Radical RSD header`. |
| **.RSP** | **ffmpeg** | ✅ Supported | Decodes as `adpcm_psx` (VAG). |
| **.PSS** | **ffmpeg** | ⚠️ Partial | Video detected as `mpeg2video`. Audio stream may require specific demuxing or is separate. |
| **.PSS** | **vgmstream** | ❌ Unsupported | Cannot open container. |
| **.ICO** | **ps2iconsys** | ℹ️ Required | Needed to convert PS2 save icons to OBJ/TGA. (Not currently included in tools). |

### Example Commands

**Convert Audio (.RSP) to WAV:**
```bash
# Using vgmstream
vgmstream-cli.exe -o output.wav input.rsp

# Using ffmpeg
ffmpeg.exe -i input.rsp output.wav
```

**Convert Video (.PSS) to MP4:**
```bash
ffmpeg.exe -i input.pss output.mp4
```

-----
